unit Utils;

interface

procedure ShowHelp;

implementation

procedure ShowHelp;
begin
  WriteLn('MCP Database Server');
  WriteLn('=================');
  WriteLn('This application allows connecting to a database and exposing it via MCP.');
  WriteLn;
  WriteLn('Usage:');
  WriteLn('  DatabaseDemo [parameters]');
  WriteLn;
  WriteLn('Parameters:');
  WriteLn('  -type=[sqlite|mysql|mssql|postgres|Firebird]  Database type (default: sqlite)');
  WriteLn('  -db=<database>                       Database name or path');
  WriteLn('  -server=<server>                     Database server address (not needed for SQLite)');
  WriteLn('  -user=<username>                     Database username (not needed for SQLite)');
  WriteLn('  -pass=<password>                     Database password (not needed for SQLite)');
  WriteLn('  -port=<port>                         Database port (optional)');
  WriteLn('  -sample                              Create sample data (only for SQLite)');
  WriteLn('  -help                                Show this help');
  WriteLn;
  WriteLn('Examples:');
  WriteLn('  DatabaseDemo -type=sqlite -db=mydata.db -sample');
  WriteLn('  DatabaseDemo -type=mysql -server=localhost -db=mydb -user=root -pass=password');
  WriteLn('  DatabaseDemo -type=postgres -server=localhost -db=postgres -user=postgres -pass=password -port=5432');
  WriteLn('  DatabaseDemo -type=firebird -db=pathdb -server=localhost -user=sysdba -pass=masterkey -port=0');
  WriteLn;
  ReadLn;
end;

end.
