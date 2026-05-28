<%@ Page Title="Profile" Language="C#" MasterPageFile="~/MasterPages/Site.Master" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="CodexPy.User.Profile" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Profile — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Profile</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto; max-width:720px; margin:0 auto; width:100%;">

        <!-- Header -->
        <div style="margin-bottom:24px;">
            <div class="eyebrow">Your account</div>
            <h1 class="h1" style="margin-top:4px;">Profile</h1>
        </div>

        <!-- Messages -->
        <asp:Panel ID="SuccessPanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; background:rgba(16,185,129,0.1); border:1px solid var(--success); color:#047857; font-size:13.5px;">
            <asp:Literal ID="SuccessLit" runat="server" />
        </asp:Panel>
        <asp:Panel ID="ErrorPanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; background:rgba(239,68,68,0.08); border:1px solid var(--error); color:var(--error); font-size:13.5px;">
            <asp:Literal ID="ErrorLit" runat="server" />
        </asp:Panel>

        <!-- Avatar & account-info card -->
        <div class="card" style="padding:28px; margin-bottom:16px; display:flex; gap:20px; align-items:center;">
            <div class="avatar" style="width:64px; height:64px; font-size:22px;">
                <asp:Literal ID="AvatarLit" runat="server" />
            </div>
            <div style="flex:1;">
                <h2 class="h2"><asp:Literal ID="DisplayNameLit" runat="server" /></h2>
                <div style="font-size:13.5px; color:var(--muted); margin-top:4px;">
                    <asp:Literal ID="RoleLit" runat="server" /> · Joined <asp:Literal ID="JoinedLit" runat="server" />
                </div>
            </div>
        </div>

        <!-- Editable fields -->
        <div class="card" style="padding:28px; margin-bottom:16px;">
            <h3 class="h3" style="margin-bottom:18px;">Personal information</h3>

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Full name</div>
                <asp:TextBox ID="NameBox" runat="server" CssClass="input" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="NameBox"
                    CssClass="validation-error" ErrorMessage="Name is required" Display="Dynamic" />
            </div>

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Email</div>
                <asp:TextBox ID="EmailBox" runat="server" CssClass="input" TextMode="Email" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="EmailBox"
                    CssClass="validation-error" ErrorMessage="Email is required" Display="Dynamic" />
                <asp:RegularExpressionValidator runat="server" ControlToValidate="EmailBox"
                    CssClass="validation-error" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Enter a valid email address" Display="Dynamic" />
            </div>

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Segment</div>
                <asp:DropDownList ID="SegmentList" runat="server" CssClass="input">
                    <asp:ListItem Value="School" Text="School student" />
                    <asp:ListItem Value="University" Text="University student" />
                    <asp:ListItem Value="Self-learner" Text="Self-learner" />
                </asp:DropDownList>
            </div>
        </div>

        <!-- Password change -->
        <div class="card" style="padding:28px; margin-bottom:16px;">
            <h3 class="h3" style="margin-bottom:6px;">Change password</h3>
            <p style="color:var(--muted); font-size:13px; margin:0 0 18px;">Leave blank to keep your current password.</p>

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">New password</div>
                <asp:TextBox ID="NewPasswordBox" runat="server" CssClass="input" TextMode="Password" />
                <asp:RegularExpressionValidator runat="server" ControlToValidate="NewPasswordBox"
                    CssClass="validation-error" ValidationExpression="^.{8,}$"
                    ErrorMessage="Password must be at least 8 characters" Display="Dynamic" />
            </div>

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Confirm new password</div>
                <asp:TextBox ID="ConfirmPasswordBox" runat="server" CssClass="input" TextMode="Password" />
                <asp:CompareValidator runat="server" ControlToValidate="ConfirmPasswordBox"
                    ControlToCompare="NewPasswordBox" CssClass="validation-error"
                    ErrorMessage="Passwords do not match" Display="Dynamic" />
            </div>
        </div>

        <!-- Save -->
        <div style="display:flex; justify-content:flex-end;">
            <asp:Button ID="SaveButton" runat="server" Text="Save changes" CssClass="btn btn-yellow" OnClick="SaveButton_Click" />
        </div>

    </div>
</asp:Content>
