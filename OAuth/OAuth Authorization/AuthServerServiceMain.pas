unit AuthServerServiceMain;

// Windows service wrapper around the same minimal OAuth 2.1 Authorization Server
// logic used by the "OAuth Authorization Server Demo" console app, so it can be
// installed to run unattended on a server instead of in a console window.
//
// All settings that differ per deployment (port, issuer URL, TLS) are read from
// an INI file next to the service .exe (same base name, .ini extension) rather
// than hardcoded, so the same binary can be installed on different servers.
// See the [Server]/[Logging] keys read in TAuthServerService.LoadConfig below.
//
// Install / uninstall (elevated command prompt):
//   OAuthAuthorizationServerService.exe /install
//   OAuthAuthorizationServerService.exe /uninstall
// Then start it from services.msc or: net start "TMS MCP OAuth Authorization Server"

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Generics.Collections, System.JSON, System.NetEncoding, System.Hash,
  System.IniFiles, System.SyncObjs, System.IOUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  TMS.MCP.HTTPServer, TMS.MCP.Utils;

type
  TStringArray = TArray<string>;

  TRegisteredClient = record
    ClientId: string;
    ClientName: string;
    RedirectURIs: TStringArray;
  end;

  TPendingAuthRequest = record
    ClientId: string;
    RedirectURI: string;
    CodeChallenge: string;
    State: string;
    Resource: string;
    RequestedScopes: TStringArray;
  end;

  TAuthCode = record
    ClientId: string;
    RedirectURI: string;
    CodeChallenge: string;
    Resource: string;
    Subject: string;
    Scopes: TStringArray;
    Used: Boolean;
    ExpiresAt: TDateTime;
  end;

  TIssuedGrant = record
    ClientId: string;
    Subject: string;
    Resource: string;
    Scopes: TStringArray;
    ExpiresAt: TDateTime;
  end;

  // Same handler logic as the console demo, just parameterized by Issuer and
  // writing log output to a file instead of a console (services have neither).
  TAuthServerHandlers = class
  private
    FIssuer: string;
    FLogFile: string;
    FLogLock: TCriticalSection;
    FClients: TDictionary<string, TRegisteredClient>;
    FPendingRequests: TDictionary<string, TPendingAuthRequest>;
    FAuthCodes: TDictionary<string, TAuthCode>;
    FAccessTokens: TDictionary<string, TIssuedGrant>;
    FRefreshTokens: TDictionary<string, TIssuedGrant>;
    function ReadBody(ARequest: TTMSMCPHTTPServerRequest): string;
    procedure WriteJSON(AResponse: TTMSMCPHTTPServerResponse; const AJSON: string; AStatusCode: Integer = 200);
    procedure WriteOAuthError(AResponse: TTMSMCPHTTPServerResponse; AStatusCode: Integer;
      const AError, ADescription: string);
    function BuildRedirect(const ARedirectURI: string; const AParams: array of TPair<string, string>): string;
    procedure HandleDiscovery(AResponse: TTMSMCPHTTPServerResponse);
    procedure HandleRegister(ARequest: TTMSMCPHTTPServerRequest; AResponse: TTMSMCPHTTPServerResponse);
    procedure HandleAuthorize(ARequest: TTMSMCPHTTPServerRequest; AResponse: TTMSMCPHTTPServerResponse);
    procedure HandleApprove(ARequest: TTMSMCPHTTPServerRequest; AResponse: TTMSMCPHTTPServerResponse);
    procedure HandleToken(ARequest: TTMSMCPHTTPServerRequest; AResponse: TTMSMCPHTTPServerResponse);
    procedure HandleIntrospect(ARequest: TTMSMCPHTTPServerRequest; AResponse: TTMSMCPHTTPServerResponse);
    procedure IssueGrant(const AGrant: TIssuedGrant; out AAccessToken, ARefreshToken: string);
  public
    constructor Create(const AIssuer, ALogFile: string);
    destructor Destroy; override;
    procedure LogMessage(const Msg: string);
    procedure HandleServerRequest(AConnection: TTMSMCPHTTPServerConnection;
      ARequest: TTMSMCPHTTPServerRequest; AResponse: TTMSMCPHTTPServerResponse);
  end;

  TAuthServerService = class(TService)
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    HttpServer: TTMSMCPHTTPServer;
    Handlers: TAuthServerHandlers;
    FPort: Word;
    FBindingIP: string;
    FUseSSL: Boolean;
    FSSLCertFile: string;
    FIssuer: string;
    FLogFile: string;
    procedure LoadConfig;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  AuthServerService: TAuthServerService;

