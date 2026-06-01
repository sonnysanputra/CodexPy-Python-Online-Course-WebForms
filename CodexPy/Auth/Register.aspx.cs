using System;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Auth
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void RegisterButton_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string name = NameBox.Text.Trim();
            string email = EmailBox.Text.Trim().ToLowerInvariant();
            string password = PasswordBox.Text;
            string segment = SegmentList.SelectedValue;

            try
            {
                using (var conn = DbHelper.GetConnection())
                {
                    // Check email uniqueness
                    using (var checkCmd = new NpgsqlCommand(
                        "SELECT COUNT(*) FROM users WHERE LOWER(email) = @email", conn))
                    {
                        checkCmd.Parameters.AddWithValue("@email", email);
                        long count = (long)checkCmd.ExecuteScalar();
                        if (count > 0)
                        {
                            ShowError("An account with this email already exists.");
                            return;
                        }
                    }

                    // Hash password
                    string passwordHash = BCrypt.Net.BCrypt.HashPassword(password);

                    // Insert user
                    using (var insertCmd = new NpgsqlCommand(
                        @"INSERT INTO users (name, email, password_hash, role, segment, status) 
                          VALUES (@name, @email, @hash, 'Student', @segment, 'active') 
                          RETURNING id", conn))
                    {
                        insertCmd.Parameters.AddWithValue("@name", name);
                        insertCmd.Parameters.AddWithValue("@email", email);
                        insertCmd.Parameters.AddWithValue("@hash", passwordHash);
                        insertCmd.Parameters.AddWithValue("@segment", segment);

                        int newId = (int)insertCmd.ExecuteScalar();

                        // Auto-login
                        Session["UserId"] = newId;
                        Session["UserName"] = name;
                        Session["UserEmail"] = email;
                        Session["Role"] = "Student";
                    }
                }

                Response.Redirect("~/User/Dashboard.aspx");
            }
            catch (Exception)
            {
                ShowError("Something went wrong. Please try again.");
            }
        }

        private void ShowError(string message)
        {
            ErrorMessage.Text = message;
            ErrorPanel.Visible = true;
        }
    }
}
