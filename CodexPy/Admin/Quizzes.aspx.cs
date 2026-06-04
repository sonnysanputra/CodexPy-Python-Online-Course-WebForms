using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Admin
{
    public partial class Quizzes : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadQuizzes();
        }

        protected void DeleteQuiz_Command(object sender, CommandEventArgs e)
        {
            int id = int.Parse(e.CommandArgument.ToString());
            try
            {
                using (var conn = DbHelper.GetConnection())
                {
                    // Grab the title BEFORE deleting so we can log it as an announcement
                    string quizTitle = null;
                    using (var titleCmd = new NpgsqlCommand("SELECT title FROM quizzes WHERE id = @id", conn))
                    {
                        titleCmd.Parameters.AddWithValue("@id", id);
                        quizTitle = titleCmd.ExecuteScalar()?.ToString();
                    }

                    using (var cmd = new NpgsqlCommand("DELETE FROM quizzes WHERE id = @id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        int rows = cmd.ExecuteNonQuery();
                        ShowMessage(rows > 0 ? "Quiz deleted." : "Quiz not found.", rows > 0);

                        if (rows > 0 && quizTitle != null)
                            AnnouncementHelper.Log("removed", "quiz", quizTitle);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Delete failed: " + ex.Message, false);
            }
            LoadQuizzes();
        }

        private void LoadQuizzes()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT q.id, q.title, q.description, q.time_limit_seconds, q.created_at,
                         m.title AS module_title,
                         (SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) AS question_count
                  FROM quizzes q
                  JOIN modules m ON q.module_id = m.id
                  ORDER BY m.sort_order, q.created_at", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    rows.Add(new
                    {
                        id = reader.GetInt32(0),
                        title = reader.GetString(1),
                        description = reader.IsDBNull(2) ? "" : reader.GetString(2),
                        time_limit_seconds = reader.GetInt32(3),
                        created_at = (object)reader.GetDateTime(4),
                        module_title = reader.GetString(5),
                        question_count = (int)reader.GetInt64(6),
                    });
                }
            }
            QuizzesRepeater.DataSource = rows;
            QuizzesRepeater.DataBind();
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
    }
}
