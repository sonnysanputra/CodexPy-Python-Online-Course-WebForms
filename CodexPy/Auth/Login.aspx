<%@ Page Title="Sign in" Language="C#" MasterPageFile="~/MasterPages/Auth.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="CodexPy.Auth.Login" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitlePH" runat="server">
    Sign in — CodexPy
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div style="display:grid; grid-template-columns:1fr 1fr; height:100vh;">

        <!-- Left: form -->
        <div style="padding:48px 56px; display:flex; flex-direction:column; justify-content:center; max-width:480px; margin:0 auto; width:100%;">
            <div style="margin-bottom:40px; display:flex; align-items:center; gap:10px; font-weight:600; font-size:17px;">
                <span style="width:28px; height:28px; border-radius:7px; background:var(--ink); color:var(--py-yellow); display:grid; place-items:center; font-family:var(--font-mono); font-weight:700; font-size:14px;">&lt;/</span>
                Codex<span class="py" style="font-family:var(--font-mono); background:var(--py-yellow); color:var(--py-blue-d); padding:1px 6px; border-radius:5px;">Py</span>
            </div>

            <h1 class="h1">Welcome back.</h1>
            <p style="font-size:15px; color:var(--muted); margin-top:10px; margin-bottom:32px;">Pick up where the snake left off.</p>

            <asp:Panel ID="ErrorPanel" runat="server" Visible="false" CssClass="validation-error" style="margin-bottom:14px; padding:10px 12px; background:rgba(239,68,68,0.08); border:1px solid var(--error); border-radius:10px;">
                <asp:Literal ID="ErrorMessage" runat="server" />
            </asp:Panel>

            <div style="margin-bottom:14px;">
                <label for="EmailBox" style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500; display:block;">Email</label>
                <asp:TextBox ID="EmailBox" runat="server" CssClass="input" TextMode="Email"
                    MaxLength="254" ClientIDMode="Static" aria-required="true" aria-describedby="EmailReq EmailFormat" />
                <asp:RequiredFieldValidator ID="EmailReq" runat="server" ClientIDMode="Static"
                    ControlToValidate="EmailBox" CssClass="validation-error"
                    ErrorMessage="Email is required" Display="Dynamic" />
                <asp:RegularExpressionValidator ID="EmailFormat" runat="server" ClientIDMode="Static"
                    ControlToValidate="EmailBox" CssClass="validation-error"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Enter a valid email address" Display="Dynamic" />
            </div>

            <div style="margin-bottom:14px;">
                <label for="PasswordBox" style="font-size:12px; color:var(--muted); margin-bottom:5px; font-weight:500; display:block;">Password</label>
                <asp:TextBox ID="PasswordBox" runat="server" CssClass="input" TextMode="Password"
                    MaxLength="128" ClientIDMode="Static" aria-required="true" aria-describedby="PasswordReq" />
                <asp:RequiredFieldValidator ID="PasswordReq" runat="server" ClientIDMode="Static"
                    ControlToValidate="PasswordBox" CssClass="validation-error"
                    ErrorMessage="Password is required" Display="Dynamic" />
            </div>

            <asp:Button ID="SignInButton" runat="server" Text="Sign in"
                CssClass="btn btn-yellow btn-lg"
                style="margin-top:18px; justify-content:center; width:100%;"
                OnClick="SignInButton_Click" />

            <p style="font-size:13px; color:var(--muted); margin-top:24px; text-align:center;">
                New to CodexPy? <a href="<%= ResolveUrl("~/Auth/Register.aspx") %>" style="color:var(--py-blue);">Create an account</a>
            </p>
        </div>

        <!-- Right: dark accent panel -->
        <div style="background:var(--ink); color:var(--bg); position:relative; overflow:hidden; display:grid; place-items:center; padding:40px;">
            <div style="position:relative; max-width:360px; text-align:center;">
                <div style="display:inline-flex; padding:5px 11px; background:rgba(255,212,59,0.15); color:var(--py-yellow); border-radius:999px; font-size:11px; font-weight:600; margin-bottom:18px;">Day 14</div>
                <h2 style="font-size:28px; font-weight:600; letter-spacing:-0.015em; line-height:1.25;">
                    "I never thought I'd actually understand list comprehensions. Then the snake purred at me."
                </h2>
                <div style="font-size:13px; color:rgba(255,255,255,0.6); margin-top:16px;">— Yusra, week 4</div>
            </div>
        </div>

    </div>
</asp:Content>
