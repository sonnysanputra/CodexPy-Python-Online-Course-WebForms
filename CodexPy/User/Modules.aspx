<%@ Page Title="All Modules" Language="C#" MasterPageFile="~/MasterPages/Site.Master" AutoEventWireup="true" CodeBehind="Modules.aspx.cs" Inherits="CodexPy.User.Modules" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server">All Modules — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server">All Modules</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto;">

        <!-- Header -->
        <div style="margin-bottom:24px;">
            <div class="eyebrow">Curriculum</div>
            <h1 class="h1" style="margin-top:4px;">All learning modules</h1>
            <p style="color:var(--muted); margin-top:4px; font-size:14px;">Start anywhere. Track your progress as you go.</p>
        </div>

        <!-- Filter by difficulty -->
        <div style="margin-bottom:18px;">
            <asp:DropDownList ID="DifficultyFilter" runat="server" CssClass="input" AutoPostBack="true"
                OnSelectedIndexChanged="DifficultyFilter_Changed" style="max-width:240px;">
                <asp:ListItem Value="All" Text="All difficulties" />
                <asp:ListItem Value="Beginner" Text="Beginner only" />
                <asp:ListItem Value="Intermediate" Text="Intermediate only" />
                <asp:ListItem Value="Advanced" Text="Advanced only" />
            </asp:DropDownList>
        </div>

        <!-- Grid of module cards -->
        <div style="display:grid; grid-template-columns:repeat(3, 1fr); gap:16px;">
            <asp:Repeater ID="ModulesRepeater" runat="server">
                <ItemTemplate>
                    <a href='<%# "ModuleDetail.aspx?id=" + Eval("id") %>' class="card card-hover" style="padding:22px; display:block; text-decoration:none;">

                        <!-- Icon swatch -->
                        <div style='width:42px; height:42px; border-radius:10px; background:<%# Eval("color") %>22; color:<%# Eval("color") %>; display:grid; place-items:center; font-weight:700; font-size:18px; margin-bottom:14px;'>
                            <%# Eval("title").ToString().Substring(0, 1) %>
                        </div>

                        <!-- Title + difficulty -->
                        <div style="display:flex; justify-content:space-between; align-items:start; gap:8px; margin-bottom:6px;">
                            <h3 class="h3" style="flex:1;"><%# Eval("title") %></h3>
                            <span class='<%# "tag " + GetDifficultyClass(Eval("difficulty") as string) %>'><%# Eval("difficulty") %></span>
                        </div>

                        <!-- Blurb -->
                        <p style="color:var(--muted); font-size:13.5px; margin:0 0 14px; line-height:1.5;"><%# Eval("blurb") %></p>

                        <!-- Meta -->
                        <div style="display:flex; gap:14px; font-size:12px; color:var(--muted); margin-bottom:14px;">
                            <span><%# Eval("lesson_count") %> lessons</span>
                            <span><%# Eval("duration") %></span>
                        </div>

                        <!-- Progress -->
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:11.5px; color:var(--muted); margin-bottom:5px;">
                                <span><%# (int)Eval("progress_percent") == 0 ? "Not started" : ((int)Eval("progress_percent") >= 100 ? "Complete" : "In progress") %></span>
                                <span style="font-family:var(--font-mono);"><%# Eval("progress_percent") %>%</span>
                            </div>
                            <div class="progress-bar">
                                <span style='display:block; height:100%; width:<%# Eval("progress_percent") %>%; background:linear-gradient(90deg, var(--py-blue), var(--py-yellow));'></span>
                            </div>
                        </div>

                    </a>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <asp:Panel ID="EmptyPanel" runat="server" Visible="false" style="padding:60px; text-align:center; color:var(--muted);">
            <p style="font-size:14px;">No modules match this filter.</p>
        </asp:Panel>

    </div>
</asp:Content>