const
  AccessTokenLifetimeSeconds = 3600;
  AuthCodeLifetimeSeconds = 120;
  AllScopes: array[0..1] of string = ('demo:read', 'demo:write');

implementation

{$R *.dfm}

type
  // Delphi grants access to a class's protected members to any code in the same
  // unit as a subclass of it - used here only to reach SSLCertFile, which
  // TTMSMCPHTTPServer keeps protected. Only needed if you set SSLCertFile below
  // (an INI pointing at a cert already in the Windows certificate store); if you
  // pre-bind the certificate to the port yourself via "netsh http add sslcert",
  // this is never touched.
  TTMSMCPHTTPServerFriend = class(TTMSMCPHTTPServer);

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  AuthServerService.Controller(CtrlCode);
end;

function TAuthServerService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

function NewId: string;
var
  GUID: TGUID;
begin
  CreateGUID(GUID);
  Result := GUIDToString(GUID).Replace('{', '').Replace('}', '').Replace('-', '');
end;

function UnixTimestamp(const ADateTime: TDateTime): Int64;
begin
  Result := Round((ADateTime - EncodeDate(1970, 1, 1)) * 86400);
end;

function ScopesToString(const AScopes: array of string): string;
var
  S: string;
begin
  Result := '';
  for S in AScopes do
    if Result = '' then
      Result := S
    else
      Result := Result + ' ' + S;
end;

function StringToScopes(const AScopeStr: string): TStringArray;
begin
  if Trim(AScopeStr) = '' then
    Result := nil
  else
    Result := AScopeStr.Split([' ']);
end;

function Base64URLEncode(const ABytes: TBytes): string;
begin
  Result := TNetEncoding.Base64.EncodeBytesToString(ABytes);
  Result := StringReplace(Result, '+', '-', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '_', [rfReplaceAll]);
  Result := StringReplace(Result, '=', '', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '', [rfReplaceAll]);
end;

function PKCEChallengeMatches(const AVerifier, AChallenge: string): Boolean;
begin
  Result := (AVerifier <> '') and (AChallenge <> '') and
    (Base64URLEncode(THashSHA2.GetHashBytes(AVerifier)) = AChallenge);
end;

function ParseFormEncoded(const AData: string): TDictionary<string, string>;
var
  Pairs: TArray<string>;
  Pair, Key, Value: string;
  EqPos: Integer;
begin
  Result := TDictionary<string, string>.Create;
  if Trim(AData) = '' then
    Exit;
  Pairs := AData.Split(['&']);
  for Pair in Pairs do
  begin
    if Pair = '' then
      Continue;
    EqPos := Pos('=', Pair);
    if EqPos > 0 then
    begin
      Key := Copy(Pair, 1, EqPos - 1);
      Value := Copy(Pair, EqPos + 1, MaxInt);
    end
    else
    begin
      Key := Pair;
      Value := '';
    end;
    Key := TTMSMCPUtils.URLDecode(StringReplace(Key, '+', ' ', [rfReplaceAll]));
    Value := TTMSMCPUtils.URLDecode(StringReplace(Value, '+', ' ', [rfReplaceAll]));
    Result.AddOrSetValue(Key, Value);
  end;
end;

function GetOrDefault(ADict: TDictionary<string, string>; const AKey: string; const ADefault: string = ''): string;
begin
  if not ADict.TryGetValue(AKey, Result) then
    Result := ADefault;
end;

{ TAuthServerHandlers }

