<%@ Page Title="Reports" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="CodexPy.Admin.Reports" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Reports — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Reports</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <!-- Header -->
        <div style="margin-bottom:22px;">
            <div class="eyebrow">Analytics</div>
            <h1 class="h1">Reports</h1>
            <p style="color:var(--muted); margin-top:4px; font-size:14px;">Cohort engagement, content performance, and user progress.</p>
        </div>

        <!-- Top KPI cards -->
        <div style="display:grid; grid-template-columns:repeat(4, 1fr); gap:12px; margin-bottom:18px;">

            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:12px;">Total learners</div>
                <div style="font-size:26px; font-weight:600;"><asp:Literal ID="TotalUsersLit" runat="server" Text="0" /></div>
                <div style="font-size:11.5px; color:var(--muted); margin-top:2px;">Registered accounts</div>
            </div>

            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:12px;">Average quiz score</div>
                <div style="font-size:26px; font-weight:600;"><asp:Literal ID="AvgScoreLit" runat="server" Text="—" /></div>
                <div style="font-size:11.5px; color:var(--muted); margin-top:2px;">Across all attempts</div>
            </div>

            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:12px;">Total quiz attempts</div>
                <div style="font-size:26px; font-weight:600;"><asp:Literal ID="TotalAttemptsLit" runat="server" Text="0" /></div>
                <div style="font-size:11.5px; color:var(--muted); margin-top:2px;">All time</div>
            </div>

            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:12px;">Active modules</div>
                <div style="font-size:26px; font-weight:600;"><asp:Literal ID="ActiveModulesLit" runat="server" Text="0" /></div>
                <div style="font-size:11.5px; color:var(--muted); margin-top:2px;">Published</div>
            </div>

        </div>

        <!-- Audience by segment + Module engagement -->
        <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-bottom:16px;">

            <!-- Audience by segment -->
            <div class="card" style="padding:24px;">
                <h3 class="h3" style="margin-bottom:14px;">Audience by segment</h3>
                <asp:Repeater ID="SegmentRepeater" runat="server">
                    <ItemTemplate>
                        <div style="padding:10px 0; border-top:1px solid var(--hairline);">
                            <div style="display:flex; justify-content:space-between; font-size:13.5px; margin-bottom:6px;">
                                <span><%# Eval("segment") %></span>
                                <strong><%# Eval("user_count") %> · <%# Eval("percentage") %>%</strong>
                            </div>
                            <div class="progress-bar"><span style='width:<%# Eval("percentage") %>%;'></span></div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="EmptySegmentPanel" runat="server" Visible="false" style="padding:20px 0; text-align:center; color:var(--muted); font-size:13px;">
                    No users registered yet.
                </asp:Panel>
            </div>

            <!-- Module engagement -->
            <div class="card" style="padding:24px;">
                <h3 class="h3" style="margin-bottom:14px;">Module engagement</h3>
                <asp:Repeater ID="ModuleEngagementRepeater" runat="server">
                    <ItemTemplate>
                        <div style="padding:10px 0; border-top:1px solid var(--hairline);">
                            <div style="display:flex; justify-content:space-between; font-size:13.5px;">
                                <div>
                                    <div style="font-weight:500;"><%# Eval("title") %></div>
                                    <div style="font-size:11.5px; color:var(--muted);"><%# Eval("difficulty") %></div>
                                </div>
                                <div style="text-align:right;">
                                    <div style="font-weight:600;"><%# Eval("enrolled_count") %></div>
                                    <div style="font-size:11.5px; color:var(--muted);">learners</div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

        </div>

        <!-- Quiz performance + Recent attempts -->
        <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px;">

            <!-- Quiz performance -->
            <div class="card" style="padding:24px;">
                <h3 class="h3" style="margin-bottom:14px;">Quiz performance</h3>
                <asp:Repeater ID="QuizPerfRepeater" runat="server">
                    <ItemTemplate>
                        <div style="padding:10px 0; border-top:1px solid var(--hairline);">
                            <div style="display:flex; justify-content:space-between; font-size:13.5px; margin-bottom:6px;">
                                <span><%# Eval("title") %></span>
                                <strong style='color: <%# (decimal)Eval("avg_score") >= 70 ? "var(--success)" : ((decimal)Eval("avg_score") >= 50 ? "var(--warning)" : "var(--error)") %>;'>
                                    <%# Math.Round((decimal)Eval("avg_score"), 0) %>%
                                </strong>
                            </div>
                            <div style="font-size:11.5px; color:var(--muted);">
                                <%# Eval("attempt_count") %> attempts
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="EmptyQuizPanel" runat="server" Visible="false" style="padding:20px 0; text-align:center; color:var(--muted); font-size:13px;">
                    No quiz attempts yet.
                </asp:Panel>
            </div>

            <!-- Recent registrations -->
            <div class="card" style="padding:24px;">
                <h3 class="h3" style="margin-bottom:14px;">User growth (last 30 days)</h3>
                <asp:Repeater ID="GrowthRepeater" runat="server">
                    <ItemTemplate>
                        <div style="display:flex; justify-content:space-between; padding:10px 0; border-top:1px solid var(--hairline); font-size:13.5px;">
                            <span><%# ((DateTime)Eval("registration_date")).ToString("MMM d, yyyy") %></span>
                            <strong><%# Eval("new_users") %> new</strong>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="EmptyGrowthPanel" runat="server" Visible="false" style="padding:20px 0; text-align:center; color:var(--muted); font-size:13px;">
                    No registrations in the last 30 days.
                </asp:Panel>
            </div>

        </div>

    </div>
</asp:Content>
