unit DatabaseHTTP.Database;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Rtti,
  System.Generics.Collections,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Pool,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Stan.ExprFuncs,
  FireDAC.VCLUI.Wait,
  FireDAC.DApt,
  FireDAC.Stan.Param,
  TMS.MCP.Helpers,
  DatabaseHTTP.Types,
  DatabaseHTTP.Connection.Params;

type
  TDatabase = class
  private
    FConnection: TFDConnection;
    FParams: TConnectionParams;
    function ExecuteQuery(const ASQL: string): TJSONValue;
    function GetTableSchema(const ATableName: string): TJSONValue;
    function QuerySafeguard(const ASQL: string): Boolean;
    procedure CreateSampleDatabase;
    procedure Config;
  public
    constructor Create;
    destructor Destroy; override;
    // MCP Tool Methods
    function RunSQLQuery(const Args: array of TValue): TValue;
    function GetTableList(const Args: array of TValue): TValue;
    function GetTableInfo(const Args: array of TValue): TValue;
    function CreateTable(const Args: array of TValue): TValue;
    function DropTable(const Args: array of TValue): TValue;
    function InsertData(const Args: array of TValue): TValue;
    function UpdateData(const Args: array of TValue): TValue;
    function DeleteData(const Args: array of TValue): TValue;
  end;

implementation

constructor TDatabase.Create;
begin
  FParams := TConnectionParams.Create;
  FConnection := TFDConnection.Create(nil);
end;

destructor TDatabase.Destroy;
begin
  FParams.Free;
  FConnection.Free;
  inherited;
end;

procedure TDatabase.Config;
begin     
  if FConnection.Connected then
    Exit;  
    
  case FParams.DBType of
    TDBType.SQLite:
    begin    
      FConnection.Params.DriverID := 'SQLite';
      FConnection.Params.Database := FParams.Database;

      // Create sample database if it doesn't exist and sample flag is on
      if (not FileExists(FParams.Database)) and FParams.CreateSampleData then
        Self.CreateSampleDatabase;

      if not FileExists(FParams.Database) then
        RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Database not found. The path of the bank informed is: ' + FParams.Database);
    end;
    TDBType.MySQL:
    begin
      FConnection.Params.DriverID := 'MySQL';
      FConnection.Params.Database := FParams.Database;
      FConnection.Params.Values['Server'] := FParams.Server;
      FConnection.Params.UserName := FParams.Username;
      FConnection.Params.Password := FParams.Password;
      if FParams.Port > 0 then
        FConnection.Params.Values['Port'] := IntToStr(FParams.Port);
    end;
    TDBType.MSSQL:
    begin
      FConnection.Params.DriverID := 'MSSQL';
      FConnection.Params.Database := FParams.Database;
      FConnection.Params.Values['Server'] := FParams.Server;
      FConnection.Params.UserName := FParams.Username;
      FConnection.Params.Password := FParams.Password;
      if FParams.Port > 0 then
        FConnection.Params.Values['Port'] := IntToStr(FParams.Port);
    end;
    TDBType.PostgreSQL:
    begin
      FConnection.Params.DriverID := 'PG';
      FConnection.Params.Database := FParams.Database;
      FConnection.Params.Values['Server'] := FParams.Server;
      FConnection.Params.UserName := FParams.Username;
      FConnection.Params.Password := FParams.Password;
      if FParams.Port > 0 then
        FConnection.Params.Values['Port'] := IntToStr(FParams.Port);
    end;
    TDBType.Firebird:
    begin
      if not FileExists(FParams.Database) then
        RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Database not found. The path of the bank informed is: ' + FParams.Database);

      FConnection.Params.DriverID := 'FB';
      FConnection.Params.Database := FParams.Database;
      FConnection.Params.Values['Server'] := FParams.Server;
      FConnection.Params.UserName := FParams.Username;
      FConnection.Params.Password := FParams.Password;
      if FParams.Port > 0 then
        FConnection.Params.Values['Port'] := IntToStr(FParams.Port);
    end;
  end;

  FConnection.LoginPrompt := False;

  try
    FConnection.Connected := True;
  except
    on E: Exception do
      RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed,
        'Unable to connect to the database, the following message indicates the possible problem: ' + E.Message);
  end;
