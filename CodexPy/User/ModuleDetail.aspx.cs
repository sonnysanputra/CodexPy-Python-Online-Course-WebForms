using System;
using System.Collections.Generic;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.User
{
    public partial class ModuleDetail : System.Web.UI.Page
    {
        private int ModuleId
        {
            get
            {
                if (int.TryParse(Request.QueryString["id"], out int id)) return id;
                return 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Auth/Login.aspx");
                return;
            }

            if (ModuleId == 0)
            {
                Response.Redirect("~/User/Modules.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadModule();
                LoadLessons();
                LoadQuizzes();
                TrackVisit(); // mark user has at least started this module
            }
        }

        protected void MarkCompleteButton_Click(object sender, EventArgs e)
        {
            int userId = (int)Session["UserId"];
            try
            {
                using (var conn = DbHelper.GetConnection())
                using (var cmd = new NpgsqlCommand(
                    @"INSERT INTO user_progress (user_id, module_id, progress, last_accessed_at)
                      VALUES (@uid, @mid, 1.0, CURRENT_TIMESTAMP)
                      ON CONFLICT (user_id, module_id)
                      DO UPDATE SET progress = 1.0, last_accessed_at = CURRENT_TIMESTAMP", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@mid", ModuleId);
                    cmd.ExecuteNonQuery();
                }
                ShowMessage("Module marked as complete!");
                LoadModule(); // refresh progress
            }
            catch (Exception ex)
            {
                ShowMessage("Could not save progress: " + ex.Message);
            }
        }

        private void LoadModule()
        {
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT m.title, m.blurb, m.difficulty, m.duration, m.color,
                         COALESCE((SELECT progress FROM user_progress WHERE user_id = @uid AND module_id = m.id), 0) AS progress
                  FROM modules m WHERE m.id = @mid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", (int)Session["UserId"]);
                cmd.Parameters.AddWithValue("@mid", ModuleId);

                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        Response.Redirect("~/User/Modules.aspx");
                        return;
                    }

                    string title = reader.GetString(0);
                    string blurb = reader.IsDBNull(1) ? "" : reader.GetString(1);
                    string difficulty = reader.GetString(2);
                    string duration = reader.IsDBNull(3) ? "" : reader.GetString(3);
                    string color = reader.IsDBNull(4) ? "#3776AB" : reader.GetString(4);
                    decimal progress = reader.GetDecimal(5);
                    int progressPercent = (int)(progress * 100);

                    PageTitleLit.Text = title;
                    CrumbLit.Text = title;
                    TitleLit.Text = title;
                    BlurbLit.Text = blurb;
                    DifficultyLit.Text = difficulty;
                    DurationLit.Text = duration;
                    IconInitialLit.Text = title.Substring(0, 1);
                    IconBox.Style["background"] = color + "22";
                    IconBox.Style["color"] = color;
                    ProgressPercentLit.Text = progressPercent.ToString();
                    ProgressFill.Style["width"] = progressPercent + "%";
                }
            }
        }

        private void LoadLessons()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                "SELECT title, content FROM lessons WHERE module_id = @mid ORDER BY sort_order, id", conn))
            {
                cmd.Parameters.AddWithValue("@mid", ModuleId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        rows.Add(new
                        {
                            title = reader.GetString(0),
                            content = reader.IsDBNull(1) ? "" : reader.GetString(1)
                        });
                    }
                }
            }
            LessonsRepeater.DataSource = rows;
            LessonsRepeater.DataBind();
            EmptyLessonsPanel.Visible = rows.Count == 0;
        }

        private void LoadQuizzes()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"SELECT q.id, q.title, q.time_limit_seconds,
                         (SELECT COUNT(*) FROM questions WHERE quiz_id = q.id) AS question_count
                  FROM quizzes q
                  WHERE q.module_id = @mid
                  ORDER BY q.created_at", conn))
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
                            time_limit_seconds = reader.GetInt32(2),
                            question_count = (int)reader.GetInt64(3),
                        });
                    }
                }
            }
            QuizzesRepeater.DataSource = rows;
            QuizzesRepeater.DataBind();
            EmptyQuizzesPanel.Visible = rows.Count == 0;
        }

        private void TrackVisit()
        {
            int userId = (int)Session["UserId"];
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand(
                @"INSERT INTO user_progress (user_id, module_id, progress, last_accessed_at)
                  VALUES (@uid, @mid, 0.05, CURRENT_TIMESTAMP)
                  ON CONFLICT (user_id, module_id)
                  DO UPDATE SET last_accessed_at = CURRENT_TIMESTAMP", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@mid", ModuleId);
                cmd.ExecuteNonQuery();
            }
        }

        private void ShowMessage(string msg)
        {
            MessageLit.Text = msg;
            MessagePanel.Visible = true;
        }
    }
}
