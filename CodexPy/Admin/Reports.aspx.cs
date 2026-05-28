using System;
using System.Collections.Generic;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Admin
{
    public partial class Reports : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadKpis();
                LoadSegmentBreakdown();
                LoadModuleEngagement();
                LoadQuizPerformance();
                LoadUserGrowth();
            }
        }

        private void LoadKpis()
        {
            using (var conn = DbHelper.GetConnection())
            {
                // Total users
                using (var cmd = new NpgsqlCommand("SELECT COUNT(*) FROM users", conn))
                    TotalUsersLit.Text = Convert.ToInt64(cmd.ExecuteScalar()).ToString("N0");

                // Average quiz score
                using (var cmd = new NpgsqlCommand("SELECT COALESCE(AVG(score), 0) FROM quiz_attempts", conn))
                {
                    decimal avg = Convert.ToDecimal(cmd.ExecuteScalar());
                    AvgScoreLit.Text = avg > 0 ? Math.Round(avg, 0).ToString() + "%" : "—";
                }

                // Total attempts
                using (var cmd = new NpgsqlCommand("SELECT COUNT(*) FROM quiz_attempts", conn))
                    TotalAttemptsLit.Text = Convert.ToInt64(cmd.ExecuteScalar()).ToString("N0");

                // Active (published) modules
                using (var cmd = new NpgsqlCommand("SELECT COUNT(*) FROM modules WHERE published = TRUE", conn))
                    ActiveModulesLit.Text = Convert.ToInt64(cmd.ExecuteScalar()).ToString("N0");
            }
        }

        private void LoadSegmentBreakdown()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            {
                long total;
                using (var cmd = new NpgsqlCommand("SELECT COUNT(*) FROM users", conn))
                    total = Convert.ToInt64(cmd.ExecuteScalar());

                if (total == 0)
                {
                    EmptySegmentPanel.Visible = true;
                    return;
                }

                using (var cmd = new NpgsqlCommand(
                    @"SELECT segment, COUNT(*) AS user_count
                      FROM users
                      GROUP BY segment
                      ORDER BY user_count DESC", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        long count = reader.GetInt64(1);
                        rows.Add(new
                        {
                            segment = reader.IsDBNull(0) ? "Unknown" : reader.GetString(0),
                            user_count = count,
                            percentage = Math.Round((double)count * 100 / total, 0)
                        });
                    }
                }
            }
            SegmentRepeater.DataSource = rows;
            SegmentRepeater.DataBind();
        }

        private void LoadModuleEngagement()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT m.title, m.difficulty,
                         (SELECT COUNT(*) FROM user_progress WHERE module_id = m.id) AS enrolled_count
                  FROM modules m
                  WHERE m.published = TRUE
                  ORDER BY enrolled_count DESC, m.sort_order
                  LIMIT 6", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    rows.Add(new
                    {
                        title = reader.GetString(0),
                        difficulty = reader.GetString(1),
                        enrolled_count = reader.GetInt64(2)
                    });
                }
            }
            ModuleEngagementRepeater.DataSource = rows;
            ModuleEngagementRepeater.DataBind();
        }

        private void LoadQuizPerformance()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT q.title, COUNT(qa.id) AS attempt_count, COALESCE(AVG(qa.score), 0) AS avg_score
                  FROM quizzes q
                  LEFT JOIN quiz_attempts qa ON qa.quiz_id = q.id
                  GROUP BY q.id, q.title
                  HAVING COUNT(qa.id) > 0
                  ORDER BY attempt_count DESC
                  LIMIT 6", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    rows.Add(new
                    {
                        title = reader.GetString(0),
                        attempt_count = reader.GetInt64(1),
                        avg_score = Convert.ToDecimal(reader.GetValue(2))
                    });
                }
            }
            QuizPerfRepeater.DataSource = rows;
            QuizPerfRepeater.DataBind();
            EmptyQuizPanel.Visible = rows.Count == 0;
        }

        private void LoadUserGrowth()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT DATE(created_at) AS registration_date, COUNT(*) AS new_users
                  FROM users
                  WHERE created_at > NOW() - INTERVAL '30 days'
                  GROUP BY DATE(created_at)
                  ORDER BY registration_date DESC", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    rows.Add(new
                    {
                        registration_date = (object)reader.GetDateTime(0),
                        new_users = reader.GetInt64(1)
                    });
                }
            }
            GrowthRepeater.DataSource = rows;
            GrowthRepeater.DataBind();
            EmptyGrowthPanel.Visible = rows.Count == 0;
        }
    }
}
