unit DatabaseMCP.Server;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Rtti,
  System.Generics.Collections,
  TMS.MCP.Server,
  TMS.MCP.Tools,
  TMS.MCP.Helpers,
  TMS.MCP.Transport.STDIO,
  DatabaseMCP.Types,
  DatabaseMCP.Database,
  DatabaseMCP.Connection.Params;

type
  TServer = class
  private
    FMCPServer: TTMSMCPServer;
    FDatabase: TDatabase;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetupServer;
    procedure Run;
  end;

implementation

constructor TServer.Create;
begin
  FMCPServer := TTMSMCPServer.Create(nil);
  FMCPServer.ServerName := 'DatabaseMCPServer';
  FMCPServer.ServerVersion := '1.0.0';

  FDatabase := TDatabase.Create;
end;

destructor TServer.Destroy;
begin
  FDatabase.Free;
  FMCPServer.Free;
  inherited;
end;

procedure TServer.SetupServer;
var
  LRunQueryTool: TTMSMCPTool;
  LTableInfoTool: TTMSMCPTool;
  LCreateTableTool: TTMSMCPTool;
  LDropTableTool: TTMSMCPTool;
  LInsertDataTool: TTMSMCPTool;
  LUpdateDataTool: TTMSMCPTool;
  LDeleteDataTool: TTMSMCPTool;

  LSQLProp: TTMSMCPToolProperty;
  LTableNameProp: TTMSMCPToolProperty;
  LTableNameCreateProp: TTMSMCPToolProperty;
  LColumnDefsProp: TTMSMCPToolProperty;
  LTableNameDropProp: TTMSMCPToolProperty;
  LTableNameInsertProp: TTMSMCPToolProperty;
  LValuesInsertProp: TTMSMCPToolProperty;
  LTableNameUpdateProp: TTMSMCPToolProperty;
  LSetValuesUpdateProp: TTMSMCPToolProperty;
  LWhereConditionUpdateProp: TTMSMCPToolProperty;
  LTableNameDeleteProp: TTMSMCPToolProperty;
  LWhereConditionDeleteProp: TTMSMCPToolProperty;
