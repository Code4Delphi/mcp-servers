unit DatabaseHTTP.Connection.Params;

interface

uses
  System.SysUtils,
  DatabaseHTTP.Utils,
  DatabaseHTTP.Types,
  TMS.MCP.Helpers;

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
  FDBType := TDBType.SQLite;
  FDatabase := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'sample.db';
  FServer := 'localhost';
  FUsername := '';
  FPassword := '';
  FPort := 0;
  FCreateSampleData := False;

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
      FCreateSampleData := True;
    end
    else if LParam.StartsWith('-') then
    begin
      if LParam.Contains('=') then
      begin
        LParamName := LParam.Substring(1, LParam.IndexOf('=') - 1).ToLower;
        LParamValue := LParam.Substring(LParam.IndexOf('=') + 1);

        if LParamValue.StartsWith('"') and LParamValue.EndsWith('"') then
          LParamValue := LParamValue.Substring(1, LParamValue.Length - 2);

        if LParamName = 'type' then
        begin
          LParamValue := LParamValue.ToLower;
          if LParamValue = 'sqlite' then
            FDBType := TDBType.SQLite
          else if LParamValue = 'mysql' then
            FDBType := TDBType.MySQL
          else if LParamValue = 'mssql' then
            FDBType := TDBType.MSSQL
          else if LParamValue = 'postgres' then
            FDBType := TDBType.PostgreSQL
          else if LParamValue = 'firebird' then
            FDBType := TDBType.Firebird
          else
          begin
            ShowHelp;
            RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Error: Unknown database type: ' + LParamValue);
            Halt(1);
          end;
        end
        else if LParamName = 'db' then
          FDatabase := LParamValue  // Now properly handles spaces
        else if LParamName = 'server' then
          FServer := LParamValue
        else if LParamName = 'user' then
          FUsername := LParamValue
        else if LParamName = 'pass' then
          FPassword := LParamValue
        else if LParamName = 'port' then
        begin
          try
            FPort := StrToInt(LParamValue);
          except
            RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Error: Invalid port number: ' + LParamValue);
            Halt(1);
          end;
        end;
      end;
    end;
  end;

  // Validate parameters
  if FDBType <> TDBType.SQLite then
  begin
    if FUsername = '' then
      Halt(1);
  end;
end;

end.
