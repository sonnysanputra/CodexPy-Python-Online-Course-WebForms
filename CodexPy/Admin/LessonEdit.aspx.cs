using System;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Admin
{
    public partial class LessonEdit : System.Web.UI.Page
    {
        private int? LessonId
        {
            get
            {
                if (int.TryParse(Request.QueryString["id"], out int id)) return id;
                return null;
            }
        }

        private int ModuleIdFromUrl
        {
            get
            {
                if (int.TryParse(Request.QueryString["moduleId"], out int id)) return id;
                return 0;
            }
        }

        // For edit mode, module id is loaded from the existing lesson
        private int currentModuleId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (LessonId.HasValue)
                {
                    LoadLesson(LessonId.Value);
                    ModeLit.Text = "Edit lesson";
                }
                else
                {
                    if (ModuleIdFromUrl == 0)
                    {
                        Response.Redirect("~/Admin/Modules.aspx");
                        return;
                    }
                    currentModuleId = ModuleIdFromUrl;
                    ModeLit.Text = "New lesson";
                    HeadingLit.Text = "Untitled lesson";
                }

                BackLink.NavigateUrl = "Lessons.aspx?moduleId=" + currentModuleId;
                CancelLink.NavigateUrl = "Lessons.aspx?moduleId=" + currentModuleId;
                ViewState["ModuleId"] = currentModuleId;
            }
            else
            {
                currentModuleId = (int)ViewState["ModuleId"];
            }
        }

        private void LoadLesson(int id)
        {
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                "SELECT module_id, title, content, sort_order FROM lessons WHERE id = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        ShowError("Lesson not found.");
                        SaveButton.Enabled = false;
                        return;
                    }
                    currentModuleId = reader.GetInt32(0);
                    TitleBox.Text = reader.GetString(1);
                    ContentBox.Text = reader.IsDBNull(2) ? "" : reader.GetString(2);
                    SortOrderBox.Text = reader.GetInt32(3).ToString();
                    HeadingLit.Text = TitleBox.Text;
                }
            }
        }

        protected void SaveButton_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string title = TitleBox.Text.Trim();
            string content = ContentBox.Text.Trim();
            int sortOrder = int.TryParse(SortOrderBox.Text, out int so) ? so : 0;
            int moduleId = (int)ViewState["ModuleId"];

            try
            {
                using (var conn = DbHelper.GetConnection())
                {
                    // Fetch the parent module title so the announcement reads naturally
                    string moduleTitle = null;
                    using (var titleCmd = new NpgsqlCommand("SELECT title FROM modules WHERE id = @id", conn))
                    {
                        titleCmd.Parameters.AddWithValue("@id", moduleId);
                        moduleTitle = titleCmd.ExecuteScalar()?.ToString();
                    }

                    if (LessonId.HasValue)
                    {
                        using (var cmd = new NpgsqlCommand(
                            @"UPDATE lessons SET title=@title, content=@content, sort_order=@sort_order WHERE id=@id", conn))
                        {
                            cmd.Parameters.AddWithValue("@title", title);
                            cmd.Parameters.AddWithValue("@content", content);
                            cmd.Parameters.AddWithValue("@sort_order", sortOrder);
                            cmd.Parameters.AddWithValue("@id", LessonId.Value);
                            cmd.ExecuteNonQuery();
                        }
                        AnnouncementHelper.Log("updated", "lesson", title, moduleTitle);
                    }
                    else
                    {
                        using (var cmd = new NpgsqlCommand(
                            @"INSERT INTO lessons (module_id, title, content, sort_order)
                              VALUES (@module_id, @title, @content, @sort_order)", conn))
                        {
                            cmd.Parameters.AddWithValue("@module_id", moduleId);
                            cmd.Parameters.AddWithValue("@title", title);
                            cmd.Parameters.AddWithValue("@content", content);
                            cmd.Parameters.AddWithValue("@sort_order", sortOrder);
                            cmd.ExecuteNonQuery();
                        }
                        AnnouncementHelper.Log("added", "lesson", title, moduleTitle);
                    }
                }

                Response.Redirect("Lessons.aspx?moduleId=" + moduleId);
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
