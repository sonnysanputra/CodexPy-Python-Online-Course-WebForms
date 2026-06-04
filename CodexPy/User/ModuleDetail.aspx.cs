using System;
using System.Collections.Generic;
using System.Linq;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.User
{
    public partial class ModuleDetail : System.Web.UI.Page
    {
        // ViewModel for forum comments (top-level + nested admin replies)
        public class CommentVM
        {
            public int Id { get; set; }
            public string Name { get; set; }
            public string Email { get; set; }
            public string Segment { get; set; }
            public string Initials { get; set; }
            public string Body { get; set; }
            public string WhenLabel { get; set; }
            public List<CommentVM> Replies { get; set; } = new List<CommentVM>();
        }

        private int ModuleId
        {
            get
            {
                if (int.TryParse(Request.QueryString["id"], out int id)) return id;
                return 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Auth/Login.aspx");
                return;
            }

            if (ModuleId == 0)
            {
                Response.Redirect("~/User/Modules.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadModule();
                LoadLessons();
                LoadQuizzes();
                LoadComments();
                TrackVisit(); // mark user has at least started this module
            }
        }

        protected void PostCommentButton_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string body = NewCommentBox.Text?.Trim();
            if (string.IsNullOrEmpty(body)) return;

            int userId = (int)Session["UserId"];

            try
            {
                using (var conn = DbHelper.GetConnection())
                using (var cmd = new NpgsqlCommand(
                    @"INSERT INTO comments (user_id, module_id, body)
                      VALUES (@uid, @mid, @body)", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@mid", ModuleId);
                    cmd.Parameters.AddWithValue("@body", body);
                    cmd.ExecuteNonQuery();
                }
                NewCommentBox.Text = "";
                CommentMessageLit.Text = "Your comment has been posted.";
                CommentMessagePanel.Visible = true;
                LoadComments();
            }
            catch (Exception ex)
            {
                CommentMessageLit.Text = "Could not post your comment: " + ex.Message;
                CommentMessagePanel.Visible = true;
            }
        }

        protected void MarkCompleteButton_Click(object sender, EventArgs e)
        {
            int userId = (int)Session["UserId"];
            try
            {
                using (var conn = DbHelper.GetConnection())
                using (var cmd = new NpgsqlCommand(
                    @"INSERT INTO user_progress (user_id, module_id, progress, last_accessed_at)
                      VALUES (@uid, @mid, 1.0, CURRENT_TIMESTAMP)
                      ON CONFLICT (user_id, module_id)
                      DO UPDATE SET progress = 1.0, last_accessed_at = CURRENT_TIMESTAMP", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@mid", ModuleId);
                    cmd.ExecuteNonQuery();
                }
                ShowMessage("Module marked as complete!");
                LoadModule(); // refresh progress
            }
            catch (Exception ex)
            {
                ShowMessage("Could not save progress: " + ex.Message);
            }
        }

        private void LoadModule()
        {
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT m.title, m.blurb, m.difficulty, m.duration, m.color,
                         COALESCE((SELECT progress FROM user_progress WHERE user_id = @uid AND module_id = m.id), 0) AS progress
                  FROM modules m WHERE m.id = @mid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", (int)Session["UserId"]);
                cmd.Parameters.AddWithValue("@mid", ModuleId);

                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        Response.Redirect("~/User/Modules.aspx");
                        return;
                    }

                    string title = reader.GetString(0);
                    string blurb = reader.IsDBNull(1) ? "" : reader.GetString(1);
                    string difficulty = reader.GetString(2);
                    string duration = reader.IsDBNull(3) ? "" : reader.GetString(3);
                    string color = reader.IsDBNull(4) ? "#3776AB" : reader.GetString(4);
                    decimal progress = reader.GetDecimal(5);
                    int progressPercent = (int)(progress * 100);

                    PageTitleLit.Text = title;
                    CrumbLit.Text = title;
                    TitleLit.Text = title;
                    BlurbLit.Text = blurb;
                    DifficultyLit.Text = difficulty;
                    DurationLit.Text = duration;
                    IconInitialLit.Text = title.Substring(0, 1);
                    IconBox.Style["background"] = color + "22";
                    IconBox.Style["color"] = color;
                    ProgressPercentLit.Text = progressPercent.ToString();
                    ProgressFill.Style["width"] = progressPercent + "%";
                }
            }
        }

        private void LoadLessons()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                "SELECT title, content FROM lessons WHERE module_id = @mid ORDER BY sort_order, id", conn))
            {
                cmd.Parameters.AddWithValue("@mid", ModuleId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        rows.Add(new
                        {
                            title = reader.GetString(0),
                            content = reader.IsDBNull(1) ? "" : reader.GetString(1)
                        });
                    }
                }
            }
            LessonsRepeater.DataSource = rows;
            LessonsRepeater.DataBind();
            EmptyLessonsPanel.Visible = rows.Count == 0;
        }

        private void LoadQuizzes()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT q.id, q.title, q.time_limit_seconds,
                         (SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) AS question_count
                  FROM quizzes q
                  WHERE q.module_id = @mid
                  ORDER BY q.created_at", conn))
            {
                cmd.Parameters.AddWithValue("@mid", ModuleId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        rows.Add(new
                        {
                            id = reader.GetInt32(0),
                            title = reader.GetString(1),
                            time_limit_seconds = reader.GetInt32(2),
                            question_count = (int)reader.GetInt64(3),
                        });
                    }
                }
            }
            QuizzesRepeater.DataSource = rows;
            QuizzesRepeater.DataBind();
            EmptyQuizzesPanel.Visible = rows.Count == 0;
        }

        private void TrackVisit()
        {
            int userId = (int)Session["UserId"];
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"INSERT INTO user_progress (user_id, module_id, progress, last_accessed_at)
                  VALUES (@uid, @mid, 0.05, CURRENT_TIMESTAMP)
                  ON CONFLICT (user_id, module_id)
                  DO UPDATE SET last_accessed_at = CURRENT_TIMESTAMP", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@mid", ModuleId);
                cmd.ExecuteNonQuery();
            }
        }

        private void ShowMessage(string msg)
        {
            MessageLit.Text = msg;
            MessagePanel.Visible = true;
        }

        // Loads the forum comments for THIS module (top-level posts + admin replies)
        private void LoadComments()
        {
            var topLevel = new List<CommentVM>();

            using (var conn = DbHelper.GetConnection())
            {
                // 1. Top-level comments + the poster's user info
                using (var cmd = new NpgsqlCommand(
                    @"SELECT c.id, c.body, c.created_at,
                             u.name, u.email, u.segment
                      FROM comments c
                      JOIN users u ON c.user_id = u.id
                      WHERE c.module_id = @mid AND c.parent_comment_id IS NULL
                      ORDER BY c.created_at DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@mid", ModuleId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            topLevel.Add(new CommentVM
                            {
                                Id = reader.GetInt32(0),
                                Body = reader.GetString(1),
                                WhenLabel = FormatAgo(reader.GetDateTime(2)),
                                Name = reader.GetString(3),
                                Email = reader.GetString(4),
                                Segment = reader.IsDBNull(5) ? "" : reader.GetString(5),
                                Initials = GetInitials(reader.GetString(3)),
                            });
                        }
                    }
                }

                // 2. Replies for those comments (one batch query)
                if (topLevel.Count > 0)
                {
                    var topIds = topLevel.Select(t => t.Id).ToArray();
                    using (var cmd = new NpgsqlCommand(
                        @"SELECT r.parent_comment_id, r.body, r.created_at, u.name
                          FROM comments r
                          JOIN users u ON r.user_id = u.id
                          WHERE r.parent_comment_id = ANY(@ids)
                          ORDER BY r.created_at", conn))
                    {
                        cmd.Parameters.AddWithValue("@ids", topIds);
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                int parentId = reader.GetInt32(0);
                                var parent = topLevel.FirstOrDefault(t => t.Id == parentId);
                                if (parent == null) continue;
                                parent.Replies.Add(new CommentVM
                                {
                                    Body = reader.GetString(1),
                                    WhenLabel = FormatAgo(reader.GetDateTime(2)),
                                    Name = reader.GetString(3),
                                });
                            }
                        }
                    }
                }
            }

            CommentsRepeater.DataSource = topLevel;
            CommentsRepeater.DataBind();
            CommentCountLit.Text = topLevel.Count.ToString();
            EmptyCommentsPanel.Visible = topLevel.Count == 0;
        }

        private static string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "?";
            var parts = fullName.Trim().Split(' ');
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        private static string FormatAgo(DateTime dt)
        {
            // PostgreSQL CURRENT_TIMESTAMP stores UTC; compare against UtcNow to avoid timezone offset.
            var span = DateTime.UtcNow - dt;
            if (span.TotalMinutes < 1) return "just now";
            if (span.TotalHours < 1) return Math.Floor(span.TotalMinutes) + "m ago";
            if (span.TotalDays < 1) return Math.Floor(span.TotalHours) + "h ago";
            if (span.TotalDays < 30) return Math.Floor(span.TotalDays) + "d ago";
            return dt.ToString("MMM d, yyyy");
        }
    }
}
