program CRUD_RTTI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  TMS.MCP.Attributes.Server,
  Produtos in 'Src\Produtos.pas',
  Vendas in 'Src\Vendas.pas';

var
  Produtos: TProdutos;
  Vendas: TVendas;
  MCPServer: TTMSMCPAttributedServer;
begin
  try
    Produtos := TProdutos.Create;
    Vendas := TVendas.Create;
    MCPServer := TTMSMCPAttributedServer.Create(nil);
    try
      MCPServer.AddObject(Produtos);
      MCPServer.AddObject(Vendas);

      MCPServer.ServerName := 'CrudRTTI';
      MCPServer.Start;
      MCPServer.Run;
    finally
      MCPServer.Free;
      Vendas.Free;
      Produtos.Free;
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
