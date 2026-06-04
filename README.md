# MCP Servers
Este repositório reúne exemplos práticos e projetos prontos de MCP Servers criados com Delphi, seguindo a especificação oficial do Model Context Protocol (MCP).

O MCP é um padrão criado pela Anthropic que permite que LLMs (Modelos de Linguagem) descubram e utilizem ferramentas externas de forma padronizada, como acesso a bancos de dados, leitura de arquivos e execução de APIs, tudo isso em tempo real e com baixo acoplamento.

## MCP Servers Disponíveis
- **[Database](https://github.com/Code4Delphi/mcp-servers/tree/master/Database)** (comunicação STDIO) - Para se conectar, consultar e trabalhar com banco de dados (SQLite, MySQL, Firebird, MS SQL ou PostgreSQL).
- **[Database-HTTP](https://github.com/Code4Delphi/mcp-servers/tree/master/Database-HTTP)** (comunicação HTTP) - Para se conectar, consultar e trabalhar com banco de dados (SQLite, MySQL, Firebird, MS SQL ou PostgreSQL).
- **[FileSystem](https://github.com/Code4Delphi/mcp-servers/tree/master/Filesystem)** (comunicação STDIO) - Para manipulação de arquivos e pastas no sistema de arquivos.
- **[DateTime](https://github.com/Code4Delphi/mcp-servers/tree/master/MCPDateTime)** (comunicação STDIO) - Expõe a data e hora atual.
- **[ServerInfoPC](https://github.com/Code4Delphi/mcp-servers/tree/master/ServerInfoPC)** (comunicação STDIO) - Informações sobre PC/Windows

## ✨ Componente utilizado
- [TMS AI Studio](https://www.tmssoftware.com/site/tmsaistudio.asp)
- [Documentação](https://download.tmssoftware.com/doc/tmsaistudio/)

## 🏷️ Cupom de desconto
- Use este cupom exclusivo e tenha 30% de desconto em qualquer produto da TMS:
```
2026Code4Delphi30
```
  
## 🚀MCP com Delphi na prática
Quer aprender a usar os milhares de MCP Servers e MCP Clients já disponíveis e, melhor ainda, criar os seus próprios de forma simples com Delphi?

No canal Code4Delphi, você encontra uma série de vídeos práticos que mostram, passo a passo, como implementar o Model Context Protocol em seus sistemas, conectando LLMs a dados reais e ferramentas externas com facilidade.

## 📚 STDIO, SSE e HTTP (Transport)
### MCP STDIO (Standard Input/Output) (Entrada/Saída Padrão)
- Comunicação via entrada/saída padrão.
- Usado em cenários locais ou quando se deseja controlar diretamente a execução do processo.
- Mais indicado para integração entre processos na mesma máquina.
- O cliente inicia o servidor MCP localmente e troca mensagens por fluxo de texto binário ou JSON.
- Exige que o servidor MCP seja iniciado pelo cliente e que o fluxo de dados seja gerenciado manualmente.
- Mais baixo nível, exige que o cliente gerencie a execução.

### MCP SSE (Server-Sent Events) (Eventos Enviados pelo Servido)
- Comunicação via HTTP streaming (eventos enviados do servidor para o cliente).
- Mais adequado para conexões remotas ou aplicações web.
- O servidor MCP já precisa estar rodando em algum endpoint acessível.
- Menos trabalho de gerenciamento de processos, pois o transporte é feito pelo protocolo HTTP.
- O cliente escuta eventos enviados continuamente pelo servidor MCP.

### MCP HTTP (Requisições HTTP tradicionais)
- Comunicação via HTTP padrão, com requisições e respostas.
- Não é streaming, funciona em modelo request/response.
- Bom para operações pontuais ou quando o tráfego contínuo não é necessário.
- Mais fácil de integrar com sistemas que já trabalham com REST APIs.

👉 Resumindo:
- STDIO: Local, direto e controlado pelo cliente.
- SSE: remoto via HTTP, streaming contínuo.
- HTTP: remoto, requisições sob demanda.


## 🔗 IA e MCP na prática
- ▶️ [Vídeos práticos sobre MCP](https://www.youtube.com/watch?v=G7H9_hGQ3Q8&list=PLLHSz4dOnnN237tIxJI10E5cy1dgXJxgP)

- 🗂️ [Repositório com exemplo de IA na Prática](https://github.com/Code4Delphi/ia-na-pratica)

- 🗂️ [Repositório com MCP Client criado com Delphi](https://github.com/Code4Delphi/mcp-client)

- 🌟 [Postagem sobre MCP Server e Client](https://code4delphi.com.br/blog/mcp/)

- 🌟 [Postagem sobre IA na prática: IAs utilizadas](https://code4delphi.com.br/blog/ia-na-pratica-ias-utilizadas/)

- 🌟 [TMS AI Studio](https://www.tmssoftware.com/site/tmsaistudio.asp)


## 📞 Contatos
[![Telegram](https://img.shields.io/badge/Telegram-Join-blue?logo=telegram)](https://t.me/Code4Delphi)
[![YouTube](https://img.shields.io/badge/YouTube-Join-red?logo=youtube&logoColor=red)](https://www.youtube.com/@code4delphi)
[![Instagram](https://img.shields.io/badge/Intagram-Follow-red?logo=instagram&logoColor=pink)](https://www.instagram.com/code4delphi/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/cesar-cardoso-dev)
[![Blog](https://img.shields.io/badge/Blog-Code4Delphi-F00?logo=delphi)](https://code4delphi.com.br/blog/)
[![Course](https://img.shields.io/badge/Course-Delphi-F00?logo=delphi)](https://go.hotmart.com/U81331747Y?dp=1)
[![E-mail](https://img.shields.io/badge/E--mail-Send-yellowgreen?logo=maildotru&logoColor=yellowgreen)](mailto:contato@code4delphi.com.br)
