unit MCPSimple.DM;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  TMS.MCP.CustomComponent,
  TMS.MCP.Server;

type
  TDM = class(TDataModule)
    TMSMCPServer1: TTMSMCPServer;
    function TMSMCPServer1Tools0Execute(const Args: array of TValue): TValue;
  private
  public
     procedure Run;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TDM.Run;
begin
  TMSMCPServer1.Start;
  TMSMCPServer1.Run;
  WriteLn('Server running');
  ReadLn;
end;

function TDM.TMSMCPServer1Tools0Execute(const Args: array of TValue): TValue;
begin
  var LNomeUsuario := Args[0].AsString;
  Result := TValue.From<string>(LNomeUsuario + '_123ACB');
end;

end.
