# MCP Server with RTTI - Transform classes and methods into MCP Servers

## Demo Video
[AI in Practice 29 - MCP Server with RTTI - Transform classes and methods into MCP Servers](https://www.youtube.com/watch?v=zc5Bza73nJs&list=PLLHSz4dOnnN237tIxJI10E5cy1dgXJxgP)

## Available Attributes
| Attribute / Type | Description / Purpose | Methods | Parameters |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| `TTMSMCPTool` | Marks a method as an MCP tool available for use by the AI ​​server or models | ✅ | ❌ |
| `TTMSMCPName` | Overrides the default name of a method or parameter for exposition or documentation purposes | ✅ | ✅ |
| `TTMSMCPDescription` | Provides a description or explanatory comment about a method or parameter | ✅ | ✅ |
| `TTMSMCPReadOnly` | Indicates read-only operations (queries without modifying data) | ✅ | ❌ |
| `TTMSMCPDestructive` | Destructive operations; indicates that a method permanently or irreversibly changes data (such as alteration or deletion) | ✅ | ❌ |
| `TTMSMCPIdempotent` | Indicates repeat-safe operations; a method can be called multiple times without changing the result after the first execution | ✅ | ❌ |
| `TTMSMCPOpenworld` | Allows a method to accept extra or unknown parameters without generating errors | ✅ | ❌ |
| `TTMSMCPOptional` | Indicates that a parameter is optional and can be omitted or have a default value | ❌ | ✅ |
| `TTMSMCPString`, `TTMSMCPFloat`, `TTMSMCPInteger`, `TTMSMCPBoolean` | Defines the return type of a method or parameter | ✅ | ✅ |

## Examples

### TTMSMCPTool

Marks a method as an available MCP tool.
```delphi
[TTMSMCPTool]
function GetUsers: TArray<string>;
```
---

### TTMSMCPName

Overrides the name of a method or parameter for exposition or documentation purposes.
```delphi
[TTMSMCPName('ListUsers')]
function GetAllUsers: TArray<string>;
```

---

### TTMSMCPDescription

Provides an explanatory description of a method or parameter. 
```delphi
[TTMSMCPDescription('Returns all active users')]
function GetActiveUsers: TArray<string>;
```

---

### TTMSMCPReadOnly

Indicates that the method is read-only (does not change data).
```delphi
[TTMSMCPReadOnly]
function GetSystemStatus: string;
```

---

### TTMSMCPDestructive

Indicates that the method performs destructive operations or permanent changes.
```delphi
[TTMSMCPDestructive]
procedure DeleteUser(const AUserId: Integer);
```

---

### TTMSMCPIdempotent

Indicates idempotent operations that are safe to be repeated (called) multiple times.
```Delphi
[TTMSMCPIdempotent]
function GetTotal(AProductId: Integer): Double;
```

---

### TTMSMCPOpenworld

Allows the method to accept extra or unknown parameters without generating errors.
```delphi
[TTMSMCPOpenworld]
procedure UpdateSettings(const Params: array of const);
```

---

### TTMSMCPOptional

Indicates that a parameter is optional.
```delphi
procedure SendEmail(const To: string; [TTMSMCPOptional] const CC: string = '');
```

---

### TTMSMCPString, TTMSMCPFloat, TTMSMCPInteger, TTMSMCPBoolean

Defines the return type of a method or parameter. 
```delphi
[TTMSMCPString]
function GetName([TTMSMCPInteger] AId: Integer): string;
```

```delphi
[TTMSMCPFloat]
function ReturnTotal([TTMSMCPInteger] AId: Integer): Double;
```

```delphi
[TTMSMCPInteger]
function GetNumero: Integer;
```

```delphi
[TTMSMCPBoolean]
function Validate([TTMSMCPString] AName: Integer; [TTMSMCPFloat] AValue: Double): Boolean;
```

---
