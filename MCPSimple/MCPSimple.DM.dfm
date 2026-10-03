object DM: TDM
  Height = 338
  Width = 401
  object TMSMCPServer1: TTMSMCPServer
    Tools = <
      item
        Name = 'TokenUsuario'
        Description = 'Retorna o token do usu'#225'rio'
        Properties = <
          item
            Name = 'NomeUsuario'
            PropertyType = ptString
            Description = 'Nome do usuario'
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
    ServerName = 'MCPSimple'
    Left = 176
    Top = 136
  end
end
