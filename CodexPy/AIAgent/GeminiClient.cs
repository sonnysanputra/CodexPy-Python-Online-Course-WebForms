using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net.Http;
using System.Text;
using Newtonsoft.Json;

namespace CodexPy.AIAgent
{
    /// <summary>
    /// One turn in a chat conversation.
    /// Role is "user" or "model" (matching Gemini's API expectation).
    /// </summary>
    public class ChatMessage
    {
        public string Role { get; set; }
        public string Text { get; set; }
    }

    /// <summary>
    /// Wraps the Google Gemini REST API.
    /// Reads GeminiApiKey + GeminiModel from Web.config appSettings.
    /// </summary>
    public static class GeminiClient
    {
        private static readonly string ApiKey =
            ConfigurationManager.AppSettings["GeminiApiKey"];

        private static readonly string Model =
            ConfigurationManager.AppSettings["GeminiModel"] ?? "gemini-2.0-flash";

        // One shared HttpClient for the whole app — recommended practice.
        private static readonly HttpClient http = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(30)
        };

        /// <summary>
        /// Sends the conversation history + system prompt to Gemini and returns its reply.
        /// Returns a friendly error string instead of throwing on common failures.
        /// </summary>
        public static string Ask(List<ChatMessage> history, string systemPrompt)
        {
            if (string.IsNullOrWhiteSpace(ApiKey) || ApiKey.StartsWith("PASTE_"))
                return "AI is not configured. Set GeminiApiKey in Web.config.";

            try
            {
                // Build the request body matching Gemini's JSON shape
                var requestBody = new
                {
                    contents = history.Select(m => new
                    {
                        role = m.Role,
                        parts = new[] { new { text = m.Text } }
                    }).ToArray(),
                    systemInstruction = new
                    {
                        parts = new[] { new { text = systemPrompt } }
                    },
                    generationConfig = new
                    {
                        temperature = 0.7,
                        maxOutputTokens = 1024
                    }
                };

                string json = JsonConvert.SerializeObject(requestBody);
                string url = "https://generativelanguage.googleapis.com/v1beta/models/"
                             + Model + ":generateContent?key=" + ApiKey;

                using (var content = new StringContent(json, Encoding.UTF8, "application/json"))
                using (var response = http.PostAsync(url, content).GetAwaiter().GetResult())
                {
                    // Handle the most common error responses with friendly messages
                    if ((int)response.StatusCode == 429)
                        return "I'm getting too many questions right now. Try again in a minute!";

                    if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized ||
                        response.StatusCode == System.Net.HttpStatusCode.Forbidden)
                        return "AI authentication failed. Check the API key in Web.config.";

                    string responseBody =
                        response.Content.ReadAsStringAsync().GetAwaiter().GetResult();

                    if (!response.IsSuccessStatusCode)
                        return "Sorry, I couldn't get an answer right now. (HTTP "
                               + (int)response.StatusCode + ")";

                    // Drill into Gemini's nested JSON to pull out the text reply
                    dynamic result = JsonConvert.DeserializeObject(responseBody);

                    if (result?.candidates == null || result.candidates.Count == 0)
                        return "I didn't get a reply — try rephrasing your question.";

                    return (string)result.candidates[0].content.parts[0].text;
                }
            }
            catch (Exception ex)
            {
                return "Sorry, something went wrong: " + ex.Message;
            }
        }
    }
}
