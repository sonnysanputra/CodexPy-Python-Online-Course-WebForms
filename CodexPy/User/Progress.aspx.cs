using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.User
{
    // Class name is "ProgressPage" because "Progress" conflicts with System.Web.UI.Page in some contexts
    public partial class ProgressPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Auth/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                int userId = (int)Session["UserId"];
                LoadKpis(userId);
                LoadModuleProgress(userId);
                LoadQuizHistory(userId);
            }
        }

        private void LoadKpis(int userId)
        {
            using (var conn = DbHelper.GetConnection())
            {
                using (var cmd = new NpgsqlCommand(
                    "SELECT COUNT(*) FROM user_progress WHERE user_id = @uid AND progress > 0", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    StartedLit.Text = Convert.ToInt64(cmd.ExecuteScalar()).ToString();
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
                    QuizCountLit.Text = Convert.ToInt64(cmd.ExecuteScalar()).ToString();
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

        private void LoadModuleProgress(int userId)
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT m.id, m.title,
                         COALESCE(up.progress, 0) AS progress,
                         up.last_accessed_at
                  FROM modules m
                  LEFT JOIN user_progress up ON up.module_id = m.id AND up.user_id = @uid
                  WHERE m.published = TRUE
                  ORDER BY m.sort_order", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        decimal progress = reader.GetDecimal(2);
                        int pct = (int)(progress * 100);
                        DateTime? lastAccessed = reader.IsDBNull(3) ? (DateTime?)null : reader.GetDateTime(3);

                        string statusLabel;
                        if (pct == 0) statusLabel = "Not started";
                        else if (pct >= 100) statusLabel = "Completed";
                        else statusLabel = "In progress";

                        string lastLabel = lastAccessed.HasValue
                            ? " · last visited " + FormatAgo(lastAccessed.Value)
                            : "";

                        rows.Add(new
                        {
                            id = reader.GetInt32(0),
                            title = reader.GetString(1),
                            progress_percent = pct,
                            status_label = statusLabel,
                            last_accessed_label = lastLabel
                        });
                    }
                }
            }
            ModulesRepeater.DataSource = rows;
            ModulesRepeater.DataBind();
        }

        protected void ModulesRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            int pct = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "progress_percent"));
            var span = (HtmlGenericControl)e.Item.FindControl("FillSpan");
            span.Style["width"] = pct + "%";
        }

        private void LoadQuizHistory(int userId)
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT qa.score, qa.completed_at, q.title AS quiz_title, m.title AS module_title
                  FROM quiz_attempts qa
                  JOIN quizzes q ON q.id = qa.quiz_id
                  JOIN modules m ON m.id = q.module_id
                  WHERE qa.user_id = @uid
                  ORDER BY qa.completed_at DESC
                  LIMIT 20", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        rows.Add(new
                        {
                            score = reader.GetInt32(0),
                            when_label = FormatAgo(reader.GetDateTime(1)),
                            quiz_title = reader.GetString(2),
                            module_title = reader.GetString(3),
                        });
                    }
                }
            }
            AttemptsRepeater.DataSource = rows;
            AttemptsRepeater.DataBind();
            EmptyAttemptsPanel.Visible = rows.Count == 0;
        }

        private string FormatAgo(DateTime dt)
        {
            // PostgreSQL CURRENT_TIMESTAMP stores UTC; Npgsql returns it with Kind=Unspecified.
            // Compare against UtcNow so the offset isn't double-applied with the local timezone.
            var span = DateTime.UtcNow - dt;
            if (span.TotalMinutes < 1) return "just now";
            if (span.TotalHours < 1) return Math.Floor(span.TotalMinutes) + "m ago";
            if (span.TotalDays < 1) return Math.Floor(span.TotalHours) + "h ago";
            if (span.TotalDays < 30) return Math.Floor(span.TotalDays) + "d ago";
            return dt.ToString("MMM d, yyyy");
        }
    }
}
