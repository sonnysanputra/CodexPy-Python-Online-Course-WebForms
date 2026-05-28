using System;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Admin
{
    public partial class UserEdit : System.Web.UI.Page
    {
        private int? UserId
        {
            get
            {
                string raw = Request.QueryString["id"];
                if (int.TryParse(raw, out int id)) return id;
                return null;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (UserId.HasValue)
                {
                    // EDIT mode — load existing user
                    LoadUser(UserId.Value);
                    ModeLit.Text = "Edit user";
                    HeadingLit.Text = NameBox.Text;
                    PasswordReq.Enabled = false; // password optional on edit
                    PasswordHintLit.Text = "(leave blank to keep current password)";
                }
                else
                {
                    // CREATE mode — empty form
                    ModeLit.Text = "Add user";
                    HeadingLit.Text = "New user";
                }
            }
        }

        private void LoadUser(int id)
        {
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                "SELECT name, email, role, segment, status FROM users WHERE id = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        ShowError("User not found.");
                        SaveButton.Enabled = false;
                        return;
                    }

                    NameBox.Text = reader.GetString(0);
                    EmailBox.Text = reader.GetString(1);
                    RoleList.SelectedValue = reader.GetString(2);
                    if (!reader.IsDBNull(3))
                        SegmentList.SelectedValue = reader.GetString(3);
                    StatusList.SelectedValue = reader.GetString(4);
                }
            }
        }

        protected void SaveButton_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string name = NameBox.Text.Trim();
            string email = EmailBox.Text.Trim().ToLowerInvariant();
            string role = RoleList.SelectedValue;
            string segment = SegmentList.SelectedValue;
            string status = StatusList.SelectedValue;
            string password = PasswordBox.Text;

            try
            {
                using (var conn = DbHelper.GetConnection())
                {
                    // Email uniqueness check (excluding current user when editing)
                    using (var checkCmd = new NpgsqlCommand(
                        "SELECT COUNT(*) FROM users WHERE LOWER(email) = @email AND id <> @id", conn))
                    {
                        checkCmd.Parameters.AddWithValue("@email", email);
                        checkCmd.Parameters.AddWithValue("@id", UserId ?? -1);
                        long count = (long)checkCmd.ExecuteScalar();
                        if (count > 0)
                        {
                            ShowError("Another user already has this email.");
                            return;
                        }
                    }

                    if (UserId.HasValue)
                    {
                        // UPDATE
                        string sql;
                        NpgsqlCommand cmd;

                        if (string.IsNullOrEmpty(password))
                        {
                            sql = @"UPDATE users
                                    SET name = @name, email = @email, role = @role,
                                        segment = @segment, status = @status
                                    WHERE id = @id";
                            cmd = new NpgsqlCommand(sql, conn);
                        }
                        else
                        {
                            sql = @"UPDATE users
                                    SET name = @name, email = @email, role = @role,
                                        segment = @segment, status = @status,
                                        password_hash = @hash
                                    WHERE id = @id";
                            cmd = new NpgsqlCommand(sql, conn);
                            cmd.Parameters.AddWithValue("@hash", BCrypt.Net.BCrypt.HashPassword(password));
                        }

                        cmd.Parameters.AddWithValue("@name", name);
                        cmd.Parameters.AddWithValue("@email", email);
                        cmd.Parameters.AddWithValue("@role", role);
                        cmd.Parameters.AddWithValue("@segment", segment);
                        cmd.Parameters.AddWithValue("@status", status);
                        cmd.Parameters.AddWithValue("@id", UserId.Value);

                        cmd.ExecuteNonQuery();
                        cmd.Dispose();
                    }
                    else
                    {
                        // INSERT (password required, already validated)
                        string hash = BCrypt.Net.BCrypt.HashPassword(password);
                        using (var insertCmd = new NpgsqlCommand(
                            @"INSERT INTO users (name, email, password_hash, role, segment, status)
                              VALUES (@name, @email, @hash, @role, @segment, @status)", conn))
                        {
                            insertCmd.Parameters.AddWithValue("@name", name);
                            insertCmd.Parameters.AddWithValue("@email", email);
                            insertCmd.Parameters.AddWithValue("@hash", hash);
                            insertCmd.Parameters.AddWithValue("@role", role);
                            insertCmd.Parameters.AddWithValue("@segment", segment);
                            insertCmd.Parameters.AddWithValue("@status", status);
                            insertCmd.ExecuteNonQuery();
                        }
                    }
                }

                Response.Redirect("~/Admin/Users.aspx");
            }
            catch (System.Threading.ThreadAbortException) { throw; } // expected from Redirect
            catch (Exception ex)
            {
                ShowError("Save failed: " + ex.Message);
            }
        }

        private void ShowError(string msg)
        {
            ErrorLit.Text = msg;
            ErrorPanel.Visible = true;
        }
    }
}
