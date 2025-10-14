# MCP Server com RTTI - Transforme classes e métodos em MCP Servers

## Vídeo de demonstração
[IA na Prática 29 - MCP Server com RTTI - Transforme classes e métodos em MCP Servers](https://www.youtube.com/watch?v=zc5Bza73nJs&list=PLLHSz4dOnnN237tIxJI10E5cy1dgXJxgP)

## Atributos disponíveis
| Atributo             | Descrição / finalidade                                              | Métodos | Parâmetros |
| -------------------- | ------------------------------------------------------------------- | ------- | ---------- |
| `TTMSMCPTool`        | Marca um método como sendo uma ferramenta (Tool) MCP                | ✅       | ❌          |
| `TTMSMCPName`        | Substitui o nome padrão de uma ferramenta ou parâmetro              | ✅       | ✅          |
| `TTMSMCPDescription` | Adiciona texto descritivo para modelos de IA                        | ✅       | ✅          |
| `TTMSMCPReadOnly`    | Indica operações somente leitura (sem efeitos colaterais)           | ✅       | ❌          |
| `TTMSMCPDestructive` | Indica operações destrutivas (modificações de dados)                | ✅       | ❌          |
| `TTMSMCPIdempotent`  | Indica operações idempotentes (seguras para repetição)              | ✅       | ❌          |
| `TTMSMCPOpenworld`   | Permite um tratamento mais flexível de parâmetros                   | ✅       | ❌          |
| `TTMSMCPOptional`    | Marca parâmetros como opcionais (podem ter valor padrão)            | ❌       | ✅          |


