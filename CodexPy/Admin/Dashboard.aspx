<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="CodexPy.Admin.Dashboard" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Admin Dashboard — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Overview</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <div style="padding:28px 32px; overflow-y:auto;">

        <!-- ========== PAGE HEADER (eyebrow label + title + current date) ========== -->
        <div style="display:flex; justify-content:space-between; align-items:end; margin-bottom:22px;">
            <div>
                <div class="eyebrow" style="margin-bottom:4px;">System overview</div>
                <h1 class="h1">Admin dashboard</h1>
                <p style="color:var(--muted); margin-top:4px; font-size:14px;">
                    <asp:Literal ID="DateLiteral" runat="server" />
                </p>
            </div>
        </div>

        <!-- ========== KPI CARDS (4-column grid of headline metrics) ========== -->
        <div style="display:grid; grid-template-columns:repeat(4, 1fr); gap:12px; margin-bottom:18px;">

            <!-- KPI 1: Total registered learners -->
            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:12px;">Total learners</div>
                <div style="font-size:26px; font-weight:600; letter-spacing:-0.02em;">
                    <asp:Literal ID="TotalUsersLit" runat="server" Text="0" />
                </div>
                <div style="font-size:11.5px; color:var(--muted); margin-top:2px;">Registered accounts</div>
            </div>

            <!-- KPI 2: Active learners in the last 7 days -->
            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:12px;">Active this week</div>
                <div style="font-size:26px; font-weight:600; letter-spacing:-0.02em;">
                    <asp:Literal ID="ActiveUsersLit" runat="server" Text="0" />
                </div>
                <div style="font-size:11.5px; color:var(--muted); margin-top:2px;">Last 7 days</div>
            </div>

            <!-- KPI 3: Total modules created -->
            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:12px;">Total modules</div>
                <div style="font-size:26px; font-weight:600; letter-spacing:-0.02em;">
                    <asp:Literal ID="TotalModulesLit" runat="server" Text="0" />
                </div>
                <div style="font-size:11.5px; color:var(--muted); margin-top:2px;">Published content</div>
            </div>

            <!-- KPI 4: All-time quiz attempts -->
            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:12px;">Quiz attempts</div>
                <div style="font-size:26px; font-weight:600; letter-spacing:-0.02em;">
                    <asp:Literal ID="QuizAttemptsLit" runat="server" Text="0" />
                </div>
                <div style="font-size:11.5px; color:var(--muted); margin-top:2px;">All time</div>
            </div>

        </div>

        <!-- ========== TWO-COLUMN SECTION (Modules list + Recent users feed) ========== -->
        <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px;">

            <!-- Left card: Modules list with difficulty tags -->
            <div class="card" style="padding:24px;">
                <h3 class="h3" style="margin-bottom:14px;">Modules</h3>
                <asp:Repeater ID="ModulesRepeater" runat="server">
                    <ItemTemplate>
                        <div style="display:grid; grid-template-columns:1fr auto; gap:10px; padding:10px 0; border-top:1px solid var(--hairline);">
                            <div>
                                <div style="font-size:13.5px; font-weight:500;"><%# Eval("title") %></div>
                                <div style="font-size:11.5px; color:var(--muted); margin-top:2px;"><%# Eval("difficulty") %> · <%# Eval("duration") %></div>
                            </div>
                            <div style="text-align:right; font-size:12px; color:var(--muted);">
                                <span class='<%# "tag " + GetDifficultyClass(Eval("difficulty") as string) %>'><%# Eval("difficulty") %></span>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <!-- Right card: Recent registrations feed (with "view all" footer link) -->
            <div class="card" style="padding:24px;">
                <h3 class="h3" style="margin-bottom:14px;">Recent registrations</h3>
                <asp:Repeater ID="RecentUsersRepeater" runat="server">
                    <ItemTemplate>
                        <div style="display:flex; justify-content:space-between; align-items:center; padding:10px 0; border-top:1px solid var(--hairline); font-size:13.5px;">
                            <div>
                                <div style="font-weight:500;"><%# Eval("name") %></div>
                                <div style="font-size:12px; color:var(--muted);"><%# Eval("email") %></div>
                            </div>
                            <span class="tag"><%# Eval("segment") %></span>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <div style="padding:10px 0; border-top:1px solid var(--hairline);">
                            <a href="<%= ResolveUrl("~/Admin/Users.aspx") %>" style="font-size:13px; color:var(--py-blue);">View all users →</a>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>
            </div>

        </div>

    </div>
</asp:Content>
