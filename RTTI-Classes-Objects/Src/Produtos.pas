unit Produtos;

interface

uses
  System.SysUtils,
  System.Rtti,
  TMS.MCP.Attributes;

type
  TProdutos = class
  public
    [TTMSMCPTool]
    function GetProdutos: TArray<string>;

    [TTMSMCPTool]
    function GetProduto(AId: Integer): string;
  end;

implementation

function TProdutos.GetProdutos: TArray<string>;
begin
  Result := ['Produto de teste A', 'Produto de teste B', 'Produto de teste C'];
end;

function TProdutos.GetProduto(AId: Integer): string;
begin
  Result := 'Produto teste código ' + AId.ToString;
end;

end.
