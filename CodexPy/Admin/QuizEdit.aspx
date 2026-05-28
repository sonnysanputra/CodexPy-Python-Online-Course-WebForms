<%@ Page Title="Quiz Editor" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="QuizEdit.aspx.cs" Inherits="CodexPy.Admin.QuizEdit" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Quiz editor — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Quiz editor</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <div style="margin-bottom:22px;">
            <div class="eyebrow"><asp:Literal ID="ModeLit" runat="server" Text="New quiz" /></div>
            <h1 class="h1" style="margin-top:4px;"><asp:Literal ID="HeadingLit" runat="server" Text="Untitled quiz" /></h1>
        </div>

        <asp:Panel ID="ErrorPanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; background:rgba(239,68,68,0.08); border:1px solid var(--error); color:var(--error); font-size:13.5px;">
            <asp:Literal ID="ErrorLit" runat="server" />
        </asp:Panel>

        <div class="card" style="padding:32px; max-width:640px;">

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Title</div>
                <asp:TextBox ID="TitleBox" runat="server" CssClass="input" placeholder="e.g. Checkpoint quiz — Lists & Dictionaries" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="TitleBox"
                    CssClass="validation-error" ErrorMessage="Title is required" Display="Dynamic" />
            </div>

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Module</div>
                <asp:DropDownList ID="ModuleList" runat="server" CssClass="input" DataValueField="id" DataTextField="title" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="ModuleList"
                    InitialValue="" CssClass="validation-error" ErrorMessage="Module is required" Display="Dynamic" />
            </div>

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Description</div>
                <asp:TextBox ID="DescriptionBox" runat="server" CssClass="input" TextMode="MultiLine" Rows="3" />
            </div>

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Time limit (minutes — 0 means no limit)</div>
                <asp:TextBox ID="TimeLimitBox" runat="server" CssClass="input" TextMode="Number" Text="0" />
                <asp:RangeValidator runat="server" ControlToValidate="TimeLimitBox"
                    Type="Integer" MinimumValue="0" MaximumValue="180"
                    CssClass="validation-error" ErrorMessage="Time limit must be between 0 and 180 minutes" Display="Dynamic" />
            </div>

            <div style="display:flex; justify-content:space-between; margin-top:24px; padding-top:18px; border-top:1px solid var(--border);">
                <a href="<%= ResolveUrl("~/Admin/Quizzes.aspx") %>" class="btn btn-ghost">Cancel</a>
                <asp:Button ID="SaveButton" runat="server" Text="Save quiz"
                    CssClass="btn btn-yellow" OnClick="SaveButton_Click" />
            </div>

        </div>
    </div>
</asp:Content>
