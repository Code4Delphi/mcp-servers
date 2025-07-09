# 🗂️ FileSystem MCP Server – Code4Delphi
Este projeto é um exemplo prático de um MCP Server criado com Delphi, que expõe funções de manipulação de arquivos e pastas por meio do Model Context Protocol (MCP).

Ele permite que LLMs (como Claude, GPT, etc.) descubram e utilizem ferramentas relacionadas ao sistema de arquivos local, de forma padronizada e segura, servindo como uma ponte entre a IA e operações reais no sistema.

## 🔧 Funcionalidades expostas via MCP
Este servidor expõe as seguintes ferramentas (tools):

ListFiles — Lista arquivos e pastas dentro do diretório raiz

ShowFileContents — Exibe o conteúdo de um arquivo de texto

FolderCreate — Cria uma nova pasta

FileCreate — Cria um novo arquivo com conteúdo

RenameFileOrFolder — Renomeia arquivos ou pastas existentes

Todas as ferramentas são registradas dinamicamente via TTMSMCPTool e seguem o padrão esperado por qualquer MCP Client compatível.

## 📁 Diretório raiz
O diretório de trabalho padrão é:

makefile
Copiar
Editar
C:\TempIA\
Você pode alterar esse caminho informando um novo via parâmetro na linha de comando ao iniciar o servidor.

## ▶️ Como executar
Compile o projeto Delphi que usa a unit FileSystem.pas.

Execute o binário gerado.

O servidor MCP iniciará e aguardará conexões de qualquer MCP Client compatível.

## 📞 Contatos
[![Telegram](https://img.shields.io/badge/Telegram-Join-blue?logo=telegram)](https://t.me/Code4Delphi)
[![YouTube](https://img.shields.io/badge/YouTube-Join-red?logo=youtube&logoColor=red)](https://www.youtube.com/@code4delphi)
[![Instagram](https://img.shields.io/badge/Intagram-Follow-red?logo=instagram&logoColor=pink)](https://www.instagram.com/code4delphi/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/cesar-cardoso-dev)
[![Blog](https://img.shields.io/badge/Blog-Code4Delphi-F00?logo=delphi)](https://code4delphi.com.br/blog/)
[![Course](https://img.shields.io/badge/Course-Delphi-F00?logo=delphi)](https://go.hotmart.com/U81331747Y?dp=1)
[![E-mail](https://img.shields.io/badge/E--mail-Send-yellowgreen?logo=maildotru&logoColor=yellowgreen)](mailto:contato@code4delphi.com.br)
