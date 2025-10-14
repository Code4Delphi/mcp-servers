# MCP Server com RTTI - Transforme classes e métodos em MCP Servers

## Vídeo de demonstração
[IA na Prática 29 - MCP Server com RTTI - Transforme classes e métodos em MCP Servers](https://www.youtube.com/watch?v=zc5Bza73nJs&list=PLLHSz4dOnnN237tIxJI10E5cy1dgXJxgP)

## Atributos disponíveis
| Atributo / Tipo       | Descrição / finalidade                                                                                                            | Métodos | Parâmetros |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| `TTMSMCPTool`         | Marca um método como uma ferramenta MCP disponível para uso pelo servidor ou modelos de IA                                        | ✅       | ❌       |
| `TTMSMCPName`         | Sobrescreve o nome padrão de um método ou parâmetro para fins de exposição ou documentação                                        | ✅       | ✅       |
| `TTMSMCPDescription`  | Fornece uma descrição ou comentário explicativo sobre um método ou parâmetro                                                      | ✅       | ✅       |
| `TTMSMCPReadOnly`     | Indica operações somente leitura (consultas sem modificar dados)                                                                  | ✅       | ❌       |
| `TTMSMCPDestructive`  | Operações destrutivas; indica que um método altera os dados de forma permanente ou irreversível (como alteração ou exclusão)      | ✅       | ❌       |
| `TTMSMCPIdempotent`   | Indica operações seguras para repetição; um método pode ser chamado várias vezes sem alterar o resultado após a primeira execução | ✅       | ❌       |
| `TTMSMCPOpenworld`    | Permite que um método aceite parâmetros extras ou desconhecidos sem gerar erros                                                   | ✅       | ❌       |
| `TTMSMCPOptional`     | Indica que um parâmetro é opcional, podendo ser omitido ou ter valor padrão                                                       | ❌       | ✅       |
| `TTMSMCPString`, `TTMSMCPFloat`, `TTMSMCPInteger`, `TTMSMCPBoolean` | Define o tipo do retorno de um método ou de um parâmetro                            | ✅       | ✅       |


## Exemplos

### TTMSMCPTool

Marca um método como uma ferramenta MCP disponível.
```delphi
[TTMSMCPTool]
function GetUsers: TArray<string>;
```
---

### TTMSMCPName

Sobrescreve o nome de um método ou parâmetro para fins de exposição ou documentação.
```delphi
[TTMSMCPName('ListUsers')]
function GetAllUsers: TArray<string>;
```

---

### TTMSMCPDescription

Fornece uma descrição explicativa sobre um método ou parâmetro.
```delphi
[TTMSMCPDescription('Retorna todos os usuários ativos')]
function GetActiveUsers: TArray<string>;
```

---

### TTMSMCPReadOnly

Indica que o método é somente leitura (não altera dados).
```delphi
[TTMSMCPReadOnly]
function GetSystemStatus: string;
```

---

### TTMSMCPDestructive

Indica que o método realiza operações destrutivas ou alterações permanentes.
```delphi
[TTMSMCPDestructive]
procedure DeleteUser(const AUserId: string);
```

---

### TTMSMCPIdempotent

Indica que o método é seguro para repetição sem alterar o resultado após a primeira execução.
```delphi
[TTMSMCPIdempotent]
procedure ActivateUser(const AUserId: string);
```

---

### TTMSMCPOpenworld

Permite que o método aceite parâmetros extras ou desconhecidos sem gerar erros.
```delphi
[TTMSMCPOpenworld]
procedure UpdateSettings(const Params: array of const);
```

---

### TTMSMCPOptional

Indica que um parâmetro é opcional.
```delphi
procedure SendEmail(const To: string; [TTMSMCPOptional] const CC: string = '');
```

---

### TTMSMCPString, TTMSMCPFloat, TTMSMCPInteger, TTMSMCPBoolean

Define o tipo do retorno de um método ou de um parâmetro.
```delphi
[TTMSMCPString] const AName: string;
[TTMSMCPInteger] const AId: Integer;
[TTMSMCPBoolean] const AActive: Boolean;
[TTMSMCPFloat] const AValue: Double;
```

---

