(function () {
    'use strict';

    var toggleBtn = document.getElementById('chatToggleBtn');
    var panel = document.getElementById('chatPanel');
    var closeBtn = document.getElementById('chatCloseBtn');
    var form = document.getElementById('chatForm');
    var input = document.getElementById('chatInput');
    var messages = document.getElementById('chatMessages');

    // Bail out if the widget isn't on this page (e.g. login page)
    if (!toggleBtn || !panel) return;

    var endpoint = window.codexpyChatEndpoint || '/Handlers/ChatHandler.ashx';

    // ---------- Toggle open/close ------------------------------------------
    toggleBtn.addEventListener('click', function () {
        panel.hidden = !panel.hidden;
        if (!panel.hidden) {
            input.focus();
            scrollToBottom();
        }
    });
    closeBtn.addEventListener('click', function () { panel.hidden = true; });

    // ---------- Submit on Enter (Shift+Enter for newline) ------------------
    input.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            form.dispatchEvent(new Event('submit', { cancelable: true }));
        }
    });
    form.addEventListener('submit', function (e) {
        e.preventDefault();
        sendMessage();
    });

    // ---------- Helpers ----------------------------------------------------
    function getModuleId() {
        // If we're on /User/ModuleDetail.aspx, grab the ?id=N
        var path = window.location.pathname.toLowerCase();
        if (path.indexOf('moduledetail.aspx') === -1) return 0;
        var match = window.location.search.match(/[?&]id=(\d+)/i);
        return match ? parseInt(match[1], 10) : 0;
    }

    function appendMessage(text, role) {
        var msg = document.createElement('div');
        msg.className = 'chat-message chat-message-' + role;
        var bubble = document.createElement('div');
        bubble.className = 'chat-bubble';
        bubble.textContent = text;  // textContent escapes HTML — safe
        msg.appendChild(bubble);
        messages.appendChild(msg);
        scrollToBottom();
        return msg;
    }

    function appendLoading() {
        var msg = document.createElement('div');
        msg.className = 'chat-message chat-message-ai chat-loading';
        msg.innerHTML =
            '<div class="chat-bubble"><span></span><span></span><span></span></div>';
        messages.appendChild(msg);
        scrollToBottom();
        return msg;
    }

    function scrollToBottom() {
        messages.scrollTop = messages.scrollHeight;
    }

    // ---------- Send a message --------------------------------------------
    function sendMessage() {
        var text = input.value.trim();
        if (!text) return;

        appendMessage(text, 'user');
        input.value = '';
        input.disabled = true;

        var loading = appendLoading();

        var payload = {
            message: text,
            moduleId: getModuleId()
        };

        fetch(endpoint, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload),
            credentials: 'same-origin'  // include ASP.NET session cookie
        })
            .then(function (res) {
                return res.json().then(function (data) {
                    return { ok: res.ok, data: data };
                });
            })
            .then(function (result) {
                if (loading.parentNode) loading.parentNode.removeChild(loading);
                if (result.data.reply) {
                    appendMessage(result.data.reply, 'ai');
                } else if (result.data.error) {
                    appendMessage('Error: ' + result.data.error, 'ai');
                } else {
                    appendMessage("I didn't get a reply. Try again.", 'ai');
                }
            })
            .catch(function () {
                if (loading.parentNode) loading.parentNode.removeChild(loading);
                appendMessage('Network error. Please try again.', 'ai');
            })
            .finally(function () {
                input.disabled = false;
                input.focus();
            });
    }
})();
