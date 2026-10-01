object MCPServerBasicDM: TMCPServerBasicDM
  OnCreate = DataModuleCreate
  Height = 389
  Width = 582
  object TMSMCPServer1: TTMSMCPServer
    Tools = <
      item
        Name = 'RetornaCodigoPessoal'
        Description = 'Retorna c'#243'digo pessoal'
        Properties = <
          item
            Name = 'NomeDaPessoa'
            PropertyType = ptString
            Description = 'Nome da Pessoa'
          end>
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
    Left = 168
    Top = 64
  end
  object TMSMCPStreamableHTTPTransport1: TTMSMCPStreamableHTTPTransport
    Port = 8081
    MCPEndpoint = '/mcp'
    UseSSL = False
    OnValidateAccessToken = TMSMCPStreamableHTTPTransport1ValidateAccessToken
    Left = 336
    Top = 64
  end
end