begin
  // Register tools
  FMCPServer.Tools.RegisterTool('run-query', 'Execute an SQL query', FDatabase.RunSQLQuery);

  // Define properties for the run-query tool
  LRunQueryTool := FMCPServer.Tools.FindByName('run-query');
  LSQLProp := LRunQueryTool.Properties.Add;
  LSQLProp.Name := 'sql';
  LSQLProp.Description := 'SQL query to execute (SELECT queries only)';
  LSQLProp.PropertyType := TTMSMCPToolPropertyType.ptString;
  LSQLProp.Required := True;

  // Register table list tool
  FMCPServer.Tools.RegisterTool('get-tables', 'Get a list of available tables', FDatabase.GetTableList);

  // Register table info tool
  FMCPServer.Tools.RegisterTool('get-table-info', 'Get information about a table', FDatabase.GetTableInfo);
  LTableInfoTool := FMCPServer.Tools.FindByName('get-table-info');
  LTableNameProp := LTableInfoTool.Properties.Add;
  LTableNameProp.Name := 'tableName';
  LTableNameProp.Description := 'Name of the table to get information about';
  LTableNameProp.PropertyType := ptString;
  LTableNameProp.Required := True;

  FMCPServer.Tools.RegisterTool('create-table', 'Create a new table', FDatabase.CreateTable);
  LCreateTableTool := FMCPServer.Tools.FindByName('create-table');
  LTableNameCreateProp := LCreateTableTool.Properties.Add;
  LTableNameCreateProp.Name := 'tableName';
  LTableNameCreateProp.Description := 'Name of the table to create';
  LTableNameCreateProp.PropertyType := ptString;
  LTableNameCreateProp.Required := True;

  LColumnDefsProp := LCreateTableTool.Properties.Add;
  LColumnDefsProp.Name := 'columnDefinitions';
  LColumnDefsProp.Description := 'Column definitions in JSON format [{"name":"col1","type":"TEXT","primary":true},...]';
  LColumnDefsProp.PropertyType := ptString;
  LColumnDefsProp.Required := True;

  // Drop table tool
  FMCPServer.Tools.RegisterTool('drop-table', 'Drop an existing table', FDatabase.DropTable);
  LDropTableTool := FMCPServer.Tools.FindByName('drop-table');
  LTableNameDropProp := LDropTableTool.Properties.Add;
  LTableNameDropProp.Name := 'tableName';
  LTableNameDropProp.Description := 'Name of the table to drop';
  LTableNameDropProp.PropertyType := ptString;
  LTableNameDropProp.Required := True;

  // Insert data tool
  FMCPServer.Tools.RegisterTool('insert-data', 'Insert data into a table', FDatabase.InsertData);
  LInsertDataTool := FMCPServer.Tools.FindByName('insert-data');
  LTableNameInsertProp := LInsertDataTool.Properties.Add;
  LTableNameInsertProp.Name := 'tableName';
  LTableNameInsertProp.Description := 'Name of the table to insert data into';
  LTableNameInsertProp.PropertyType := ptString;
  LTableNameInsertProp.Required := True;

  LValuesInsertProp := LInsertDataTool.Properties.Add;
  LValuesInsertProp.Name := 'values';
  LValuesInsertProp.Description := 'Values to insert in JSON format {"column1":"value1","column2":value2}';
  LValuesInsertProp.PropertyType := ptString;
  LValuesInsertProp.Required := True;

  // Update data tool
  FMCPServer.Tools.RegisterTool('update-data', 'Update data in a table', FDatabase.UpdateData);
  LUpdateDataTool := FMCPServer.Tools.FindByName('update-data');
  LTableNameUpdateProp := LUpdateDataTool.Properties.Add;
  LTableNameUpdateProp.Name := 'tableName';
  LTableNameUpdateProp.Description := 'Name of the table to update data in';
  LTableNameUpdateProp.PropertyType := ptString;
  LTableNameUpdateProp.Required := True;

  LSetValuesUpdateProp := LUpdateDataTool.Properties.Add;
  LSetValuesUpdateProp.Name := 'setValues';
  LSetValuesUpdateProp.Description := 'Values to set in JSON format {"column1":"value1","column2":value2}';
  LSetValuesUpdateProp.PropertyType := ptString;
  LSetValuesUpdateProp.Required := True;

  LWhereConditionUpdateProp := LUpdateDataTool.Properties.Add;
  LWhereConditionUpdateProp.Name := 'whereCondition';
  LWhereConditionUpdateProp.Description := 'WHERE condition (e.g., "id = 1")';
  LWhereConditionUpdateProp.PropertyType := ptString;
  LWhereConditionUpdateProp.Required := True;

  // Delete data tool
  FMCPServer.Tools.RegisterTool('delete-data', 'Delete data from a table', FDatabase.DeleteData);
  LDeleteDataTool := FMCPServer.Tools.FindByName('delete-data');
  LTableNameDeleteProp := LDeleteDataTool.Properties.Add;
  LTableNameDeleteProp.Name := 'tableName';
  LTableNameDeleteProp.Description := 'Name of the table to delete data from';
  LTableNameDeleteProp.PropertyType := ptString;
  LTableNameDeleteProp.Required := True;

  LWhereConditionDeleteProp := LDeleteDataTool.Properties.Add;
  LWhereConditionDeleteProp.Name := 'whereCondition';
  LWhereConditionDeleteProp.Description := 'WHERE condition (e.g., "id = 1"), leave empty to delete all rows';
  LWhereConditionDeleteProp.PropertyType := ptString;
  LWhereConditionDeleteProp.Required := False;
end;

procedure TServer.Run;
begin
  FMCPServer.Start;
  FMCPServer.Run;
end;

end.
