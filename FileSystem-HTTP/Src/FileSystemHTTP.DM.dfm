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
      end
      item
        Name = 'ShowFileContents'
        Description = 'Show File Contents'
        Properties = <
          item
            Name = 'NameFile'
            PropertyType = ptString
            Description = 'Name of the file to open and display data'
          end>
        OnExecute = TMSMCPServer1Tools1Execute
        ReturnType = ptString
        ReadOnlyHint = False
        DestructiveHint = False
        IdempotentHint = False
        OpenWorldHint = False
      end
      item
        Name = 'FolderCreate'
        Description = 'Create a folder with the given name'
        Properties = <
          item
            Name = 'NameFolder'
            PropertyType = ptString
            Description = 'Name of the folder to be created'
          end>
        OnExecute = TMSMCPServer1Tools2Execute
        ReturnType = ptString
        ReadOnlyHint = False
        DestructiveHint = False
        IdempotentHint = False
        OpenWorldHint = False
      end
      item
        Name = 'FileCreate'
        Description = 'Create a file with the given name'
        Properties = <
          item
            Name = 'NameFile'
            PropertyType = ptString
            Description = 'Name and extension of the file to be created'
          end
          item
            Name = 'Contents'
            PropertyType = ptString
            Description = 'Content to be added to the file that will be created'
          end>
        OnExecute = TMSMCPServer1Tools3Execute
        ReturnType = ptString
        ReadOnlyHint = False
        DestructiveHint = False
        IdempotentHint = False
        OpenWorldHint = False
      end
      item
        Name = 'RenameFileOrFolder'
        Description = 'Rename folder or file name from old name to new name'
        Properties = <
          item
            Name = 'OldName'
            PropertyType = ptString
            Description = 'Name of the file or folder to be renamed'
          end
          item
            Name = 'NewName'
            PropertyType = ptString
            Description = 'New name to be used'
          end>
        OnExecute = TMSMCPServer1Tools4Execute
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
