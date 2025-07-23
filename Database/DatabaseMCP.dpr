program DatabaseMCP;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DatabaseMCP.Connection.Params in 'Src\DatabaseMCP.Connection.Params.pas',
  DatabaseMCP.Types in 'Src\DatabaseMCP.Types.pas',
  DatabaseMCP.DatabaseServer in 'Src\DatabaseMCP.DatabaseServer.pas',
  DatabaseMCP.Utils in 'Src\DatabaseMCP.Utils.pas';

var
  DatabaseServer: TDatabaseServer;
  ConnectionParams: TConnectionParams;
begin
  try
    ConnectionParams := TConnectionParams.Create;
    try
      DatabaseServer := TDatabaseServer.Create(ConnectionParams);
      try
        DatabaseServer.SetupServer;
        DatabaseServer.Run;
      finally
        DatabaseServer.Free;
      end;
    finally
      ConnectionParams.Free;
    end;
  except
    on E: Exception do
    begin
      ExitCode := 1;
    end;
  end;
end.
