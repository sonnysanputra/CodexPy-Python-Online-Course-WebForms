<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="CodexPy.Default" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>CodexPy — Connection Test</title>
</head>
<body>
    <form runat="server">
        <h1>Database connection test</h1>
        <p>Below should list 6 modules from Supabase:</p>
        <asp:Literal ID="ResultLiteral" runat="server" />
    </form>
</body>
</html>
