unit MCPServerOAuth.DM;

interface

uses
  System.SysUtils,
  System.Classes,
  System.RTTI,
  TMS.MCP.CustomComponent,
  TMS.MCP.Server;

type
  TMCPServerOAuthDM = class(TDataModule)
    TMSMCPServer1: TTMSMCPServer;
    function TMSMCPServer1Tools0Execute(const Args: array of TValue): TValue;
    procedure DataModuleCreate(Sender: TObject);
  private

  public

  end;

var
  MCPServerOAuthDM: TMCPServerOAuthDM;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TMCPServerOAuthDM.DataModuleCreate(Sender: TObject);
begin
  TMSMCPServer1.Start;
  TMSMCPServer1.Run;
end;

function TMCPServerOAuthDM.TMSMCPServer1Tools0Execute(const Args: array of TValue): TValue;
begin
  var LNomePessoa := Args[0].AsString;

  Result := TValue.From<string>('Token pessoal é: ' + DateTimeToStr(Now));
end;

end.
