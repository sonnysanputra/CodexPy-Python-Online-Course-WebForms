<%@ Page Title="Module" Language="C#" MasterPageFile="~/MasterPages/Site.Master" AutoEventWireup="true" CodeBehind="ModuleDetail.aspx.cs" Inherits="CodexPy.User.ModuleDetail" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server"><asp:Literal ID="PageTitleLit" runat="server" /> — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server"><asp:Literal ID="CrumbLit" runat="server" /></asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto; max-width:900px; margin:0 auto; width:100%;">

        <div style="margin-bottom:8px;">
            <a href="<%= ResolveUrl("~/User/Modules.aspx") %>" style="font-size:13px; color:var(--py-blue);">← Back to all modules</a>
        </div>

        <!-- Status messages -->
        <asp:Panel ID="MessagePanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; background:rgba(16,185,129,0.1); border:1px solid var(--success); color:var(--success); font-size:13.5px;">
            <asp:Literal ID="MessageLit" runat="server" />
        </asp:Panel>

        <!-- Header -->
        <div style="margin-bottom:24px;">
            <div style="display:flex; align-items:center; gap:14px; margin-bottom:14px;">
                <div runat="server" id="IconBox" style='width:56px; height:56px; border-radius:12px; display:grid; place-items:center; font-weight:700; font-size:24px;'>
                    <asp:Literal ID="IconInitialLit" runat="server" />
                </div>
                <div>
                    <div class="eyebrow"><asp:Literal ID="DifficultyLit" runat="server" /> · <asp:Literal ID="DurationLit" runat="server" /></div>
                    <h1 class="h1" style="margin-top:2px;"><asp:Literal ID="TitleLit" runat="server" /></h1>
                </div>
            </div>
            <p style="color:var(--muted); font-size:15px; line-height:1.55; margin:0;"><asp:Literal ID="BlurbLit" runat="server" /></p>
        </div>

        <!-- Progress bar -->
        <div class="card" style="padding:18px 22px; margin-bottom:24px;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                <div style="font-size:12px; color:var(--muted); font-weight:600; text-transform:uppercase; letter-spacing:.08em;">Your progress</div>
                <strong style="font-size:18px; font-family:var(--font-mono);"><asp:Literal ID="ProgressPercentLit" runat="server" Text="0" />%</strong>
            </div>
            <div class="progress-bar"><span runat="server" id="ProgressFill"></span></div>
            <div style="margin-top:14px; display:flex; justify-content:flex-end;">
                <asp:Button ID="MarkCompleteButton" runat="server" Text="Mark module complete" CssClass="btn btn-secondary btn-sm" OnClick="MarkCompleteButton_Click" />
            </div>
        </div>

        <!-- Lessons -->
        <h2 class="h2" style="margin-bottom:14px;">Lessons</h2>
        <asp:Repeater ID="LessonsRepeater" runat="server">
            <ItemTemplate>
                <div class="card" style="padding:24px; margin-bottom:14px;">
                    <div style="display:flex; gap:14px; margin-bottom:12px; align-items:start;">
                        <div style="width:32px; height:32px; border-radius:50%; background:var(--bg-sunk); color:var(--ink-2); display:grid; place-items:center; font-weight:600; font-size:13px; flex-shrink:0;">
                            <%# Container.ItemIndex + 1 %>
                        </div>
                        <h3 class="h3" style="margin-top:4px;"><%# Eval("title") %></h3>
                    </div>
                    <div style="padding-left:46px; color:var(--ink-2); font-size:14.5px; line-height:1.7; white-space:pre-wrap;">
                        <%# Eval("content") %>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="EmptyLessonsPanel" runat="server" Visible="false" class="card" style="padding:40px; text-align:center; color:var(--muted);">
            No lessons have been added to this module yet. Check back later!
        </asp:Panel>

        <!-- Quizzes for this module -->
        <h2 class="h2" style="margin-top:32px; margin-bottom:14px;">Quizzes</h2>
        <asp:Repeater ID="QuizzesRepeater" runat="server">
            <ItemTemplate>
                <div class="card" style="padding:22px; margin-bottom:12px; display:flex; justify-content:space-between; align-items:center;">
                    <div>
                        <div style="font-size:15px; font-weight:600;"><%# Eval("title") %></div>
                        <div style="font-size:12.5px; color:var(--muted); margin-top:4px;">
                            <%# Eval("question_count") %> questions
                            <%# (int)Eval("time_limit_seconds") > 0 ? " · " + ((int)Eval("time_limit_seconds")/60) + " min" : "" %>
                        </div>
                    </div>
                    <a href='<%# "Quiz.aspx?id=" + Eval("id") %>' class="btn btn-yellow">Take quiz →</a>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="EmptyQuizzesPanel" runat="server" Visible="false" class="card" style="padding:24px; text-align:center; color:var(--muted); font-size:13.5px;">
            No quizzes available for this module yet.
        </asp:Panel>

    </div>
</asp:Content>
