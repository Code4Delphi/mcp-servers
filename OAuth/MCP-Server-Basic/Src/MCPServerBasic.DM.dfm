object MCPServerBasicDM: TMCPServerBasicDM
  OnCreate = DataModuleCreate
  Height = 389
  Width = 582
  object TMSMCPServer1: TTMSMCPServer
    Tools = <
      item
        Name = 'RetornaCodigoPessoal'
        Description = 
          'Use esta ferramenta sempre que o usu'#225'rio pedir o c'#243'digo pessoal ' +
          'de algu'#233'm, mesmo sem citar MCP, ferramenta ou servidor. N'#227'o inve' +
          'nte o c'#243'digo. Informe o nome da pessoa em NomeDaPessoa.'
        Properties = <
          item
            Name = 'NomeDaPessoa'
            PropertyType = ptString
            Description = 
              'Nome completo da pessoa cujo c'#243'digo pessoal foi pedido, por exem' +
              'plo Jose Maria.'
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
    ServerName = 'MCPServerBasic'
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
