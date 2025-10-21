object FileSystemHTTPDM: TFileSystemHTTPDM
  OnCreate = DataModuleCreate
  Height = 389
  Width = 582
  object TMSMCPServer1: TTMSMCPServer
    Tools = <
      item
        Name = 'ListFiles'
        Description = 'List files'
        Properties = <>
        OnExecute = TMSMCPServer1Tools0Execute
        ReturnType = ptString
        ReadOnlyHint = False
        DestructiveHint = False
        IdempotentHint = False
        OpenWorldHint = False
      end>
    Resources = <>
    Prompts = <>
    ServerVersion = '1.0.0'
    ServerName = 'FileSystemMCPServer'
    Transport = TMSMCPStreamableHTTPTransport1
    OnLog = TMSMCPServer1Log
    Left = 208
    Top = 64
  end
  object TMSMCPStreamableHTTPTransport1: TTMSMCPStreamableHTTPTransport
    Port = 8080
    MCPEndpoint = '/mcp'
    ProtocolVersion = '2025-06-18'
    UseSSL = False
    SSLVersion = sslvTLSv1_2
    Left = 376
    Top = 64
  end
end
