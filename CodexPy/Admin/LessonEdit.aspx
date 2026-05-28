<%@ Page Title="Lesson Editor" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="LessonEdit.aspx.cs" Inherits="CodexPy.Admin.LessonEdit" ValidateRequest="false" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Lesson editor — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Lesson editor</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <div style="margin-bottom:8px;">
            <asp:HyperLink ID="BackLink" runat="server" style="font-size:13px; color:var(--py-blue);" Text="← Back to lessons" />
        </div>

        <div style="margin-bottom:22px;">
            <div class="eyebrow"><asp:Literal ID="ModeLit" runat="server" Text="New lesson" /></div>
            <h1 class="h1" style="margin-top:4px;"><asp:Literal ID="HeadingLit" runat="server" Text="Untitled lesson" /></h1>
        </div>

        <asp:Panel ID="ErrorPanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; background:rgba(239,68,68,0.08); border:1px solid var(--error); color:var(--error); font-size:13.5px;">
            <asp:Literal ID="ErrorLit" runat="server" />
        </asp:Panel>

        <div class="card" style="padding:32px; max-width:800px;">

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Lesson title</div>
                <asp:TextBox ID="TitleBox" runat="server" CssClass="input" placeholder="e.g. Creating and indexing lists" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="TitleBox"
                    CssClass="validation-error" ErrorMessage="Title is required" Display="Dynamic" />
            </div>

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Sort order (within the module)</div>
                <asp:TextBox ID="SortOrderBox" runat="server" CssClass="input" TextMode="Number" Text="0" style="max-width:120px;" />
            </div>

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Lesson content</div>
                <div style="font-size:11.5px; color:var(--muted-2); margin-bottom:6px;">
                    Write the study material. You can use plain text or basic HTML (e.g. &lt;p&gt;, &lt;h2&gt;, &lt;ul&gt;, &lt;code&gt;).
                </div>
                <asp:TextBox ID="ContentBox" runat="server" CssClass="input" TextMode="MultiLine" Rows="14" style="font-family:var(--font-mono); font-size:13px;" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="ContentBox"
                    CssClass="validation-error" ErrorMessage="Content is required" Display="Dynamic" />
            </div>

            <div style="display:flex; justify-content:space-between; margin-top:24px; padding-top:18px; border-top:1px solid var(--border);">
                <asp:HyperLink ID="CancelLink" runat="server" CssClass="btn btn-ghost" Text="Cancel" />
                <asp:Button ID="SaveButton" runat="server" Text="Save lesson"
                    CssClass="btn btn-yellow" OnClick="SaveButton_Click" />
            </div>

        </div>
    </div>
</asp:Content>
