# TMS MCP Database Server Demo

This README explains how to set up and use the TMS MCP Database Server Demo with a client using STDIO transport.

## Overview

The Database Server Demo is a Model Context Protocol (MCP) server implementation that connects to a database (SQLite, MySQL, MS SQL, or PostgreSQL) and exposes it through MCP tools. This allows AI assistants to query databases and work with the data directly.

## Requirements

- Delphi 10.0 or later
- TMS FNC Core Pack
- TMS MCP SDK
- Database drivers for your selected database type
- Database server (except for SQLite, which is file-based)

## Building the Server

1. Open the `DatabaseDemo.dproj` project in your Delphi IDE.
2. Build the project (Shift+F9 or Run → Build).
3. The compiled executable will be available in the `Win32\Debug` or `Win32\Release` folder, depending on your configuration.

## Running the Database Server

The database server accepts several command-line parameters to configure the database connection:

```
DatabaseDemo [parameters]
```

**Parameters:**

- `-type=[sqlite|mysql|mssql|postgres]`  Database type (default: sqlite)
- `-db=<database>`                       Database name or path
- `-server=<server>`                     Database server address (not needed for SQLite)
- `-user=<username>`                     Database username (not needed for SQLite)
- `-pass=<password>`                     Database password (not needed for SQLite)
- `-port=<port>`                         Database port (optional)
- `-sample`                              Create sample data (only for SQLite)
- `-help`                                Show this help

### Examples

**SQLite (File-based database)**

```
DatabaseDemo -type=sqlite -db=C:\path\to\mydata.db -sample
```

Creates or opens a SQLite database at the specified path and initializes it with sample data.

**MySQL**

```
DatabaseDemo -type=mysql -server=localhost -db=mydb -user=root -pass=password
```

**PostgreSQL**

```
DatabaseDemo -type=postgres -server=localhost -db=postgres -user=postgres -pass=password -port=5432
```

**Microsoft SQL Server**

```
DatabaseDemo -type=mssql -server=localhost -db=mydatabase -user=sa -pass=password
```

## Setting Up a Client

You can use any MCP client that supports STDIO transport to connect to this server. Here are two common options:

### Option 1: Using Claude for Desktop

1. Install [Claude for Desktop](https://claude.ai/download).
2. Edit the Claude Desktop configuration file located at:
   - macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - Windows: `%APPDATA%\Claude\claude_desktop_config.json`
3. Add the Database Server to the `mcpServers` section:

```json
{
  "mcpServers": {
    "database": {
      "command": "PATH_TO_EXE\\DatabaseDemo.exe",
      "args": ["-type=sqlite", "-db=C:\\path\\to\\mydata.db", "-sample"]
    }
  }
}
```

Replace `PATH_TO_EXE` with the absolute path to your compiled executable.

4. Restart Claude for Desktop.
5. Ask Claude about your database, e.g., "What tables are in my database?" or "Show me the first 5 records from the customers table."

### Option 2: Using MCP Inspector

1. Install the MCP Inspector tool:
   ```bash
   npm install -g @modelcontextprotocol/inspector
   ```

2. Run the Inspector with your server:
   ```bash
   npx @modelcontextprotocol/inspector PATH_TO_EXE\DatabaseDemo.exe -type=sqlite -db=mydata.db -sample
   ```

3. Use the Inspector UI to test the database-related tools and view the schema as resources.

## Available Tools

### `query`

- **Description:** Execute a read-only SQL query
- **Parameters:**
  - `sql` (string): The SQL query to execute
- **Returns:** The query results in JSON format

### `get_schema`

- **Description:** Get the database schema
- **Parameters:** None
- **Returns:** JSON object describing tables, columns, and relationships

### `get_tables`

- **Description:** List all tables in the database
- **Parameters:** None
- **Returns:** List of table names in JSON format

### `get_table_data`

- **Description:** Get data from a specific table
- **Parameters:**
  - `table` (string): The table name
  - `limit` (number, optional): Maximum number of rows to return
  - `offset` (number, optional): Number of rows to skip
- **Returns:** Table data in JSON format

## Resources

The server also exposes database structure as resources:

- `database://schema`: The complete database schema
- `database://table/{tableName}`: Structure of a specific table
- `database://sample/{tableName}`: Sample data from a specific table

## Troubleshooting

### Database Connection Issues:

- Verify your database server is running and accessible.
- Check connection parameters (server address, port, username, password).
- Ensure required database drivers are installed.

### Permission Issues:

- Ensure the user has appropriate permissions to access the database.
- For SQLite, check if the application has write access to the file location.

### Query Errors:

- Verify your SQL syntax is correct for the specific database type.
- Check if referenced tables and columns exist.

If Claude for Desktop doesn't show the database tools, check the logs at:

- macOS: `~/Library/Logs/Claude/mcp*.log`
- Windows: `%APPDATA%\Claude\logs\mcp*.log`

## Security Considerations

The Database Server executes SQL queries directly, so it's recommended to:

- Use a read-only database user when possible.
- Set up proper database permissions.
- Be cautious with sensitive data.
- Use environment variables for passwords rather than command-line arguments.

The server enforces read-only operations by default and will reject SQL statements that modify data (`INSERT`, `UPDATE`, `DELETE`, `DROP`, etc.) unless specifically configured to allow them.

## License

This demo is part of the TMS MCP SDK subject to the TMS Software license agreement.
