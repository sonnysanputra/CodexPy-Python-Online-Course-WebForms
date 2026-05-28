using System;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.User
{
    public partial class Quiz : System.Web.UI.Page
    {
        private int QuizId
        {
            get { return int.TryParse(Request.QueryString["id"], out int id) ? id : 0; }
        }

        private int ModuleIdForQuiz
        {
            get { return ViewState["ModuleId"] as int? ?? 0; }
            set { ViewState["ModuleId"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Auth/Login.aspx");
                return;
            }
            if (QuizId == 0)
            {
                Response.Redirect("~/User/Modules.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadQuizInfo();
                LoadQuestions();
            }
        }

        private void LoadQuizInfo()
        {
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand("SELECT title, module_id FROM quizzes WHERE id = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", QuizId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        Response.Redirect("~/User/Modules.aspx");
                        return;
                    }
                    string title = reader.GetString(0);
                    int moduleId = reader.GetInt32(1);

                    PageTitleLit.Text = title;
                    QuizTitleLit.Text = title;
                    ModuleIdForQuiz = moduleId;
                    BackToModuleLink.NavigateUrl = "ModuleDetail.aspx?id=" + moduleId;
                    ResultModuleLink.NavigateUrl = "ModuleDetail.aspx?id=" + moduleId;
                }
            }
        }

        private void LoadQuestions()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                "SELECT id, prompt, options_json FROM questions WHERE quiz_id = @qid ORDER BY sort_order, id", conn))
            {
                cmd.Parameters.AddWithValue("@qid", QuizId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        rows.Add(new
                        {
                            id = reader.GetInt32(0),
                            prompt = reader.GetString(1),
                            options_json = reader.IsDBNull(2) ? "[]" : reader.GetString(2)
                        });
                    }
                }
            }

            QuestionsRepeater.DataSource = rows;
            QuestionsRepeater.DataBind();
            QuestionCountLit.Text = rows.Count.ToString();

            if (rows.Count == 0)
            {
                EmptyPanel.Visible = true;
                SubmitPanel.Visible = false;
            }
        }

        protected void QuestionsRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            string optsJson = DataBinder.Eval(e.Item.DataItem, "options_json") as string ?? "[]";
            var serializer = new JavaScriptSerializer();
            List<string> options;
            try { options = serializer.Deserialize<List<string>>(optsJson); }
            catch { options = new List<string>(); }

            var radioList = (RadioButtonList)e.Item.FindControl("OptionsList");
            for (int i = 0; i < options.Count; i++)
            {
                if (!string.IsNullOrEmpty(options[i]))
                {
                    // HTML-encode so option text like "<class 'int'>" displays correctly
                    radioList.Items.Add(new ListItem(System.Web.HttpUtility.HtmlEncode(options[i]), i.ToString()));
                }
            }
        }

        protected void SubmitButton_Click(object sender, EventArgs e)
        {
            int userId = (int)Session["UserId"];
            int correctCount = 0;
            int totalCount = 0;
            var serializer = new JavaScriptSerializer();

            using (var conn = DbHelper.GetConnection())
            {
                foreach (RepeaterItem item in QuestionsRepeater.Items)
                {
                    if (item.ItemType != ListItemType.Item && item.ItemType != ListItemType.AlternatingItem) continue;

                    var qidField = (HiddenField)item.FindControl("QuestionIdField");
                    var optsList = (RadioButtonList)item.FindControl("OptionsList");
                    var feedbackPanel = (Panel)item.FindControl("FeedbackPanel");
                    var verdictLit = (Literal)item.FindControl("VerdictLit");
                    var explanationLit = (Literal)item.FindControl("ExplanationLit");

                    int questionId = int.Parse(qidField.Value);
                    int selectedIdx = -1;
                    if (!string.IsNullOrEmpty(optsList.SelectedValue))
                    {
                        int.TryParse(optsList.SelectedValue, out selectedIdx);
                    }

                    totalCount++;

                    // Fetch correct answer + explanation from DB (don't trust client)
                    using (var cmd = new NpgsqlCommand(
                        "SELECT correct_answer, explanation, options_json FROM questions WHERE id = @id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", questionId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                int correctIdx = reader.IsDBNull(0) ? -1 : reader.GetInt32(0);
                                string explanation = reader.IsDBNull(1) ? "" : reader.GetString(1);
                                string optsJson = reader.IsDBNull(2) ? "[]" : reader.GetString(2);

                                bool isCorrect = (selectedIdx == correctIdx);
                                if (isCorrect) correctCount++;

                                feedbackPanel.Visible = true;
                                if (isCorrect)
                                {
                                    verdictLit.Text = "✓ Correct!";
                                    feedbackPanel.Style["background"] = "rgba(16,185,129,0.1)";
                                    feedbackPanel.Style["color"] = "#047857";
                                }
                                else
                                {
                                    string correctText = "";
                                    try
                                    {
                                        var opts = serializer.Deserialize<List<string>>(optsJson);
                                        if (correctIdx >= 0 && correctIdx < opts.Count)
                                            correctText = System.Web.HttpUtility.HtmlEncode(opts[correctIdx]);
                                    }
                                    catch { }
                                    verdictLit.Text = selectedIdx < 0
                                        ? "✗ No answer selected. Correct: " + correctText
                                        : "✗ Wrong. Correct answer: " + correctText;
                                    feedbackPanel.Style["background"] = "rgba(239,68,68,0.08)";
                                    feedbackPanel.Style["color"] = "#991B1B";
                                }
                                explanationLit.Text = explanation;
                                optsList.Enabled = false; // lock answers
                            }
                        }
                    }
                }

                int scorePercent = totalCount > 0 ? (int)Math.Round((double)correctCount * 100 / totalCount) : 0;

                // Save attempt
                using (var cmd = new NpgsqlCommand(
                    "INSERT INTO quiz_attempts (user_id, quiz_id, score) VALUES (@uid, @qid, @score)", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@qid", QuizId);
                    cmd.Parameters.AddWithValue("@score", scorePercent);
                    cmd.ExecuteNonQuery();
                }

                // Bump user_progress for this module
                using (var cmd = new NpgsqlCommand(
                    @"INSERT INTO user_progress (user_id, module_id, progress, last_accessed_at)
                      VALUES (@uid, @mid, 0.5, CURRENT_TIMESTAMP)
                      ON CONFLICT (user_id, module_id)
                      DO UPDATE SET last_accessed_at = CURRENT_TIMESTAMP,
                                    progress = GREATEST(user_progress.progress, 0.5)", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@mid", ModuleIdForQuiz);
                    cmd.ExecuteNonQuery();
                }

                ScoreLit.Text = scorePercent.ToString();
                ScoreSubLit.Text = correctCount + " correct out of " + totalCount + " questions.";
                ResultPanel.Visible = true;
                SubmitPanel.Visible = false;
            }
        }
    }
}
