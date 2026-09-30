unit MCPServerOAuth.DM;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  TMS.MCP.Server,
  TMS.MCP.Transport,
  TMS.MCP.Transport.StreamableHTTP,
  TMS.MCP.CustomComponent,
  TMS.MCP.Auth;

type
  TMCPServerOAuthDM = class(TDataModule)
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

procedure TMCPServerOAuthDM.DataModuleCreate(Sender: TObject);
begin
  //Authorization settings
  TMSMCPStreamableHTTPTransport1.RequireBearerAuthentication := True;
  TMSMCPStreamableHTTPTransport1.AuthorizationServers.Add('http://localhost:8081');
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
  WriteLn('Press Enter to stop...');
  ReadLn;
end;

procedure TMCPServerOAuthDM.TMSMCPStreamableHTTPTransport1ValidateAccessToken(Sender: TObject; const AToken,
  AResourceURI: string; var AValidation: TTMSMCPAccessTokenValidation);
begin
  AValidation.Valid := False;

  if AToken <> 'Code4Delphi' then
  begin
     AValidation.ErrorDescription := 'The provided token is invalid (provide Code4Delphi)';
     Exit;
  end;

  AValidation.Valid := True;
  AValidation.Subject := 'Subject test';
  AValidation.Scopes := ['Scopes test'];
end;

function TMCPServerOAuthDM.TMSMCPServer1Tools0Execute(const Args: array of TValue): TValue;
begin
  var LNomePessoal := Args[0].AsString;
  Result := TValue.From<string>('Código pessoal: ' + DateTimeToStr(Now));
end;

end.
