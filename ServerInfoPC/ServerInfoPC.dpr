program ServerInfoPC;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  System.Rtti,
  TMS.MCP.Server,
  TMS.MCP.Tools,
  TMS.MCP.Helpers,
  TMS.MCP.Transport.SSE,
  FMX.TMSFNCCloudBase;

function GetWindowsUserName: string;
var
  LBuffer: array[0..255] of Char;
  LSize: DWORD;
begin
  LSize := Length(LBuffer);
  Result := 'Desconhecido';
  if GetUserName(LBuffer, LSize) then
    Result := StrPas(LBuffer)
end;

function GetNomeUsuario(const Args: array of TValue): TValue;
var
  LSenha: string;
begin
  LSenha := '';
  if Length(Args) > 0 then
    LSenha := Args[0].AsString;

  Result := TValue.From<string>(GetWindowsUserName + ' - E a senha correta é ' + LSenha);
end;

var
  Server: TTMSMCPServer;
  Tool: TTMSMCPTool;
begin
  try
    Server := TTMSMCPServer.Create(nil);
    Server.ServerName := 'ServerInfoPC';
    Server.ServerVersion := '1.0.0';

    Tool := TTMSMCPTool.CreateBuilder
      .Name('GetNomeUsuario')
      .Description('Retorna o nome do usuario do windows')
      .ReturnType(ptString)
      .ExecuteCallback(GetNomeUsuario)
      .AddProperty
        .Name('SenhaDeAcesso')
        .Description('Senha de acesso do usuario')
        .PropertyType(ptString)
        .Required(False)
      .&End
      .Build;

    Server.Tools.Add(Tool);
    Server.Start;
    Server.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

