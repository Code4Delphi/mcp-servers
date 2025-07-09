unit Utils;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils;

type
  TUtils = class
  private

  public
    class function ListFolderContents(const AFolderPath: string; AExtension: string = '*'): string;
    class function FolderCreate(const AFolderPath: string): Boolean;
    class function FileCreate(const AFileName: string; const AContents: string = ''): Boolean;
    class function RenameFileOrFolder(const AOldName, ANewName: string): Boolean;
    class function ShowFileContents(const AFileName: string): string; static;
  end;

implementation

class function TUtils.ListFolderContents(const AFolderPath: string; AExtension: string = '*'): string;
var
  LFolder: string;
  LFile: string;
begin
  Result := '';

  for LFolder in TDirectory.GetDirectories(AFolderPath) do
    Result := Result + sLineBreak + TPath.GetFileName(LFolder);

  for LFile in TDirectory.GetFiles(AFolderPath, '*.' + AExtension) do
    Result := Result + sLineBreak + TPath.GetFileName(LFile);

  Result := Result.Trim;
end;

class function TUtils.FolderCreate(const AFolderPath: string): Boolean;
begin
  try
    if not TDirectory.Exists(AFolderPath) then
      TDirectory.CreateDirectory(AFolderPath);

    Result := True;
  except
    Result := False;
  end;
end;

class function TUtils.FileCreate(const AFileName: string; const AContents: string): Boolean;
begin
  try
    TFile.WriteAllText(AFileName, AContents);

    Result := True;
  except
    Result := False;
  end;
end;

class function TUtils.RenameFileOrFolder(const AOldName, ANewName: string): Boolean;
var
  LNewFileName: string;
begin
  try
    LNewFileName := TPath.Combine(TPath.GetDirectoryName(AOldName), ANewName);
    TDirectory.Move(AOldName, LNewFileName);
    Result := True;
  except
    on E: Exception do
    try
      TFile.Move(AOldName, LNewFileName);
      Result := True;
    except
      Result := False;
    end;
  end;
end;

class function TUtils.ShowFileContents(const AFileName: string): string;
begin
  Result := '';
  try
    if TFile.Exists(AFileName) then
      Result := TFile.ReadAllText(AFileName);
  except
    on E: Exception do
      Result := '';
  end;
end;

end.
