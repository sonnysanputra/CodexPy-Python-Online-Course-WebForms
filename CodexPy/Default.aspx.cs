using System;
using System.Text;
using CodexPy.Data;

namespace CodexPy
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var sb = new StringBuilder();
            try
            {
                using (var conn = DbHelper.GetConnection())
                using (var cmd = new Npgsql.NpgsqlCommand("SELECT id, title, difficulty FROM modules ORDER BY sort_order", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    sb.Append("<ul>");
                    while (reader.Read())
                    {
                        sb.AppendFormat("<li>#{0} — <strong>{1}</strong> ({2})</li>",
                            reader.GetInt32(0),
                            reader.GetString(1),
                            reader.GetString(2));
                    }
                    sb.Append("</ul>");
                }
                sb.Insert(0, "<p style='color:green'>✓ Connection successful!</p>");
            }
            catch (Exception ex)
            {
                sb.AppendFormat("<p style='color:red'>✗ Connection FAILED: {0}</p>", ex.Message);
            }
            ResultLiteral.Text = sb.ToString();
        }
    }
}
