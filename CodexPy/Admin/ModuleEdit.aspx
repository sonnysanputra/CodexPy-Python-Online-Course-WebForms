<%@ Page Title="Module Editor" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="ModuleEdit.aspx.cs" Inherits="CodexPy.Admin.ModuleEdit" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Module editor — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Module editor</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <!-- ========== PAGE HEADER (mode label "New/Edit" + module title heading) ========== -->
        <div style="margin-bottom:22px;">
            <div class="eyebrow"><asp:Literal ID="ModeLit" runat="server" Text="New module" /></div>
            <h1 class="h1" style="margin-top:4px;"><asp:Literal ID="HeadingLit" runat="server" Text="Untitled module" /></h1>
        </div>

        <!-- ========== ERROR BANNER (shown if module not found, save fails, etc.) ========== -->
        <asp:Panel ID="ErrorPanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; background:rgba(239,68,68,0.08); border:1px solid var(--error); color:var(--error); font-size:13.5px;">
            <asp:Literal ID="ErrorLit" runat="server" />
        </asp:Panel>

        <!-- ========== FORM CARD (wraps all input fields + action buttons) ========== -->
        <div class="card" style="padding:32px; max-width:720px;">

            <!-- Field: Title (required) -->
            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Title</div>
                <asp:TextBox ID="TitleBox" runat="server" CssClass="input" placeholder="e.g. Lists & Dictionaries" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="TitleBox"
                    CssClass="validation-error" ErrorMessage="Title is required" Display="Dynamic" />
            </div>

            <!-- Field: Blurb (required, multi-line textarea) -->
            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Blurb (short summary shown in the catalog)</div>
                <asp:TextBox ID="BlurbBox" runat="server" CssClass="input" TextMode="MultiLine" Rows="2" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="BlurbBox"
                    CssClass="validation-error" ErrorMessage="Blurb is required" Display="Dynamic" />
            </div>

            <!-- Three-column row: Difficulty / Duration / Sort order -->
            <div style="display:grid; grid-template-columns:1fr 1fr 1fr; gap:12px; margin-bottom:14px;">
                <div>
                    <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Difficulty</div>
                    <asp:DropDownList ID="DifficultyList" runat="server" CssClass="input">
                        <asp:ListItem Value="Beginner" />
                        <asp:ListItem Value="Intermediate" />
                        <asp:ListItem Value="Advanced" />
                    </asp:DropDownList>
                </div>
                <div>
                    <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Duration</div>
                    <asp:TextBox ID="DurationBox" runat="server" CssClass="input" placeholder="e.g. 1h 30m" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="DurationBox"
                        CssClass="validation-error" ErrorMessage="Duration is required" Display="Dynamic" />
                    <asp:RegularExpressionValidator runat="server" ControlToValidate="DurationBox"
                        ValidationExpression="^(\d+h(\s\d+m)?|\d+m)$"
                        CssClass="validation-error" ErrorMessage="Use format like 1h 30m, 45m, or 2h" Display="Dynamic" />
                </div>
                <div>
                    <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Sort order</div>
                    <asp:TextBox ID="SortOrderBox" runat="server" CssClass="input" TextMode="Number" Text="1" min="1" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="SortOrderBox"
                        CssClass="validation-error" ErrorMessage="Sort order is required" Display="Dynamic" />
                    <asp:RangeValidator runat="server" ControlToValidate="SortOrderBox"
                        Type="Integer" MinimumValue="1" MaximumValue="9999"
                        CssClass="validation-error" ErrorMessage="Sort order must be 1 or higher" Display="Dynamic" />
                </div>
            </div>

            <!-- Field: Color (hex) -->
            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Color (hex)</div>
                <asp:TextBox ID="ColorBox" runat="server" CssClass="input" Text="#3776AB" />
            </div>

            <!-- Field: Published checkbox -->
            <div style="margin-bottom:14px;">
                <asp:CheckBox ID="PublishedBox" runat="server" Text="&nbsp;Published (visible to learners)" Checked="true" />
            </div>

            <!-- ========== FORM ACTION BUTTONS (Cancel left, Save right) ========== -->
            <div style="display:flex; justify-content:space-between; margin-top:24px; padding-top:18px; border-top:1px solid var(--border);">
                <a href="<%= ResolveUrl("~/Admin/Modules.aspx") %>" class="btn btn-ghost">Cancel</a>
                <asp:Button ID="SaveButton" runat="server" Text="Save module"
                    CssClass="btn btn-yellow" OnClick="SaveButton_Click" />
            </div>

        </div>
    </div>
</asp:Content>
