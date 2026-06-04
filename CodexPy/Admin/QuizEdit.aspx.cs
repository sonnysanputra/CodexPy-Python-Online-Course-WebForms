using System;
using System.Collections.Generic;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Admin
{
    public partial class QuizEdit : System.Web.UI.Page
    {
        private int? QuizId
        {
            get
            {
                if (int.TryParse(Request.QueryString["id"], out int id)) return id;
                return null;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadModulesDropdown();

                if (QuizId.HasValue)
                {
                    LoadQuiz(QuizId.Value);
                    ModeLit.Text = "Edit quiz";
                }
                else
                {
                    ModeLit.Text = "New quiz";
                    HeadingLit.Text = "Untitled quiz";
                }
            }
        }

        private void LoadModulesDropdown()
        {
            var items = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand("SELECT id, title FROM modules ORDER BY sort_order", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    items.Add(new
                    {
                        id = reader.GetInt32(0).ToString(),
                        title = reader.GetString(1)
                    });
                }
            }
            ModuleList.DataSource = items;
            ModuleList.DataBind();
            ModuleList.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select module --", ""));
        }

        private void LoadQuiz(int id)
        {
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                "SELECT title, description, module_id, time_limit_seconds FROM quizzes WHERE id = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        ShowError("Quiz not found.");
                        SaveButton.Enabled = false;
                        return;
                    }
                    TitleBox.Text = reader.GetString(0);
                    DescriptionBox.Text = reader.IsDBNull(1) ? "" : reader.GetString(1);
                    ModuleList.SelectedValue = reader.GetInt32(2).ToString();
                    TimeLimitBox.Text = (reader.GetInt32(3) / 60).ToString(); // seconds -> minutes
                    HeadingLit.Text = TitleBox.Text;
                }
            }
        }

        protected void SaveButton_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string title = TitleBox.Text.Trim();
            string description = DescriptionBox.Text.Trim();
            int moduleId = int.Parse(ModuleList.SelectedValue);
            int timeLimitMinutes = int.TryParse(TimeLimitBox.Text, out int tl) ? tl : 0;
            int timeLimitSeconds = timeLimitMinutes * 60;

            try
            {
                using (var conn = DbHelper.GetConnection())
                {
                    if (QuizId.HasValue)
                    {
                        using (var cmd = new NpgsqlCommand(
                            @"UPDATE quizzes
                              SET title=@title, description=@description, module_id=@module_id, time_limit_seconds=@time_limit
                              WHERE id = @id", conn))
                        {
                            cmd.Parameters.AddWithValue("@title", title);
                            cmd.Parameters.AddWithValue("@description", description);
                            cmd.Parameters.AddWithValue("@module_id", moduleId);
                            cmd.Parameters.AddWithValue("@time_limit", timeLimitSeconds);
                            cmd.Parameters.AddWithValue("@id", QuizId.Value);
                            cmd.ExecuteNonQuery();
                        }
                        AnnouncementHelper.Log("updated", "quiz", title);
                    }
                    else
                    {
                        using (var cmd = new NpgsqlCommand(
                            @"INSERT INTO quizzes (title, description, module_id, time_limit_seconds)
                              VALUES (@title, @description, @module_id, @time_limit)", conn))
                        {
                            cmd.Parameters.AddWithValue("@title", title);
                            cmd.Parameters.AddWithValue("@description", description);
                            cmd.Parameters.AddWithValue("@module_id", moduleId);
                            cmd.Parameters.AddWithValue("@time_limit", timeLimitSeconds);
                            cmd.ExecuteNonQuery();
                        }
                        AnnouncementHelper.Log("added", "quiz", title);
                    }
                }

                Response.Redirect("~/Admin/Quizzes.aspx");
            }
            catch (System.Threading.ThreadAbortException) { throw; }
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
