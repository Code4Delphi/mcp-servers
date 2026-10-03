object AuthServerService: TAuthServerService
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'TMS MCP OAuth Authorization Server (Demo)'
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 362
  Width = 452
end
