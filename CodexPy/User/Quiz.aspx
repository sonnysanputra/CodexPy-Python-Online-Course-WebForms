<%@ Page Title="Quiz" Language="C#" MasterPageFile="~/MasterPages/Site.Master" AutoEventWireup="true" CodeBehind="Quiz.aspx.cs" Inherits="CodexPy.User.Quiz" ValidateRequest="false" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server"><asp:Literal ID="PageTitleLit" runat="server" Text="Quiz" /> — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Take quiz</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; max-width:780px; margin:0 auto; width:100%;">

        <!-- ========== BREADCRUMB (link back to parent module page) ========== -->
        <div style="margin-bottom:8px;">
            <asp:HyperLink ID="BackToModuleLink" runat="server" style="font-size:13px; color:var(--py-blue);" Text="← Back to module" />
        </div>

        <!-- ========== PAGE HEADER (quiz title + question count) ========== -->
        <div style="margin-bottom:24px;">
            <div class="eyebrow">Quiz</div>
            <h1 class="h1" style="margin-top:4px;"><asp:Literal ID="QuizTitleLit" runat="server" /></h1>
            <p style="color:var(--muted); font-size:14px; margin-top:4px;">
                <asp:Literal ID="QuestionCountLit" runat="server" /> questions
            </p>
        </div>

        <!-- ========== RESULT PANEL (large score display — only visible after submit) ========== -->
        <asp:Panel ID="ResultPanel" runat="server" Visible="false" style="margin-bottom:24px;">
            <div class="card" style="padding:32px; text-align:center;">
                <div class="eyebrow">Your score</div>
                <div style="font-size:60px; font-weight:600; margin:14px 0; color:var(--py-blue-d);">
                    <asp:Literal ID="ScoreLit" runat="server" />%
                </div>
                <p style="color:var(--muted); font-size:14px;">
                    <asp:Literal ID="ScoreSubLit" runat="server" />
                </p>
                <div style="margin-top:18px; display:flex; justify-content:center; gap:10px;">
                    <asp:HyperLink ID="ResultModuleLink" runat="server" CssClass="btn btn-primary" Text="← Back to module" />
                    <asp:HyperLink ID="ResultDashLink" runat="server" CssClass="btn btn-secondary" Text="Dashboard" NavigateUrl="~/User/Dashboard.aspx" />
                </div>
            </div>
        </asp:Panel>

        <!-- ========== QUESTION CARDS (one card per question with radio options) ========== -->
        <asp:Repeater ID="QuestionsRepeater" runat="server" OnItemDataBound="QuestionsRepeater_ItemDataBound">
            <ItemTemplate>
                <div class="card" style="padding:24px; margin-bottom:14px;">
                    <!-- Question header: numbered circle + prompt text -->
                    <div style="display:flex; gap:14px; margin-bottom:12px; align-items:start;">
                        <div style="width:32px; height:32px; border-radius:50%; background:var(--bg-sunk); color:var(--ink-2); display:grid; place-items:center; font-weight:600; font-size:13px; flex-shrink:0;">
                            <%# Container.ItemIndex + 1 %>
                        </div>
                        <div style="flex:1; font-size:15px; line-height:1.55;"><%# Eval("prompt") %></div>
                    </div>
                    <!-- Hidden field carrying the question's DB id for grading on postback -->
                    <asp:HiddenField runat="server" ID="QuestionIdField" Value='<%# Eval("id") %>' />
                    <div style="padding-left:46px;">
                        <!-- Options radio list (populated in ItemDataBound from the question's JSON options) -->
                        <asp:RadioButtonList runat="server" ID="OptionsList" RepeatLayout="Flow" />
                        <!-- Feedback panel: shown after submit with correct/incorrect verdict + explanation -->
                        <asp:Panel runat="server" ID="FeedbackPanel" Visible="false" style="margin-top:12px; padding:12px 14px; border-radius:8px; font-size:13.5px;">
                            <strong style="display:block; margin-bottom:4px;"><asp:Literal runat="server" ID="VerdictLit" /></strong>
                            <asp:Literal runat="server" ID="ExplanationLit" />
                        </asp:Panel>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <!-- Empty state — shown if the quiz has no questions yet -->
        <asp:Panel ID="EmptyPanel" runat="server" Visible="false" CssClass="card" style="padding:40px; text-align:center; color:var(--muted);">
            This quiz doesn't have any questions yet. Ask an admin to add some.
        </asp:Panel>

        <!-- ========== SUBMIT BUTTON (right-aligned; hidden after submit) ========== -->
        <asp:Panel ID="SubmitPanel" runat="server" style="display:flex; justify-content:flex-end; margin-top:18px;">
            <asp:Button ID="SubmitButton" runat="server" Text="Submit quiz" CssClass="btn btn-yellow btn-lg" OnClick="SubmitButton_Click" />
        </asp:Panel>

    </div>
</asp:Content>
