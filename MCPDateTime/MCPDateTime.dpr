program MCPDateTime;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Rtti,
  TMS.MCP.Server,
  TMS.MCP.Tools,
  TMS.MCP.Helpers;

function DateAndTime(const Args: array of TValue): TValue;
begin
  Result := TValue.From<string>(DateTimeToStr(Now));
end;

var
  MCPServer: TTMSMCPServer;
  MCPTool: TTMSMCPTool;

begin
  try
    //CREATE MCP SERVER
    MCPServer := TTMSMCPServer.Create(nil);
    MCPServer.ServerName := 'MCPNow';
    MCPServer.ServerVersion := '1.0.0';

    //CREATE TOLL
    MCPTool := TTMSMCPTool.CreateBuilder
      .Name('DateAndTime')
      .Description('Current date and time')
      .ReturnType(ptString)
      .ExecuteCallback(DateAndTime)
      .Build;

    MCPServer.Tools.Add(MCPTool);

    MCPServer.Start;
    MCPServer.Run;
  except
    on E: Exception do
    begin
      WriteLn(Format('Error: %s', [E.Message]));
      ExitCode := 1;
    end;
  end;
end.
