# MCP Servers
This repository brings together practical examples and ready-made MCP Server projects created with Delphi, following the official Model Context Protocol (MCP) specification.

MCP is a standard created by Anthropic that allows LLMs (Language Models) to discover and use external tools in a standardized way, such as accessing databases, reading files, and executing APIs, all in real time and with loose coupling.

## Available MCP Servers
- **[Database](https://github.com/Code4Delphi/mcp-servers/tree/master/Database)** (STDIO communication) - For connecting to, querying, and working with databases (SQLite, MySQL, Firebird, MS SQL, or PostgreSQL).
- **[Database-HTTP](https://github.com/Code4Delphi/mcp-servers/tree/master/Database-HTTP)** (HTTP communication) - For connecting to, querying, and working with databases (SQLite, MySQL, Firebird, MS SQL, or PostgreSQL).
- **[FileSystem](https://github.com/Code4Delphi/mcp-servers/tree/master/Filesystem)** (STDIO communication) - For manipulating files and folders in the file system.
- **[DateTime](https://github.com/Code4Delphi/mcp-servers/tree/master/MCPDateTime)** (STDIO communication) - Exposes the current date and time.
- **[ServerInfoPC](https://github.com/Code4Delphi/mcp-servers/tree/master/ServerInfoPC)** (STDIO communication) - PC/Windows Information

## ✨ Component used
- [TMS AI Studio](https://www.tmssoftware.com/site/tmsaistudio.asp)
- [Documentation](https://download.tmssoftware.com/doc/tmsaistudio/)

## 🚀MCP with Delphi in Practice
Want to learn how to use the thousands of MCP Servers and MCP Clients already available and, even better, create your own easily with Delphi?

On the Code4Delphi channel, you'll find a series of practical videos that show you, step by step, how to implement the Model Context Protocol in your systems, easily connecting LLMs to real data and external tools.

## 📚 STDIO, SSE, and HTTP (Transport)
### MCP STDIO (Standard Input/Output)
- Communication via standard input/output.
- Used in local scenarios or when you want to directly control process execution.
- Best suited for integration between processes on the same machine.
- The client starts the MCP server locally and exchanges messages via binary text streams or JSON.
- Requires the MCP server to be started by the client and the data stream to be manually managed.
- Lowest level, requires the client to manage execution.

### MCP SSE (Server-Sent Events)
- Communication via HTTP streaming (events sent from the server to the client).
- Best suited for remote connections or web applications.
- The MCP server must already be running on an accessible endpoint. - Less process management work, as transport is handled via the HTTP protocol.
- The client listens for events sent continuously by the MCP server.

### MCP HTTP (Traditional HTTP Requests)
- Communication via standard HTTP, with requests and responses.
- Not streaming, it works in a request/response model.
- Good for one-off operations or when continuous traffic is not necessary.
- Easier to integrate with systems that already work with REST APIs.

👉 In short:
- STDIO: Local, direct, and client-controlled.
- SSE: Remote via HTTP, continuous streaming.
- HTTP: Remote, on-demand requests.

## 🔗 AI and MCP in Practice
- ▶️ [Practical Videos about MCP](https://www.youtube.com/watch?v=G7H9_hGQ3Q8&list=PLLHSz4dOnnN237tIxJI10E5cy1dgXJxgP)

- 🗂️ [Repository with examples of AI in Practice](https://github.com/Code4Delphi/ia-na-pratica)

- 🗂️ [Repository with MCP Client created with Delphi](https://github.com/Code4Delphi/mcp-client)

- 🌟 [Post about MCP Server and Client](https://code4delphi.com.br/blog/mcp/)

- 🌟 [Post about AI in Practice: AIs Applications used](https://code4delphi.com.br/blog/ia-na-pratica-ias-utilizadas/)

- 🌟 [TMS AI Studio](https://www.tmssoftware.com/site/tmsaistudio.asp)

## 📞 Contatos
[![Telegram](https://img.shields.io/badge/Telegram-Join-blue?logo=telegram)](https://t.me/Code4Delphi)
[![YouTube](https://img.shields.io/badge/YouTube-Join-red?logo=youtube&logoColor=red)](https://www.youtube.com/@code4delphi)
[![Instagram](https://img.shields.io/badge/Intagram-Follow-red?logo=instagram&logoColor=pink)](https://www.instagram.com/code4delphi/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/cesar-cardoso-dev)
[![Blog](https://img.shields.io/badge/Blog-Code4Delphi-F00?logo=delphi)](https://code4delphi.com.br/blog/)
[![Course](https://img.shields.io/badge/Course-Delphi-F00?logo=delphi)](https://go.hotmart.com/U81331747Y?dp=1)
[![E-mail](https://img.shields.io/badge/E--mail-Send-yellowgreen?logo=maildotru&logoColor=yellowgreen)](mailto:contato@code4delphi.com.br)