constructor TAuthServerHandlers.Create(const AIssuer, ALogFile: string);
begin
  inherited Create;
  FIssuer := AIssuer;
  FLogFile := ALogFile;
  FLogLock := TCriticalSection.Create;
  FClients := TDictionary<string, TRegisteredClient>.Create;
  FPendingRequests := TDictionary<string, TPendingAuthRequest>.Create;
  FAuthCodes := TDictionary<string, TAuthCode>.Create;
  FAccessTokens := TDictionary<string, TIssuedGrant>.Create;
  FRefreshTokens := TDictionary<string, TIssuedGrant>.Create;
end;

destructor TAuthServerHandlers.Destroy;
begin
  FRefreshTokens.Free;
  FAccessTokens.Free;
  FAuthCodes.Free;
  FPendingRequests.Free;
  FClients.Free;
  FLogLock.Free;
  inherited;
end;

procedure TAuthServerHandlers.LogMessage(const Msg: string);
begin
  FLogLock.Enter;
  try
    TFile.AppendAllText(FLogFile, Format('[%s] %s' + sLineBreak,
      [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), Msg]));
  finally
    FLogLock.Leave;
  end;
end;

function TAuthServerHandlers.ReadBody(ARequest: TTMSMCPHTTPServerRequest): string;
var
  Stream: TStringStream;
begin
  if not Assigned(ARequest.PostStream) then
    Exit('');
  Stream := TStringStream.Create('', TEncoding.UTF8);
  try
    Stream.CopyFrom(ARequest.PostStream, 0);
    Result := Stream.DataString;
  finally
    Stream.Free;
  end;
end;

procedure TAuthServerHandlers.WriteJSON(AResponse: TTMSMCPHTTPServerResponse; const AJSON: string;
  AStatusCode: Integer = 200);
begin
  AResponse.ResponseCode := AStatusCode;
  AResponse.Headers.AddValue('Content-Type', 'application/json');
  AResponse.ContentText := AJSON;
end;

procedure TAuthServerHandlers.WriteOAuthError(AResponse: TTMSMCPHTTPServerResponse; AStatusCode: Integer;
  const AError, ADescription: string);
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('error', AError);
    if ADescription <> '' then
      Obj.AddPair('error_description', ADescription);
    WriteJSON(AResponse, Obj.ToJSON, AStatusCode);
  finally
    Obj.Free;
  end;
end;

function TAuthServerHandlers.BuildRedirect(const ARedirectURI: string;
  const AParams: array of TPair<string, string>): string;
var
  Sep: string;
  P: TPair<string, string>;
begin
  Result := ARedirectURI;
  if Pos('?', ARedirectURI) > 0 then
    Sep := '&'
  else
    Sep := '?';
  for P in AParams do
  begin
    Result := Result + Sep + P.Key + '=' + TTMSMCPUtils.URLEncode(P.Value);
    Sep := '&';
  end;
end;

procedure TAuthServerHandlers.HandleDiscovery(AResponse: TTMSMCPHTTPServerResponse);
var
  Obj: TJSONObject;
  Arr: TJSONArray;
  S: string;
begin
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('issuer', FIssuer);
    Obj.AddPair('authorization_endpoint', FIssuer + '/authorize');
    Obj.AddPair('token_endpoint', FIssuer + '/token');
    Obj.AddPair('registration_endpoint', FIssuer + '/register');
    Obj.AddPair('introspection_endpoint', FIssuer + '/introspect');

    Arr := TJSONArray.Create;
    Arr.Add('code');
    Obj.AddPair('response_types_supported', Arr);

    Arr := TJSONArray.Create;
    Arr.Add('authorization_code');
    Arr.Add('refresh_token');
    Obj.AddPair('grant_types_supported', Arr);

    Arr := TJSONArray.Create;
    Arr.Add('S256');
    Obj.AddPair('code_challenge_methods_supported', Arr);

    Arr := TJSONArray.Create;
    Arr.Add('none');
    Obj.AddPair('token_endpoint_auth_methods_supported', Arr);

    Arr := TJSONArray.Create;
    for S in AllScopes do
      Arr.Add(S);
    Obj.AddPair('scopes_supported', Arr);

    WriteJSON(AResponse, Obj.ToJSON);
  finally
    Obj.Free;
  end;
end;

