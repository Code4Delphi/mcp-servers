unit Vendas;

interface

uses
  System.SysUtils,
  System.Rtti,
  TMS.MCP.Attributes.Server,
  TMS.MCP.Attributes;

type
  TVendas = class
  public
    [TTMSMCPTool]
    [TTMSMCPDescription('Retorna lista com vendas')]
    function List: TArray<string>;

    [TTMSMCPTool]
    [TTMSMCPDescription('Retorna dados da venda buscada')]
    function Get([TTMSMCPDescription('Código da venda a ser retornada')] AId: Integer): string;
  end;

implementation

function TVendas.List: TArray<string>;
begin
  Result := ['Venda 1001', 'Venda 1002', 'Venda 1003'];
end;

function TVendas.Get(AId: Integer): string;
begin
  Result := 'Venda teste código ' + AId.ToString;
end;

end.
