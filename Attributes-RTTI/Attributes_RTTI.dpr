program Attributes_RTTI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  TMS.MCP.Attributes.Server,
  Produto in 'Src\Produto.pas';

var
  Produto: TProduto;
  MCPServer: TTMSMCPAttributedServer;
begin
  try
    Produto := TProduto.Create;
    MCPServer := TTMSMCPServerFactory.CreateFromObject(Produto);
    try
      MCPServer.ServerName := 'ManipulaDadosDeProdutos';
      MCPServer.Start;
      MCPServer.Run;
    finally
      MCPServer.Free;
      Produto.Free;
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
