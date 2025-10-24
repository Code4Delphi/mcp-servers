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
    TMSMCPStreamableHTTPTransport1: TTMSMCPStreamableHTTPTransport;
    procedure TMSMCPServer1Log(Sender: TObject; const LogMessage: string);
    procedure DataModuleCreate(Sender: TObject);
    function TMSMCPServer1Tools0Execute(const Args: array of TValue): TValue;
    function TMSMCPServer1Tools1Execute(const Args: array of TValue): TValue;
    function TMSMCPServer1Tools2Execute(const Args: array of TValue): TValue;
    function TMSMCPServer1Tools3Execute(const Args: array of TValue): TValue;
    function TMSMCPServer1Tools4Execute(const Args: array of TValue): TValue;
  private
    FRootDirectory: string;
  public
    procedure Run;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TFileSystemHTTPDM.DataModuleCreate(Sender: TObject);
begin
  FRootDirectory := 'C:\TempIA\';
  TUtils.FolderCreate(FRootDirectory);
end;

procedure TFileSystemHTTPDM.Run;
begin
  TMSMCPServer1.Start;
  WriteLn('Server running');
  WriteLn('Name: ' + TMSMCPServer1.ServerName);
  WriteLn('Port: ' + TMSMCPStreamableHTTPTransport1.Port.ToString);
  WriteLn('Endpoint: ' + TMSMCPStreamableHTTPTransport1.MCPEndpoint);
  WriteLn('Press Enter to stop...');
  ReadLn;
end;

procedure TFileSystemHTTPDM.TMSMCPServer1Log(Sender: TObject; const LogMessage: string);
begin
  WriteLn(Format('[%s] %s', [DateTimeToStr(Now), LogMessage]));
end;

function TFileSystemHTTPDM.TMSMCPServer1Tools0Execute(const Args: array of TValue): TValue;
begin
  Result := TValue.From<string>(TUtils.ListFolderContents(FRootDirectory));
end;

function TFileSystemHTTPDM.TMSMCPServer1Tools1Execute(const Args: array of TValue): TValue;
var
  LFileName: string;
  LResult: string;
begin
  if Length(Args) <= 0 then
  begin
    Result := TValue.From<string>('File not informed');
    Exit;
  end;

  LFileName := FRootDirectory + Args[0].AsString;
  if not FileExists(LFileName) then
  begin
    Result := TValue.From<string>('File does not exist: ' + LFileName);
    Exit;
  end;

  try
    LResult := TUtils.ShowFileContents(LFileName);
  except on E: Exception do
    LResult := 'Unable to return data. Msg: ' + E.Message;
  end;

  Result := TValue.From<string>(LResult);
end;

function TFileSystemHTTPDM.TMSMCPServer1Tools2Execute(const Args: array of TValue): TValue;
var
  LFolderPath: string;
  LResult: string;
begin
  if Length(Args) <= 0 then
  begin
    Result := TValue.From<string>('Name folder not informed');
    Exit;
  end;

  LFolderPath := FRootDirectory + Args[0].AsString;
  if DirectoryExists(LFolderPath) then
  begin
    Result := TValue.From<string>('Folder already exists: ' + LFolderPath);
    Exit;
  end;

  LResult := 'Unable to create folder';
  try
    if TUtils.FolderCreate(LFolderPath) then
      LResult := 'Folder created successfully in: ' + LFolderPath;
  except on E: Exception do
    LResult := 'Unable to create folder. Msg: ' + E.Message;
  end;

  Result := TValue.From<string>(LResult);
end;

function TFileSystemHTTPDM.TMSMCPServer1Tools3Execute(const Args: array of TValue): TValue;
var
  LFileName: string;
  LContent: string;
  LResult: string;
begin
  if Length(Args) <= 0 then
  begin
    Result := TValue.From<string>('Name file not informed');
    Exit;
  end;

  LFileName := FRootDirectory + Args[0].AsString;
  if FileExists(LFileName) then
  begin
    Result := TValue.From<string>('File already exists: ' + LFileName);
    Exit;
  end;

  LContent := '';
  if Length(Args) > 1 then
    LContent := Args[1].AsString;

  LResult := 'Unable to create file';
  try
    if TUtils.FileCreate(LFileName, LContent) then
      LResult := 'File created successfully in: ' + LFileName;
  except on E: Exception do
    LResult := 'Unable to create file. Msg: ' + E.Message;
  end;

  Result := TValue.From<string>(LResult);
end;

function TFileSystemHTTPDM.TMSMCPServer1Tools4Execute(const Args: array of TValue): TValue;
var
  LOld: string;
  LNew: string;
  LResult: string;
begin
  if Length(Args) <= 1 then
  begin
    Result := TValue.From<string>('Old or new names not provided');
    Exit;
  end;

  LOld := FRootDirectory + Args[0].AsString;
  if not(FileExists(LOld)) and not(DirectoryExists(LOld))  then
  begin
    Result := TValue.From<string>('File or folder not found: ' + LOld);
    Exit;
  end;

  LNew := FRootDirectory + Args[1].AsString;
  if FileExists(LNew) or DirectoryExists(LNew) then
  begin
    Result := TValue.From<string>('Folder or file already exists: ' + LNew);
    Exit;
  end;

  LResult := 'Unable to rename';
  try
    if TUtils.RenameFileOrFolder(LOld, LNew) then
      LResult := 'File/folder renamed successfully';
  except on E: Exception do
    LResult := 'Unable to rename. Msg: ' + E.Message;
  end;

  Result := TValue.From<string>(LResult);
end;

end.
