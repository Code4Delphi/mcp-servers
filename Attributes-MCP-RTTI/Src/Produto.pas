unit Produto;

interface

uses
  System.SysUtils,
  System.Rtti,
  TMS.MCP.Attributes;

type
  TProduto = class
  public
    [TTMSMCPTool]
    [TTMSMCPName('ListProduto')]
    [TTMSMCPDescription('Retorna todos os produtos ativos')]
    function GetAllProducts: TArray<string>;

    [TTMSMCPTool]
    [TTMSMCPReadOnly]
    function GetProduct(AId: Integer): string;

    [TTMSMCPTool]
    [TTMSMCPDestructive]
    procedure Deletar(AId: Integer);

    [TTMSMCPTool]
    [TTMSMCPIdempotent]
    function GetStatus(AId: Integer): Boolean;

    [TTMSMCPTool]
    [TTMSMCPOpenworld]
    procedure List(AParams: array of const);

    [TTMSMCPTool]
    procedure SaveName(ANome: string; [TTMSMCPOptional] const AObservation: string = '');

    [TTMSMCPTool]
    [TTMSMCPString]
    function GetName(AId: Integer): string;

    [TTMSMCPTool]
    [TTMSMCPFloat]
    function GetPrice(AId: Integer): Double;

    [TTMSMCPTool]
    [TTMSMCPInteger]
    function GetSequence(AId: Integer): Integer;

    [TTMSMCPTool]
    [TTMSMCPBoolean]
    function GetActive([TTMSMCPName('Id do produto')] AId: Integer): Boolean;

    [TTMSMCPTool]
    [TTMSMCPFloat]
    function GetTotal([TTMSMCPInteger] AId: Integer; [TTMSMCPString] ALog: string): Double;
  end;

implementation

function TProduto.GetAllProducts: TArray<string>;
begin
  Result := ['Produto de teste A', 'Produto de teste B', 'Produto de teste C'];
end;

function TProduto.GetProduct(AId: Integer): string;
begin
  Result := 'Produto teste código ' + AId.ToString;
end;

procedure TProduto.Deletar(AId: Integer);
begin

end;

function TProduto.GetStatus(AId: Integer): Boolean;
begin
  Result := True;
end;

procedure TProduto.List(AParams: array of const);
begin

end;

procedure TProduto.SaveName(ANome: string; [TTMSMCPOptional] const AObservation: string = '');
begin

end;

function TProduto.GetName(AId: Integer): string;
begin
  Result := 'Nome do produto código ' + AId.ToString;
end;

function TProduto.GetPrice(AId: Integer): Double;
begin
  Result := AId * 10.5;
end;

function TProduto.GetSequence(AId: Integer): Integer;
begin
  Result := AId + 10;
end;

function TProduto.GetActive(AId: Integer): Boolean;
begin
  Result := True;
end;

function TProduto.GetTotal(AId: Integer; ALog: string): Double;
begin
  Result := AId * 100;
end;

end.
