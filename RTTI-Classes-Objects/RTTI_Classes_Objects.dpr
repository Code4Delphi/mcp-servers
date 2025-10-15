program RTTI_Classes_Objects;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  TMS.MCP.Attributes.Server,
  Produtos in 'Src\Produtos.pas',
  Vendas in 'Src\Vendas.pas';

var
  MCPServer: TTMSMCPAttributedServer;
  Produtos: TProdutos;
begin
  try
    MCPServer := TTMSMCPAttributedServer.Create(nil);
    Produtos := TProdutos.Create;
    try
      MCPServer.Targets.AddClass(TVenda);

      //MCPServer.AddClass(TVenda);
      //MCPServer.AddClass(TVenda);
      //MCPServer.AddObject(Produtos);

      MCPServer.ServerName := 'RTTIClassesObjects';
      MCPServer.Start;
      MCPServer.Run;
    finally
      Produtos.Free;
      MCPServer.Free;
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
