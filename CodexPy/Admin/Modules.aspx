<%@ Page Title="Manage Modules" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="Modules.aspx.cs" Inherits="CodexPy.Admin.Modules" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Manage Modules — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Manage Modules</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <!-- ========== PAGE HEADER (title on the left, primary action button on the right) ========== -->
        <div style="display:flex; justify-content:space-between; align-items:end; margin-bottom:22px;">
            <div>
                <h1 class="h1">Manage modules</h1>
                <p style="color:var(--muted); margin-top:4px; font-size:14px;">
                    <asp:Literal ID="TotalLit" runat="server" /> total modules
                </p>
            </div>
            <a href="<%= ResolveUrl("~/Admin/ModuleEdit.aspx") %>" class="btn btn-primary">+ New module</a>
        </div>

        <!-- ========== STATUS BANNER (shows success/error message after a delete) ========== -->
        <asp:Panel ID="MessagePanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; font-size:13.5px;">
            <asp:Literal ID="MessageLit" runat="server" />
        </asp:Panel>

        <!-- ========== MODULE LIST TABLE (card-wrapped data table) ========== -->
        <div class="card" style="padding:0; overflow:hidden;">
            <table class="data-table">
                <!-- Table header row (column titles) -->
                <thead>
                    <tr>
                        <th style="width:60px;">#</th>
                        <th>Title</th>
                        <th>Difficulty</th>
                        <th>Duration</th>
                        <th>Status</th>
                        <th style="text-align:right;">Actions</th>
                    </tr>
                </thead>
                <!-- Table body — one row per module via Repeater -->
                <tbody>
                    <asp:Repeater ID="ModulesRepeater" runat="server">
                        <ItemTemplate>
                            <tr>
                                <!-- Sort-order number cell (mono font) -->
                                <td style="font-family:var(--font-mono); font-size:12px; color:var(--muted);">
                                    <%# string.Format("{0:D2}", Eval("sort_order")) %>
                                </td>
                                <!-- Module identity cell (color-coded thumbnail + title + blurb) -->
                                <td>
                                    <div style="display:flex; align-items:center; gap:12px;">
                                        <div style='width:36px; height:36px; border-radius:8px; background:<%# Eval("color") %>22; color:<%# Eval("color") %>; display:grid; place-items:center; font-weight:600; font-size:14px;'>
                                            <%# Eval("title").ToString().Substring(0, 1) %>
                                        </div>
                                        <div>
                                            <div style="font-size:14.5px; font-weight:500;"><%# Eval("title") %></div>
                                            <div style="font-size:12px; color:var(--muted);"><%# Eval("blurb") %></div>
                                        </div>
                                    </div>
                                </td>
                                <!-- Difficulty pill (color depends on level) -->
                                <td><span class='<%# "tag " + GetDifficultyClass(Eval("difficulty") as string) %>'><%# Eval("difficulty") %></span></td>
                                <!-- Duration cell -->
                                <td style="color:var(--muted); font-size:13px;"><%# Eval("duration") %></td>
                                <!-- Published/Draft status indicator (green dot if published) -->
                                <td>
                                    <span style='font-size:12px; color: <%# (bool)Eval("published") ? "var(--success)" : "var(--muted)" %>'>
                                        ● <%# (bool)Eval("published") ? "Published" : "Draft" %>
                                    </span>
                                </td>
                                <!-- Per-row action buttons: Lessons (nested CRUD), Edit, Delete -->
                                <td style="text-align:right;">
                                    <a href='<%# "Lessons.aspx?moduleId=" + Eval("id") %>' class="btn btn-ghost btn-sm">Lessons</a>

                                    <a href='<%# "ModuleEdit.aspx?id=" + Eval("id") %>' class="btn btn-ghost btn-sm">Edit</a>
                                    <asp:LinkButton runat="server" Text="Delete"
                                        CssClass="btn btn-ghost btn-sm"
                                        style="color:var(--error);"
                                        CommandArgument='<%# Eval("id") %>'
                                        OnCommand="DeleteModule_Command"
                                        OnClientClick="return confirm('Delete this module? Lessons and quizzes inside it will also be deleted.');" />
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
            <!-- Empty state — shown only when zero modules exist -->
            <asp:Panel ID="EmptyPanel" runat="server" Visible="false" style="padding:40px; text-align:center; color:var(--muted);">
                No modules yet. Click <strong>+ New module</strong> to add one.
            </asp:Panel>
        </div>

    </div>
</asp:Content>
