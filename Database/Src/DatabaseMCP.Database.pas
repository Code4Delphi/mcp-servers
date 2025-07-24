unit DatabaseMCP.Database;

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
  DatabaseMCP.Types,
  DatabaseMCP.Connection.Params;

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
    constructor Create(const AParams: TConnectionParams);
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

constructor TDatabase.Create(const AParams: TConnectionParams);
begin
  FParams := AParams;
end;

procedure TDatabase.Config;
begin
  FConnection := TFDConnection.Create(nil);
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

destructor TDatabase.Destroy;
begin
  FConnection.Free;
  inherited;
end;

procedure TDatabase.CreateSampleDatabase;
var
  LConnection: TFDConnection;
begin
  LConnection := TFDConnection.Create(nil);
  try
    LConnection.Params.DriverID := 'SQLite';
    LConnection.Params.Database := 'sample.db';
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
  UpperSQL: string;
begin
  // Enhanced safety check to allow data modification with safeguards
  UpperSQL := UpperCase(ASQL.Trim);

  // Allowed operations
  Result := UpperSQL.StartsWith('SELECT') or
    UpperSQL.StartsWith('INSERT') or
    UpperSQL.StartsWith('UPDATE') or
    UpperSQL.StartsWith('DELETE') or
    UpperSQL.StartsWith('CREATE TABLE') or
    UpperSQL.StartsWith('ALTER TABLE') or
    UpperSQL.StartsWith('DROP TABLE');

  // Block potentially dangerous operations
  if UpperSQL.Contains('PRAGMA') or UpperSQL.Contains('ATTACH') or UpperSQL.Contains('DETACH') then
    Result := False;
end;

function TDatabase.ExecuteQuery(const ASQL: string): TJSONValue;
var
  Query: TFDQuery;
  ResultArray: TJSONArray;
  RowObj: TJSONObject;
  Field: TField;
  I: Integer;
  IsSelectQuery: Boolean;
  ResultObj: TJSONObject;
  RowsAffected: Integer;
begin
  Result := nil;

  if not QuerySafeguard(ASQL) then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Query not allowed for security reasons');

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := ASQL;

    IsSelectQuery := UpperCase(ASQL.TrimLeft).StartsWith('SELECT');

    try
      if IsSelectQuery then
      begin
        // Handle SELECT queries with result sets
        Query.Open;
        ResultArray := TJSONArray.Create;

        while not Query.Eof do
        begin
          RowObj := TJSONObject.Create;

          for I := 0 to Query.FieldCount - 1 do
          begin
            Field := Query.Fields[I];

            if Field.IsNull then
              RowObj.AddPair(Field.FieldName, TJSONNull.Create)
            else
            begin
              case Field.DataType of
                ftString, ftWideString, ftMemo, ftWideMemo:
                  RowObj.AddPair(Field.FieldName, Field.AsString);
                ftInteger, ftSmallint, ftWord, ftLargeint:
                  RowObj.AddPair(Field.FieldName, TJSONNumber.Create(Field.AsInteger));
                ftFloat, ftCurrency, ftBCD:
                  RowObj.AddPair(Field.FieldName, TJSONNumber.Create(Field.AsFloat));
                ftBoolean:
                  RowObj.AddPair(Field.FieldName, TJSONBool.Create(Field.AsBoolean));
                ftDate, ftDateTime, ftTimeStamp:
                  RowObj.AddPair(Field.FieldName, FormatDateTime('yyyy-mm-dd hh:nn:ss', Field.AsDateTime));
                else
                  RowObj.AddPair(Field.FieldName, Field.AsString);
              end;
            end;
          end;

          ResultArray.Add(RowObj);
          Query.Next;
        end;

        Result := ResultArray;
      end
      else
      begin
        // Handle non-SELECT queries (INSERT, UPDATE, DELETE, CREATE, ALTER, DROP)
        Query.ExecSQL(ASQL);

        RowsAffected := 0;
        ResultObj := TJSONObject.Create;
        ResultObj.AddPair('success', TJSONBool.Create(True));
        ResultObj.AddPair('rowsAffected', TJSONNumber.Create(RowsAffected));
        ResultObj.AddPair('message', Format('Query executed successfully. Rows affected: %d', [RowsAffected]));

        Result := ResultObj;
      end;
    except
      on E: Exception do
      begin
        RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Query execution error: ' + E.Message);
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TDatabase.GetTableSchema(const ATableName: string): TJSONValue;
var
  Query: TFDQuery;
  ResultArray: TJSONArray;
  ColumnObj: TJSONObject;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    // SQLite-specific query to get table schema
    Query.SQL.Text := 'PRAGMA table_info(' + ATableName + ')';

    try
      Query.Open;

      ResultArray := TJSONArray.Create;

      while not Query.Eof do
      begin
        ColumnObj := TJSONObject.Create;
        ColumnObj.AddPair('name', Query.FieldByName('name').AsString);
        ColumnObj.AddPair('type', Query.FieldByName('type').AsString);
        ColumnObj.AddPair('notnull', TJSONBool.Create(Query.FieldByName('notnull').AsInteger = 1));
        ColumnObj.AddPair('pk', TJSONBool.Create(Query.FieldByName('pk').AsInteger = 1));

        ResultArray.Add(ColumnObj);
        Query.Next;
      end;

      Result := ResultArray;
    except
      on E: Exception do
      begin
        RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Table schema query error: ' + E.Message);
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TDatabase.RunSQLQuery(const Args: array of TValue): TValue;
var
  SQL: string;
  QueryResult: TJSONValue;
