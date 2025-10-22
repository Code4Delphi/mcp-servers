program DatabaseMCP_HTTP;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DatabaseHTTP.Connection.Params in 'Src\DatabaseHTTP.Connection.Params.pas',
  DatabaseHTTP.Types in 'Src\DatabaseHTTP.Types.pas',
  DatabaseHTTP.Database in 'Src\DatabaseHTTP.Database.pas',
  DatabaseHTTP.Utils in 'Src\DatabaseHTTP.Utils.pas',
  DatabaseHTTP.Server in 'Src\DatabaseHTTP.Server.pas';

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
    begin
      WriteLn('Error: ' + E.Message);
      ReadLn;
      ExitCode := 1;
    end;
  end;
end.
