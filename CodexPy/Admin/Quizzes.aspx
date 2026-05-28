<%@ Page Title="Manage Quizzes" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="Quizzes.aspx.cs" Inherits="CodexPy.Admin.Quizzes" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Manage Quizzes — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Manage Quizzes</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <div style="display:flex; justify-content:space-between; align-items:end; margin-bottom:22px;">
            <div>
                <h1 class="h1">Manage quizzes</h1>
                <p style="color:var(--muted); margin-top:4px; font-size:14px;">
                    <asp:Literal ID="TotalLit" runat="server" /> quizzes
                </p>
            </div>
            <a href="<%= ResolveUrl("~/Admin/QuizEdit.aspx") %>" class="btn btn-primary">+ New quiz</a>
        </div>

        <asp:Panel ID="MessagePanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; font-size:13.5px;">
            <asp:Literal ID="MessageLit" runat="server" />
        </asp:Panel>

        <div class="card" style="padding:0; overflow:hidden;">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Quiz</th>
                        <th>Module</th>
                        <th>Questions</th>
                        <th>Time limit</th>
                        <th>Created</th>
                        <th style="text-align:right;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="QuizzesRepeater" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div style="font-weight:500;"><%# Eval("title") %></div>
                                    <div style="font-size:12px; color:var(--muted);"><%# Eval("description") %></div>
                                </td>
                                <td><span class="tag"><%# Eval("module_title") %></span></td>
                                <td><%# Eval("question_count") %></td>
                                <td style="color:var(--muted); font-size:13px;">
                                    <%# (int)Eval("time_limit_seconds") == 0 ? "No limit" : (((int)Eval("time_limit_seconds")) / 60) + " min" %>
                                </td>
                                <td style="color:var(--muted); font-size:13px;"><%# ((DateTime)Eval("created_at")).ToString("MMM d, yyyy") %></td>
                                <td style="text-align:right;">
                                    <a href='<%# "Questions.aspx?quizId=" + Eval("id") %>' class="btn btn-ghost btn-sm">Questions</a>

                                    <a href='<%# "QuizEdit.aspx?id=" + Eval("id") %>' class="btn btn-ghost btn-sm">Edit</a>
                                    <asp:LinkButton runat="server" Text="Delete"
                                        CssClass="btn btn-ghost btn-sm"
                                        style="color:var(--error);"
                                        CommandArgument='<%# Eval("id") %>'
                                        OnCommand="DeleteQuiz_Command"
                                        OnClientClick="return confirm('Delete this quiz and all its questions? This cannot be undone.');" />
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
            <asp:Panel ID="EmptyPanel" runat="server" Visible="false" style="padding:40px; text-align:center; color:var(--muted);">
                No quizzes yet. Click <strong>+ New quiz</strong> to create one.
            </asp:Panel>
        </div>

    </div>
</asp:Content>
