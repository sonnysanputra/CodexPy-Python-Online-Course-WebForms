using System;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Admin
{
    public partial class Questions : System.Web.UI.Page
    {
        private int QuizId
        {
            get
            {
                if (int.TryParse(Request.QueryString["quizId"], out int id)) return id;
                return 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (QuizId == 0)
            {
                Response.Redirect("~/Admin/Quizzes.aspx");
                return;
            }

            AddQuestionLink.NavigateUrl = "QuestionEdit.aspx?quizId=" + QuizId;

            if (!IsPostBack)
            {
                LoadQuizTitle();
                LoadQuestions();
            }
        }

        protected void DeleteQuestion_Command(object sender, CommandEventArgs e)
        {
            int id = int.Parse(e.CommandArgument.ToString());
            try
            {
                using (var conn = DbHelper.GetConnection())
                {
                    // Grab the prompt + parent quiz title BEFORE deleting so we can log it
                    string shortPrompt = null, quizTitle = null;
                    using (var titleCmd = new NpgsqlCommand(
                        @"SELECT q.prompt, qz.title
                          FROM questions q JOIN quizzes qz ON q.quiz_id = qz.id
                          WHERE q.id = @id", conn))
                    {
                        titleCmd.Parameters.AddWithValue("@id", id);
                        using (var reader = titleCmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string p = reader.GetString(0);
                                shortPrompt = p.Length > 80 ? p.Substring(0, 80) + "…" : p;
                                quizTitle = reader.GetString(1);
                            }
                        }
                    }

                    using (var cmd = new NpgsqlCommand("DELETE FROM questions WHERE id = @id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        int rows = cmd.ExecuteNonQuery();
                        ShowMessage(rows > 0 ? "Question deleted." : "Question not found.", rows > 0);

                        if (rows > 0 && shortPrompt != null)
                            AnnouncementHelper.Log("removed", "question", shortPrompt, quizTitle);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Delete failed: " + ex.Message, false);
            }
            LoadQuestions();
        }

        private void LoadQuizTitle()
        {
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand("SELECT title FROM quizzes WHERE id = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", QuizId);
                var result = cmd.ExecuteScalar();
                QuizTitleLit.Text = result?.ToString() ?? "Unknown";
            }
        }

        private void LoadQuestions()
        {
            var rows = new List<dynamic>();
            var serializer = new JavaScriptSerializer();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                "SELECT id, prompt, options_json, correct_answer, points, sort_order FROM questions WHERE quiz_id = @qid ORDER BY sort_order, id", conn))
            {
                cmd.Parameters.AddWithValue("@qid", QuizId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string optsJson = reader.IsDBNull(2) ? "[]" : reader.GetString(2);
                        int correctIdx = reader.IsDBNull(3) ? -1 : reader.GetInt32(3);
                        string correctText = "—";
                        try
                        {
                            var opts = serializer.Deserialize<List<string>>(optsJson);
                            if (correctIdx >= 0 && correctIdx < opts.Count)
                                correctText = opts[correctIdx];
                        }
                        catch { }

                        rows.Add(new
                        {
                            id = reader.GetInt32(0),
                            prompt = reader.GetString(1),
                            correct_text = correctText,
                            points = reader.GetInt32(4),
                            sort_order = reader.GetInt32(5),
                        });
                    }
                }
            }
            QuestionsRepeater.DataSource = rows;
            QuestionsRepeater.DataBind();
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
            return text.Length <= maxLength ? text : text.Substring(0, maxLength) + "…";
        }
    }
}
