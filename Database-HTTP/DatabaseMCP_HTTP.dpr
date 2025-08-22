program DatabaseMCP_HTTP;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Connection.Params in 'Src\Connection.Params.pas',
  Types in 'Src\Types.pas',
  Database in 'Src\Database.pas',
  Utils in 'Src\Utils.pas',
  Server in 'Src\Server.pas';

var
  ServerMCP: TServer;

begin
  try
    ServerMCP := TServer.Create;
    try
      ServerMCP.SetupServer;
      ServerMCP.Run;
    finally
      ServerMCP.Free;
    end;
  except
    on E: Exception do
      ExitCode := 1;
  end;
end.