procedure TAuthServerHandlers.HandleRegister(ARequest: TTMSMCPHTTPServerRequest; AResponse: TTMSMCPHTTPServerResponse);
var
  ReqObj, RespObj: TJSONObject;
  ReqJSON: TJSONValue;
  RedirectArr, RespRedirectArr, RespGrantArr, RespRespArr: TJSONArray;
  Client: TRegisteredClient;
  RedirectURIs: TStringArray;
  I: Integer;
  ClientName: string;
begin
  ReqJSON := TJSONObject.ParseJSONValue(ReadBody(ARequest));
  try
    if not (ReqJSON is TJSONObject) then
    begin
      WriteOAuthError(AResponse, 400, 'invalid_client_metadata', 'Request body must be a JSON object');
      Exit;
    end;
    ReqObj := TJSONObject(ReqJSON);

    if Assigned(ReqObj.GetValue('redirect_uris')) and (ReqObj.GetValue('redirect_uris') is TJSONArray) then
      RedirectArr := TJSONArray(ReqObj.GetValue('redirect_uris'))
    else
      RedirectArr := nil;

    if not Assigned(RedirectArr) or (RedirectArr.Count = 0) then
    begin
      WriteOAuthError(AResponse, 400, 'invalid_client_metadata', 'redirect_uris is required and must be non-empty');
      Exit;
    end;

    SetLength(RedirectURIs, RedirectArr.Count);
    for I := 0 to RedirectArr.Count - 1 do
      RedirectURIs[I] := RedirectArr.Items[I].Value;

    if Assigned(ReqObj.GetValue('client_name')) then
      ClientName := ReqObj.GetValue('client_name').Value
    else
      ClientName := 'MCP Client';

    Client.ClientId := NewId;
    Client.ClientName := ClientName;
    Client.RedirectURIs := RedirectURIs;
    FClients.AddOrSetValue(Client.ClientId, Client);

    LogMessage(Format('Registered client "%s" (%s) with %d redirect URI(s)',
      [ClientName, Client.ClientId, Length(RedirectURIs)]));

    RespObj := TJSONObject.Create;
    try
      RespObj.AddPair('client_id', Client.ClientId);
      RespObj.AddPair('client_name', ClientName);
      RespObj.AddPair('client_id_issued_at', TJSONNumber.Create(UnixTimestamp(Now)));
      RespObj.AddPair('token_endpoint_auth_method', 'none');

      RespRedirectArr := TJSONArray.Create;
      for I := 0 to High(RedirectURIs) do
        RespRedirectArr.Add(RedirectURIs[I]);
      RespObj.AddPair('redirect_uris', RespRedirectArr);

      RespGrantArr := TJSONArray.Create;
      RespGrantArr.Add('authorization_code');
      RespGrantArr.Add('refresh_token');
      RespObj.AddPair('grant_types', RespGrantArr);

      RespRespArr := TJSONArray.Create;
      RespRespArr.Add('code');
      RespObj.AddPair('response_types', RespRespArr);

      WriteJSON(AResponse, RespObj.ToJSON, 201);
    finally
      RespObj.Free;
    end;
  finally
    ReqJSON.Free;
  end;
end;

procedure TAuthServerHandlers.HandleAuthorize(ARequest: TTMSMCPHTTPServerRequest; AResponse: TTMSMCPHTTPServerResponse);
var
  Params: TDictionary<string, string>;
  ClientId, RedirectURI, ResponseType, CodeChallenge, CodeChallengeMethod, State, Scope, Resource: string;
  Client: TRegisteredClient;
  RedirectValid: Boolean;
  Req: TPendingAuthRequest;
  RequestId: string;
  Html: TStringBuilder;
  I: Integer;
  ScopeName: string;
