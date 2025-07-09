program FileSystemMCP;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Utils in 'Src\Utils.pas',
  FileSystem in 'Src\FileSystem.pas';

var
  FileSystem: TFileSystem;
begin
  try
    FileSystem := TFileSystem.Create;
    try
      FileSystem.Run;
    finally
      FileSystem.Free;
    end;
  except
    on E: Exception do
      ExitCode := 1;
  end;
end.
