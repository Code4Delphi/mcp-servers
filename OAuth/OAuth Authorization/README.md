# OAuth Authorization

A minimal but spec-faithful OAuth 2.1 Authorization Server, packaged as a Windows Service, built to let the [OAuth Resource](../OAuth%20Resource/README.md) demo (or any real MCP client — Claude Desktop, MCP Inspector) exercise the full MCP Authorization loop end to end: discovery → dynamic client registration → PKCE authorize + fake login/consent → token exchange → the resource server calling back here to introspect the token.

This is a **test tool, not a production identity provider**: there is no real credential check (the "login" page just asks you to approve as a fixed demo user), all state is in-memory only, and only public clients (PKCE, no client secret) are supported — which matches what MCP clients use.

## Overview

Endpoints (default port 9000):

| Method | Path | Purpose |
|---|---|---|
| GET | `/.well-known/oauth-authorization-server` | RFC 8414 metadata |
| POST | `/register` | RFC 7591 dynamic client registration |
| GET | `/authorize` | PKCE authorize + consent page |
| POST | `/authorize/approve` | Consent submit → redirect with code |
| POST | `/token` | `authorization_code` / `refresh_token` grants |
| POST | `/introspect` | RFC 7662 token introspection |

## Requirements

- Delphi 11.1 or later
- TMS AI Studio

## Building

1. Open `OAuthAuthorizationServerService.dproj` in your Delphi IDE.
2. Build the project (Shift+F9 or Run → Build).

## Configuration

Settings are read from an INI file next to the service executable (same base name, `.ini` extension), so the same binary can be deployed with different settings per server:

```ini
[Server]
Port=9000
BindingIP=
UseSSL=0
SSLCertFile=
Issuer=http://localhost:9000

[Logging]
LogFile=
```

If `LogFile` is left blank, it defaults to the executable's own name with a `.log` extension.

## Installing and running

From an elevated command prompt:

```
OAuthAuthorizationServerService.exe /install
net start "TMS MCP OAuth Authorization Server"
```

To remove it:

```
net stop "TMS MCP OAuth Authorization Server"
OAuthAuthorizationServerService.exe /uninstall
```

Run this service before starting the [OAuth Resource](../OAuth%20Resource/README.md) server, which points its `AuthorizationServers` property at this server's issuer URL and calls `/introspect` to validate bearer tokens.
