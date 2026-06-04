<%@ Page Title="Forum" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="Forum.aspx.cs" Inherits="CodexPy.Admin.Forum" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Forum — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Forum</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <!-- ========== PAGE HEADER (title + total count + unread badge) ========== -->
        <div style="margin-bottom:22px;">
            <div class="eyebrow">Community feedback</div>
            <h1 class="h1">Forum</h1>
            <p style="color:var(--muted); margin-top:4px; font-size:14px;">
                <asp:Literal ID="TotalLit" runat="server" /> comments &middot;
                <asp:Literal ID="UnreadLit" runat="server" /> unread
            </p>
        </div>

        <!-- ========== STATUS BANNER (shows success/error after admin actions) ========== -->
        <asp:Panel ID="MessagePanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; font-size:13.5px;">
            <asp:Literal ID="MessageLit" runat="server" />
        </asp:Panel>

        <!-- ========== FILTER DROPDOWN (All / Unread / Read / Replied) ========== -->
        <div style="margin-bottom:18px;">
            <asp:DropDownList ID="FilterList" runat="server" CssClass="input" AutoPostBack="true"
                OnSelectedIndexChanged="FilterList_Changed" style="max-width:240px;">
                <asp:ListItem Value="All" Text="All comments" />
                <asp:ListItem Value="Unread" Text="Unread only" />
                <asp:ListItem Value="Read" Text="Read only" />
                <asp:ListItem Value="Replied" Text="Replied only" />
            </asp:DropDownList>
        </div>

        <!-- ========== COMMENTS LIST (one card per top-level comment with nested replies) ========== -->
        <asp:Repeater ID="CommentsRepeater" runat="server">
            <ItemTemplate>
                <div class="card" style="padding:20px; margin-bottom:12px;">
                    <!-- One flex row: avatar (fixed-width) + content column (flex:1) -->
                    <div style="display:flex; gap:14px; align-items:flex-start; text-align:left;">

                        <!-- Avatar column -->
                        <div class="avatar" style="width:38px; height:38px; flex-shrink:0; font-size:12px;">
                            <%# Eval("Initials") %>
                        </div>

                        <!-- Content column — everything inside aligns naturally to the right of the avatar -->
                        <div style="flex:1; min-width:0; text-align:left;">
                            <!-- Identity row: name + segment + email -->
                            <div style="display:flex; flex-wrap:wrap; gap:8px; align-items:center;">
                                <strong style="font-size:14px;"><%# Eval("Name") %></strong>
                                <span class="tag" style="font-size:11px;"><%# Eval("Segment") %></span>
                                <span style="font-size:12px; color:var(--muted);"><%# Eval("Email") %></span>
                            </div>

                            <!-- Module + timestamp + read/unread + replied status -->
                            <div style="font-size:11.5px; color:var(--muted); margin-top:2px;">
                                <strong style="color:var(--py-blue);"><%# Eval("ModuleTitle") %></strong>
                                &middot; <%# Eval("WhenLabel") %>
                                <%# (bool)Eval("IsRead") ? "&middot; <span style='color:var(--success);'>Read</span>" : "&middot; <span style='color:var(--warning);'>Unread</span>" %>
                                <%# ((System.Collections.IList)Eval("Replies")).Count > 0 ? "&middot; <span style='color:var(--py-blue);'>Replied</span>" : "" %>
                            </div>

                            <!-- Comment body (Eval on same line as opening tag — pre-wrap would render markup indentation as visible space) -->
                            <div style="font-size:14px; line-height:1.55; white-space:pre-wrap; margin-top:10px;"><%# Eval("Body") %></div>

                            <!-- Nested admin replies (if any) -->
                            <asp:Repeater runat="server" DataSource='<%# Eval("Replies") %>'>
                                <ItemTemplate>
                                    <div style="margin-top:12px; padding:12px 14px; background:var(--bg-sunk); border-radius:8px;">
                                        <div style="display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin-bottom:4px;">
                                            <strong style="font-size:13px;"><%# Eval("Name") %></strong>
                                            <span class="tag adv" style="font-size:11px;">Admin</span>
                                            <span style="font-size:11.5px; color:var(--muted);">&middot; <%# Eval("WhenLabel") %></span>
                                        </div>
                                        <div style="font-size:13.5px; line-height:1.5; white-space:pre-wrap;"><%# Eval("Body") %></div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>

                            <!-- Action buttons -->
                            <div style="display:flex; gap:8px; margin-top:12px; flex-wrap:wrap;">
                                <asp:LinkButton runat="server" Text="Mark as read"
                                    CssClass="btn btn-ghost btn-sm"
                                    CommandArgument='<%# Eval("Id") %>'
                                    OnCommand="MarkRead_Command"
                                    Visible='<%# !(bool)Eval("IsRead") %>' />
                                <asp:LinkButton runat="server" Text="Mark as unread"
                                    CssClass="btn btn-ghost btn-sm"
                                    CommandArgument='<%# Eval("Id") %>'
                                    OnCommand="MarkUnread_Command"
                                    Visible='<%# (bool)Eval("IsRead") %>' />
                                <asp:LinkButton runat="server" Text="Reply"
                                    CssClass="btn btn-ghost btn-sm"
                                    CommandArgument='<%# Eval("Id") %>'
                                    OnCommand="ToggleReplyForm_Command" />
                                <asp:LinkButton runat="server" Text="Delete"
                                    CssClass="btn btn-ghost btn-sm"
                                    style="color:var(--error);"
                                    CommandArgument='<%# Eval("Id") %>'
                                    OnCommand="DeleteComment_Command"
                                    OnClientClick="return confirm('Delete this comment? Any replies will also be removed.');" />
                            </div>

                            <!-- Inline reply form (only visible when this thread is the open one) -->
                            <asp:Panel runat="server" ID="ReplyPanel" Visible='<%# Eval("ShowReplyForm") %>'
                                style="margin-top:12px;">
                                <asp:TextBox runat="server" ID="ReplyBox" CssClass="input" TextMode="MultiLine" Rows="3"
                                    placeholder="Write your reply..." />
                                <div style="display:flex; justify-content:flex-end; margin-top:8px; gap:8px;">
                                    <asp:LinkButton runat="server" Text="Cancel"
                                        CssClass="btn btn-ghost btn-sm"
                                        CommandArgument='<%# Eval("Id") %>'
                                        OnCommand="CancelReply_Command" />
                                    <asp:Button runat="server" Text="Post reply"
                                        CssClass="btn btn-yellow btn-sm"
                                        CommandArgument='<%# Eval("Id") %>'
                                        OnCommand="PostReply_Command" />
                                </div>
                            </asp:Panel>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <!-- Empty state — shown when filter returns zero comments -->
        <asp:Panel ID="EmptyPanel" runat="server" Visible="false" class="card" style="padding:40px; text-align:center; color:var(--muted);">
            No comments match the current filter.
        </asp:Panel>

    </div>
</asp:Content>