begin
  Params := ParseFormEncoded(ARequest.QueryParams);
  try
    ClientId := GetOrDefault(Params, 'client_id');
    RedirectURI := GetOrDefault(Params, 'redirect_uri');
    ResponseType := GetOrDefault(Params, 'response_type');
    CodeChallenge := GetOrDefault(Params, 'code_challenge');
    CodeChallengeMethod := GetOrDefault(Params, 'code_challenge_method');
    State := GetOrDefault(Params, 'state');
    Scope := GetOrDefault(Params, 'scope');
    Resource := GetOrDefault(Params, 'resource');

    if not FClients.TryGetValue(ClientId, Client) then
    begin
      AResponse.ResponseCode := 400;
      AResponse.Headers.AddValue('Content-Type', 'text/html');
      AResponse.ContentText := '<h3>Authorization error</h3><p>Unknown client_id.</p>';
      Exit;
    end;

    RedirectValid := False;
    for I := 0 to High(Client.RedirectURIs) do
      if Client.RedirectURIs[I] = RedirectURI then
      begin
        RedirectValid := True;
        Break;
      end;

    if not RedirectValid then
    begin
      // Never redirect on an unvalidated redirect_uri - show an in-page error instead.
      AResponse.ResponseCode := 400;
      AResponse.Headers.AddValue('Content-Type', 'text/html');
      AResponse.ContentText := '<h3>Authorization error</h3><p>redirect_uri does not match a registered value for this client.</p>';
      Exit;
    end;

    if ResponseType <> 'code' then
    begin
      AResponse.Redirect(BuildRedirect(RedirectURI, [
        TPair<string, string>.Create('error', 'unsupported_response_type'),
        TPair<string, string>.Create('state', State)]));
      Exit;
    end;

    if (CodeChallenge = '') or (CodeChallengeMethod <> 'S256') then
    begin
      AResponse.Redirect(BuildRedirect(RedirectURI, [
        TPair<string, string>.Create('error', 'invalid_request'),
        TPair<string, string>.Create('error_description', 'PKCE with S256 is required'),
        TPair<string, string>.Create('state', State)]));
      Exit;
    end;

    Req.ClientId := ClientId;
    Req.RedirectURI := RedirectURI;
    Req.CodeChallenge := CodeChallenge;
    Req.State := State;
    Req.Resource := Resource;
    if Trim(Scope) = '' then
      Req.RequestedScopes := StringToScopes(ScopesToString(AllScopes))
    else
      Req.RequestedScopes := StringToScopes(Scope);

    RequestId := NewId;
    FPendingRequests.AddOrSetValue(RequestId, Req);

    Html := TStringBuilder.Create;
    try
      Html.Append('<html><head><title>Demo Authorization Server</title></head><body style="font-family:sans-serif;max-width:480px;margin:40px auto;">');
      Html.Append('<h2>Demo Authorization Server</h2>');
      Html.Append(Format('<p><b>%s</b> is requesting access, signed in as <b>demo-user</b>.</p>', [Client.ClientName]));
      // Path-relative (not root-relative): resolves correctly whether this
      // server is mounted at the domain root or reverse-proxied under a
      // subpath (e.g. /mcp/auth/authorize -> /mcp/auth/authorize/approve).
      Html.Append('<form method="POST" action="authorize/approve">');
      Html.Append(Format('<input type="hidden" name="request_id" value="%s">', [RequestId]));
      Html.Append(Format('<input type="hidden" name="scope_count" value="%d">', [Length(Req.RequestedScopes)]));
      Html.Append('<p>Requested permissions:</p>');
      for I := 0 to High(Req.RequestedScopes) do
      begin
        ScopeName := Req.RequestedScopes[I];
        Html.Append(Format('<input type="hidden" name="scope_name_%d" value="%s">', [I, ScopeName]));
        Html.Append(Format('<label><input type="checkbox" name="scope_grant_%d" value="1" checked> %s</label><br>', [I, ScopeName]));
      end;
      Html.Append('<p><button type="submit" name="action" value="approve">Approve</button> ');
      Html.Append('<button type="submit" name="action" value="deny">Deny</button></p>');
      Html.Append('</form></body></html>');

      AResponse.ResponseCode := 200;
      AResponse.Headers.AddValue('Content-Type', 'text/html');
      AResponse.ContentText := Html.ToString;
    finally
      Html.Free;
    end;
  finally
    Params.Free;
  end;
end;

