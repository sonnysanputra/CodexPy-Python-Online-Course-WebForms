using System;
using System.Collections.Generic;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.User
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Auth gate (master page also checks, but child Page_Load runs first)
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Auth/Login.aspx");
                return;
            }

            int userId = (int)Session["UserId"];
            string fullName = Session["UserName"]?.ToString() ?? "Learner";
            UserFirstNameLit.Text = fullName.Split(' ')[0];

            // Time-of-day greeting
            int hr = DateTime.Now.Hour;
            GreetingLit.Text = hr < 12 ? "Good morning. Let's get into some Python."
                              : hr < 18 ? "Good afternoon. Time to learn."
                              : "Good evening. A short lesson before bed?";

            if (!IsPostBack)
            {
                LoadKpis(userId);
                LoadContinueModule(userId);
                LoadRecentScores(userId);
            }
        }

        private void LoadKpis(int userId)
        {
            using (var conn = DbHelper.GetConnection())
            {
                using (var cmd = new NpgsqlCommand(
                    "SELECT COUNT(*) FROM user_progress WHERE user_id = @uid AND progress > 0 AND progress < 1", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    InProgressLit.Text = Convert.ToInt64(cmd.ExecuteScalar()).ToString();
                }

                using (var cmd = new NpgsqlCommand(
                    "SELECT COUNT(*) FROM user_progress WHERE user_id = @uid AND progress >= 1", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    CompletedLit.Text = Convert.ToInt64(cmd.ExecuteScalar()).ToString();
                }

                using (var cmd = new NpgsqlCommand(
                    "SELECT COUNT(*) FROM quiz_attempts WHERE user_id = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    AttemptsLit.Text = Convert.ToInt64(cmd.ExecuteScalar()).ToString();
                }

                using (var cmd = new NpgsqlCommand(
                    "SELECT COALESCE(AVG(score), 0) FROM quiz_attempts WHERE user_id = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    decimal avg = Convert.ToDecimal(cmd.ExecuteScalar());
                    AvgScoreLit.Text = avg > 0 ? Math.Round(avg, 0).ToString() + "%" : "—";
                }
            }
        }

        private void LoadContinueModule(int userId)
        {
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT m.id, m.title, m.blurb, up.progress
                  FROM user_progress up
                  JOIN modules m ON m.id = up.module_id
                  WHERE up.user_id = @uid AND up.progress < 1
                  ORDER BY up.last_accessed_at DESC
                  LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        int moduleId = reader.GetInt32(0);
                        ContinueTitleLit.Text = reader.GetString(1);
                        ContinueBlurbLit.Text = reader.IsDBNull(2) ? "" : reader.GetString(2);
                        decimal progress = reader.GetDecimal(3);
                        int percent = (int)(progress * 100);
                        ContinueProgressFill.Style["width"] = percent + "%";
                        ContinuePercentLit.Text = percent.ToString();
                        ContinueLink.NavigateUrl = "ModuleDetail.aspx?id=" + moduleId;
                        ContinuePanel.Visible = true;
                    }
                    else
                    {
                        EmptyContinuePanel.Visible = true;
                    }
                }
            }
        }

        private void LoadRecentScores(int userId)
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT q.title AS quiz_title, qa.score, qa.completed_at
                  FROM quiz_attempts qa
                  JOIN quizzes q ON q.id = qa.quiz_id
                  WHERE qa.user_id = @uid
                  ORDER BY qa.completed_at DESC
                  LIMIT 5", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        rows.Add(new
                        {
                            quiz_title = reader.GetString(0),
                            score = reader.GetInt32(1),
                            completed_at = (object)reader.GetDateTime(2),
                        });
                    }
                }
            }
            RecentScoresRepeater.DataSource = rows;
            RecentScoresRepeater.DataBind();
            EmptyScoresPanel.Visible = rows.Count == 0;
        }

        protected string FormatDate(object dateValue)
        {
            if (dateValue == null) return "";
            DateTime dt = (DateTime)dateValue;
            var span = DateTime.Now - dt;
            if (span.TotalMinutes < 1) return "just now";
            if (span.TotalHours < 1) return Math.Floor(span.TotalMinutes) + "m ago";
            if (span.TotalDays < 1) return Math.Floor(span.TotalHours) + "h ago";
            if (span.TotalDays < 30) return Math.Floor(span.TotalDays) + "d ago";
            return dt.ToString("MMM d");
        }
    }
}
