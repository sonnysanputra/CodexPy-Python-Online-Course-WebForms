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
                LoadAnnouncements();
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
            // PostgreSQL CURRENT_TIMESTAMP stores UTC; compare against UtcNow so the timezone
            // offset isn't double-counted (otherwise a fresh quiz attempt would show as "8h ago").
            var span = DateTime.UtcNow - dt;
            if (span.TotalMinutes < 1) return "just now";
            if (span.TotalHours < 1) return Math.Floor(span.TotalMinutes) + "m ago";
            if (span.TotalDays < 1) return Math.Floor(span.TotalHours) + "h ago";
            if (span.TotalDays < 30) return Math.Floor(span.TotalDays) + "d ago";
            return dt.ToString("MMM d");
        }

        // Pulls the 10 most recent announcements and turns each into a row the Repeater
        // can render (icon + human-readable description + "X ago" label).
        private void LoadAnnouncements()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT action, target_type, target_name, parent_name, created_at
                  FROM announcements
                  ORDER BY created_at DESC
                  LIMIT 10", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    string action = reader.GetString(0);
                    string targetType = reader.GetString(1);
                    string targetName = reader.GetString(2);
                    string parentName = reader.IsDBNull(3) ? null : reader.GetString(3);
                    DateTime createdAt = reader.GetDateTime(4);

                    rows.Add(new
                    {
                        icon = GetAnnouncementIcon(targetType),
                        description = BuildAnnouncementText(action, targetType, targetName, parentName),
                        when_label = FormatDate(createdAt)
                    });
                }
            }
            AnnouncementsRepeater.DataSource = rows;
            AnnouncementsRepeater.DataBind();
            EmptyAnnouncementsPanel.Visible = rows.Count == 0;
        }

        // Maps the target type to a small emoji so each row has a quick visual cue
        private string GetAnnouncementIcon(string targetType)
        {
            switch (targetType)
            {
                case "module":   return "📘";
                case "lesson":   return "📖";
                case "quiz":     return "📝";
                case "question": return "❓";
                default:         return "📌";
            }
        }

        // Builds a human-readable sentence for each announcement row, e.g.
        // "New lesson added in Lists & Dictionaries: List comprehensions"
        private string BuildAnnouncementText(string action, string targetType, string targetName, string parentName)
        {
            switch (targetType)
            {
                case "module":
                    if (action == "added")   return "New module added: " + targetName;
                    if (action == "updated") return "Module updated: " + targetName;
                    return "Module removed: " + targetName;

                case "lesson":
                    string inModule = parentName != null ? " in " + parentName : "";
                    string fromModule = parentName != null ? " from " + parentName : "";
                    if (action == "added")   return "New lesson added" + inModule + ": " + targetName;
                    if (action == "updated") return "Lesson updated" + inModule + ": " + targetName;
                    return "Lesson removed" + fromModule + ": " + targetName;

                case "quiz":
                    if (action == "added")   return "New quiz added: " + targetName;
                    if (action == "updated") return "Quiz updated: " + targetName;
                    return "Quiz removed: " + targetName;

                case "question":
                    string inQuiz = parentName != null ? " in " + parentName : "";
                    string fromQuiz = parentName != null ? " from " + parentName : "";
                    if (action == "added")   return "New question added" + inQuiz;
                    if (action == "updated") return "Question updated" + inQuiz;
                    return "Question removed" + fromQuiz;

                default:
                    return targetType + " " + action + ": " + targetName;
            }
        }
    }
}
