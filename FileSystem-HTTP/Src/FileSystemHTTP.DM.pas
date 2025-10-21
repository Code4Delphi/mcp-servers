unit FileSystemHTTP.DM;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  TMS.MCP.Server,
  TMS.MCP.Transport,
  TMS.MCP.Transport.StreamableHTTP,
  TMS.MCP.CustomComponent,
  FileSystemHTTP.Utils;

type
  TFileSystemHTTPDM = class(TDataModule)
    TMSMCPServer1: TTMSMCPServer;
    procedure TMSMCPServer1Log(Sender: TObject; const LogMessage: string);
    procedure DataModuleCreate(Sender: TObject);
    function TMSMCPServer1Tools0Execute(const Args: array of TValue): TValue;
  private
    FRootDirectory: string;
  public
    procedure Run;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

const
  HTTP_PORT = 8080;
  HTTP_END_POINT = '/filesystem';

procedure TFileSystemHTTPDM.DataModuleCreate(Sender: TObject);
begin
  TMSMCPStreamableHTTPTransport1.Port := HTTP_PORT;
  TMSMCPStreamableHTTPTransport1.MCPEndpoint := HTTP_END_POINT;

  FRootDirectory := 'C:\TempIA\';
  if not ParamStr(1).Trim.IsEmpty then
    FRootDirectory := IncludeTrailingPathDelimiter(ParamStr(1).Trim);

  if not DirectoryExists(FRootDirectory) then
   TUtils.FolderCreate(FRootDirectory);
end;

procedure TFileSystemHTTPDM.TMSMCPServer1Log(Sender: TObject; const LogMessage: string);
begin
  WriteLn(Format('[%s] %s', [DateTimeToStr(Now), LogMessage]));
end;

procedure TFileSystemHTTPDM.Run;
begin
  TMSMCPServer1.Start;
  WriteLn('Server running');
  WriteLn('Name: ' + TMSMCPServer1.ServerName);
  WriteLn('Port: ' + HTTP_PORT.ToString);
  WriteLn('Endpoint: ' + HTTP_END_POINT);
  WriteLn('Press Enter to stop...');
  ReadLn;
end;

function TFileSystemHTTPDM.TMSMCPServer1Tools0Execute(const Args: array of TValue): TValue;
begin
  Result := TValue.From<string>(TUtils.ListFolderContents(FRootDirectory));
end;

end.