begin
  if Length(Args) < 1 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing SQL parameter');

  SQL := Args[0].AsString;

  QueryResult := ExecuteQuery(SQL);

  Result := TValue.From<string>(QueryResult.ToString);
  QueryResult.Free;
end;

function TDatabase.GetTableList(const Args: array of TValue): TValue;
var
  Query: TFDQuery;
  Tables: TJSONArray;
begin
  Self.Config;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    // SQLite-specific query to get table list
    Query.SQL.Text := 'SELECT name FROM sqlite_master WHERE type=''table'' AND name NOT LIKE ''sqlite_%''';
    if FConnection.Params.DriverID = 'MySQL' then
      Query.SQL.Text := Format('SELECT table_name as name FROM information_schema.tables WHERE table_schema = "%s"', [FConnection.Params.Database])
    else if FConnection.Params.DriverID = 'FB' then
      //Query.SQL.Text := 'SELECT TRIM(RDB$RELATION_NAME) AS table_name FROM RDB$RELATIONS WHERE RDB$SYSTEM_FLAG = 0 AND RDB$VIEW_BLR IS NULL';
      Query.SQL.Text := 'SELECT RDB$RELATION_NAME as name FROM RDB$RELATIONS  WHERE RDB$SYSTEM_FLAG = 0 AND RDB$RELATION_TYPE = 0';

    try
      Query.Open;

      Tables := TJSONArray.Create;

      while not Query.Eof do
      begin
        Tables.Add(Query.FieldByName('name').AsString);
        Query.Next;
      end;

      Result := TValue.From<string>(Tables.ToString);
      Tables.Free;
    except
      on E: Exception do
        RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Error getting table list: ' + E.Message);
    end;
  finally
    Query.Free;
  end;
end;

function TDatabase.GetTableInfo(const Args: array of TValue): TValue;
var
  TableName: string;
  Schema: TJSONValue;
begin
  if Length(Args) < 1 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing table name parameter');

  TableName := Args[0].AsString;

  Schema := GetTableSchema(TableName);
  try
    Result := TValue.From<string>(Schema.ToString);
  finally
    Schema.Free;
  end;
end;

function TDatabase.CreateTable(const Args: array of TValue): TValue;
var
  TableName: string;
  ColumnDefs: string;
  ColDef: string;
  SQL: string;
  ColumnDefsObj: TJSONValue;
  ColumnDefsArray: TJSONArray;
  I: Integer;
  ColumnObj: TJSONObject;
  ColumnName: string;
  ColumnType: string;
  IsPrimary: Boolean;
  IsNotNull: Boolean;
  ColumnSQL: TStringList;
  JSONResult: TJSONValue;
