using System;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Admin
{
    public partial class QuestionEdit : System.Web.UI.Page
    {
        private int? QuestionId
        {
            get
            {
                if (int.TryParse(Request.QueryString["id"], out int id)) return id;
                return null;
            }
        }

        private int QuizIdFromUrl
        {
            get
            {
                if (int.TryParse(Request.QueryString["quizId"], out int id)) return id;
                return 0;
            }
        }

        private int currentQuizId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (QuestionId.HasValue)
                {
                    LoadQuestion(QuestionId.Value);
                    ModeLit.Text = "Edit question";
                }
                else
                {
                    if (QuizIdFromUrl == 0)
                    {
                        Response.Redirect("~/Admin/Quizzes.aspx");
                        return;
                    }
                    currentQuizId = QuizIdFromUrl;
                    ModeLit.Text = "New question";
                    CorrectA.Checked = true; // default to first option correct
                }

                BackLink.NavigateUrl = "Questions.aspx?quizId=" + currentQuizId;
                CancelLink.NavigateUrl = "Questions.aspx?quizId=" + currentQuizId;
                ViewState["QuizId"] = currentQuizId;
            }
            else
            {
                currentQuizId = (int)ViewState["QuizId"];
            }
        }

        private void LoadQuestion(int id)
        {
            var serializer = new JavaScriptSerializer();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                "SELECT quiz_id, prompt, options_json, correct_answer, explanation, points, sort_order FROM questions WHERE id = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        ShowError("Question not found.");
                        SaveButton.Enabled = false;
                        return;
                    }
                    currentQuizId = reader.GetInt32(0);
                    PromptBox.Text = reader.GetString(1);

                    // Parse options
                    string optsJson = reader.IsDBNull(2) ? "[]" : reader.GetString(2);
                    var opts = new List<string>();
                    try { opts = serializer.Deserialize<List<string>>(optsJson); } catch { }
                    while (opts.Count < 4) opts.Add("");

                    OptionA.Text = opts[0];
                    OptionB.Text = opts[1];
                    OptionC.Text = opts[2];
                    OptionD.Text = opts[3];

                    int correctIdx = reader.IsDBNull(3) ? 0 : reader.GetInt32(3);
                    CorrectA.Checked = correctIdx == 0;
                    CorrectB.Checked = correctIdx == 1;
                    CorrectC.Checked = correctIdx == 2;
                    CorrectD.Checked = correctIdx == 3;

                    ExplanationBox.Text = reader.IsDBNull(4) ? "" : reader.GetString(4);
                    PointsBox.Text = reader.GetInt32(5).ToString();
                    SortOrderBox.Text = reader.GetInt32(6).ToString();
                }
            }
        }

        protected void SaveButton_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string prompt = PromptBox.Text.Trim();
            string a = OptionA.Text.Trim();
            string b = OptionB.Text.Trim();
            string c = OptionC.Text.Trim();
            string d = OptionD.Text.Trim();

            // Require at least 2 options filled in
            int filledCount = 0;
            if (!string.IsNullOrEmpty(a)) filledCount++;
            if (!string.IsNullOrEmpty(b)) filledCount++;
            if (!string.IsNullOrEmpty(c)) filledCount++;
            if (!string.IsNullOrEmpty(d)) filledCount++;
            if (filledCount < 2)
            {
                ShowError("Please provide at least 2 answer options.");
                return;
            }

            int correctIdx = 0;
            if (CorrectB.Checked) correctIdx = 1;
            else if (CorrectC.Checked) correctIdx = 2;
            else if (CorrectD.Checked) correctIdx = 3;

            // Make sure the selected correct answer isn't empty
            string[] options = { a, b, c, d };
            if (string.IsNullOrEmpty(options[correctIdx]))
            {
                ShowError("The selected correct answer is empty. Please fill it in or pick another option.");
                return;
            }

            var serializer = new JavaScriptSerializer();
            string optsJson = serializer.Serialize(options);

            string explanation = ExplanationBox.Text.Trim();
            int points = int.TryParse(PointsBox.Text, out int p) ? p : 10;
            int sortOrder = int.TryParse(SortOrderBox.Text, out int so) ? so : 0;
            int quizId = (int)ViewState["QuizId"];

            try
            {
                using (var conn = DbHelper.GetConnection())
                {
                    if (QuestionId.HasValue)
                    {
                        using (var cmd = new NpgsqlCommand(
                            @"UPDATE questions
                              SET prompt=@prompt, kind='mcq', options_json=@opts,
                                  correct_answer=@correct, explanation=@explain,
                                  points=@points, sort_order=@sort_order
                              WHERE id=@id", conn))
                        {
                            cmd.Parameters.AddWithValue("@prompt", prompt);
                            cmd.Parameters.AddWithValue("@opts", optsJson);
                            cmd.Parameters.AddWithValue("@correct", correctIdx);
                            cmd.Parameters.AddWithValue("@explain", explanation);
                            cmd.Parameters.AddWithValue("@points", points);
                            cmd.Parameters.AddWithValue("@sort_order", sortOrder);
                            cmd.Parameters.AddWithValue("@id", QuestionId.Value);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        using (var cmd = new NpgsqlCommand(
                            @"INSERT INTO questions (quiz_id, prompt, kind, options_json, correct_answer, explanation, points, sort_order)
                              VALUES (@quiz_id, @prompt, 'mcq', @opts, @correct, @explain, @points, @sort_order)", conn))
                        {
                            cmd.Parameters.AddWithValue("@quiz_id", quizId);
                            cmd.Parameters.AddWithValue("@prompt", prompt);
                            cmd.Parameters.AddWithValue("@opts", optsJson);
                            cmd.Parameters.AddWithValue("@correct", correctIdx);
                            cmd.Parameters.AddWithValue("@explain", explanation);
                            cmd.Parameters.AddWithValue("@points", points);
                            cmd.Parameters.AddWithValue("@sort_order", sortOrder);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                Response.Redirect("Questions.aspx?quizId=" + quizId);
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
