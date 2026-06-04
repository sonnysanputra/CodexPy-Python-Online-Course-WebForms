<%@ Page Title="Register" Language="C#" MasterPageFile="~/MasterPages/Auth.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="CodexPy.Auth.Register" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitlePH" runat="server">
    Create your account — CodexPy
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- ========== TWO-COLUMN SPLIT LAYOUT (form left, marketing panel right) ========== -->
    <div style="display:grid; grid-template-columns:1fr 1fr; height:100vh;">

        <!-- ========== LEFT COLUMN — REGISTRATION FORM ========== -->
        <div style="padding:48px 56px; display:flex; flex-direction:column; justify-content:center; max-width:520px; margin:0 auto; width:100%; overflow-y:auto;">

            <!-- Brand logo (top-left of the form column) -->
            <div style="margin-bottom:32px; display:flex; align-items:center; gap:10px; font-weight:600; font-size:17px;">
                <span style="width:28px; height:28px; border-radius:7px; background:var(--ink); color:var(--py-yellow); display:grid; place-items:center; font-family:var(--font-mono); font-weight:700; font-size:14px;">&lt;/</span>
                Codex<span class="py" style="font-family:var(--font-mono); background:var(--py-yellow); color:var(--py-blue-d); padding:1px 6px; border-radius:5px;">Py</span>
            </div>

            <!-- Page heading + tagline -->
            <h1 class="h1">Start learning.</h1>
            <p style="font-size:15px; color:var(--muted); margin-top:10px; margin-bottom:24px;">Free forever for the first three modules. No credit card.</p>

            <!-- Error banner (shown if email already exists or DB write fails) -->
            <asp:Panel ID="ErrorPanel" runat="server" Visible="false" CssClass="validation-error" style="margin-bottom:14px; padding:10px 12px; background:rgba(239,68,68,0.08); border:1px solid var(--error); border-radius:10px;">
                <asp:Literal ID="ErrorMessage" runat="server" />
            </asp:Panel>

            <!-- Field: Full name (required validator) -->
            <div style="margin-bottom:14px;">
                <label for="NameBox" style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500; display:block;">Full name</label>
                <asp:TextBox ID="NameBox" runat="server" CssClass="input"
                    MaxLength="100" ClientIDMode="Static" aria-required="true" aria-describedby="NameReq" />
                <asp:RequiredFieldValidator ID="NameReq" runat="server" ClientIDMode="Static"
                    ControlToValidate="NameBox"
                    CssClass="validation-error" ErrorMessage="Name is required" Display="Dynamic" />
            </div>

            <!-- Field: Email (required + regex-format validators) -->
            <div style="margin-bottom:14px;">
                <label for="EmailBox" style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500; display:block;">Email</label>
                <asp:TextBox ID="EmailBox" runat="server" CssClass="input" TextMode="Email"
                    MaxLength="254" ClientIDMode="Static" aria-required="true" aria-describedby="RegEmailReq RegEmailFormat" />
                <asp:RequiredFieldValidator ID="RegEmailReq" runat="server" ClientIDMode="Static"
                    ControlToValidate="EmailBox"
                    CssClass="validation-error" ErrorMessage="Email is required" Display="Dynamic" />
                <asp:RegularExpressionValidator ID="RegEmailFormat" runat="server" ClientIDMode="Static"
                    ControlToValidate="EmailBox"
                    CssClass="validation-error" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Enter a valid email address" Display="Dynamic" />
            </div>

            <!-- Field: Password (required + 8-character-minimum validators) -->
            <div style="margin-bottom:14px;">
                <label for="PasswordBox" style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500; display:block;">Password</label>
                <asp:TextBox ID="PasswordBox" runat="server" CssClass="input" TextMode="Password"
                    MaxLength="128" ClientIDMode="Static" aria-required="true" aria-describedby="RegPasswordReq RegPasswordFormat" />
                <asp:RequiredFieldValidator ID="RegPasswordReq" runat="server" ClientIDMode="Static"
                    ControlToValidate="PasswordBox"
                    CssClass="validation-error" ErrorMessage="Password is required" Display="Dynamic" />
                <asp:RegularExpressionValidator ID="RegPasswordFormat" runat="server" ClientIDMode="Static"
                    ControlToValidate="PasswordBox"
                    CssClass="validation-error" ValidationExpression="^.{8,}$"
                    ErrorMessage="Password must be at least 8 characters" Display="Dynamic" />
            </div>

            <!-- Field: Confirm password (RequiredFieldValidator + CompareValidator) -->
            <div style="margin-bottom:14px;">
                <label for="ConfirmBox" style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500; display:block;">Confirm password</label>
                <asp:TextBox ID="ConfirmBox" runat="server" CssClass="input" TextMode="Password"
                    MaxLength="128" ClientIDMode="Static" aria-required="true" aria-describedby="RegConfirmReq RegConfirmCompare" />
                <asp:RequiredFieldValidator ID="RegConfirmReq" runat="server" ClientIDMode="Static"
                    ControlToValidate="ConfirmBox"
                    CssClass="validation-error" ErrorMessage="Confirm password is required" Display="Dynamic" />
                <asp:CompareValidator ID="RegConfirmCompare" runat="server" ClientIDMode="Static"
                    ControlToValidate="ConfirmBox"
                    ControlToCompare="PasswordBox" CssClass="validation-error"
                    ErrorMessage="Passwords do not match" Display="Dynamic" />
            </div>

            <!-- Field: Segment radio group (School / University / Self-learner) -->
            <div style="margin-bottom:14px;">
                <fieldset style="border:none; margin:0; padding:0;">
                    <legend style="font-size:12px; color:var(--muted); margin-bottom:8px; font-weight:500; padding:0;">I am a…</legend>
                    <asp:RadioButtonList ID="SegmentList" runat="server" RepeatDirection="Horizontal" CssClass="seg" RepeatLayout="Flow">
                        <asp:ListItem Value="School" Text="&nbsp;School student&nbsp;" />
                        <asp:ListItem Value="University" Text="&nbsp;University student&nbsp;" Selected="True" />
                        <asp:ListItem Value="Self-learner" Text="&nbsp;Self-learner&nbsp;" />
                    </asp:RadioButtonList>
                </fieldset>
            </div>

            <!-- Submit button (triggers RegisterButton_Click — inserts user with hashed password) -->
            <asp:Button ID="RegisterButton" runat="server" Text="Create my account"
                CssClass="btn btn-yellow btn-lg"
                style="margin-top:18px; justify-content:center; width:100%;"
                OnClick="RegisterButton_Click" />

            <!-- Footer link back to Login page -->
            <p style="font-size:12px; color:var(--muted); margin-top:24px; text-align:center;">
                Already have an account? <a href="<%= ResolveUrl("~/Auth/Login.aspx") %>" style="color:var(--py-blue);">Sign in</a>
            </p>
        </div>

        <!-- ========== RIGHT COLUMN — DARK MARKETING PANEL ========== -->
        <div style="background:var(--ink); color:var(--bg); position:relative; overflow:hidden; display:grid; place-items:center; padding:40px;">
            <div style="position:relative; max-width:380px; text-align:center;">
                <div style="display:inline-flex; padding:5px 11px; background:rgba(255,212,59,0.15); color:var(--py-yellow); border-radius:999px; font-size:11px; font-weight:600; margin-bottom:18px;">Free trial</div>
                <h2 style="font-size:28px; font-weight:600; letter-spacing:-0.015em; line-height:1.25;">
                    Master Python through structured modules, interactive quizzes, and real-world examples.
                </h2>
            </div>
        </div>

    </div>
</asp:Content>
