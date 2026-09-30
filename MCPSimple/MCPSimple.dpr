program MCPSimple;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  MCPSimple.DM in 'MCPSimple.DM.pas' {DM: TDataModule};

var
  DM: TDM;
begin
  try
    DM := TDM.Create(nil);
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
