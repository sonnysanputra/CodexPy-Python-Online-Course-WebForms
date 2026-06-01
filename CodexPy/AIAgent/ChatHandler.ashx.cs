using CodexPy.Data;
using Newtonsoft.Json;
using Npgsql;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.SessionState;

namespace CodexPy.AIAgent
{
    /// <summary>
    /// AJAX endpoint for the chat widget.
    /// Receives JSON { message, moduleId? } and returns { reply } or { error }.
    /// Session-aware: tracks conversation history per logged-in user.
    /// </summary>
    public class ChatHandler : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            try
            {
                // Must be logged in to chat
                if (context.Session["UserId"] == null)
                {
                    context.Response.StatusCode = 401;
                    context.Response.Write(JsonConvert.SerializeObject(new { error = "Not logged in" }));
                    return;
                }

                // Parse incoming JSON
                string body;
                using (var reader = new StreamReader(context.Request.InputStream))
                {
                    body = reader.ReadToEnd();
                }
                dynamic request = JsonConvert.DeserializeObject(body);
                string userMessage = (string)request?.message;
                int moduleId = 0;
                try { moduleId = (int)(request?.moduleId ?? 0); } catch { moduleId = 0; }

                if (string.IsNullOrWhiteSpace(userMessage))
                {
                    context.Response.Write(JsonConvert.SerializeObject(new { error = "Empty message" }));
                    return;
                }

                // Special case: client requested to clear history
                if (userMessage == "__clear__")
                {
                    context.Session["ChatHistory"] = null;
                    context.Response.Write(JsonConvert.SerializeObject(new { reply = "" }));
                    return;
                }

                // Pull existing chat history from Session (per-user)
                var history = context.Session["ChatHistory"] as List<ChatMessage> ?? new List<ChatMessage>();

                // Append the new user turn
                history.Add(new ChatMessage { Role = "user", Text = userMessage });

                // Build system prompt — adds module-specific context if applicable
                string systemPrompt = BuildSystemPrompt(moduleId);

                // Keep token usage in check — only send the last 20 turns
                var trimmed = history.Skip(Math.Max(0, history.Count - 20)).ToList();

                // Call Gemini
                string reply = GeminiClient.Ask(trimmed, systemPrompt);

                // Save the AI reply so the next turn has full context
                history.Add(new ChatMessage { Role = "model", Text = reply });
                context.Session["ChatHistory"] = history;

                context.Response.Write(JsonConvert.SerializeObject(new { reply = reply }));
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 500;
                context.Response.Write(JsonConvert.SerializeObject(new { error = ex.Message }));
            }
        }

        /// <summary>
        /// Builds the system prompt. If moduleId > 0, fetches the module's title + lessons
        /// from the database and injects them as context so the AI can answer specifically
        /// about the material the student is reading.
        /// </summary>
        private string BuildSystemPrompt(int moduleId)
        {
            string basePrompt =
                "You are a friendly Python tutor for the CodexPy learning platform. " +
                "Help students understand Python concepts with clear, concise explanations " +
                "and small code examples. Keep responses focused and beginner-appropriate. " +
                "Use plain text only — no markdown formatting like ** or # since the chat UI " +
                "renders them literally.";

            if (moduleId <= 0) return basePrompt;

            try
            {
                using (var conn = DbHelper.GetConnection())
                {
                    string moduleTitle = null;
                    using (var cmd = new NpgsqlCommand(
                        "SELECT title FROM modules WHERE id = @id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", moduleId);
                        var result = cmd.ExecuteScalar();
                        moduleTitle = result?.ToString();
                    }
                    if (moduleTitle == null) return basePrompt;

                    var lessons = new List<string>();
                    using (var cmd = new NpgsqlCommand(
                        "SELECT title, content FROM lessons WHERE module_id = @id ORDER BY sort_order, id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", moduleId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string t = reader.GetString(0);
                                string c = reader.IsDBNull(1) ? "" : reader.GetString(1);
                                lessons.Add(t + ":\n" + c);
                            }
                        }
                    }
                    if (lessons.Count == 0) return basePrompt;

                    return basePrompt +
                        "\n\nThe student is currently studying the module \"" + moduleTitle + "\". " +
                        "Here is the lesson content from this module that you should reference when answering:\n\n" +
                        string.Join("\n\n---\n\n", lessons);
                }
            }
            catch
            {
                // If DB lookup fails, fall back to the base prompt
                return basePrompt;
            }
        }
    }
}