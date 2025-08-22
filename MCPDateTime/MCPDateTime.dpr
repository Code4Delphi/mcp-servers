program MCPDateTime;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Rtti,
  TMS.MCP.Server,
  TMS.MCP.Tools,
  TMS.MCP.Helpers,
  TMS.MCP.Transport.StreamableHTTP;

function DateAndTime(const Args: array of TValue): TValue;
begin
  Result := TValue.From<string>(DateTimeToStr(Now));
end;

var
  MCPServer: TTMSMCPServer;
  MCPTool: TTMSMCPTool;
  HTTPTransport: TTMSMCPStreamableHTTPTransport;

begin
  try
    //CREATE MCP SERVER
    MCPServer := TTMSMCPServer.Create(nil);
    MCPServer.ServerName := 'MCPNow';
    MCPServer.ServerVersion := '1.0.0';

    //CREATE HTTP TRANSPORT WITH CUSTOM ENDPOINT
    HTTPTransport := TTMSMCPStreamableHTTPTransport.Create(nil, 9090, '/datetime');
    MCPServer.Transport := HTTPTransport;

    //CREATE TOOL
    MCPTool := TTMSMCPTool.CreateBuilder
      .Name('DateAndTime')
      .Description('Current date and time')
      .ReturnType(ptString)
      .ExecuteCallback(DateAndTime)
      .Build;

    MCPServer.Tools.Add(MCPTool);

    MCPServer.Start;
    //MCPServer.Run;
    WriteLn(Format('Server running. Port: %d. Endpoint: %s', [HTTPTransport.Port, HTTPTransport.MCPEndpoint]));
    WriteLn('Press Enter to stop...');
    ReadLn;
  except
    on E: Exception do
    begin
      WriteLn(Format('Error: %s', [E.Message]));
      ExitCode := 1;
    end;
  end;
end.
