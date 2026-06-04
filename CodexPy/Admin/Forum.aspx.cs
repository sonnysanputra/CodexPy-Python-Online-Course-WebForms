using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Admin
{
    public partial class Forum : System.Web.UI.Page
    {
        // ViewModel: one row per comment, optionally containing nested replies
        public class CommentVM
        {
            public int Id { get; set; }
            public string Name { get; set; }
            public string Email { get; set; }
            public string Segment { get; set; }
            public string Initials { get; set; }
            public string Body { get; set; }
            public string WhenLabel { get; set; }
            public bool IsRead { get; set; }
            public string ModuleTitle { get; set; }
            public List<CommentVM> Replies { get; set; } = new List<CommentVM>();
            public bool ShowReplyForm { get; set; }
        }

        // Track which comment's reply form is currently open (so it survives postback)
        private int? OpenReplyId
        {
            get
            {
                if (ViewState["OpenReplyId"] == null) return null;
                return (int)ViewState["OpenReplyId"];
            }
            set { ViewState["OpenReplyId"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadComments();
        }

        protected void FilterList_Changed(object sender, EventArgs e)
        {
            OpenReplyId = null; // collapse any open reply form when filter changes
            LoadComments();
        }

        // Action handlers ----------------------------------------------------

        protected void MarkRead_Command(object sender, CommandEventArgs e)
        {
            int id = int.Parse(e.CommandArgument.ToString());
            UpdateReadFlag(id, true);
            LoadComments();
        }

        protected void MarkUnread_Command(object sender, CommandEventArgs e)
        {
            int id = int.Parse(e.CommandArgument.ToString());
            UpdateReadFlag(id, false);
            LoadComments();
        }

        protected void ToggleReplyForm_Command(object sender, CommandEventArgs e)
        {
            int id = int.Parse(e.CommandArgument.ToString());
            // Click twice on the same comment → close the form
            OpenReplyId = (OpenReplyId == id) ? (int?)null : id;
            LoadComments();
        }

        protected void CancelReply_Command(object sender, CommandEventArgs e)
        {
            OpenReplyId = null;
            LoadComments();
        }

        protected void PostReply_Command(object sender, CommandEventArgs e)
        {
            int parentId = int.Parse(e.CommandArgument.ToString());

            // Walk up the control tree to find the ReplyBox sibling
            Control btn = (Control)sender;
            var replyBox = (TextBox)btn.NamingContainer.FindControl("ReplyBox");
            if (replyBox == null) return;

            string body = replyBox.Text?.Trim();
            if (string.IsNullOrEmpty(body))
            {
                ShowMessage("Reply cannot be empty.", false);
                return;
            }

            int adminId = (int)Session["UserId"];

            try
            {
                using (var conn = DbHelper.GetConnection())
                {
                    // Look up the module_id of the parent comment so the reply lives on the same module
                    int moduleId;
                    using (var cmd = new NpgsqlCommand(
                        "SELECT module_id FROM comments WHERE id = @id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", parentId);
                        var res = cmd.ExecuteScalar();
                        if (res == null)
                        {
                            ShowMessage("Parent comment no longer exists.", false);
                            return;
                        }
                        moduleId = Convert.ToInt32(res);
                    }

                    // Insert the reply and mark the parent as read in one go
                    using (var cmd = new NpgsqlCommand(
                        @"INSERT INTO comments (user_id, module_id, parent_comment_id, body)
                          VALUES (@uid, @mid, @pid, @body)", conn))
                    {
                        cmd.Parameters.AddWithValue("@uid", adminId);
                        cmd.Parameters.AddWithValue("@mid", moduleId);
                        cmd.Parameters.AddWithValue("@pid", parentId);
                        cmd.Parameters.AddWithValue("@body", body);
                        cmd.ExecuteNonQuery();
                    }
                    using (var cmd = new NpgsqlCommand(
                        "UPDATE comments SET is_read = TRUE WHERE id = @id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", parentId);
                        cmd.ExecuteNonQuery();
                    }
                }

                OpenReplyId = null;
                ShowMessage("Reply posted.", true);
                LoadComments();
            }
            catch (Exception ex)
            {
                ShowMessage("Could not post reply: " + ex.Message, false);
            }
        }

        protected void DeleteComment_Command(object sender, CommandEventArgs e)
        {
            int id = int.Parse(e.CommandArgument.ToString());
            try
            {
                using (var conn = DbHelper.GetConnection())
                using (var cmd = new NpgsqlCommand("DELETE FROM comments WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    int rows = cmd.ExecuteNonQuery();
                    ShowMessage(rows > 0 ? "Comment deleted." : "Comment not found.", rows > 0);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Delete failed: " + ex.Message, false);
            }
            LoadComments();
        }

        // Internal helpers ---------------------------------------------------

        private void UpdateReadFlag(int id, bool isRead)
        {
            try
            {
                using (var conn = DbHelper.GetConnection())
                using (var cmd = new NpgsqlCommand("UPDATE comments SET is_read = @r WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@r", isRead);
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                }
                ShowMessage(isRead ? "Marked as read." : "Marked as unread.", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Update failed: " + ex.Message, false);
            }
        }

        private void LoadComments()
        {
            string filter = FilterList.SelectedValue ?? "All";

            // Build a filter predicate that runs in SQL on top-level comments only
            string whereExtra = "";
            if (filter == "Unread") whereExtra = " AND c.is_read = FALSE";
            else if (filter == "Read") whereExtra = " AND c.is_read = TRUE";
            else if (filter == "Replied")
                whereExtra = " AND EXISTS (SELECT 1 FROM comments r WHERE r.parent_comment_id = c.id)";

            string topLevelSql =
                @"SELECT c.id, c.body, c.is_read, c.created_at,
                         u.name, u.email, u.segment,
                         m.title AS module_title
                  FROM comments c
                  JOIN users u ON c.user_id = u.id
                  JOIN modules m ON c.module_id = m.id
                  WHERE c.parent_comment_id IS NULL " + whereExtra + @"
                  ORDER BY c.created_at DESC";

            var topLevel = new List<CommentVM>();
            using (var conn = DbHelper.GetConnection())
            {
                using (var cmd = new NpgsqlCommand(topLevelSql, conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int id = reader.GetInt32(0);
                        topLevel.Add(new CommentVM
                        {
                            Id = id,
                            Body = reader.GetString(1),
                            IsRead = reader.GetBoolean(2),
                            WhenLabel = FormatAgo(reader.GetDateTime(3)),
                            Name = reader.GetString(4),
                            Email = reader.GetString(5),
                            Segment = reader.IsDBNull(6) ? "" : reader.GetString(6),
                            ModuleTitle = reader.GetString(7),
                            Initials = GetInitials(reader.GetString(4)),
                            ShowReplyForm = (OpenReplyId == id)
                        });
                    }
                }

                // Load replies in one batch for all top-level comment ids we just fetched
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
                                    Name = reader.GetString(3)
                                });
                            }
                        }
                    }
                }

                // KPI counts (always for the whole table, not the filter)
                using (var cmd = new NpgsqlCommand("SELECT COUNT(*) FROM comments WHERE parent_comment_id IS NULL", conn))
                    TotalLit.Text = Convert.ToInt64(cmd.ExecuteScalar()).ToString();
                using (var cmd = new NpgsqlCommand("SELECT COUNT(*) FROM comments WHERE parent_comment_id IS NULL AND is_read = FALSE", conn))
                    UnreadLit.Text = Convert.ToInt64(cmd.ExecuteScalar()).ToString();
            }

            CommentsRepeater.DataSource = topLevel;
            CommentsRepeater.DataBind();
            EmptyPanel.Visible = topLevel.Count == 0;
        }

        // Utilities ----------------------------------------------------------

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

        private void ShowMessage(string text, bool success)
        {
            MessageLit.Text = text;
            MessagePanel.Visible = true;
            MessagePanel.BackColor = success
                ? System.Drawing.ColorTranslator.FromHtml("#D1FAE5")
                : System.Drawing.ColorTranslator.FromHtml("#FEE2E2");
            MessagePanel.ForeColor = success
                ? System.Drawing.ColorTranslator.FromHtml("#065F46")
                : System.Drawing.ColorTranslator.FromHtml("#991B1B");
        }
    }
}
