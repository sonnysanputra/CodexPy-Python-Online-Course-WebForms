<%@ Page Title="Manage Users" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="Users.aspx.cs" Inherits="CodexPy.Admin.Users" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Manage Users — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Manage Users</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <!-- ========== PAGE HEADER (title + total/filtered count, "+ Add user" button) ========== -->
        <div style="display:flex; justify-content:space-between; align-items:end; margin-bottom:22px;">
            <div>
                <h1 class="h1">Manage users</h1>
                <p style="color:var(--muted); margin-top:4px; font-size:14px;">
                    <asp:Literal ID="TotalLit" runat="server" /> total · <asp:Literal ID="FilteredLit" runat="server" /> shown
                </p>
            </div>
            <a href="<%= ResolveUrl("~/Admin/UserEdit.aspx") %>" class="btn btn-primary">+ Add user</a>
        </div>

        <!-- ========== STATUS BANNER (shows success/error after delete or self-delete guard) ========== -->
        <asp:Panel ID="MessagePanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; font-size:13.5px;">
            <asp:Literal ID="MessageLit" runat="server" />
        </asp:Panel>

        <!-- ========== SEARCH + FILTER ROW (name/email search + segment + role + Apply button) ========== -->
        <div style="display:flex; gap:10px; margin-bottom:14px; align-items:center;">
            <asp:TextBox ID="SearchBox" runat="server" CssClass="input" placeholder="Search by name or email…" style="max-width:320px;" />
            <asp:DropDownList ID="SegmentFilter" runat="server" CssClass="input" style="max-width:200px;">
                <asp:ListItem Value="All" Text="All segments" />
                <asp:ListItem Value="School" Text="School" />
                <asp:ListItem Value="University" Text="University" />
                <asp:ListItem Value="Self-learner" Text="Self-learner" />
            </asp:DropDownList>
            <asp:DropDownList ID="RoleFilter" runat="server" CssClass="input" style="max-width:160px;">
                <asp:ListItem Value="All" Text="All roles" />
                <asp:ListItem Value="Student" Text="Student" />
                <asp:ListItem Value="Admin" Text="Admin" />
            </asp:DropDownList>
            <asp:Button ID="FilterButton" runat="server" Text="Apply" CssClass="btn btn-secondary" OnClick="FilterButton_Click" />
        </div>

        <!-- ========== USERS LIST TABLE (card-wrapped data table) ========== -->
        <div class="card" style="padding:0; overflow:hidden;">
            <table class="data-table">
                <!-- Table header row (column titles) -->
                <thead>
                    <tr>
                        <th>User</th>
                        <th>Role</th>
                        <th>Segment</th>
                        <th>Joined</th>
                        <th>Last active</th>
                        <th>Status</th>
                        <th style="text-align:right;">Actions</th>
                    </tr>
                </thead>
                <!-- Table body — one row per user via Repeater -->
                <tbody>
                    <asp:Repeater ID="UsersRepeater" runat="server">
                        <ItemTemplate>
                            <tr>
                                <!-- User identity cell (avatar initials + name + email) -->
                                <td>
                                    <div style="display:flex; align-items:center; gap:10px;">
                                        <div class="avatar" style="width:30px; height:30px; font-size:11px;"><%# GetInitials(Eval("name") as string) %></div>
                                        <div>
                                            <div style="font-weight:500;"><%# Eval("name") %></div>
                                            <div style="font-size:12px; color:var(--muted);"><%# Eval("email") %></div>
                                        </div>
                                    </div>
                                </td>
                                <!-- Role pill ("adv" class for Admin, plain "tag" for Student) -->
                                <td><span class='<%# Eval("role").ToString() == "Admin" ? "tag adv" : "tag" %>'><%# Eval("role") %></span></td>
                                <!-- Segment pill -->
                                <td><span class="tag"><%# Eval("segment") %></span></td>
                                <!-- Join date -->
                                <td style="color:var(--muted); font-size:13px;"><%# FormatDate(Eval("created_at")) %></td>
                                <!-- Last-active date -->
                                <td style="color:var(--muted); font-size:13px;"><%# FormatDate(Eval("last_active_at")) %></td>
                                <!-- Status indicator (green dot if active) -->
                                <td>
                                    <span style='font-size:12px; color: <%# Eval("status").ToString() == "active" ? "var(--success)" : "var(--muted)" %>'>
                                        ● <%# Eval("status") %>
                                    </span>
                                </td>
                                <!-- Per-row action buttons: Edit, Delete -->
                                <td style="text-align:right;">
                                    <a href='<%# "UserEdit.aspx?id=" + Eval("id") %>' class="btn btn-ghost btn-sm">Edit</a>
                                    <asp:LinkButton runat="server" Text="Delete"
                                        CssClass="btn btn-ghost btn-sm"
                                        style="color:var(--error);"
                                        CommandArgument='<%# Eval("id") %>'
                                        OnCommand="DeleteUser_Command"
                                        OnClientClick="return confirm('Delete this user? This cannot be undone.');" />
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
            <!-- Empty state — shown only when filters return zero rows -->
            <asp:Panel ID="EmptyPanel" runat="server" Visible="false" style="padding:40px; text-align:center; color:var(--muted);">
                No users match the current filters.
            </asp:Panel>
        </div>

    </div>
</asp:Content>
