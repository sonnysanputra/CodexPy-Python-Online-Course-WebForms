<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/MasterPages/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="CodexPy.User.Dashboard" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Dashboard — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Dashboard</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <!-- ========== WELCOME HEADER (personalized greeting with user's first name) ========== -->
        <div style="margin-bottom:24px;">
            <div class="eyebrow">Welcome back</div>
            <h1 class="h1" style="margin-top:4px;">Hi, <asp:Literal ID="UserFirstNameLit" runat="server" />!</h1>
            <p style="color:var(--muted); margin-top:4px; font-size:14px;"><asp:Literal ID="GreetingLit" runat="server" /></p>
        </div>

        <!-- ========== KPI CARDS (4-column grid of personal learning metrics) ========== -->
        <div style="display:grid; grid-template-columns:repeat(4, 1fr); gap:12px; margin-bottom:24px;">

            <!-- KPI 1: Modules started but not yet complete -->
            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:12px;">Modules in progress</div>
                <div style="font-size:26px; font-weight:600;"><asp:Literal ID="InProgressLit" runat="server" Text="0" /></div>
                <div style="font-size:11.5px; color:var(--muted); margin-top:2px;">Started but not finished</div>
            </div>

            <!-- KPI 2: Modules at 100% completion -->
            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:12px;">Modules completed</div>
                <div style="font-size:26px; font-weight:600;"><asp:Literal ID="CompletedLit" runat="server" Text="0" /></div>
                <div style="font-size:11.5px; color:var(--muted); margin-top:2px;">100% finished</div>
            </div>

            <!-- KPI 3: Total quiz attempts by this user -->
            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:12px;">Quiz attempts</div>
                <div style="font-size:26px; font-weight:600;"><asp:Literal ID="AttemptsLit" runat="server" Text="0" /></div>
                <div style="font-size:11.5px; color:var(--muted); margin-top:2px;">All time</div>
            </div>

            <!-- KPI 4: Average score across all the user's quiz attempts -->
            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:12px;">Average score</div>
                <div style="font-size:26px; font-weight:600;"><asp:Literal ID="AvgScoreLit" runat="server" Text="—" /></div>
                <div style="font-size:11.5px; color:var(--muted); margin-top:2px;">Across all quizzes</div>
            </div>

        </div>

        <!-- ========== TWO-COLUMN SECTION (Continue-learning panel + Recent quiz scores) ========== -->
        <div style="display:grid; grid-template-columns:1.5fr 1fr; gap:16px;">

            <!-- Left card: Continue learning (shows the most recent in-progress module) -->
            <div class="card" style="padding:28px;">
                <h2 class="h2" style="margin-bottom:8px;">Continue learning</h2>
                <p style="color:var(--muted); font-size:13.5px; margin-bottom:18px;">Pick up where you left off, or start a new module.</p>

                <!-- "Currently studying" block — shown only if the user has an in-progress module -->
                <asp:Panel ID="ContinuePanel" runat="server" Visible="false">
                    <div style="padding:18px; border:1px solid var(--border); border-radius:var(--r-md); display:flex; justify-content:space-between; align-items:center;">
                        <div style="flex:1;">
                            <div style="font-size:11px; color:var(--muted); font-weight:600; text-transform:uppercase; letter-spacing:.08em; margin-bottom:4px;">Currently studying</div>
                            <div style="font-size:17px; font-weight:600; margin-bottom:4px;"><asp:Literal ID="ContinueTitleLit" runat="server" /></div>
                            <div style="font-size:13px; color:var(--muted); margin-bottom:10px;"><asp:Literal ID="ContinueBlurbLit" runat="server" /></div>
                            <div style="display:flex; align-items:center; gap:10px;">
                                <div class="progress-bar" style="flex:1; max-width:200px;"><span runat="server" id="ContinueProgressFill"></span></div>
                                <span style="font-size:12px; color:var(--muted); font-family:var(--font-mono);"><asp:Literal ID="ContinuePercentLit" runat="server" Text="0" />%</span>
                            </div>
                        </div>
                        <asp:HyperLink ID="ContinueLink" runat="server" CssClass="btn btn-yellow" Text="Continue →" />
                    </div>
                </asp:Panel>

                <!-- Empty state — shown if the user hasn't started any module yet -->
                <asp:Panel ID="EmptyContinuePanel" runat="server" Visible="false" style="padding:24px; text-align:center; border:1px dashed var(--border); border-radius:var(--r-md); color:var(--muted);">
                    <p style="margin:0 0 12px; font-size:14px;">You haven't started any modules yet.</p>
                    <a href="<%= ResolveUrl("~/User/Modules.aspx") %>" class="btn btn-primary btn-sm">Browse modules →</a>
                </asp:Panel>
            </div>

            <!-- Right card: Recent quiz scores (color-coded green/yellow/red by score) -->
            <div class="card" style="padding:24px;">
                <h3 class="h3" style="margin-bottom:14px;">Recent quiz scores</h3>
                <asp:Repeater ID="RecentScoresRepeater" runat="server">
                    <ItemTemplate>
                        <div style="display:flex; justify-content:space-between; padding:10px 0; border-top:1px solid var(--hairline);">
                            <div>
                                <div style="font-size:13.5px; font-weight:500;"><%# Eval("quiz_title") %></div>
                                <div style="font-size:11.5px; color:var(--muted);"><%# FormatDate(Eval("completed_at")) %></div>
                            </div>
                            <strong style='color:<%# (int)Eval("score") >= 70 ? "var(--success)" : ((int)Eval("score") >= 50 ? "var(--warning)" : "var(--error)") %>;'>
                                <%# Eval("score") %>%
                            </strong>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="EmptyScoresPanel" runat="server" Visible="false" style="padding:14px 0; text-align:center; color:var(--muted); font-size:13px;">
                    No quiz attempts yet. Try one!
                </asp:Panel>
            </div>

        </div>

    </div>
</asp:Content>
