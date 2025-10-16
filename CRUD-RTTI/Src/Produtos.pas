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
    [TTMSMCPDescription('Retorna lista com produtos')]
    [TTMSMCPReadOnly]
    function List: TArray<string>;

    [TTMSMCPTool]
    [TTMSMCPDescription('Retorna um produto pelo seu id')]
    [TTMSMCPReadOnly]
    function Get([TTMSMCPDescription('Código do produto a ser retornado')] AId: Integer): string;

    [TTMSMCPTool]
    [TTMSMCPDescription('Recebe dados a serem gravado e retorna o Id do produto cadastrado')]
    [TTMSMCPInteger]
    function Post(ANome: string): Integer;

    [TTMSMCPTool]
    [TTMSMCPDescription('Recebe dados a serem alterado e retorna True se obteve sucesso')]
    [TTMSMCPDestructive]
    [TTMSMCPBoolean]
    function Put(ANome: string): Boolean;

    [TTMSMCPTool]
    [TTMSMCPDescription('Exclui produto com base no Id informado')]
    [TTMSMCPDestructive]
    [TTMSMCPBoolean]
    function Delete(ANome: string): Boolean;

    [TTMSMCPTool]
    [TTMSMCPDescription('Retorna se produto esta ativo')]
    [TTMSMCPIdempotent]
    function GetStatus(AId: Integer): Boolean;

    [TTMSMCPTool]
    [TTMSMCPDescription('Retorna lista de produtos com base nos filtros recebidos')]
    [TTMSMCPOpenworld]
    procedure Filter(AParams: array of const);

    [TTMSMCPTool]
    [TTMSMCPDescription('Retorna o estoque do produto do Id informado')]
    [TTMSMCPFloat]
    function GetEstoque([TTMSMCPInteger] AId: Integer; [TTMSMCPString] [TTMSMCPOptional] ALog: string = ''): Double;
  end;

implementation

function TProdutos.List: TArray<string>;
begin
  Result := ['Produto de teste A', 'Produto de teste B', 'Produto de teste C'];
end;

function TProdutos.Get(AId: Integer): string;
begin
  Result := 'Produto teste código ' + AId.ToString;
end;

function TProdutos.Post(ANome: string): Integer;
begin
  //GRAVA PRODUTO
  Result := 100;
end;

function TProdutos.Put(ANome: string): Boolean;
begin
  //ALTERA PRODUTO
  Result := True;
end;

function TProdutos.Delete(ANome: string): Boolean;
begin
  //DELETA PRODUTO
  Result := True;
end;

function TProdutos.GetStatus(AId: Integer): Boolean;
begin
  Result := True;
end;

procedure TProdutos.Filter(AParams: array of const);
begin

end;

function TProdutos.GetEstoque(AId: Integer; ALog: string): Double;
begin
  Result := 150.10;
end;

end.
