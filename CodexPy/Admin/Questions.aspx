<%@ Page Title="Quiz Questions" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="Questions.aspx.cs" Inherits="CodexPy.Admin.Questions" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Quiz Questions — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Questions</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <div style="margin-bottom:8px;">
            <a href="<%= ResolveUrl("~/Admin/Quizzes.aspx") %>" style="font-size:13px; color:var(--py-blue);">← Back to quizzes</a>
        </div>

        <div style="display:flex; justify-content:space-between; align-items:end; margin-bottom:22px;">
            <div>
                <div class="eyebrow">Quiz questions</div>
                <h1 class="h1" style="margin-top:4px;">"<asp:Literal ID="QuizTitleLit" runat="server" />"</h1>
                <p style="color:var(--muted); margin-top:4px; font-size:14px;">
                    <asp:Literal ID="TotalLit" runat="server" /> questions
                </p>
            </div>
            <asp:HyperLink ID="AddQuestionLink" runat="server" CssClass="btn btn-primary" Text="+ New question" />
        </div>

        <asp:Panel ID="MessagePanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; font-size:13.5px;">
            <asp:Literal ID="MessageLit" runat="server" />
        </asp:Panel>

        <div class="card" style="padding:0; overflow:hidden;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width:60px;">#</th>
                        <th>Question</th>
                        <th>Correct answer</th>
                        <th>Points</th>
                        <th style="text-align:right;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="QuestionsRepeater" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="font-family:var(--font-mono); font-size:12px; color:var(--muted);">
                                    Q<%# Container.ItemIndex + 1 %>
                                </td>
                                <td style="max-width:480px;">
                                    <div style="font-size:13.5px;"><%# Truncate(Eval("prompt") as string, 120) %></div>
                                </td>
                                <td style="color:var(--success); font-size:13px; font-weight:500;">
                                    <%# Truncate(Eval("correct_text") as string, 60) %>
                                </td>
                                <td><%# Eval("points") %></td>
                                <td style="text-align:right;">
                                    <a href='<%# "QuestionEdit.aspx?id=" + Eval("id") %>' class="btn btn-ghost btn-sm">Edit</a>
                                    <asp:LinkButton runat="server" Text="Delete"
                                        CssClass="btn btn-ghost btn-sm"
                                        style="color:var(--error);"
                                        CommandArgument='<%# Eval("id") %>'
                                        OnCommand="DeleteQuestion_Command"
                                        OnClientClick="return confirm('Delete this question?');" />
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
            <asp:Panel ID="EmptyPanel" runat="server" Visible="false" style="padding:40px; text-align:center; color:var(--muted);">
                No questions yet. Click <strong>+ New question</strong> to add an MCQ.
            </asp:Panel>
        </div>

    </div>
</asp:Content>
