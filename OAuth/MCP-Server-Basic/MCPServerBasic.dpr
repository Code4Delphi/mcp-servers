program MCPServerBasic;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  MCPServerBasic.DM in 'Src\MCPServerBasic.DM.pas' {MCPServerBasicDM: TDataModule};

begin
  try
    var LDM := TMCPServerBasicDM.Create(nil);
  except
    on E: Exception do
    begin
      WriteLn('Error: ' + E.Message);
      ReadLn;
      ExitCode := 1;
    end;
  end;
end.
