using System;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Admin
{
    public partial class ModuleEdit : System.Web.UI.Page
    {
        private int? ModuleId
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
                if (ModuleId.HasValue)
                {
                    LoadModule(ModuleId.Value);
                    ModeLit.Text = "Edit module";
                }
                else
                {
                    ModeLit.Text = "New module";
                    HeadingLit.Text = "Untitled module";
                }
            }
        }

        private void LoadModule(int id)
        {
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                "SELECT title, blurb, difficulty, duration, color, icon, sort_order, published FROM modules WHERE id = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        ShowError("Module not found.");
                        SaveButton.Enabled = false;
                        return;
                    }
                    TitleBox.Text = reader.GetString(0);
                    BlurbBox.Text = reader.IsDBNull(1) ? "" : reader.GetString(1);
                    DifficultyList.SelectedValue = reader.GetString(2);
                    DurationBox.Text = reader.IsDBNull(3) ? "" : reader.GetString(3);
                    ColorBox.Text = reader.IsDBNull(4) ? "#3776AB" : reader.GetString(4);
                    IconBox.Text = reader.IsDBNull(5) ? "book" : reader.GetString(5);
                    SortOrderBox.Text = reader.GetInt32(6).ToString();
                    PublishedBox.Checked = reader.GetBoolean(7);
                    HeadingLit.Text = TitleBox.Text;
                }
            }
        }

        protected void SaveButton_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string title = TitleBox.Text.Trim();
            string blurb = BlurbBox.Text.Trim();
            string difficulty = DifficultyList.SelectedValue;
            string duration = DurationBox.Text.Trim();
            string color = ColorBox.Text.Trim();
            string icon = IconBox.Text.Trim();
            int sortOrder = int.TryParse(SortOrderBox.Text, out int so) ? so : 0;
            bool published = PublishedBox.Checked;

            try
            {
                using (var conn = DbHelper.GetConnection())
                {
                    if (ModuleId.HasValue)
                    {
                        // UPDATE
                        using (var cmd = new NpgsqlCommand(
                            @"UPDATE modules
                              SET title=@title, blurb=@blurb, difficulty=@difficulty, duration=@duration,
                                  color=@color, icon=@icon, sort_order=@sort_order, published=@published,
                                  updated_at = CURRENT_TIMESTAMP
                              WHERE id = @id", conn))
                        {
                            cmd.Parameters.AddWithValue("@title", title);
                            cmd.Parameters.AddWithValue("@blurb", blurb);
                            cmd.Parameters.AddWithValue("@difficulty", difficulty);
                            cmd.Parameters.AddWithValue("@duration", duration);
                            cmd.Parameters.AddWithValue("@color", color);
                            cmd.Parameters.AddWithValue("@icon", icon);
                            cmd.Parameters.AddWithValue("@sort_order", sortOrder);
                            cmd.Parameters.AddWithValue("@published", published);
                            cmd.Parameters.AddWithValue("@id", ModuleId.Value);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        // INSERT
                        using (var cmd = new NpgsqlCommand(
                            @"INSERT INTO modules (title, blurb, difficulty, duration, color, icon, sort_order, published)
                              VALUES (@title, @blurb, @difficulty, @duration, @color, @icon, @sort_order, @published)", conn))
                        {
                            cmd.Parameters.AddWithValue("@title", title);
                            cmd.Parameters.AddWithValue("@blurb", blurb);
                            cmd.Parameters.AddWithValue("@difficulty", difficulty);
                            cmd.Parameters.AddWithValue("@duration", duration);
                            cmd.Parameters.AddWithValue("@color", color);
                            cmd.Parameters.AddWithValue("@icon", icon);
                            cmd.Parameters.AddWithValue("@sort_order", sortOrder);
                            cmd.Parameters.AddWithValue("@published", published);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                Response.Redirect("~/Admin/Modules.aspx");
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