end;

procedure TDatabase.CreateSampleDatabase;
var
  LConnection: TFDConnection;
begin
  LConnection := TFDConnection.Create(nil);
  try
    LConnection.Params.DriverID := 'SQLite';
    LConnection.Params.Database := 'C:\IA\mcp-servers\Database\Bin\sample.db';    
    LConnection.LoginPrompt := False;
    LConnection.Connected := True;

    // Create sample tables
    LConnection.ExecSQL('CREATE TABLE customers (id INTEGER PRIMARY KEY, name TEXT, email TEXT, created_at TEXT)');
    LConnection.ExecSQL('CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT, price REAL, quantity INTEGER)');
    LConnection.ExecSQL('CREATE TABLE orders (id INTEGER PRIMARY KEY, customer_id INTEGER, order_date TEXT, ' +
                       'FOREIGN KEY(customer_id) REFERENCES customers(id))');
    LConnection.ExecSQL('CREATE TABLE order_items (id INTEGER PRIMARY KEY, order_id INTEGER, product_id INTEGER, ' +
                       'quantity INTEGER, price REAL, ' +
                       'FOREIGN KEY(order_id) REFERENCES orders(id), ' +
                       'FOREIGN KEY(product_id) REFERENCES products(id))');

    // Insert sample data
    LConnection.ExecSQL('INSERT INTO customers (name, email, created_at) VALUES ' +
                       '("John Doe", "john@example.com", "2023-01-15"), ' +
                       '("Jane Smith", "jane@example.com", "2023-02-20"), ' +
                       '("Bob Johnson", "bob@example.com", "2023-03-10")');

    LConnection.ExecSQL('INSERT INTO products (name, price, quantity) VALUES ' +
                       '("Laptop", 999.99, 10), ' +
                       '("Smartphone", 699.99, 20), ' +
                       '("Headphones", 149.99, 30)');

    LConnection.ExecSQL('INSERT INTO orders (customer_id, order_date) VALUES ' +
                       '(1, "2023-04-05"), ' +
                       '(2, "2023-04-10"), ' +
                       '(3, "2023-04-15")');

    LConnection.ExecSQL('INSERT INTO order_items (order_id, product_id, quantity, price) VALUES ' +
                       '(1, 1, 1, 999.99), ' +
                       '(1, 3, 1, 149.99), ' +
                       '(2, 2, 2, 699.99), ' +
                       '(3, 1, 1, 999.99), ' +
                       '(3, 2, 1, 699.99), ' +
                       '(3, 3, 2, 149.99)');
  finally
    LConnection.Free;
  end;
end;

function TDatabase.QuerySafeguard(const ASQL: string): Boolean;
var
  LUpperSQL: string;
begin
  // Enhanced safety check to allow data modification with safeguards
  LUpperSQL := UpperCase(ASQL.Trim);

  // Allowed operations
  Result := LUpperSQL.StartsWith('SELECT') or
    LUpperSQL.StartsWith('INSERT') or
    LUpperSQL.StartsWith('UPDATE') or
    LUpperSQL.StartsWith('DELETE') or
    LUpperSQL.StartsWith('CREATE TABLE') or
    LUpperSQL.StartsWith('ALTER TABLE') or
    LUpperSQL.StartsWith('DROP TABLE');

  // Block potentially dangerous operations
  if LUpperSQL.Contains('PRAGMA') or LUpperSQL.Contains('ATTACH') or LUpperSQL.Contains('DETACH') then
    Result := False;
end;

function TDatabase.ExecuteQuery(const ASQL: string): TJSONValue;
var
  LQuery: TFDQuery;
  LResultArray: TJSONArray;
  LRowObj: TJSONObject;
  LField: TField;
  I: Integer;
  LIsSelectQuery: Boolean;
  LResultObj: TJSONObject;
  LRowsAffected: Integer;
