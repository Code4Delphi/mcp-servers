program MCPServerOAuth;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  MCPServerOAuth.DM in 'Src\MCPServerOAuth.DM.pas' {MCPServerOAuthDM: TDataModule};

begin
  try
    var LDM := TMCPServerOAuthDM.Create(nil);
  except
    on E: Exception do
    begin
      WriteLn('Error: ' + E.Message);
      ReadLn;
      ExitCode := 1;
    end;
  end;
end.
