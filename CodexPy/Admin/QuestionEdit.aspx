<%@ Page Title="Question Editor" Language="C#" MasterPageFile="~/MasterPages/Admin.Master" AutoEventWireup="true" CodeBehind="QuestionEdit.aspx.cs" Inherits="CodexPy.Admin.QuestionEdit" ValidateRequest="false" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">Question editor — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">Question editor</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <div style="margin-bottom:8px;">
            <asp:HyperLink ID="BackLink" runat="server" style="font-size:13px; color:var(--py-blue);" Text="← Back to questions" />
        </div>

        <div style="margin-bottom:22px;">
            <div class="eyebrow"><asp:Literal ID="ModeLit" runat="server" Text="New question" /></div>
            <h1 class="h1" style="margin-top:4px;">Multiple-choice question</h1>
        </div>

        <asp:Panel ID="ErrorPanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; background:rgba(239,68,68,0.08); border:1px solid var(--error); color:var(--error); font-size:13.5px;">
            <asp:Literal ID="ErrorLit" runat="server" />
        </asp:Panel>

        <div class="card" style="padding:32px; max-width:800px;">

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Question prompt</div>
                <asp:TextBox ID="PromptBox" runat="server" CssClass="input" TextMode="MultiLine" Rows="3"
                    placeholder="e.g. What is the output of print(type(3.14))?" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="PromptBox"
                    CssClass="validation-error" ErrorMessage="Question prompt is required" Display="Dynamic" />
            </div>

            <!-- Options -->
            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:8px; font-weight:500;">Answer options (select the correct one)</div>

                <div style="display:flex; gap:10px; align-items:center; margin-bottom:8px;">
                    <asp:RadioButton ID="CorrectA" runat="server" GroupName="correct" />
                    <span style="font-family:var(--font-mono); width:18px; color:var(--muted);">A.</span>
                    <asp:TextBox ID="OptionA" runat="server" CssClass="input" placeholder="Option A" />
                </div>
                <div style="display:flex; gap:10px; align-items:center; margin-bottom:8px;">
                    <asp:RadioButton ID="CorrectB" runat="server" GroupName="correct" />
                    <span style="font-family:var(--font-mono); width:18px; color:var(--muted);">B.</span>
                    <asp:TextBox ID="OptionB" runat="server" CssClass="input" placeholder="Option B" />
                </div>
                <div style="display:flex; gap:10px; align-items:center; margin-bottom:8px;">
                    <asp:RadioButton ID="CorrectC" runat="server" GroupName="correct" />
                    <span style="font-family:var(--font-mono); width:18px; color:var(--muted);">C.</span>
                    <asp:TextBox ID="OptionC" runat="server" CssClass="input" placeholder="Option C" />
                </div>
                <div style="display:flex; gap:10px; align-items:center; margin-bottom:8px;">
                    <asp:RadioButton ID="CorrectD" runat="server" GroupName="correct" />
                    <span style="font-family:var(--font-mono); width:18px; color:var(--muted);">D.</span>
                    <asp:TextBox ID="OptionD" runat="server" CssClass="input" placeholder="Option D" />
                </div>
            </div>

            <div style="margin-bottom:14px;">
                <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">
                    Explanation <span style="color:var(--muted-2); font-weight:400;">(shown to student after submitting)</span>
                </div>
                <asp:TextBox ID="ExplanationBox" runat="server" CssClass="input" TextMode="MultiLine" Rows="3" />
            </div>

            <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:14px;">
                <div>
                    <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Points</div>
                    <asp:TextBox ID="PointsBox" runat="server" CssClass="input" TextMode="Number" Text="10" />
                </div>
                <div>
                    <div style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500;">Sort order</div>
                    <asp:TextBox ID="SortOrderBox" runat="server" CssClass="input" TextMode="Number" Text="0" />
                </div>
            </div>

            <div style="display:flex; justify-content:space-between; margin-top:24px; padding-top:18px; border-top:1px solid var(--border);">
                <asp:HyperLink ID="CancelLink" runat="server" CssClass="btn btn-ghost" Text="Cancel" />
                <asp:Button ID="SaveButton" runat="server" Text="Save question"
                    CssClass="btn btn-yellow" OnClick="SaveButton_Click" />
            </div>

        </div>
    </div>
</asp:Content>
