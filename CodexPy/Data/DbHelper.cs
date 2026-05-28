using System.Configuration;
using Npgsql;

namespace CodexPy.Data
{
    /// <summary>
    /// Provides a single point for opening database connections to Supabase.
    /// Reads the connection string from Web.config (key: "CodexPyDb").
    /// </summary>
    public static class DbHelper
    {
        private static readonly string ConnectionString =
            ConfigurationManager.ConnectionStrings["CodexPyDb"].ConnectionString;

        /// <summary>
        /// Returns an OPEN NpgsqlConnection. Caller is responsible for disposing it
        /// (use `using` block).
        /// </summary>
        public static NpgsqlConnection GetConnection()
        {
            var conn = new NpgsqlConnection(ConnectionString);
            conn.Open();
            return conn;
        }
    }
}
