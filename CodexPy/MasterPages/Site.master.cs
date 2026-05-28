using System;

namespace CodexPy.MasterPages
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            // Auth gate runs in Init phase (before child Page_Load) so child pages
            // can safely assume Session["UserId"] is set.
            if (Session != null && Session["UserId"] == null)
            {
                Response.Redirect("~/Auth/Login.aspx");
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string name = Session["UserName"]?.ToString() ?? "Learner";
            UserName.Text = name;
            UserInitials.Text = GetInitials(name);
        }

        protected string IsActive(string page)
        {
            if (Request != null && Request.Url != null &&
                Request.Url.AbsolutePath.EndsWith(page, StringComparison.OrdinalIgnoreCase))
            {
                return "nav-item active";
            }
            return "nav-item";
        }

        private string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "?";
            var parts = fullName.Trim().Split(' ');
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }
    }
}