procedure TAuthServerHandlers.HandleApprove(ARequest: TTMSMCPHTTPServerRequest; AResponse: TTMSMCPHTTPServerResponse);
var
  Form: TDictionary<string, string>;
  RequestId, Action: string;
  Req: TPendingAuthRequest;
  ScopeCount, I: Integer;
  Granted: TStringArray;
  GrantedCount: Integer;
  Code: TAuthCode;
  CodeId: string;
begin
  Form := ParseFormEncoded(ReadBody(ARequest));
  try
    RequestId := GetOrDefault(Form, 'request_id');
    Action := GetOrDefault(Form, 'action');

    if not FPendingRequests.TryGetValue(RequestId, Req) then
    begin
      AResponse.ResponseCode := 400;
      AResponse.Headers.AddValue('Content-Type', 'text/html');
      AResponse.ContentText := '<h3>Authorization error</h3><p>This authorization request has expired or was already used.</p>';
      Exit;
    end;
    FPendingRequests.Remove(RequestId);

    if Action <> 'approve' then
    begin
      LogMessage(Format('Access denied by user for client %s', [Req.ClientId]));
      AResponse.Redirect(BuildRedirect(Req.RedirectURI, [
        TPair<string, string>.Create('error', 'access_denied'),
        TPair<string, string>.Create('state', Req.State)]));
      Exit;
    end;

    ScopeCount := StrToIntDef(GetOrDefault(Form, 'scope_count', '0'), 0);
    SetLength(Granted, ScopeCount);
    GrantedCount := 0;
    for I := 0 to ScopeCount - 1 do
      if GetOrDefault(Form, 'scope_grant_' + IntToStr(I)) = '1' then
      begin
        Granted[GrantedCount] := GetOrDefault(Form, 'scope_name_' + IntToStr(I));
        Inc(GrantedCount);
      end;
    SetLength(Granted, GrantedCount);

    Code.ClientId := Req.ClientId;
    Code.RedirectURI := Req.RedirectURI;
    Code.CodeChallenge := Req.CodeChallenge;
    Code.Resource := Req.Resource;
    Code.Subject := 'demo-user';
    Code.Scopes := Granted;
    Code.Used := False;
    Code.ExpiresAt := Now + (AuthCodeLifetimeSeconds / 86400);

    CodeId := NewId;
    FAuthCodes.AddOrSetValue(CodeId, Code);

    LogMessage(Format('Access approved for client %s, granted scopes: [%s]', [Req.ClientId, ScopesToString(Granted)]));

    AResponse.Redirect(BuildRedirect(Req.RedirectURI, [
      TPair<string, string>.Create('code', CodeId),
      TPair<string, string>.Create('state', Req.State)]));
  finally
    Form.Free;
  end;
end;

procedure TAuthServerHandlers.IssueGrant(const AGrant: TIssuedGrant; out AAccessToken, ARefreshToken: string);
begin
  AAccessToken := NewId;
  ARefreshToken := NewId;
  FAccessTokens.AddOrSetValue(AAccessToken, AGrant);
  FRefreshTokens.AddOrSetValue(ARefreshToken, AGrant);
end;

procedure TAuthServerHandlers.HandleToken(ARequest: TTMSMCPHTTPServerRequest; AResponse: TTMSMCPHTTPServerResponse);
var
  Form: TDictionary<string, string>;
  GrantType: string;
  Code: TAuthCode;
  Grant: TIssuedGrant;
  AccessToken, RefreshToken: string;
  RespObj: TJSONObject;
