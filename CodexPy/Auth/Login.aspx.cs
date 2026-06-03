using System;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Auth
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // If already logged in, redirect to appropriate landing
            if (!IsPostBack && Session["UserId"] != null)
            {
                RedirectByRole(Session["Role"]?.ToString());
            }
        }

        protected void SignInButton_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = EmailBox.Text.Trim().ToLowerInvariant();
            string password = PasswordBox.Text;

            try
            {
                using (var conn = DbHelper.GetConnection())
                using (var cmd = new NpgsqlCommand(
                    "SELECT id, name, password_hash, role, status FROM users WHERE LOWER(email) = @email",
                    conn))
                {
                    cmd.Parameters.AddWithValue("@email", email);

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            ShowError("No account found with that email.");
                            return;
                        }

                        int userId = reader.GetInt32(0);
                        string name = reader.GetString(1);
                        string passwordHash = reader.GetString(2);
                        string role = reader.GetString(3);
                        string status = reader.GetString(4);

                        if (status != "active")
                        {
                            ShowError("This account has been suspended. Contact an administrator.");
                            return;
                        }

                        if (!BCrypt.Net.BCrypt.Verify(password, passwordHash))
                        {
                            ShowError("Incorrect password.");
                            return;
                        }

                        // Success — stored into the session dict
                        Session["UserId"] = userId;
                        Session["UserName"] = name;
                        Session["UserEmail"] = email;
                        Session["Role"] = role;

                        // Update last_active_at
                        reader.Close();
                        using (var updateCmd = new NpgsqlCommand(
                            "UPDATE users SET last_active_at = CURRENT_TIMESTAMP WHERE id = @id", conn))
                        {
                            updateCmd.Parameters.AddWithValue("@id", userId);
                            updateCmd.ExecuteNonQuery();
                        }

                        RedirectByRole(role);
                    }
                }
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

        private void RedirectByRole(string role)
        {
            if (role == "Admin")
                Response.Redirect("~/Admin/Dashboard.aspx");
            else
                Response.Redirect("~/User/Dashboard.aspx");
        }

    }
}
