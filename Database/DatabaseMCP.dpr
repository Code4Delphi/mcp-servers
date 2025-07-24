program DatabaseMCP;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DatabaseMCP.Connection.Params in 'Src\DatabaseMCP.Connection.Params.pas',
  DatabaseMCP.Types in 'Src\DatabaseMCP.Types.pas',
  DatabaseMCP.Database in 'Src\DatabaseMCP.Database.pas',
  DatabaseMCP.Utils in 'Src\DatabaseMCP.Utils.pas',
  DatabaseMCP.Server in 'Src\DatabaseMCP.Server.pas';

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