begin
  Form := ParseFormEncoded(ReadBody(ARequest));
  try
    GrantType := GetOrDefault(Form, 'grant_type');

    if GrantType = 'authorization_code' then
    begin
      if not FAuthCodes.TryGetValue(GetOrDefault(Form, 'code'), Code) then
      begin
        WriteOAuthError(AResponse, 400, 'invalid_grant', 'Unknown authorization code');
        Exit;
      end;
      if Code.Used or (Code.ExpiresAt < Now) then
      begin
        WriteOAuthError(AResponse, 400, 'invalid_grant', 'Authorization code already used or expired');
        Exit;
      end;
      if Code.ClientId <> GetOrDefault(Form, 'client_id') then
      begin
        WriteOAuthError(AResponse, 400, 'invalid_grant', 'client_id does not match the authorization request');
        Exit;
      end;
      if Code.RedirectURI <> GetOrDefault(Form, 'redirect_uri') then
      begin
        WriteOAuthError(AResponse, 400, 'invalid_grant', 'redirect_uri does not match the authorization request');
        Exit;
      end;
      if not PKCEChallengeMatches(GetOrDefault(Form, 'code_verifier'), Code.CodeChallenge) then
      begin
        WriteOAuthError(AResponse, 400, 'invalid_grant', 'PKCE code_verifier does not match code_challenge');
        Exit;
      end;

      Code.Used := True;
      FAuthCodes.AddOrSetValue(GetOrDefault(Form, 'code'), Code);

      Grant.ClientId := Code.ClientId;
      Grant.Subject := Code.Subject;
      Grant.Resource := Code.Resource;
      Grant.Scopes := Code.Scopes;
      Grant.ExpiresAt := Now + (AccessTokenLifetimeSeconds / 86400);
      IssueGrant(Grant, AccessToken, RefreshToken);

      LogMessage(Format('Issued access token for client %s, subject %s, scopes [%s]',
        [Grant.ClientId, Grant.Subject, ScopesToString(Grant.Scopes)]));
    end
    else if GrantType = 'refresh_token' then
    begin
      if not FRefreshTokens.TryGetValue(GetOrDefault(Form, 'refresh_token'), Grant) then
      begin
        WriteOAuthError(AResponse, 400, 'invalid_grant', 'Unknown refresh token');
        Exit;
      end;
      // Rotate: the old refresh token is single-use.
      FRefreshTokens.Remove(GetOrDefault(Form, 'refresh_token'));
      Grant.ExpiresAt := Now + (AccessTokenLifetimeSeconds / 86400);
      IssueGrant(Grant, AccessToken, RefreshToken);

      LogMessage(Format('Refreshed access token for client %s, subject %s', [Grant.ClientId, Grant.Subject]));
    end
    else
    begin
      WriteOAuthError(AResponse, 400, 'unsupported_grant_type', 'Only authorization_code and refresh_token are supported');
      Exit;
    end;

    RespObj := TJSONObject.Create;
    try
      RespObj.AddPair('access_token', AccessToken);
      RespObj.AddPair('token_type', 'Bearer');
      RespObj.AddPair('expires_in', TJSONNumber.Create(AccessTokenLifetimeSeconds));
      RespObj.AddPair('refresh_token', RefreshToken);
      RespObj.AddPair('scope', ScopesToString(Grant.Scopes));
      WriteJSON(AResponse, RespObj.ToJSON);
    finally
      RespObj.Free;
    end;
  finally
    Form.Free;
  end;
end;

procedure TAuthServerHandlers.HandleIntrospect(ARequest: TTMSMCPHTTPServerRequest; AResponse: TTMSMCPHTTPServerResponse);
var
  Form: TDictionary<string, string>;
  Token: string;
  Grant: TIssuedGrant;
  RespObj: TJSONObject;
begin
  Form := ParseFormEncoded(ReadBody(ARequest));
  try
    Token := GetOrDefault(Form, 'token');
    RespObj := TJSONObject.Create;
    try
      if FAccessTokens.TryGetValue(Token, Grant) and (Grant.ExpiresAt > Now) then
      begin
        RespObj.AddPair('active', TJSONBool.Create(True));
        RespObj.AddPair('sub', Grant.Subject);
        RespObj.AddPair('client_id', Grant.ClientId);
        RespObj.AddPair('scope', ScopesToString(Grant.Scopes));
        RespObj.AddPair('aud', Grant.Resource);
        RespObj.AddPair('exp', TJSONNumber.Create(UnixTimestamp(Grant.ExpiresAt)));
      end
      else
        RespObj.AddPair('active', TJSONBool.Create(False));
      WriteJSON(AResponse, RespObj.ToJSON);
    finally
      RespObj.Free;
    end;
  finally
    Form.Free;
  end;
end;

procedure TAuthServerHandlers.HandleServerRequest(AConnection: TTMSMCPHTTPServerConnection;
  ARequest: TTMSMCPHTTPServerRequest; AResponse: TTMSMCPHTTPServerResponse);
