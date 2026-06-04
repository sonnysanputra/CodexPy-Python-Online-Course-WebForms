using System;
using Npgsql;

namespace CodexPy.Data
{
    // Records platform activity (modules/lessons/quizzes/questions added, updated, removed)
    // so students can see a feed of recent changes on their dashboard.
    public static class AnnouncementHelper
    {
        // Insert one row into the announcements table.
        // Logging silently fails on error — we never want a logging hiccup to break the main CRUD flow.
        public static void Log(string action, string targetType, string targetName, string parentName = null)
        {
            try
            {
                using (var conn = DbHelper.GetConnection())
                using (var cmd = new NpgsqlCommand(
                    @"INSERT INTO announcements (action, target_type, target_name, parent_name)
                      VALUES (@action, @target_type, @target_name, @parent_name)", conn))
                {
                    cmd.Parameters.AddWithValue("@action", action);
                    cmd.Parameters.AddWithValue("@target_type", targetType);
                    cmd.Parameters.AddWithValue("@target_name", targetName ?? "(unknown)");
                    cmd.Parameters.AddWithValue("@parent_name", (object)parentName ?? DBNull.Value);
                    cmd.ExecuteNonQuery();
                }
            }
            catch
            {
                // Silently ignore — announcements are a nice-to-have, not critical.
            }
        }
    }
}
