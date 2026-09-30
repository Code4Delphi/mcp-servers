program MCPServerOAuth;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  MCPServerOAuth.DM in 'MCPServerOAuth.DM.pas' {MCPServerOAuthDM: TDataModule};

begin
  try
    MCPServerOAuthDM := TMCPServerOAuthDM.Create(nil);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