begin
  AResponse.Headers.AddValue('Access-Control-Allow-Origin', '*');
  AResponse.Headers.AddValue('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  AResponse.Headers.AddValue('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if ARequest.CommandType = hsmOPTION then
  begin
    AResponse.ResponseCode := 204;
    Exit;
  end;

  LogMessage(Format('%s %s', [ARequest.Command, ARequest.URI]));

  try
    if (ARequest.URI = '/.well-known/oauth-authorization-server') and (ARequest.CommandType = hsmGET) then
      HandleDiscovery(AResponse)
    else if (ARequest.URI = '/register') and (ARequest.CommandType = hsmPOST) then
      HandleRegister(ARequest, AResponse)
    else if (ARequest.URI = '/authorize') and (ARequest.CommandType = hsmGET) then
      HandleAuthorize(ARequest, AResponse)
    else if (ARequest.URI = '/authorize/approve') and (ARequest.CommandType = hsmPOST) then
      HandleApprove(ARequest, AResponse)
    else if (ARequest.URI = '/token') and (ARequest.CommandType = hsmPOST) then
      HandleToken(ARequest, AResponse)
    else if (ARequest.URI = '/introspect') and (ARequest.CommandType = hsmPOST) then
      HandleIntrospect(ARequest, AResponse)
    else
    begin
      AResponse.ResponseCode := 404;
      AResponse.Headers.AddValue('Content-Type', 'application/json');
      AResponse.ContentText := '{"error":"not_found"}';
    end;
  except
    on E: Exception do
    begin
      LogMessage('Error: ' + E.Message);
      WriteOAuthError(AResponse, 500, 'server_error', E.Message);
    end;
  end;
end;

{ TAuthServerService }

procedure TAuthServerService.LoadConfig;
var
  Ini: TIniFile;
  IniFile: string;
begin
  IniFile := TPath.ChangeExtension(ParamStr(0), '.ini');
  Ini := TIniFile.Create(IniFile);
  try
    FPort := Ini.ReadInteger('Server', 'Port', 9000);
    FBindingIP := Ini.ReadString('Server', 'BindingIP', '');
    FUseSSL := Ini.ReadBool('Server', 'UseSSL', False);
    FSSLCertFile := Ini.ReadString('Server', 'SSLCertFile', '');
    FIssuer := Ini.ReadString('Server', 'Issuer', Format('http://localhost:%d', [FPort]));
    FLogFile := Ini.ReadString('Logging', 'LogFile', '');
    if FLogFile = '' then
      FLogFile := TPath.ChangeExtension(ParamStr(0), '.log');
  finally
    Ini.Free;
  end;
end;

procedure TAuthServerService.ServiceCreate(Sender: TObject);
begin
  LoadConfig;

  Handlers := TAuthServerHandlers.Create(FIssuer, FLogFile);
  Handlers.LogMessage('Service created.');

  HttpServer := TTMSMCPHTTPServer.Create(nil);
  HttpServer.OnCommandGet := Handlers.HandleServerRequest;
  HttpServer.OnCommandOther := Handlers.HandleServerRequest;
  HttpServer.Port := FPort;
  if FBindingIP <> '' then
    HttpServer.BindingIP := FBindingIP;
  HttpServer.UseSSL := FUseSSL;
  if FUseSSL and (FSSLCertFile <> '') then
    TTMSMCPHTTPServerFriend(HttpServer).SSLCertFile := FSSLCertFile;
end;

procedure TAuthServerService.ServiceDestroy(Sender: TObject);
begin
  FreeAndNil(HttpServer);
  FreeAndNil(Handlers);
end;

procedure TAuthServerService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  HttpServer.Active := True;
  Handlers.LogMessage(Format('Listening on %s (port %d, SSL=%s). Ready.',
    [FIssuer, FPort, BoolToStr(FUseSSL, True)]));
  Started := True;
end;

procedure TAuthServerService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  HttpServer.Active := False;
  Handlers.LogMessage('Service stopped.');
  Stopped := True;
end;

end.
