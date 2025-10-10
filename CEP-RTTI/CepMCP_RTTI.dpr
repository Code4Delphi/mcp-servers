program CepMCP_RTTI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  TMS.MCP.Attributes.Server,
  CEP in 'Src\CEP.pas';

var
  CEP: TCEP;
  MCPServer: TTMSMCPAttributedServer;
begin
  try
    CEP := TCEP.Create;
    MCPServer := TTMSMCPServerFactory.CreateFromObject(CEP);
    try
      MCPServer.ServerName := 'RetornaEnderecoDeCEP';
      MCPServer.Start;
      MCPServer.Run;
    finally
      MCPServer.Free;
      CEP.Free;
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
