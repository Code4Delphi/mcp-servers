unit MCPServerBasic.DM;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Rtti,
  IdHTTP,
  TMS.MCP.Server,
  TMS.MCP.Transport,
  TMS.MCP.Transport.StreamableHTTP,
  TMS.MCP.CustomComponent,
  TMS.MCP.Auth,
  TMS.MCP.Utils;

type
  TMCPServerBasicDM = class(TDataModule)
    TMSMCPServer1: TTMSMCPServer;
    TMSMCPStreamableHTTPTransport1: TTMSMCPStreamableHTTPTransport;
    procedure DataModuleCreate(Sender: TObject);
    function TMSMCPServer1Tools0Execute(const Args: array of TValue): TValue;
    procedure TMSMCPStreamableHTTPTransport1ValidateAccessToken(Sender: TObject; const AToken, AResourceURI: string;
      var AValidation: TTMSMCPAccessTokenValidation);
  private

  public

  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

const
  { Issuer impresso no console do OAuth Authorization Server Demo.
    Sem barra no final e em porta diferente deste MCP (8081). }
  AUTHORIZATION_SERVER_ISSUER = 'http://localhost:8935';

procedure TMCPServerBasicDM.DataModuleCreate(Sender: TObject);
begin
  //Authorization settings
  TMSMCPStreamableHTTPTransport1.RequireBearerAuthentication := True;
  TMSMCPStreamableHTTPTransport1.AuthorizationServers.Add(AUTHORIZATION_SERVER_ISSUER);
  TMSMCPStreamableHTTPTransport1.ResourceScopesSupported.Add('demo:read');
  TMSMCPStreamableHTTPTransport1.ResourceScopesSupported.Add('demo:write');
  TMSMCPStreamableHTTPTransport1.RequiredScopes.Add('demo:read');
  TMSMCPStreamableHTTPTransport1.PublicHost := '';
  //TMSMCPStreamableHTTPTransport1.ConfigureSSL(FCertFile, FKeyFile, FKeyPassword);

  TMSMCPServer1.Start;
  WriteLn('Server running');
  WriteLn('Name: ' + TMSMCPServer1.ServerName);
  WriteLn('Port: ' + TMSMCPStreamableHTTPTransport1.Port.ToString);
  WriteLn('Endpoint: ' + TMSMCPStreamableHTTPTransport1.MCPEndpoint);
  WriteLn('Authorization server: ' + AUTHORIZATION_SERVER_ISSUER);
  WriteLn('Press Enter to stop...');
  ReadLn;
end;

procedure TMCPServerBasicDM.TMSMCPStreamableHTTPTransport1ValidateAccessToken(Sender: TObject; const AToken,
  AResourceURI: string; var AValidation: TTMSMCPAccessTokenValidation);
var
  Http: TIdHTTP;
  ReqBody: TStringStream;
  RespBody: TStringStream;
  Json: TJSONObject;
  Audience: string;
begin
  AValidation.Valid := False;
  Json := nil;
  Http := TIdHTTP.Create(nil);
  ReqBody := TStringStream.Create('token=' + TTMSMCPUtils.URLEncode(AToken));
  RespBody := TStringStream.Create;
  try
    try
      Http.Request.ContentType := 'application/x-www-form-urlencoded';
      Http.Post(AUTHORIZATION_SERVER_ISSUER + '/introspect', ReqBody, RespBody);

      Json := TJSONObject.ParseJSONValue(RespBody.DataString) as TJSONObject;
      if not Assigned(Json) or not Assigned(Json.GetValue('active')) or
        not (Json.GetValue('active') is TJSONBool) or
        not TJSONBool(Json.GetValue('active')).AsBoolean then
        AValidation.ErrorDescription := 'Token inativo ou resposta de introspection inválida'
      else
      begin
        Audience := '';
        if Assigned(Json.GetValue('aud')) then
          Audience := Json.GetValue('aud').Value;
        if Audience <> AResourceURI then
          AValidation.ErrorDescription :=
            'Token emitido para outro recurso. Esperado "' + AResourceURI + '", aud "' + Audience + '"'
        else if not Assigned(Json.GetValue('sub')) or not Assigned(Json.GetValue('scope')) then
          AValidation.ErrorDescription := 'Introspection sem subject ou scope'
        else
        begin
          AValidation.Valid := True;
          AValidation.Subject := Json.GetValue('sub').Value;
          AValidation.Scopes := Json.GetValue('scope').Value.Split([' ']);
        end;
      end;
    except
      on E: Exception do
        AValidation.ErrorDescription := 'Introspection indisponível: ' + E.Message;
    end;
  finally
    Json.Free;
    RespBody.Free;
    ReqBody.Free;
    Http.Free;
  end;

  if not AValidation.Valid then
    WriteLn(AValidation.ErrorDescription);
end;

function TMCPServerBasicDM.TMSMCPServer1Tools0Execute(const Args: array of TValue): TValue;
begin
  var LNomePessoal := Args[0].AsString;
  Result := TValue.From<string>('Código pessoal: ' + DateTimeToStr(Now));
end;

end.
