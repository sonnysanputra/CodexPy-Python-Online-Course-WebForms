using System;
using System.Collections.Generic;
using System.Globalization;
using CodexPy.Data;
using Npgsql;

namespace CodexPy.Admin
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            DateLiteral.Text = DateTime.Now.ToString("dddd, MMMM d yyyy", CultureInfo.InvariantCulture);

            if (!IsPostBack)
            {
                LoadKpis();
                LoadModules();
                LoadRecentUsers();
            }
        }

        private void LoadKpis()
        {
            using (var conn = DbHelper.GetConnection())
            {
                TotalUsersLit.Text = ScalarCount(conn, "SELECT COUNT(*) FROM users");
                ActiveUsersLit.Text = ScalarCount(conn, "SELECT COUNT(*) FROM users WHERE last_active_at > NOW() - INTERVAL '7 days'");
                TotalModulesLit.Text = ScalarCount(conn, "SELECT COUNT(*) FROM modules");
                QuizAttemptsLit.Text = ScalarCount(conn, "SELECT COUNT(*) FROM quiz_attempts");
            }
        }

        private string ScalarCount(NpgsqlConnection conn, string sql)
        {
            using (var cmd = new NpgsqlCommand(sql, conn))
            {
                var result = cmd.ExecuteScalar();
                return Convert.ToInt64(result).ToString("N0"); //ToString NO, to add thousands seperators "1,000 not 1000"
            }
        }

        private void LoadModules()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand("SELECT title, difficulty, duration FROM modules ORDER BY sort_order LIMIT 6", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    rows.Add(new
                    {
                        title = reader.GetString(0),
                        difficulty = reader.GetString(1),
                        duration = reader.IsDBNull(2) ? "" : reader.GetString(2)
                    });
                }
            }
            ModulesRepeater.DataSource = rows;
            ModulesRepeater.DataBind();
        }

        private void LoadRecentUsers()
        {
            var rows = new List<dynamic>();
            using (var conn = DbHelper.GetConnection())
            using (var cmd = new NpgsqlCommand("SELECT name, email, segment FROM users ORDER BY created_at DESC LIMIT 8", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    rows.Add(new
                    {
                        name = reader.GetString(0),
                        email = reader.GetString(1),
                        segment = reader.IsDBNull(2) ? "Unknown" : reader.GetString(2)
                    });
                }
            }
            RecentUsersRepeater.DataSource = rows;
            RecentUsersRepeater.DataBind();
        }

        /// <summary>Used by markup to map difficulty to CSS tag class.</summary>
        protected string GetDifficultyClass(string difficulty)
        {
            if (difficulty == "Beginner") return "beg dot";
            if (difficulty == "Intermediate") return "int dot";
            if (difficulty == "Advanced") return "adv dot";
            return "";
        }
    }
}
