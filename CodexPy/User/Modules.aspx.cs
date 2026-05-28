using System;
using System.Collections.Generic;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.User
{
    public partial class Modules : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Auth/Login.aspx");
                return;
            }

            if (!IsPostBack) LoadModules();
        }

        protected void DifficultyFilter_Changed(object sender, EventArgs e)
        {
            LoadModules();
        }

        private void LoadModules()
        {
            int userId = (int)Session["UserId"];
            string diff = DifficultyFilter.SelectedValue;

            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT m.id, m.title, m.blurb, m.difficulty, m.duration, m.color,
                         (SELECT COUNT(*) FROM lessons WHERE module_id = m.id) AS lesson_count,
                         COALESCE((SELECT progress FROM user_progress WHERE user_id = @uid AND module_id = m.id), 0) AS progress
                  FROM modules m
                  WHERE m.published = TRUE
                    AND (@diff = 'All' OR m.difficulty = @diff)
                  ORDER BY m.sort_order", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@diff", diff);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        decimal progress = reader.GetDecimal(7);
                        rows.Add(new
                        {
                            id = reader.GetInt32(0),
                            title = reader.GetString(1),
                            blurb = reader.IsDBNull(2) ? "" : reader.GetString(2),
                            difficulty = reader.GetString(3),
                            duration = reader.IsDBNull(4) ? "" : reader.GetString(4),
                            color = reader.IsDBNull(5) ? "#3776AB" : reader.GetString(5),
                            lesson_count = reader.GetInt64(6),
                            progress_percent = (int)(progress * 100),
                        });
                    }
                }
            }

            ModulesRepeater.DataSource = rows;
            ModulesRepeater.DataBind();
            EmptyPanel.Visible = rows.Count == 0;
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
