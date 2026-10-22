# Harbour & MiniGUI Development Instructions

You are an expert Harbour and MiniGUI developer. When generating, refactoring, or documenting code, you MUST strictly adhere to the harbour-doc standard v1.1.0.

## 1. Naming Conventions (Hungarian Notation)
Always use Hungarian notation prefixes for variables and parameters:
- `c` for Character (e.g., `cName`, `cDbfName`)
- `n` for Numeric (e.g., `nId`, `nCount`)
- `l` for Logical (e.g., `lFound`, `lSuccess`)
- `d` for Date (e.g., `dToday`, `dCreatedAt`)
- `a` for Array (e.g., `aStruct`, `aProducts`)
- `h` for Hash (e.g., `hData`, `hConfig`)
- `o` for Object (e.g., `oProduct`, `oWindow`)
- `x` for Any/Unknown (e.g., `xValue`)

## 2. Documentation Block Syntax
- Use `/** ... */` (double asterisk) for documentation blocks
- Single asterisk `/* ... */` is ignored by the parser
- Every continuation line SHOULD begin with `*`
- Doc block must immediately precede the symbol (blank lines allowed)

## 3. Required Tags
Every public symbol MUST have these tags:
- `@brief`: One-sentence summary (first line)
- `@param`: Format: `@param cName (C) -> Description`
- `@return`: Format: `@return (Type) -> Description`
  - For procedures: `@return (NIL) -> Nothing` (NEVER use "void")
  - For objects: `@return (O) -> Description`
- `@since`: Version number (e.g., `1.0.0`)
- `@see`: Cross-reference related symbols (one per line)
- `@example`: Usage example (always last tag)

## 4. Type Codes
Use single-letter type codes in parentheses:
- `(C)` Character
- `(N)` Numeric
- `(L)` Logical
- `(D)` Date
- `(A)` Array
- `(H)` Hash
- `(O)` Object
- `(X)` Any/Unknown
- `(NIL)` No value (procedure return)

## 5. File Header Template
Every `.prg` file MUST start with:
```harbour
/*
      Company       : <Company Name>
      Program       : <Program Name>
      Module        : <FileName.prg>
      Compiler      : MINIGUI - Harbour Win32 GUI
      Author        : <Author Name>
      Email         : <email@example.com>
      Date          : YYYY-MM-DD
      Language      : EN
      Description   : <Brief description>
      Notes         : Hungarian notation enforced. UI strings via T( cKey ).
*/