begin
  if Length(Args) < 2 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing required parameters');

  TableName := Args[0].AsString;
  ColumnDefs := Args[1].AsString;

  if TableName.Trim = '' then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Table name cannot be empty');

  try
    ColumnDefsObj := TJSONObject.ParseJSONValue(ColumnDefs);
    if not (ColumnDefsObj is TJSONArray) then
      RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Column definitions must be a JSON array');

    ColumnDefsArray := TJSONArray(ColumnDefsObj);
    if ColumnDefsArray.Count = 0 then
      RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'At least one column must be defined');

    ColumnSQL := TStringList.Create;
    try
      for I := 0 to ColumnDefsArray.Count - 1 do
      begin
        if not (ColumnDefsArray.Items[I] is TJSONObject) then
          Continue;

        ColumnObj := TJSONObject(ColumnDefsArray.Items[I]);

        if not ColumnObj.TryGetValue<string>('name', ColumnName) or (ColumnName.Trim = '') then
          Continue;

        if not ColumnObj.TryGetValue<string>('type', ColumnType) then
          ColumnType := 'TEXT';

        if ColumnObj.TryGetValue<Boolean>('primary', IsPrimary) then
          // Skip the primary key part here, will add later
        else
          IsPrimary := False;

        if ColumnObj.TryGetValue<Boolean>('notNull', IsNotNull) then
          // Skip the not null part here, will add later
        else
          IsNotNull := False;

        // Build column definition
        ColDef := ColumnName + ' ' + ColumnType;

        if IsNotNull then
          ColDef := ColDef + ' NOT NULL';

        if IsPrimary then
          ColDef := ColDef + ' PRIMARY KEY';

        ColumnSQL.Add(ColDef);
      end;

      SQL := Format('CREATE TABLE %s (%s)',
        [TableName, ColumnSQL.CommaText.Replace('"', '')]);

      JSONResult := ExecuteQuery(SQL);
      Result := TValue.From<string>(JSONResult.ToString);
    finally
      ColumnSQL.Free;
      ColumnDefsObj.Free;
    end;
  except
    on E: Exception do
      RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Error creating table: ' + E.Message);
  end;
end;

function TDatabase.DropTable(const Args: array of TValue): TValue;
var
  TableName: string;
  SQL: string;
  JSONResult: TJSONValue;
begin
  if Length(Args) < 1 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing table name parameter');

  TableName := Args[0].AsString;

  if TableName.Trim = '' then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Table name cannot be empty');

  SQL := Format('DROP TABLE IF EXISTS %s', [TableName]);

  JSONResult := ExecuteQuery(SQL);
  Result := TValue.From<string>(JSONResult.ToString);
end;

function TDatabase.InsertData(const Args: array of TValue): TValue;
var
  TableName: string;
  ValuesJSON: string;
  ValuesObj: TJSONObject;
  SQL: string;
  ColumnsStr: string;
  ValuesStr: string;
  I: Integer;
  JSONResult: TJSONValue;
  Pair: TJSONPair;
  Query: TFDQuery;
begin
  if Length(Args) < 2 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing required parameters');

  TableName := Args[0].AsString;
  ValuesJSON := Args[1].AsString;

  if TableName.Trim = '' then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Table name cannot be empty');

  try
    ValuesObj := TJSONObject.ParseJSONValue(ValuesJSON) as TJSONObject;
    if not Assigned(ValuesObj) or (ValuesObj.Count = 0) then
      RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Values must be a non-empty JSON object');

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConnection;

      // Build column and values lists
      ColumnsStr := '';
      ValuesStr := '';

      for I := 0 to ValuesObj.Count - 1 do
      begin
        Pair := ValuesObj.Pairs[I];

        if I > 0 then
        begin
          ColumnsStr := ColumnsStr + ', ';
          ValuesStr := ValuesStr + ', ';
        end;

        ColumnsStr := ColumnsStr + Pair.JsonString.Value;
        ValuesStr := ValuesStr + ':' + Pair.JsonString.Value;
      end;

      SQL := Format('INSERT INTO %s (%s) VALUES (%s)',
        [TableName, ColumnsStr, ValuesStr]);

      Query.SQL.Text := SQL;

      // Add parameter values
      for I := 0 to ValuesObj.Count - 1 do
      begin
        Pair := ValuesObj.Pairs[I];

        if Pair.JsonValue is TJSONNull then
          Query.ParamByName(Pair.JsonString.Value).Clear
        else if Pair.JsonValue is TJSONString then
          Query.ParamByName(Pair.JsonString.Value).AsString := TJSONString(Pair.JsonValue).Value
        else if Pair.JsonValue is TJSONNumber then
          Query.ParamByName(Pair.JsonString.Value).AsFloat := TJSONNumber(Pair.JsonValue).AsDouble
        else if Pair.JsonValue is TJSONBool then
          Query.ParamByName(Pair.JsonString.Value).AsBoolean := TJSONBool(Pair.JsonValue).AsBoolean;
      end;

      Query.ExecSQL;

      JSONResult := TJSONObject.Create;
      TJSONObject(JSONResult).AddPair('success', TJSONBool.Create(True));
      TJSONObject(JSONResult).AddPair('rowsAffected', TJSONNumber.Create(1));
      TJSONObject(JSONResult).AddPair('message', 'Data inserted successfully');

      Result := TValue.From<string>(JSONResult.ToString);
    finally
      Query.Free;
      ValuesObj.Free;
    end;
  except
    on E: Exception do
      RaiseJsonRpcError(TTMSMCPErrorCode.ecOperationFailed, 'Error inserting data: ' + E.Message);
  end;
