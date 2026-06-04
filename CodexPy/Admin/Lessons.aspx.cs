using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Admin
{
    public partial class Lessons : System.Web.UI.Page
    {
        private int ModuleId
        {
            get
            {
                if (int.TryParse(Request.QueryString["moduleId"], out int id)) return id;
                return 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (ModuleId == 0)
            {
                Response.Redirect("~/Admin/Modules.aspx");
                return;
            }

            AddLessonLink.NavigateUrl = "LessonEdit.aspx?moduleId=" + ModuleId;

            if (!IsPostBack)
            {
                LoadModuleTitle();
                LoadLessons();
            }
        }

        protected void DeleteLesson_Command(object sender, CommandEventArgs e)
        {
            int id = int.Parse(e.CommandArgument.ToString());
            try
            {
                using (var conn = DbHelper.GetConnection())
                {
                    // Grab lesson title + parent module title BEFORE deleting so we can log it
                    string lessonTitle = null, moduleTitle = null;
                    using (var titleCmd = new NpgsqlCommand(
                        @"SELECT l.title, m.title
                          FROM lessons l JOIN modules m ON l.module_id = m.id
                          WHERE l.id = @id", conn))
                    {
                        titleCmd.Parameters.AddWithValue("@id", id);
                        using (var reader = titleCmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lessonTitle = reader.GetString(0);
                                moduleTitle = reader.GetString(1);
                            }
                        }
                    }

                    using (var cmd = new NpgsqlCommand("DELETE FROM lessons WHERE id = @id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        int rows = cmd.ExecuteNonQuery();
                        ShowMessage(rows > 0 ? "Lesson deleted." : "Lesson not found.", rows > 0);

                        if (rows > 0 && lessonTitle != null)
                            AnnouncementHelper.Log("removed", "lesson", lessonTitle, moduleTitle);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Delete failed: " + ex.Message, false);
            }
            LoadLessons();
        }

        private void LoadModuleTitle()
        {
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand("SELECT title FROM modules WHERE id = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", ModuleId);
                var result = cmd.ExecuteScalar();
                ModuleTitleLit.Text = result?.ToString() ?? "Unknown";
            }
        }

        private void LoadLessons()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                "SELECT id, title, content, sort_order FROM lessons WHERE module_id = @mid ORDER BY sort_order", conn))
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
                            content = reader.IsDBNull(2) ? "" : reader.GetString(2),
                            sort_order = reader.GetInt32(3)
                        });
                    }
                }
            }
            LessonsRepeater.DataSource = rows;
            LessonsRepeater.DataBind();
            TotalLit.Text = rows.Count.ToString();
            EmptyPanel.Visible = rows.Count == 0;
        }

        private void ShowMessage(string text, bool success)
        {
            MessageLit.Text = text;
            MessagePanel.Visible = true;
            MessagePanel.BackColor = success ? System.Drawing.ColorTranslator.FromHtml("#D1FAE5") : System.Drawing.ColorTranslator.FromHtml("#FEE2E2");
            MessagePanel.ForeColor = success ? System.Drawing.ColorTranslator.FromHtml("#065F46") : System.Drawing.ColorTranslator.FromHtml("#991B1B");
        }

        protected string Truncate(string text, int maxLength)
        {
            if (string.IsNullOrEmpty(text)) return "—";
            text = text.Replace("\r", " ").Replace("\n", " ");
            return text.Length <= maxLength ? text : text.Substring(0, maxLength) + "…";
        }
    }
}
