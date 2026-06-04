using System;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.User
{
    public partial class Profile : System.Web.UI.Page
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
                LoadProfile();
            }
        }

        private void LoadProfile()
        {
            int userId = (int)Session["UserId"];
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                "SELECT name, email, role, segment, created_at FROM users WHERE id = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        ShowError("Profile not found.");
                        return;
                    }
                    string name = reader.GetString(0);
                    NameBox.Text = name;
                    DisplayNameLit.Text = name;
                    AvatarLit.Text = GetInitials(name);

                    EmailBox.Text = reader.GetString(1);
                    RoleLit.Text = reader.GetString(2);
                    if (!reader.IsDBNull(3))
                        SegmentList.SelectedValue = reader.GetString(3);
                    JoinedLit.Text = reader.GetDateTime(4).ToString("MMMM yyyy");
                }
            }
        }

        protected void SaveButton_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int userId = (int)Session["UserId"];
            string name = NameBox.Text.Trim();
            string email = EmailBox.Text.Trim().ToLowerInvariant();
            string segment = SegmentList.SelectedValue;
            string newPassword = NewPasswordBox.Text;
            string confirmPassword = ConfirmPasswordBox.Text;

            // If the user is changing their password, both fields must be filled
            if (!string.IsNullOrEmpty(newPassword) && string.IsNullOrEmpty(confirmPassword))
            {
                ShowError("Please confirm your new password.");
                return;
            }
            if (string.IsNullOrEmpty(newPassword) && !string.IsNullOrEmpty(confirmPassword))
            {
                ShowError("Please enter your new password before confirming it.");
                return;
            }

            try
            {
                using (var conn = DbHelper.GetConnection())
                {
                    // Email uniqueness check (excluding self)
                    using (var checkCmd = new NpgsqlCommand(
                        "SELECT COUNT(*) FROM users WHERE LOWER(email) = @email AND id <> @id", conn))
                    {
                        checkCmd.Parameters.AddWithValue("@email", email);
                        checkCmd.Parameters.AddWithValue("@id", userId);
                        long count = (long)checkCmd.ExecuteScalar();
                        if (count > 0)
                        {
                            ShowError("Another user already has this email.");
                            return;
                        }
                    }

                    if (string.IsNullOrEmpty(newPassword))
                    {
                        // Update without password
                        using (var cmd = new NpgsqlCommand(
                            @"UPDATE users SET name=@name, email=@email, segment=@segment
                              WHERE id=@id", conn))
                        {
                            cmd.Parameters.AddWithValue("@name", name);
                            cmd.Parameters.AddWithValue("@email", email);
                            cmd.Parameters.AddWithValue("@segment", segment);
                            cmd.Parameters.AddWithValue("@id", userId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        // Update with new password
                        string hash = BCrypt.Net.BCrypt.HashPassword(newPassword);
                        using (var cmd = new NpgsqlCommand(
                            @"UPDATE users SET name=@name, email=@email, segment=@segment, password_hash=@hash
                              WHERE id=@id", conn))
                        {
                            cmd.Parameters.AddWithValue("@name", name);
                            cmd.Parameters.AddWithValue("@email", email);
                            cmd.Parameters.AddWithValue("@segment", segment);
                            cmd.Parameters.AddWithValue("@hash", hash);
                            cmd.Parameters.AddWithValue("@id", userId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                // Refresh session
                Session["UserName"] = name;
                Session["UserEmail"] = email;

                NewPasswordBox.Text = "";
                ConfirmPasswordBox.Text = "";
                LoadProfile(); // refresh display
                ShowSuccess("Profile updated successfully.");
            }
            catch (Exception ex)
            {
                ShowError("Save failed: " + ex.Message);
            }
        }

        private void ShowSuccess(string msg)
        {
            SuccessLit.Text = msg;
            SuccessPanel.Visible = true;
        }

        private void ShowError(string msg)
        {
            ErrorLit.Text = msg;
            ErrorPanel.Visible = true;
        }

        private string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "?";
            var parts = fullName.Trim().Split(' ');
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }
    }
}
