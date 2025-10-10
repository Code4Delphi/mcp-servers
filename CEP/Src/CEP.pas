unit CEP;

interface

uses
  System.SysUtils,
  System.Rtti,
  TMS.MCP.CloudBase,
  TMS.MCP.Attributes;

type
  TCEP = class
  public
    [TTMSMCPTool]
    function GetEndereco(const ACEP: string): string;
  end;

implementation

function TCEP.GetEndereco(const ACEP: string): string;
var
  LRequest: TTMSMCPCloudBase;
  LResult: string;
begin
  LRequest := TTMSMCPCloudBase.Create;
  try
    LRequest.Request.Host := 'https://viacep.com.br/ws/';
    LRequest.Request.Path := Format('%s/json', [ACEP.Replace('-', '', [])]);

    LRequest.ExecuteRequest(
      procedure(const ARequestResult:TTMSMCPCloudBaseRequestResult)
      begin
        LResult := ARequestResult.ResultString;
      end, nil, False);

    Result := LResult;
  finally
    LRequest.Free;
  end;
end;

end.
