program FileSystemMCP_HTTP;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  FileSystemHTTP.DM in 'Src\FileSystemHTTP.DM.pas' {FileSystemHTTPDM: TDataModule},
  FileSystemHTTP.Utils in 'Src\FileSystemHTTP.Utils.pas';

var
  DM: TFileSystemHTTPDM;

begin
  try
    DM := TFileSystemHTTPDM.Create(nil);
    try
      DM.Run;
    finally
      DM.Free;
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
