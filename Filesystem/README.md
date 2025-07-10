# 🗂️ FileSystem MCP Server – Code4Delphi
Este projeto é um exemplo prático de um MCP Server criado com Delphi, que expõe funcionalidades para manipulação de arquivos e pastas no sistema de arquivos.

Ele permite que LLMs (como Claude, GPT, etc.) descubram e utilizem ferramentas relacionadas ao sistema de arquivos local, de forma padronizada e segura, servindo como uma ponte entre a IA e operações reais no sistema.

## 🔧 Funcionalidades expostas via MCP
Este servidor expõe as seguintes ferramentas (tools):

ListFiles: Lista arquivos e pastas dentro do diretório raiz

ShowFileContents: Exibe o conteúdo de um arquivo de texto

FolderCreate: Cria uma nova pasta

FileCreate: Cria um novo arquivo com conteúdo

RenameFileOrFolder: Renomeia arquivos ou pastas existentes


## 📁 Diretório raiz
O diretório de trabalho padrão é: C:\TempIA\
Você pode alterar esse caminho informando um novo via parâmetro na linha de comando ao iniciar o servidor (parâmetro por linha de comando no atalho do .exe).

## ▶️ Demonstração
Vídeo de demonstração de uso: [FileSystem MCP Server Vídeo](https://www.youtube.com/watch?v=G7H9_hGQ3Q8&list=PLLHSz4dOnnN237tIxJI10E5cy1dgXJxgP)

## ⚙️Acessando a partir do Claude Desktop
- [Link para download do Claude Desktop](https://claude.ai/download)
- Conteúdo a ser adicionado ao arquivo claude_desktop_config.json:

```
{
  "mcpServers": {
    "FileSystem": {
      "command": "C:/IA/mcp-servers/Filesystem/Bin/FileSystemMCP.exe",
      "args": [
        "C:/TempIA/"
      ]
    }
  }
}
```

## 📞 Contatos
[![Telegram](https://img.shields.io/badge/Telegram-Join-blue?logo=telegram)](https://t.me/Code4Delphi)
[![YouTube](https://img.shields.io/badge/YouTube-Join-red?logo=youtube&logoColor=red)](https://www.youtube.com/@code4delphi)
[![Instagram](https://img.shields.io/badge/Intagram-Follow-red?logo=instagram&logoColor=pink)](https://www.instagram.com/code4delphi/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/cesar-cardoso-dev)
[![Blog](https://img.shields.io/badge/Blog-Code4Delphi-F00?logo=delphi)](https://code4delphi.com.br/blog/)
[![Course](https://img.shields.io/badge/Course-Delphi-F00?logo=delphi)](https://go.hotmart.com/U81331747Y?dp=1)
[![E-mail](https://img.shields.io/badge/E--mail-Send-yellowgreen?logo=maildotru&logoColor=yellowgreen)](mailto:contato@code4delphi.com.br)
