<%@ Page Title="Lessons" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="Lessons.aspx.cs" Inherits="CodexPy.Admin.Lessons" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Manage Lessons — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Lessons</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <!-- ========== BREADCRUMB (link back to parent Modules list) ========== -->
        <div style="margin-bottom:8px;">
            <a href="<%= ResolveUrl("~/Admin/Modules.aspx") %>" style="font-size:13px; color:var(--py-blue);">← Back to modules</a>
        </div>

        <!-- ========== PAGE HEADER (module title heading + "New lesson" button) ========== -->
        <div style="display:flex; justify-content:space-between; align-items:end; margin-bottom:22px;">
            <div>
                <div class="eyebrow">Module content</div>
                <h1 class="h1" style="margin-top:4px;">Lessons for "<asp:Literal ID="ModuleTitleLit" runat="server" />"</h1>
                <p style="color:var(--muted); margin-top:4px; font-size:14px;">
                    <asp:Literal ID="TotalLit" runat="server" /> lessons in this module
                </p>
            </div>
            <asp:HyperLink ID="AddLessonLink" runat="server" CssClass="btn btn-primary" Text="+ New lesson" />
        </div>

        <!-- ========== STATUS BANNER (shows success/error after a delete) ========== -->
        <asp:Panel ID="MessagePanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; font-size:13.5px;">
            <asp:Literal ID="MessageLit" runat="server" />
        </asp:Panel>

        <!-- ========== LESSONS LIST TABLE (card-wrapped data table) ========== -->
        <div class="card" style="padding:0; overflow:hidden;">
            <table class="data-table">
                <!-- Table header row (column titles) -->
                <thead>
                    <tr>
                        <th style="width:60px;">#</th>
                        <th>Lesson</th>
                        <th>Preview</th>
                        <th style="text-align:right;">Actions</th>
                    </tr>
                </thead>
                <!-- Table body — one row per lesson via Repeater -->
                <tbody>
                    <asp:Repeater ID="LessonsRepeater" runat="server">
                        <ItemTemplate>
                            <tr>
                                <!-- Sort-order number cell (mono font) -->
                                <td style="font-family:var(--font-mono); font-size:12px; color:var(--muted);">
                                    <%# string.Format("{0:D2}", Eval("sort_order")) %>
                                </td>
                                <!-- Lesson title cell -->
                                <td style="font-weight:500;"><%# Eval("title") %></td>
                                <!-- Content preview cell (truncated to 100 chars) -->
                                <td style="color:var(--muted); font-size:13px; max-width:400px;">
                                    <%# Truncate(Eval("content") as string, 100) %>
                                </td>
                                <!-- Per-row action buttons: Edit, Delete -->
                                <td style="text-align:right;">
                                    <a href='<%# "LessonEdit.aspx?id=" + Eval("id") %>' class="btn btn-ghost btn-sm">Edit</a>
                                    <asp:LinkButton runat="server" Text="Delete"
                                        CssClass="btn btn-ghost btn-sm"
                                        style="color:var(--error);"
                                        CommandArgument='<%# Eval("id") %>'
                                        OnCommand="DeleteLesson_Command"
                                        OnClientClick="return confirm('Delete this lesson? This cannot be undone.');" />
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
            <!-- Empty state — shown only when this module has zero lessons -->
            <asp:Panel ID="EmptyPanel" runat="server" Visible="false" style="padding:40px; text-align:center; color:var(--muted);">
                No lessons yet. Click <strong>+ New lesson</strong> to add content for this module.
            </asp:Panel>
        </div>

    </div>
</asp:Content>
