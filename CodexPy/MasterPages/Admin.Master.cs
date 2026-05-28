using System;

namespace CodexPy.MasterPages
{
    public partial class AdminMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Authentication gate — only logged-in admins can access admin pages
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Auth/Login.aspx");
                return;
            }
            if (Session["Role"]?.ToString() != "Admin")
            {
                Response.Redirect("~/Auth/Login.aspx?denied=1");
                return;
            }

            // Show logged-in user name
            string name = Session["UserName"]?.ToString() ?? "Admin";
            UserName.Text = name;
            UserInitials.Text = GetInitials(name);
        }


        /// <summary>
        /// Returns "nav-item active" if the current URL ends with the given page,
        /// otherwise "nav-item". Used to highlight the active sidebar link.
        /// </summary>
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
