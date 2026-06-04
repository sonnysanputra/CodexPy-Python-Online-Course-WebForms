using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Admin
{
    public partial class Modules : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadModules();
        }

        protected void DeleteModule_Command(object sender, CommandEventArgs e)
        {
            int id = int.Parse(e.CommandArgument.ToString());
            try
            {
                using (var conn = DbHelper.GetConnection())
                {
                    // Grab the title BEFORE deleting so we can log it as an announcement
                    string moduleTitle = null;
                    using (var titleCmd = new NpgsqlCommand("SELECT title FROM modules WHERE id = @id", conn))
                    {
                        titleCmd.Parameters.AddWithValue("@id", id);
                        moduleTitle = titleCmd.ExecuteScalar()?.ToString();
                    }

                    using (var cmd = new NpgsqlCommand("DELETE FROM modules WHERE id = @id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        int rows = cmd.ExecuteNonQuery();
                        ShowMessage(rows > 0 ? "Module deleted." : "Module not found.", rows > 0);

                        if (rows > 0 && moduleTitle != null)
                            AnnouncementHelper.Log("removed", "module", moduleTitle);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Delete failed: " + ex.Message, false);
            }
            LoadModules();
        }

        private void LoadModules()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                "SELECT id, title, blurb, difficulty, duration, color, sort_order, published FROM modules ORDER BY sort_order", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    rows.Add(new
                    {
                        id = reader.GetInt32(0),
                        title = reader.GetString(1),
                        blurb = reader.IsDBNull(2) ? "" : reader.GetString(2),
                        difficulty = reader.GetString(3),
                        duration = reader.IsDBNull(4) ? "" : reader.GetString(4),
                        color = reader.IsDBNull(5) ? "#3776AB" : reader.GetString(5),
                        sort_order = reader.GetInt32(6),
                        published = reader.GetBoolean(7),
                    });
                }
            }
            ModulesRepeater.DataSource = rows; //Tells the ModulesRepeater where to get the data
            ModulesRepeater.DataBind(); //Renders the data
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

        protected string GetDifficultyClass(string difficulty)
        {
            if (difficulty == "Beginner") return "beg dot";
            if (difficulty == "Intermediate") return "int dot";
            if (difficulty == "Advanced") return "adv dot";
            return "";
        }
    }
}