end;

function TDatabase.UpdateData(const Args: array of TValue): TValue;
var
  TableName: string;
  SetValuesJSON: string;
  WhereCondition: string;
  SetValuesObj: TJSONObject;
  SQL, SetClause: string;
  I: Integer;
  Pair: TJSONPair;
  Query: TFDQuery;
  JSONResult: TJSONValue;
  RowsAffected: integer;
begin
  if Length(Args) < 3 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing required parameters');

  TableName := Args[0].AsString;
  SetValuesJSON := Args[1].AsString;
  WhereCondition := Args[2].AsString;

  if TableName.Trim = '' then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Table name cannot be empty');

  try
    SetValuesObj := TJSONObject.ParseJSONValue(SetValuesJSON) as TJSONObject;
    if not Assigned(SetValuesObj) or (SetValuesObj.Count = 0) then
      RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Set values must be a non-empty JSON object');

    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConnection;

      // Build SET clause
      SetClause := '';

      for I := 0 to SetValuesObj.Count - 1 do
      begin
        Pair := SetValuesObj.Pairs[I];

        if I > 0 then
          SetClause := SetClause + ', ';

        SetClause := SetClause + Pair.JsonString.Value + ' = :' + Pair.JsonString.Value;
      end;

      // Build SQL statement
      SQL := Format('UPDATE %s SET %s', [TableName, SetClause]);

      if WhereCondition.Trim <> '' then
        SQL := SQL + ' WHERE ' + WhereCondition;

      Query.SQL.Text := SQL;

      // Add parameter values
      for I := 0 to SetValuesObj.Count - 1 do
      begin
        Pair := SetValuesObj.Pairs[I];

        if Pair.JsonValue is TJSONNull then
          Query.ParamByName(Pair.JsonString.Value).Clear
        else if Pair.JsonValue is TJSONString then
          Query.ParamByName(Pair.JsonString.Value).AsString := TJSONString(Pair.JsonValue).Value
        else if Pair.JsonValue is TJSONNumber then
          Query.ParamByName(Pair.JsonString.Value).AsFloat := TJSONNumber(Pair.JsonValue).AsDouble
        else if Pair.JsonValue is TJSONBool then
          Query.ParamByName(Pair.JsonString.Value).AsBoolean := TJSONBool(Pair.JsonValue).AsBoolean;
      end;

      RowsAffected := Query.ExecSQL(SQL);

      JSONResult := nil;
      Result := TJSONObject.Create;
      TJSONObject(JSONResult).AddPair('success', TJSONBool.Create(True));
      TJSONObject(JSONResult).AddPair('rowsAffected', TJSONNumber.Create(RowsAffected));
      TJSONObject(JSONResult).AddPair('message', Format('Data updated successfully. Rows affected: %d', [RowsAffected]));

      Result := TValue.From<string>(JSONResult.ToString);
    finally
      Query.Free;
      SetValuesObj.Free;
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
  TableName: string;
  WhereCondition: string;
  SQL: string;
  JSONResult: TJSONValue;
  Query: TFDQuery;
  RowsAffected: integer;
begin
  if Length(Args) < 1 then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Missing table name parameter');

  TableName := Args[0].AsString;

  if Length(Args) >= 2 then
    WhereCondition := Args[1].AsString
  else
    WhereCondition := '';

  if TableName.Trim = '' then
    RaiseJsonRpcError(TTMSMCPErrorCode.ecInvalidParams, 'Table name cannot be empty');

  // Build SQL statement
  SQL := Format('DELETE FROM %s', [TableName]);

  if WhereCondition.Trim <> '' then
    SQL := SQL + ' WHERE ' + WhereCondition;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := SQL;

    RowsAffected := Query.ExecSQL(SQL);

    JSONResult := TJSONObject.Create;
    TJSONObject(JSONResult).AddPair('success', TJSONBool.Create(True));
    TJSONObject(JSONResult).AddPair('rowsAffected', TJSONNumber.Create(RowsAffected));
    TJSONObject(JSONResult).AddPair('message', Format('Data deleted successfully. Rows affected: %d', [RowsAffected]));

    Result := TValue.From<string>(JSONResult.ToString);
  finally
    Query.Free;
  end;
end;

end.
