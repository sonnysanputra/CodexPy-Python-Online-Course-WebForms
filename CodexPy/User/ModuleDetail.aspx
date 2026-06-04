<%@ Page Title="Module" Language="C#" MasterPageFile="~/MasterPages/Site.Master" AutoEventWireup="true" CodeBehind="ModuleDetail.aspx.cs" Inherits="CodexPy.User.ModuleDetail" %>

<asp:Content ContentPlaceHolderID="TitlePH" runat="server"><asp:Literal ID="PageTitleLit" runat="server" /> — CodexPy</asp:Content>
<asp:Content ContentPlaceHolderID="CrumbPH" runat="server"><asp:Literal ID="CrumbLit" runat="server" /></asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding:28px 32px; overflow-y:auto; max-width:900px; margin:0 auto; width:100%;">

        <!-- ========== BREADCRUMB (link back to module catalog) ========== -->
        <div style="margin-bottom:8px;">
            <a href="<%= ResolveUrl("~/User/Modules.aspx") %>" style="font-size:13px; color:var(--py-blue);">← Back to all modules</a>
        </div>

        <!-- ========== STATUS BANNER (shown after marking module complete) ========== -->
        <asp:Panel ID="MessagePanel" runat="server" Visible="false" style="margin-bottom:14px; padding:10px 14px; border-radius:10px; background:rgba(16,185,129,0.1); border:1px solid var(--success); color:var(--success); font-size:13.5px;">
            <asp:Literal ID="MessageLit" runat="server" />
        </asp:Panel>

        <!-- ========== MODULE HEADER (color-coded icon swatch + title + blurb) ========== -->
        <div style="margin-bottom:24px;">
            <div style="display:flex; align-items:center; gap:14px; margin-bottom:14px;">
                <!-- Icon swatch (background color comes from module's color column) -->
                <div runat="server" id="IconBox" style='width:56px; height:56px; border-radius:12px; display:grid; place-items:center; font-weight:700; font-size:24px;'>
                    <asp:Literal ID="IconInitialLit" runat="server" />
                </div>
                <div>
                    <!-- Eyebrow: difficulty · duration -->
                    <div class="eyebrow"><asp:Literal ID="DifficultyLit" runat="server" /> · <asp:Literal ID="DurationLit" runat="server" /></div>
                    <h1 class="h1" style="margin-top:2px;"><asp:Literal ID="TitleLit" runat="server" /></h1>
                </div>
            </div>
            <!-- Module description blurb -->
            <p style="color:var(--muted); font-size:15px; line-height:1.55; margin:0;"><asp:Literal ID="BlurbLit" runat="server" /></p>
        </div>

        <!-- ========== PROGRESS CARD (progress bar + "Mark complete" button) ========== -->
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

        <!-- ========== LESSONS SECTION (numbered lesson cards from this module) ========== -->
        <h2 class="h2" style="margin-bottom:14px;">Lessons</h2>
        <asp:Repeater ID="LessonsRepeater" runat="server">
            <ItemTemplate>
                <div class="card" style="padding:24px; margin-bottom:14px;">
                    <!-- Lesson header: numbered circle + title + "Listen" button -->
                    <div style="display:flex; gap:14px; margin-bottom:12px; align-items:center; justify-content:space-between;">
                        <div style="display:flex; gap:14px; align-items:start; flex:1;">
                            <div style="width:32px; height:32px; border-radius:50%; background:var(--bg-sunk); color:var(--ink-2); display:grid; place-items:center; font-weight:600; font-size:13px; flex-shrink:0;">
                                <%# Container.ItemIndex + 1 %>
                            </div>
                            <h3 class="h3" style="margin-top:4px;"><%# Eval("title") %></h3>
                        </div>
                        <!-- Text-to-speech button (toggles between Listen / Stop) -->
                        <button type="button" class="lesson-tts-btn" title="Read this lesson aloud"
                            style="background:transparent; border:1px solid var(--border); border-radius:8px; padding:6px 12px; cursor:pointer; font-size:13px; display:flex; align-items:center; gap:6px; color:var(--ink-2); flex-shrink:0;">
                            <span class="lesson-tts-icon">🔊</span>
                            <span class="lesson-tts-label">Listen</span>
                        </button>
                    </div>
                    <!-- Lesson body content (Eval on same line — pre-wrap preserves the markup indentation otherwise) -->
                    <div class="lesson-content" style="padding-left:46px; color:var(--ink-2); font-size:14.5px; line-height:1.7; white-space:pre-wrap;"><%# Eval("content") %></div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <!-- Empty state — shown if no lessons exist for this module -->
        <asp:Panel ID="EmptyLessonsPanel" runat="server" Visible="false" class="card" style="padding:40px; text-align:center; color:var(--muted);">
            No lessons have been added to this module yet. Check back later!
        </asp:Panel>

        <!-- ========== QUIZZES SECTION (cards linking to Quiz.aspx for each quiz) ========== -->
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

        <!-- Empty state — shown if no quizzes exist for this module -->
        <asp:Panel ID="EmptyQuizzesPanel" runat="server" Visible="false" class="card" style="padding:24px; text-align:center; color:var(--muted); font-size:13.5px;">
            No quizzes available for this module yet.
        </asp:Panel>

        <!-- ========== DISCUSSION SECTION (forum for this module — comments + admin replies) ========== -->
        <h2 class="h2" style="margin-top:32px; margin-bottom:14px;">
            Discussion <span style="color:var(--muted); font-weight:400; font-size:16px;">(<asp:Literal ID="CommentCountLit" runat="server" Text="0" />)</span>
        </h2>

        <!-- New comment form (only visible to logged-in students) -->
        <div class="card" style="padding:20px; margin-bottom:14px;">
            <div style="font-size:12px; color:var(--muted); margin-bottom:6px; font-weight:500;">Share your thoughts on this module</div>
            <asp:TextBox ID="NewCommentBox" runat="server" CssClass="input" TextMode="MultiLine" Rows="3"
                placeholder="What worked, what didn't, suggestions for the lessons or quizzes..." />
            <asp:RequiredFieldValidator ID="NewCommentReq" runat="server" ControlToValidate="NewCommentBox"
                ValidationGroup="PostComment" CssClass="validation-error"
                ErrorMessage="Please write something before posting" Display="Dynamic" />
            <div style="display:flex; justify-content:flex-end; margin-top:10px;">
                <asp:Button ID="PostCommentButton" runat="server" Text="Post comment"
                    CssClass="btn btn-yellow" ValidationGroup="PostComment" OnClick="PostCommentButton_Click" />
            </div>
        </div>

        <!-- Status banner for comment-posting feedback -->
        <asp:Panel ID="CommentMessagePanel" runat="server" Visible="false"
            style="margin-bottom:14px; padding:10px 14px; border-radius:10px; background:rgba(16,185,129,0.1); border:1px solid var(--success); color:#065F46; font-size:13.5px;">
            <asp:Literal ID="CommentMessageLit" runat="server" />
        </asp:Panel>

        <!-- Comments list — one card per top-level comment with admin replies nested -->
        <asp:Repeater ID="CommentsRepeater" runat="server">
            <ItemTemplate>
                <div class="card" style="padding:18px; margin-bottom:10px;">
                    <!-- One flex row: avatar (fixed-width) + content column (flex:1) -->
                    <div style="display:flex; gap:12px; align-items:flex-start; text-align:left;">

                        <!-- Avatar -->
                        <div class="avatar" style="width:36px; height:36px; flex-shrink:0; font-size:12px;">
                            <%# Eval("Initials") %>
                        </div>

                        <!-- Content column: identity, body, replies all stack vertically aligned to the right of the avatar -->
                        <div style="flex:1; min-width:0; text-align:left;">
                            <!-- Identity row: name + segment + email + timestamp -->
                            <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap; margin-bottom:4px;">
                                <strong style="font-size:14px;"><%# Eval("Name") %></strong>
                                <span class="tag" style="font-size:11px;"><%# Eval("Segment") %></span>
                                <span style="font-size:12px; color:var(--muted);"><%# Eval("Email") %></span>
                                <span style="font-size:11.5px; color:var(--muted);">&middot; <%# Eval("WhenLabel") %></span>
                            </div>

                            <!-- Comment body (Eval on same line — pre-wrap would render markup whitespace as visible space) -->
                            <div style="font-size:14px; line-height:1.5; white-space:pre-wrap; margin-top:8px;"><%# Eval("Body") %></div>

                            <!-- Admin replies nested -->
                            <asp:Repeater runat="server" DataSource='<%# Eval("Replies") %>'>
                                <ItemTemplate>
                                    <div style="margin-top:12px; padding:14px; background:var(--bg-sunk); border-radius:8px;">
                                        <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap; margin-bottom:4px;">
                                            <strong style="font-size:13.5px;"><%# Eval("Name") %></strong>
                                            <span class="tag adv" style="font-size:11px;">Admin</span>
                                            <span style="font-size:11.5px; color:var(--muted);">&middot; <%# Eval("WhenLabel") %></span>
                                        </div>
                                        <div style="font-size:13.5px; line-height:1.5; white-space:pre-wrap;"><%# Eval("Body") %></div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <!-- Empty state when this module has no comments yet -->
        <asp:Panel ID="EmptyCommentsPanel" runat="server" Visible="false" class="card" style="padding:24px; text-align:center; color:var(--muted); font-size:13.5px;">
            No comments yet. Be the first to share your thoughts!
        </asp:Panel>

    </div>

    <!-- Text-to-speech for lesson cards (uses the browser's built-in SpeechSynthesis API) -->
    <script type="text/javascript">
        (function () {
            if (!('speechSynthesis' in window)) {
                // Browser doesn't support TTS — hide the listen buttons completely
                var btns = document.querySelectorAll('.lesson-tts-btn');
                for (var i = 0; i < btns.length; i++) btns[i].style.display = 'none';
                return;
            }

            var currentBtn = null;

            function resetButton(btn) {
                btn.querySelector('.lesson-tts-icon').textContent = '🔊';
                btn.querySelector('.lesson-tts-label').textContent = 'Listen';
            }

            function stopSpeaking() {
                window.speechSynthesis.cancel();
                if (currentBtn) {
                    resetButton(currentBtn);
                    currentBtn = null;
                }
            }

            document.querySelectorAll('.lesson-tts-btn').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    // Click again on the same button → stop reading
                    if (currentBtn === btn) {
                        stopSpeaking();
                        return;
                    }
                    // Switching to a new lesson → stop the old one first
                    if (currentBtn) stopSpeaking();

                    var card = btn.closest('.card');
                    var contentEl = card ? card.querySelector('.lesson-content') : null;
                    if (!contentEl) return;

                    var text = (contentEl.innerText || contentEl.textContent || '').trim();
                    if (!text) return;

                    var utterance = new SpeechSynthesisUtterance(text);
                    utterance.rate = 1.0;
                    utterance.pitch = 1.0;
                    utterance.volume = 1.0;

                    // When playback finishes naturally, reset the button
                    utterance.onend = function () {
                        if (currentBtn === btn) {
                            resetButton(btn);
                            currentBtn = null;
                        }
                    };
                    utterance.onerror = function () {
                        if (currentBtn === btn) {
                            resetButton(btn);
                            currentBtn = null;
                        }
                    };

                    currentBtn = btn;
                    btn.querySelector('.lesson-tts-icon').textContent = '⏹';
                    btn.querySelector('.lesson-tts-label').textContent = 'Stop';

                    window.speechSynthesis.speak(utterance);
                });
            });

            // Stop reading if the user navigates away
            window.addEventListener('beforeunload', function () {
                window.speechSynthesis.cancel();
            });
        })();
    </script>
</asp:Content>
