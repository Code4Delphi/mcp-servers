unit MCPServerOAuth.DM;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  TMS.MCP.Server,
  TMS.MCP.Transport,
  TMS.MCP.Transport.StreamableHTTP,
  TMS.MCP.CustomComponent;

type
  TMCPServerOAuthDM = class(TDataModule)
    TMSMCPServer1: TTMSMCPServer;
    TMSMCPStreamableHTTPTransport1: TTMSMCPStreamableHTTPTransport;
    procedure TMSMCPServer1Log(Sender: TObject; const LogMessage: string);
    procedure DataModuleCreate(Sender: TObject);
    function TMSMCPServer1Tools0Execute(const Args: array of TValue): TValue;
  private

  public

  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TMCPServerOAuthDM.DataModuleCreate(Sender: TObject);
begin
  TMSMCPServer1.Start;
  WriteLn('Server running');
  WriteLn('Name: ' + TMSMCPServer1.ServerName);
  WriteLn('Port: ' + TMSMCPStreamableHTTPTransport1.Port.ToString);
  WriteLn('Endpoint: ' + TMSMCPStreamableHTTPTransport1.MCPEndpoint);
  WriteLn('Press Enter to stop...');
  ReadLn;
end;

procedure TMCPServerOAuthDM.TMSMCPServer1Log(Sender: TObject; const LogMessage: string);
begin
  WriteLn(Format('[%s] %s', [DateTimeToStr(Now), LogMessage]));
end;

function TMCPServerOAuthDM.TMSMCPServer1Tools0Execute(const Args: array of TValue): TValue;
begin
  var LNomePessoal := Args[0].AsString;
  Result := TValue.From<string>('Código pessoal: ' + DateTimeToStr(Now));
end;

end.
