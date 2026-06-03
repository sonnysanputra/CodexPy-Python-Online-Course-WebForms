<%@ Page Title="Edit User" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="UserEdit.aspx.cs" Inherits="CodexPy.Admin.UserEdit" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">User editor — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">User editor</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <!-- ========== PAGE HEADER (mode label "Add/Edit" + user heading) ========== -->
        <div style="margin-bottom:22px;">
            <div class="eyebrow"><asp:Literal ID="ModeLit" runat="server" Text="Add user" /></div>
            <h1 class="h1" style="margin-top:4px;"><asp:Literal ID="HeadingLit" runat="server" Text="New user" /></h1>
        </div>

        <!-- ========== ERROR BANNER (shown if email is duplicate or save fails) ========== -->
        <asp:Panel ID="ErrorPanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; background:rgba(239,68,68,0.08); border:1px solid var(--error); color:var(--error); font-size:13.5px;">
            <asp:Literal ID="ErrorLit" runat="server" />
        </asp:Panel>

        <!-- ========== FORM CARD (wraps all input fields + action buttons) ========== -->
        <div class="card" style="padding:32px; max-width:640px;">

            <!-- Field: Full name (required) -->
            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Full name</div>
                <asp:TextBox ID="NameBox" runat="server" CssClass="input" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="NameBox"
                    CssClass="validation-error" ErrorMessage="Name is required" Display="Dynamic" />
            </div>

            <!-- Field: Email (required + regex-format validators) -->
            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Email</div>
                <asp:TextBox ID="EmailBox" runat="server" CssClass="input" TextMode="Email" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="EmailBox"
                    CssClass="validation-error" ErrorMessage="Email is required" Display="Dynamic" />
                <asp:RegularExpressionValidator runat="server" ControlToValidate="EmailBox"
                    CssClass="validation-error" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Enter a valid email address" Display="Dynamic" />
            </div>

            <!-- Two-column row: Role / Segment dropdowns -->
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:14px;">
                <div>
                    <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Role</div>
                    <asp:DropDownList ID="RoleList" runat="server" CssClass="input">
                        <asp:ListItem Value="Student" Text="Student" />
                        <asp:ListItem Value="Admin" Text="Admin" />
                    </asp:DropDownList>
                </div>
                <div>
                    <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Segment</div>
                    <asp:DropDownList ID="SegmentList" runat="server" CssClass="input">
                        <asp:ListItem Value="School" Text="School" />
                        <asp:ListItem Value="University" Text="University" />
                        <asp:ListItem Value="Self-learner" Text="Self-learner" />
                    </asp:DropDownList>
                </div>
            </div>

            <!-- Field: Status dropdown (active / dormant / suspended) -->
            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Status</div>
                <asp:DropDownList ID="StatusList" runat="server" CssClass="input">
                    <asp:ListItem Value="active" Text="Active" />
                    <asp:ListItem Value="dormant" Text="Dormant" />
                    <asp:ListItem Value="suspended" Text="Suspended" />
                </asp:DropDownList>
            </div>

            <!-- Field: Password (required for new users, optional for edits — toggled in code-behind) -->
            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">
                    Password
                    <span style="color:var(--muted-2); font-weight:400;"><asp:Literal ID="PasswordHintLit" runat="server" Text="(required for new users)" /></span>
                </div>
                <asp:TextBox ID="PasswordBox" runat="server" CssClass="input" TextMode="Password" />
                <asp:RequiredFieldValidator ID="PasswordReq" runat="server" ControlToValidate="PasswordBox"
                    CssClass="validation-error" ErrorMessage="Password is required" Display="Dynamic" Enabled="true" />
                <asp:RegularExpressionValidator ID="PasswordLen" runat="server" ControlToValidate="PasswordBox"
                    CssClass="validation-error" ValidationExpression="^.{8,}$"
                    ErrorMessage="Password must be at least 8 characters" Display="Dynamic" />
            </div>

            <!-- ========== FORM ACTION BUTTONS (Cancel left, Save right) ========== -->
            <div style="display:flex; justify-content:space-between; margin-top:24px; padding-top:18px; border-top:1px solid var(--border);">
                <a href="<%= ResolveUrl("~/Admin/Users.aspx") %>" class="btn btn-ghost">Cancel</a>
                <asp:Button ID="SaveButton" runat="server" Text="Save user"
                    CssClass="btn btn-yellow" OnClick="SaveButton_Click" />
            </div>

        </div>

    </div>
</asp:Content>
