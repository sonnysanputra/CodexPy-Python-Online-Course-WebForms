<%@ Page Title="My Progress" Language="C#" MasterPageFile="~/MasterPages/Site.Master" AutoEventWireup="true" CodeBehind="Progress.aspx.cs" Inherits="CodexPy.User.ProgressPage" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">My Progress — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">My Progress</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <!-- ========== PAGE HEADER (eyebrow + title + tagline) ========== -->
        <div style="margin-bottom:24px;">
            <div class="eyebrow">Your journey</div>
            <h1 class="h1" style="margin-top:4px;">Learning progress</h1>
            <p style="color:var(--muted); margin-top:4px; font-size:14px;">Track where you've been and what's next.</p>
        </div>

        <!-- ========== KPI CARDS (4-column grid of progress metrics) ========== -->
        <div style="display:grid; grid-template-columns:repeat(4, 1fr); gap:12px; margin-bottom:24px;">
            <!-- KPI 1: Total modules the user has started -->
            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:8px;">Modules started</div>
                <div style="font-size:26px; font-weight:600;"><asp:Literal ID="StartedLit" runat="server" Text="0" /></div>
            </div>
            <!-- KPI 2: Modules completed at 100% -->
            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:8px;">Modules completed</div>
                <div style="font-size:26px; font-weight:600;"><asp:Literal ID="CompletedLit" runat="server" Text="0" /></div>
            </div>
            <!-- KPI 3: Quizzes taken (all attempts) -->
            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:8px;">Quizzes taken</div>
                <div style="font-size:26px; font-weight:600;"><asp:Literal ID="QuizCountLit" runat="server" Text="0" /></div>
            </div>
            <!-- KPI 4: Average quiz score -->
            <div class="card" style="padding:18px;">
                <div style="font-size:12px; color:var(--muted); font-weight:500; margin-bottom:8px;">Average score</div>
                <div style="font-size:26px; font-weight:600;"><asp:Literal ID="AvgScoreLit" runat="server" Text="—" /></div>
            </div>
        </div>

        <!-- ========== TWO-COLUMN SECTION (Module progress list + Quiz history feed) ========== -->
        <div style="display:grid; grid-template-columns:1.4fr 1fr; gap:16px;">

            <!-- Left card: Per-module progress (title → ModuleDetail link + progress bar + status) -->
            <div class="card" style="padding:24px;">
                <h3 class="h3" style="margin-bottom:14px;">Module progress</h3>
                <asp:Repeater ID="ModulesRepeater" runat="server" OnItemDataBound="ModulesRepeater_ItemDataBound">
                    <ItemTemplate>
                        <div style="padding:12px 0; border-top:1px solid var(--hairline);">
                            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
                                <a href='<%# "ModuleDetail.aspx?id=" + Eval("id") %>' style="font-size:14px; font-weight:500; color:var(--ink);"><%# Eval("title") %></a>
                                <span style="font-size:12px; color:var(--muted); font-family:var(--font-mono);"><%# Eval("progress_percent") %>%</span>
                            </div>
                            <div class="progress-bar">
                                <span runat="server" id="FillSpan"></span>
                            </div>
                            <div style="font-size:11.5px; color:var(--muted-2); margin-top:5px;">
                                <%# Eval("status_label") %><%# Eval("last_accessed_label") %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <!-- Right card: Quiz history (chronological list with color-coded scores) -->
            <div class="card" style="padding:24px;">
                <h3 class="h3" style="margin-bottom:14px;">Quiz history</h3>
                <asp:Repeater ID="AttemptsRepeater" runat="server">
                    <ItemTemplate>
                        <div style="padding:12px 0; border-top:1px solid var(--hairline);">
                            <div style="display:flex; justify-content:space-between; align-items:start; gap:10px;">
                                <div>
                                    <div style="font-size:13.5px; font-weight:500;"><%# Eval("quiz_title") %></div>
                                    <div style="font-size:11.5px; color:var(--muted); margin-top:2px;"><%# Eval("module_title") %> · <%# Eval("when_label") %></div>
                                </div>
                                <strong style='color: <%# (int)Eval("score") >= 70 ? "var(--success)" : ((int)Eval("score") >= 50 ? "var(--warning)" : "var(--error)") %>;'>
                                    <%# Eval("score") %>%
                                </strong>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <!-- Empty state — shown if no quiz attempts exist yet -->
                <asp:Panel ID="EmptyAttemptsPanel" runat="server" Visible="false" style="padding:20px 0; text-align:center; color:var(--muted); font-size:13px;">
                    No quiz attempts yet.
                </asp:Panel>
            </div>

        </div>

    </div>
</asp:Content>
