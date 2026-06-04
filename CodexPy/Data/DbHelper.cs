using System.Configuration;
using Npgsql;

namespace CodexPy.Data
{
    //Provides a single point for opening database connections to Supabase.
    //Reads the connection string from Web.config (key: "CodexPyDb").
    public static class DbHelper
    {
        private static readonly string ConnectionString =
            ConfigurationManager.ConnectionStrings["CodexPyDb"].ConnectionString;

        //Returns an OPEN NpgsqlConnection, Caller is responsible for disposing it
        public static NpgsqlConnection GetConnection()
        {
            var conn = new NpgsqlConnection(ConnectionString);
            conn.Open();
            return conn;
        }
    }
}
