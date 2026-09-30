object MCPServerOAuthDM: TMCPServerOAuthDM
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
  object TMSMCPServer1: TTMSMCPServer
    Tools = <
      item
        Name = 'RetornaTokenPessoal'
        Description = 'Retorna token pessoal'
        Properties = <
          item
            Name = 'NoPessoa'
            PropertyType = ptString
            Description = 'Nome da pessoa desejada'
          end>
        OnExecute = TMSMCPServer1Tools0Execute
        ReturnType = ptString
        Title = 'Retorna token pessoal Title'
        ReadOnlyHint = False
        DestructiveHint = False
        IdempotentHint = False
        OpenWorldHint = False
      end>
    Resources = <>
    Prompts = <>
    ServerVersion = '1.0.0'
    ServerName = 'MCPServer'
    Left = 280
    Top = 184
  end
end
