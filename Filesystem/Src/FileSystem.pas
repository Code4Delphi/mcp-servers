unit FileSystem;

interface

uses
  System.SysUtils,
  System.Classes,
  System.RTTI,
  TMS.MCP.Server,
  TMS.MCP.Tools,
  TMS.MCP.Helpers,
  TMS.MCP.Transport.SSE,
  FMX.TMSFNCCloudBase,
  Utils;

type
  TFileSystem = class
  private
    FMCPServer: TTMSMCPServer;
    FRootDirectory: string;
    procedure ListFilesAddTool;
    function ListFiles(const Args: array of TValue): TValue;
    procedure ShowFileContentsAddTool;
    function ShowFileContents(const Args: array of TValue): TValue;
    procedure FolderCreateAddTool;
    function FolderCreate(const Args: array of TValue): TValue;
    procedure FileCreateAddTool;
    function FileCreate(const Args: array of TValue): TValue;
    procedure RenameFileOrFolderAddTool;
    function RenameFileOrFolder(const Args: array of TValue): TValue;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Run;
  end;

implementation

constructor TFileSystem.Create;
begin
  FMCPServer := TTMSMCPServer.Create(nil);
  FMCPServer.ServerName := 'FileSystem';
  FMCPServer.ServerVersion := '1.0.0';

  FRootDirectory := 'C:\TempIA\';
  if not ParamStr(1).Trim.IsEmpty then
    FRootDirectory := IncludeTrailingPathDelimiter(ParamStr(1).Trim);

  if not DirectoryExists(FRootDirectory) then
   TUtils.FolderCreate(FRootDirectory);

  Self.ListFilesAddTool;
  Self.ShowFileContentsAddTool;
  Self.FolderCreateAddTool;
  Self.FileCreateAddTool;
  Self.RenameFileOrFolderAddTool;
end;

destructor TFileSystem.Destroy;
begin
  FMCPServer.Free;
  inherited;
end;

procedure TFileSystem.Run;
begin
  FMCPServer.Start;
  FMCPServer.Run;
end;

procedure TFileSystem.ListFilesAddTool;
var
  LTool: TTMSMCPTool;
begin
  LTool := TTMSMCPTool.CreateBuilder
    .Name('ListFiles')
    .Description('List files')
    .ReturnType(ptString)
    .ExecuteCallback(Self.ListFiles)
    .Build;

  FMCPServer.Tools.Add(LTool);
end;

function TFileSystem.ListFiles(const Args: array of TValue): TValue;
begin
  Result := TValue.From<string>(TUtils.ListFolderContents(FRootDirectory));
end;

procedure TFileSystem.ShowFileContentsAddTool;
var
  LTool: TTMSMCPTool;
begin
  LTool := TTMSMCPTool.CreateBuilder
    .Name('ShowFileContents')
    .Description('Show File Contents')
    .ReturnType(ptString)
    .ExecuteCallback(Self.ShowFileContents)
    .AddProperty
      .Name('NameFile')
      .Description('Name of the file to open and display data')
      .PropertyType(ptString)
      .Required(True)
    .&end
    .Build;

  FMCPServer.Tools.Add(LTool);
end;

function TFileSystem.ShowFileContents(const Args: array of TValue): TValue;
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

procedure TFileSystem.FolderCreateAddTool;
var
  LTool: TTMSMCPTool;
begin
  LTool := TTMSMCPTool.CreateBuilder
    .Name('FolderCreate')
    .Description('Create a folder with the given name')
    .ReturnType(ptString)
    .ExecuteCallback(Self.FolderCreate)
    .AddProperty     //Crie uma pasta com o nome Teste56
      .Name('NameFolder')
      .Description('Name of the folder to be created')
      .PropertyType(ptString)
      .Required(True)
    .&end
    .Build;

  FMCPServer.Tools.Add(LTool);
end;

function TFileSystem.FolderCreate(const Args: array of TValue): TValue;
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

procedure TFileSystem.FileCreateAddTool;
var
  LTool: TTMSMCPTool;
begin
  LTool := TTMSMCPTool.CreateBuilder
    .Name('FileCreate')
    .Description('Create a file with the given name')
    .ReturnType(ptString)
    .ExecuteCallback(Self.FileCreate)
    .AddProperty
      .Name('NameFile')
      .Description('Name and extension of the file to be created')
      .PropertyType(ptString)
      .Required(True)
    .&end
    .AddProperty
      .Name('Contents')
      .Description('Content to be added to the file that will be created')
      .PropertyType(ptString)
      .Required(True)
    .&end
    .Build;

  FMCPServer.Tools.Add(LTool);
end;

function TFileSystem.FileCreate(const Args: array of TValue): TValue;
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

procedure TFileSystem.RenameFileOrFolderAddTool;
var
  LTool: TTMSMCPTool;
begin
  LTool := TTMSMCPTool.CreateBuilder
    .Name('RenameFileOrFolder')
    .Description('Rename folder or file name from old name to new name')
    .ReturnType(ptString)
    .ExecuteCallback(Self.RenameFileOrFolder)
    .AddProperty
      .Name('OldName')
      .Description('Name of the file or folder to be renamed')
      .PropertyType(ptString)
      .Required(True)
    .&end
    .AddProperty
      .Name('NewName')
      .Description('New name to be used')
      .PropertyType(ptString)
      .Required(True)
    .&end
    .Build;

  FMCPServer.Tools.Add(LTool);
end;

function TFileSystem.RenameFileOrFolder(const Args: array of TValue): TValue;
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