begin
  Result := nil;

  if not QuerySafeguard(ASQL) then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Query not allowed for security reasons');

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := ASQL;

    LIsSelectQuery := UpperCase(ASQL.TrimLeft).StartsWith('SELECT');

    try
      if LIsSelectQuery then
      begin
        // Handle SELECT queries with result sets
        LQuery.Open;
        LResultArray := TJSONArray.Create;

        while not LQuery.Eof do
        begin
          LRowObj := TJSONObject.Create;

          for I := 0 to LQuery.FieldCount - 1 do
          begin
            LField := LQuery.Fields[I];

            if LField.IsNull then
              LRowObj.AddPair(LField.FieldName, TJSONNull.Create)
            else
            begin
              case LField.DataType of
                ftString, ftWideString, ftMemo, ftWideMemo:
                  LRowObj.AddPair(LField.FieldName, LField.AsString);
                ftInteger, ftSmallint, ftWord, ftLargeint:
                  LRowObj.AddPair(LField.FieldName, TJSONNumber.Create(LField.AsInteger));
                ftFloat, ftCurrency, ftBCD:
                  LRowObj.AddPair(LField.FieldName, TJSONNumber.Create(LField.AsFloat));
                ftBoolean:
                  LRowObj.AddPair(LField.FieldName, TJSONBool.Create(LField.AsBoolean));
                ftDate, ftDateTime, ftTimeStamp:
                  LRowObj.AddPair(LField.FieldName, FormatDateTime('yyyy-mm-dd hh:nn:ss', LField.AsDateTime));
                else
                  LRowObj.AddPair(LField.FieldName, LField.AsString);
              end;
            end;
          end;

          LResultArray.Add(LRowObj);
          LQuery.Next;
        end;

        Result := LResultArray;
      end
      else
      begin
        // Handle non-SELECT queries (INSERT, UPDATE, DELETE, CREATE, ALTER, DROP)
        LQuery.ExecSQL(ASQL);

        LRowsAffected := 0;
        LResultObj := TJSONObject.Create;
        LResultObj.AddPair('success', TJSONBool.Create(True));
        LResultObj.AddPair('rowsAffected', TJSONNumber.Create(LRowsAffected));
        LResultObj.AddPair('message', Format('Query executed successfully. Rows affected: %d', [LRowsAffected]));

        Result := LResultObj;
      end;
    except
      on E: Exception do
      begin
        RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Query execution error: ' + E.Message);
      end;
    end;
  finally
    LQuery.Free;
  end;
end;

function TDatabase.GetTableSchema(const ATableName: string): TJSONValue;
var
  LQuery: TFDQuery;
  LResultArray: TJSONArray;
  LColumnObj: TJSONObject;
begin
  Result := nil;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;

    // SQLite-specific LQuery to get table schema
    LQuery.SQL.Text := 'PRAGMA table_info(' + ATableName + ')';

    try
      LQuery.Open;

      LResultArray := TJSONArray.Create;

      while not LQuery.Eof do
      begin
        LColumnObj := TJSONObject.Create;
        LColumnObj.AddPair('name', LQuery.FieldByName('name').AsString);
        LColumnObj.AddPair('type', LQuery.FieldByName('type').AsString);
        LColumnObj.AddPair('notnull', TJSONBool.Create(LQuery.FieldByName('notnull').AsInteger = 1));
        LColumnObj.AddPair('pk', TJSONBool.Create(LQuery.FieldByName('pk').AsInteger = 1));

        LResultArray.Add(LColumnObj);
        LQuery.Next;
      end;

      Result := LResultArray;
    except
      on E: Exception do
      begin
        RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Table schema query error: ' + E.Message);
      end;
    end;
  finally
    LQuery.Free;
  end;
end;

function TDatabase.RunSQLQuery(const Args: array of TValue): TValue;
var
  LSQL: string;
  LQueryResult: TJSONValue;
begin
  Self.Config;
  
  if Length(Args) < 1 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing SQL parameter');

  LSQL := Args[0].AsString;

  LQueryResult := ExecuteQuery(LSQL);

  Result := TValue.From<string>(LQueryResult.ToString);
  LQueryResult.Free;
end;

function TDatabase.GetTableList(const Args: array of TValue): TValue;
var
  LQuery: TFDQuery;
  LTables: TJSONArray;
