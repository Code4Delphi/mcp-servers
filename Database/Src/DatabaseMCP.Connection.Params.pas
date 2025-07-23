unit DatabaseMCP.Connection.Params;

interface

uses
  System.SysUtils,
  DatabaseMCP.Utils,
  DatabaseMCP.Types;

type
  TConnectionParams = class
  private
    FDBType: TDBType;
    FDatabase: string;
    FServer: string;
    FUsername: string;
    FPassword: string;
    FPort: Integer;
    FCreateSampleData: Boolean;
  public
    constructor Create;
    property DBType: TDBType read FDBType write FDBType;
    property Database: string read FDatabase write FDatabase;
    property Server: string read FServer write FServer;
    property Username: string read FUsername write FUsername;
    property Password: string read FPassword write FPassword;
    property Port: Integer read FPort write FPort;
    property CreateSampleData: Boolean read FCreateSampleData write FCreateSampleData;
  end;

implementation

constructor TConnectionParams.Create;
var
  I: Integer;
  LParam: string;
  LParamName: string;
  LParamValue: string;
begin
  // Set defaults
  Self.DBType := TDBType.SQLite;
  Self.Database := 'sample.db';
  Self.Server := 'localhost';
  Self.Username := '';
  Self.Password := '';
  Self.Port := 0;
  Self.CreateSampleData := False;

  for I := 1 to ParamCount do
  begin
    LParam := ParamStr(I);

    if (LParam = '-help') or (LParam = '--help') or (LParam = '/?') then
    begin
      ShowHelp;
      Halt(0);
    end
    else if LParam = '-sample' then
    begin
      Self.CreateSampleData := True;
    end
    else if LParam.StartsWith('-') then
    begin
      if LParam.Contains('=') then
      begin
        LParamName := LParam.Substring(1, LParam.IndexOf('=') - 1).ToLower;
        LParamValue := LParam.Substring(LParam.IndexOf('=') + 1);

        if LParamValue.StartsWith('"') and LParamValue.EndsWith('"') then
        begin
          LParamValue := LParamValue.Substring(1, LParamValue.Length - 2);
        end;

        if LParamName = 'type' then
        begin
          LParamValue := LParamValue.ToLower;
          if LParamValue = 'sqlite' then
            Self.DBType := TDBType.SQLite
          else if LParamValue = 'mysql' then
            Self.DBType := TDBType.MySQL
          else if LParamValue = 'mssql' then
            Self.DBType := TDBType.MSSQL
          else if LParamValue = 'postgres' then
            Self.DBType := TDBType.PostgreSQL
          else if LParamValue = 'firebird' then
            Self.DBType := TDBType.Firebird
          else
          begin
            WriteLn('Error: Unknown database type: ' + LParamValue);
            ShowHelp;
            Halt(1);
          end;
        end
        else if LParamName = 'db' then
          Self.Database := LParamValue  // Now properly handles spaces
        else if LParamName = 'server' then
          Self.Server := LParamValue
        else if LParamName = 'user' then
          Self.Username := LParamValue
        else if LParamName = 'pass' then
          Self.Password := LParamValue
        else if LParamName = 'port' then
        begin
          try
            Self.Port := StrToInt(LParamValue);
          except
            WriteLn('Error: Invalid port number: ' + LParamValue);
            Halt(1);
          end;
        end;
      end;
    end;
  end;

  // Validate parameters
  if Self.DBType <> TDBType.SQLite then
  begin
    if Self.Username = '' then
      Halt(1);
  end;
end;

end.
