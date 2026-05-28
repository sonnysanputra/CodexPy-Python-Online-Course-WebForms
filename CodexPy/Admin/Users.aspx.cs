using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Admin
{
    public partial class Users : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadUsers();
            }
        }

        protected void FilterButton_Click(object sender, EventArgs e)
        {
            LoadUsers();
        }

        protected void DeleteUser_Command(object sender, CommandEventArgs e)
        {
            int userId = int.Parse(e.CommandArgument.ToString());

            // Prevent deleting yourself
            if (Session["UserId"] != null && (int)Session["UserId"] == userId)
            {
                ShowMessage("You cannot delete your own admin account.", false);
                LoadUsers();
                return;
            }

            try
            {
                using (var conn = DbHelper.GetConnection())
                using (var cmd = new NpgsqlCommand("DELETE FROM users WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", userId);
                    int rows = cmd.ExecuteNonQuery();
                    if (rows > 0)
                        ShowMessage("User deleted successfully.", true);
                    else
                        ShowMessage("User not found.", false);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Delete failed: " + ex.Message, false);
            }
            LoadUsers();
        }

        private void LoadUsers()
        {
            string search = SearchBox.Text?.Trim() ?? "";
            string segment = SegmentFilter.SelectedValue;
            string role = RoleFilter.SelectedValue;

            var rows = new List<dynamic>();
            int total;

            using (var conn = DbHelper.GetConnection())
            {
                // Total count (unfiltered)
                using (var totalCmd = new NpgsqlCommand("SELECT COUNT(*) FROM users", conn))
                    total = Convert.ToInt32(totalCmd.ExecuteScalar());

                // Build filtered query
                string sql = @"SELECT id, name, email, role, segment, status, created_at, last_active_at
                               FROM users
                               WHERE (@search = '' OR LOWER(name) LIKE @like OR LOWER(email) LIKE @like)
                                 AND (@segment = 'All' OR segment = @segment)
                                 AND (@role = 'All' OR role = @role)
                               ORDER BY created_at DESC";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@search", search.ToLower());
                    cmd.Parameters.AddWithValue("@like", "%" + search.ToLower() + "%");
                    cmd.Parameters.AddWithValue("@segment", segment);
                    cmd.Parameters.AddWithValue("@role", role);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            rows.Add(new
                            {
                                id = reader.GetInt32(0),
                                name = reader.GetString(1),
                                email = reader.GetString(2),
                                role = reader.GetString(3),
                                segment = reader.IsDBNull(4) ? "" : reader.GetString(4),
                                status = reader.GetString(5),
                                created_at = (object)reader.GetDateTime(6),
                                last_active_at = reader.IsDBNull(7) ? null : (object)reader.GetDateTime(7),
                            });
                        }
                    }
                }
            }

            UsersRepeater.DataSource = rows;
            UsersRepeater.DataBind();

            TotalLit.Text = total.ToString();
            FilteredLit.Text = rows.Count.ToString();
            EmptyPanel.Visible = rows.Count == 0;
        }

        private void ShowMessage(string text, bool success)
        {
            MessageLit.Text = text;
            MessagePanel.Visible = true;
            MessagePanel.BackColor = success ? System.Drawing.ColorTranslator.FromHtml("#D1FAE5") : System.Drawing.ColorTranslator.FromHtml("#FEE2E2");
            MessagePanel.ForeColor = success ? System.Drawing.ColorTranslator.FromHtml("#065F46") : System.Drawing.ColorTranslator.FromHtml("#991B1B");
        }

        protected string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            var parts = name.Trim().Split(' ');
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        protected string FormatDate(object dateValue)
        {
            if (dateValue == null || dateValue == DBNull.Value) return "Never";
            DateTime dt = (DateTime)dateValue;
            var span = DateTime.Now - dt;
            if (span.TotalMinutes < 1) return "just now";
            if (span.TotalHours < 1) return Math.Floor(span.TotalMinutes) + "m ago";
            if (span.TotalDays < 1) return Math.Floor(span.TotalHours) + "h ago";
            if (span.TotalDays < 30) return Math.Floor(span.TotalDays) + "d ago";
            return dt.ToString("MMM d, yyyy");
        }
    }
}