begin
  Self.Config;
  
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;

    // SQLite-specific LQuery to get table list
    LQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type=''table'' AND name NOT LIKE ''sqlite_%''';
    if FConnection.Params.DriverID = 'MySQL' then
      LQuery.SQL.Text := Format('SELECT table_name as name FROM information_schema.tables WHERE table_schema = "%s"', [FConnection.Params.Database])
    else if FConnection.Params.DriverID = 'FB' then
      LQuery.SQL.Text := 'SELECT RDB$RELATION_NAME as name FROM RDB$RELATIONS  WHERE RDB$SYSTEM_FLAG = 0 AND RDB$RELATION_TYPE = 0';

    try
      LQuery.Open;

      LTables := TJSONArray.Create;

      while not LQuery.Eof do
      begin
        LTables.Add(LQuery.FieldByName('name').AsString);
        LQuery.Next;
      end;

      Result := TValue.From<string>(LTables.ToString);
      LTables.Free;
    except
      on E: Exception do
        RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Error getting table list: ' + E.Message);
    end;
  finally
    LQuery.Free;
  end;
end;

function TDatabase.GetTableInfo(const Args: array of TValue): TValue;
var
  LTableName: string;
  LSchema: TJSONValue;
begin
  Self.Config;
  
  if Length(Args) < 1 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing table name parameter');

  LTableName := Args[0].AsString;

  LSchema := GetTableSchema(LTableName);
  try
    Result := TValue.From<string>(LSchema.ToString);
  finally
    LSchema.Free;
  end;
end;

function TDatabase.CreateTable(const Args: array of TValue): TValue;
var
  LTableName: string;
  LColumnDefs: string;
  LColDef: string;
  LSQL: string;
  LColumnDefsObj: TJSONValue;
  LColumnDefsArray: TJSONArray;
  I: Integer;
  LColumnObj: TJSONObject;
  LColumnName: string;
  LColumnType: string;
  LIsPrimary: Boolean;
  LIsNotNull: Boolean;
  LColumnSQL: TStringList;
  LJSONResult: TJSONValue;
begin
  Self.Config;

  if Length(Args) < 2 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing required parameters');

  LTableName := Args[0].AsString;
  LColumnDefs := Args[1].AsString;

  if LTableName.Trim = '' then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Table name cannot be empty');

  try
    LColumnDefsObj := TJSONObject.ParseJSONValue(LColumnDefs);
    if not (LColumnDefsObj is TJSONArray) then
      RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Column definitions must be a JSON array');

    LColumnDefsArray := TJSONArray(LColumnDefsObj);
    if LColumnDefsArray.Count = 0 then
      RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'At least one column must be defined');

    LColumnSQL := TStringList.Create;
    try
      for I := 0 to LColumnDefsArray.Count - 1 do
      begin
        if not (LColumnDefsArray.Items[I] is TJSONObject) then
          Continue;

        LColumnObj := TJSONObject(LColumnDefsArray.Items[I]);

        if not LColumnObj.TryGetValue<string>('name', LColumnName) or (LColumnName.Trim = '') then
          Continue;

        if not LColumnObj.TryGetValue<string>('type', LColumnType) then
          LColumnType := 'TEXT';

        if LColumnObj.TryGetValue<Boolean>('primary', LIsPrimary) then
          // Skip the primary key part here, will add later
        else
          LIsPrimary := False;

        if LColumnObj.TryGetValue<Boolean>('notNull', LIsNotNull) then
          // Skip the not null part here, will add later
        else
          LIsNotNull := False;

        // Build column definition
        LColDef := LColumnName + ' ' + LColumnType;

        if LIsNotNull then
          LColDef := LColDef + ' NOT NULL';

        if LIsPrimary then
          LColDef := LColDef + ' PRIMARY KEY';

        LColumnSQL.Add(LColDef);
      end;

      LSQL := Format('CREATE TABLE %s (%s)',
        [LTableName, LColumnSQL.CommaText.Replace('"', '')]);

      LJSONResult := ExecuteQuery(LSQL);
      Result := TValue.From<string>(LJSONResult.ToString);
    finally
      LColumnSQL.Free;
      LColumnDefsObj.Free;
    end;
  except
    on E: Exception do
      RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Error creating table: ' + E.Message);
  end;
end;

function TDatabase.DropTable(const Args: array of TValue): TValue;
var
  LTableName: string;
  LSQL: string;
  LJSONResult: TJSONValue;
begin
  Self.Config;

  if Length(Args) < 1 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing table name parameter');

  LTableName := Args[0].AsString;

  if LTableName.Trim = '' then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Table name cannot be empty');

  LSQL := Format('DROP TABLE IF EXISTS %s', [LTableName]);

  LJSONResult := ExecuteQuery(LSQL);
  Result := TValue.From<string>(LJSONResult.ToString);
end;

function TDatabase.InsertData(const Args: array of TValue): TValue;
var
  LTableName: string;
  LValuesJSON: string;
  LValuesObj: TJSONObject;
  LSQL: string;
  LColumnsStr: string;
  LValuesStr: string;
  I: Integer;
  LJSONResult: TJSONValue;
  LPair: TJSONPair;
  LQuery: TFDQuery;
begin
  Self.Config;

  if Length(Args) < 2 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing required parameters');

  LTableName := Args[0].AsString;
  LValuesJSON := Args[1].AsString;

  if LTableName.Trim = '' then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Table name cannot be empty');

  try
    LValuesObj := TJSONObject.ParseJSONValue(LValuesJSON) as TJSONObject;
    if not Assigned(LValuesObj) or (LValuesObj.Count = 0) then
      RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Values must be a non-empty JSON object');

    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;

      // Build column and values lists
      LColumnsStr := '';
      LValuesStr := '';

      for I := 0 to LValuesObj.Count - 1 do
      begin
        LPair := LValuesObj.Pairs[I];

        if I > 0 then
        begin
          LColumnsStr := LColumnsStr + ', ';
          LValuesStr := LValuesStr + ', ';
        end;

        LColumnsStr := LColumnsStr + LPair.JsonString.Value;
        LValuesStr := LValuesStr + ':' + LPair.JsonString.Value;
      end;

      LSQL := Format('INSERT INTO %s (%s) VALUES (%s)',
        [LTableName, LColumnsStr, LValuesStr]);

      LQuery.SQL.Text := LSQL;

      // Add parameter values
      for I := 0 to LValuesObj.Count - 1 do
      begin
        LPair := LValuesObj.Pairs[I];

        if LPair.JsonValue is TJSONNull then
          LQuery.ParamByName(LPair.JsonString.Value).Clear
        else if LPair.JsonValue is TJSONString then
          LQuery.ParamByName(LPair.JsonString.Value).AsString := TJSONString(LPair.JsonValue).Value
        else if LPair.JsonValue is TJSONNumber then
          LQuery.ParamByName(LPair.JsonString.Value).AsFloat := TJSONNumber(LPair.JsonValue).AsDouble
        else if LPair.JsonValue is TJSONBool then
          LQuery.ParamByName(LPair.JsonString.Value).AsBoolean := TJSONBool(LPair.JsonValue).AsBoolean;
      end;

      LQuery.ExecSQL;

      LJSONResult := TJSONObject.Create;
      TJSONObject(LJSONResult).AddPair('success', TJSONBool.Create(True));
      TJSONObject(LJSONResult).AddPair('rowsAffected', TJSONNumber.Create(1));
      TJSONObject(LJSONResult).AddPair('message', 'Data inserted successfully');

      Result := TValue.From<string>(LJSONResult.ToString);
    finally
      LQuery.Free;
      LValuesObj.Free;
    end;
  except
    on E: Exception do
      RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Error inserting data: ' + E.Message);
  end;
end;

function TDatabase.UpdateData(const Args: array of TValue): TValue;
var
  LTableName: string;
  LSetValuesJSON: string;
  LWhereCondition: string;
  LSetValuesObj: TJSONObject;
  LSQL, SetClause: string;
  I: Integer;
  LPair: TJSONPair;
  LQuery: TFDQuery;
  LJSONResult: TJSONValue;
  LRowsAffected: integer;
begin
  Self.Config;

  if Length(Args) < 3 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing required parameters');

  LTableName := Args[0].AsString;
  LSetValuesJSON := Args[1].AsString;
  LWhereCondition := Args[2].AsString;

  if LTableName.Trim = '' then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Table name cannot be empty');

  try
    LSetValuesObj := TJSONObject.ParseJSONValue(LSetValuesJSON) as TJSONObject;
    if not Assigned(LSetValuesObj) or (LSetValuesObj.Count = 0) then
      RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Set values must be a non-empty JSON object');

    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;

      // Build SET clause
      SetClause := '';

      for I := 0 to LSetValuesObj.Count - 1 do
      begin
        LPair := LSetValuesObj.Pairs[I];

        if I > 0 then
          SetClause := SetClause + ', ';

        SetClause := SetClause + LPair.JsonString.Value + ' = :' + LPair.JsonString.Value;
      end;

      // Build LSQL statement
      LSQL := Format('UPDATE %s SET %s', [LTableName, SetClause]);

      if LWhereCondition.Trim <> '' then
        LSQL := LSQL + ' WHERE ' + LWhereCondition;

      LQuery.SQL.Text := LSQL;

      // Add parameter values
      for I := 0 to LSetValuesObj.Count - 1 do
      begin
        LPair := LSetValuesObj.Pairs[I];

        if LPair.JsonValue is TJSONNull then
          LQuery.ParamByName(LPair.JsonString.Value).Clear
        else if LPair.JsonValue is TJSONString then
          LQuery.ParamByName(LPair.JsonString.Value).AsString := TJSONString(LPair.JsonValue).Value
        else if LPair.JsonValue is TJSONNumber then
          LQuery.ParamByName(LPair.JsonString.Value).AsFloat := TJSONNumber(LPair.JsonValue).AsDouble
        else if LPair.JsonValue is TJSONBool then
          LQuery.ParamByName(LPair.JsonString.Value).AsBoolean := TJSONBool(LPair.JsonValue).AsBoolean;
      end;

      LRowsAffected := LQuery.ExecSQL(LSQL);

      LJSONResult := nil;
      Result := TJSONObject.Create;
      TJSONObject(LJSONResult).AddPair('success', TJSONBool.Create(True));
      TJSONObject(LJSONResult).AddPair('rowsAffected', TJSONNumber.Create(LRowsAffected));
      TJSONObject(LJSONResult).AddPair('message', Format('Data updated successfully. Rows affected: %d', [LRowsAffected]));

      Result := TValue.From<string>(LJSONResult.ToString);
    finally
      LQuery.Free;
      LSetValuesObj.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Error updating data: ' + E.Message);
    end;
  end;
end;

function TDatabase.DeleteData(const Args: array of TValue): TValue;
var
  LTableName: string;
  LWhereCondition: string;
  LSQL: string;
  LJSONResult: TJSONValue;
  LQuery: TFDQuery;
  LRowsAffected: integer;
begin
  Self.Config;

  if Length(Args) < 1 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing table name parameter');

  LTableName := Args[0].AsString;

  if Length(Args) >= 2 then
    LWhereCondition := Args[1].AsString
  else
    LWhereCondition := '';

  if LTableName.Trim = '' then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Table name cannot be empty');

  // Build LSQL statement
  LSQL := Format('DELETE FROM %s', [LTableName]);

  if LWhereCondition.Trim <> '' then
    LSQL := LSQL + ' WHERE ' + LWhereCondition;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := LSQL;

    LRowsAffected := LQuery.ExecSQL(LSQL);

    LJSONResult := TJSONObject.Create;
    TJSONObject(LJSONResult).AddPair('success', TJSONBool.Create(True));
    TJSONObject(LJSONResult).AddPair('rowsAffected', TJSONNumber.Create(LRowsAffected));
    TJSONObject(LJSONResult).AddPair('message', Format('Data deleted successfully. Rows affected: %d', [LRowsAffected]));

    Result := TValue.From<string>(LJSONResult.ToString);
  finally
    LQuery.Free;
  end;
end;

end.
