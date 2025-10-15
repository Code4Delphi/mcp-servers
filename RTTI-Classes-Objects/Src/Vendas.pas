unit Vendas;

interface

uses
  System.SysUtils,
  System.Rtti,
  TMS.MCP.Attributes.Server,  TMS.MCP.Server, //**
  TMS.MCP.Attributes;

type
  TVenda = class
  public
    [TTMSMCPTool]
    function GetVendas: TArray<string>;

    [TTMSMCPTool]
    function GetVenda(AId: Integer): string;

    constructor Create;
  end;

implementation

constructor TVenda.Create;
begin

end;

function TVenda.GetVendas: TArray<string>;
begin
  Result := ['Venda 1001', 'Venda 1002', 'Venda 1003'];
end;

function TVenda.GetVenda(AId: Integer): string;
begin
  Result := 'Venda teste código ' + AId.ToString;
end;

end.
