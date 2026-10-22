# 📘 Harbour / MiniGUI Extended — Code Documentation Project

**Purpose**: Definitive guide and template set for documenting Harbour/MiniGUI Extended source code using the `harbour-doc` standard (compatible with JSDoc / Doxygen / PHPDoc conventions).

**Author**: {{PERSON_NAME}}  
**Company**: {{COMPANY_NAME}}  
**Language**: {{LANGUAGE}}  
**Version**: 1.1.0  
**Last updated**: October 21, 2026

---

## 📋 Table of Contents

1. [Project Initialization](#1-project-initialization)
2. [Core Directives](#2-core-directives)
3. [The Documentation Block](#3-the-documentation-block)
4. [Documenting Functions & Procedures](#4-documenting-functions--procedures)
5. [Documenting Classes](#5-documenting-classes)
6. [Documenting Methods](#6-documenting-methods)
7. [Documenting Constants (#define)](#7-documenting-constants-define)
8. [Tag Reference](#8-tag-reference)
9. [Type Codes](#9-type-codes)
10. [Parser Rules](#10-parser-rules)
11. [Best Practices & Style Guide](#11-best-practices--style-guide)
12. [Common Mistakes](#12-common-mistakes)
13. [File Header Standards](#13-file-header-standards)
14. [Module Documentation](#14-module-documentation)
15. [Generating Documentation with harbour-doc](#15-generating-documentation-with-harbour-doc)
16. [Mandatory Checklist](#16-mandatory-checklist)
17. [Quick Reference Card](#17-quick-reference-card)

---

## 1. Project Initialization

### 1.0 Mandatory Pre-Generation Interview

⚠️ **ZERO TOLERANCE RULE**: Before generating ANY documentation output, the documentation generator (or the human documenter) MUST collect the following metadata interactively. If the user does not provide a value, the DEFAULT listed below MUST be used and a warning emitted.

```
┌─────────────────────────────────────────────────────────────┐
│  PROJECT METADATA FORM  (MUST BE COLLECTED BEFORE GENERATE) │
├─────────────────────────────────────────────────────────────┤
│  Language (EN/ES/PT/FR/DE) : _______________  [DEFAULT: EN] │
│  Person Name               : _______________  [DEFAULT: ""] │
│  Company Name              : _______________  [DEFAULT: ""] │
│  Project Name              : _______________  [REQUIRED]    │
│  Project Version           : _______________  [DEFAULT: "1.0.0"] │
│  Start Date                : _______________  [DEFAULT: today] │
│  Contact Email             : _______________  [DEFAULT: ""] │
│  Website                   : _______________  [DEFAULT: ""] │
└─────────────────────────────────────────────────────────────┘
```

#### 1.0.1 Language Rules

1. **Default language is ENGLISH (`EN`)** if the user does not specify one.
2. All **free-text documentation content** (brief descriptions, extended descriptions, `@param` descriptions, `@return` descriptions, `@example` comments, module briefs) MUST be written in the selected language.
3. **Code identifiers** (function names, variable names, class names, method names, constants) ALWAYS remain in English regardless of the selected documentation language (Harbour convention).
4. **Tags** (`@param`, `@return`, `@since`, `@see`, `@example`, etc.) ALWAYS remain in English.
5. If a non-English language is selected, a comment line must be added to the file header: `Language : <CODE>` (e.g. `Language : ES`).

#### 1.0.2 Metadata Resolution Rules

| Field | If user provides nothing... |
|-------|-----------------------------|
| Language | Use `EN` (English) |
| Person Name | Use empty string; emit warning `W0001` |
| Company Name | Use empty string; emit warning `W0002` |
| Project Name | **MUST be provided** — abort generation with error `E0001` |
| Project Version | Use `"1.0.0"` |
| Start Date | Use current date (ISO 8601: `YYYY-MM-DD`) |
| Contact Email | Use empty string; emit warning `W0003` |
| Website | Use empty string; emit warning `W0004` |

#### 1.0.3 Interactive Prompt Template

The generator MUST ask the following questions in this exact order before producing any output:

```
[harbour-doc] Project initialization required.
  Project name? (required): ___
  Language [EN/ES/PT/FR/DE] (default: EN): ___
  Author name (default: ""): ___
  Company name (default: ""): ___
  Version (default: 1.0.0): ___
  Contact email (default: ""): ___
  Website (default: ""): ___
```

If running in **non-interactive / batch mode**, the metadata MUST be supplied via environment variables or a `harbour-doc.json` config file. If absent, defaults apply and warnings are emitted.

#### 1.0.4 Warning and Error Codes for Metadata

| Code | Severity | Trigger |
|------|----------|---------|
| W0001 | Warning | Person Name not provided |
| W0002 | Warning | Company Name not provided |
| W0003 | Warning | Contact Email not provided |
| W0004 | Warning | Website not provided |
| E0001 | Error | Project Name not provided (generation aborts) |
| E0002 | Error | Invalid language code (not in EN/ES/PT/FR/DE) |

### 1.1 Project Structure

```
project/
├── docs/
│   ├── api/                    # Generated HTML/Markdown API docs
│   ├── guides/                 # User guides
│   └── index.md                # Documentation index
├── src/
│   ├── main.prg
│   ├── modules/
│   └── classes/
├── i18n/
│   ├── en.json
│   └── es.json
├── tests/
├── build.hbp
└── README.md
```

---

## 2. Core Directives

### 2.1 Documentation Block Syntax

All documentation uses `/** ... */` blocks (double asterisk to start). Single asterisk `/* ... */` is treated as a regular comment and ignored by the documentation generator.

### 2.2 Tag Format

All tags start with `@` and appear on their own line. Type codes are single letters in parentheses: `(C)`, `(N)`, `(L)`, etc. Use `->` separator between type and description (recommended).

### 2.3 Hungarian Notation

Parameter names MUST use Hungarian notation matching their type code:

| Prefix | Type | Example |
|--------|------|---------|
| c | C | cName |
| n | N | nAmount |
| l | L | lFlag |
| d | D | dDate |
| a | A | aItems |
| h | H | hData |
| o | O | oObject |
| x | X | xValue |

### 2.4 Association Rules

The doc block is associated with the next non-comment code line. Blank lines between block and symbol are allowed. Any non-blank code line resets the association.

### 2.5 Zero Tolerance

Every public symbol MUST be documented. Undocumented symbols are flagged by `harbour-doc` validation.

---

## 3. The Documentation Block

### 3.1 Multi-line Form (RECOMMENDED)

```harbour
/**
 * Brief description on the first line.
 *
 * Extended description on the following lines.
 * Can span multiple paragraphs.
 *
 * @param cName (C) -> Description of the parameter
 * @return (L) -> Description of the return value
 * @since 1.0.0
 * @see RelatedSymbol
 * @example
 *   LOCAL lOk := MyFunction( "test" )
 */
FUNCTION MyFunction( cName )
   ...
```

### 3.2 Single-line Form (COMPACT)

```harbour
/** Returns the entity identifier. @return (C) -> ID string */
METHOD GetId() CLASS TBaseEntity
   RETURN ::cId
```

### 3.3 Critical Rules

- The block MUST start with `/**` (two asterisks).
- The block MUST end with `*/`.
- Every continuation line SHOULD begin with `*` (recommended style).
- Free-text description is accumulated BEFORE the first `@` tag.
- Text after a tag belongs to that tag.
- Regular `/* ... */` comments and `//` line comments do NOT interfere.

---

## 4. Documenting Functions & Procedures

### 4.1 Minimal Function

```harbour
/**
 * Calculates the total price including tax.
 * @param nPrice (N) -> Base unit price
 * @return (N) -> Final total price
 */
FUNCTION CalculateTotal( nPrice )
   RETURN nPrice * 1.12
```

### 4.2 Complete Function

```harbour
/**
 * Calculates the total price including tax and discount.
 *
 * This function applies a percentage tax to the base price and then
 * subtracts an optional flat discount. Negative totals are clamped to zero.
 *
 * @param nPrice    (N) -> Base unit price before tax
 * @param nQuantity (N) -> Number of units to calculate
 * @param nTaxRate  (N) -> Tax percentage to apply (0-100)
 * @param nDiscount (N) -> Flat discount amount to subtract
 * @return (N) -> Final total price after tax and discount
 * @since 1.0.0
 * @see FormatCurrency
 * @example
 *   nTotal := CalculateTotal( 100.00, 5, 12.0, 50.00 )
 *   // Result: 510.00
 */
FUNCTION CalculateTotal( nPrice, nQuantity, nTaxRate, nDiscount )
   LOCAL nSubtotal := nPrice * nQuantity
   LOCAL nTax      := nSubtotal * ( nTaxRate / 100 )
   LOCAL nTotal    := nSubtotal + nTax - nDiscount
   IF nTotal < 0
      nTotal := 0
   ENDIF
   RETURN nTotal
```

### 4.3 Procedures

Procedures have no return value. Document with `PROCEDURE` and omit `@return` (or use `@return (NIL) -> Nothing`):

```harbour
/**
 * Logs a system event to the application event table.
 *
 * @param cEventCode (C) -> Event type code (INFO, WARN, ERROR)
 * @param cModule    (C) -> Module name generating the event
 * @param cMessage   (C) -> Descriptive event message
 * @param cUser      (C) -> Username associated with the event
 * @since 1.0.0
 * @see CalculateTotal
 * @example
 *   LogEvent( "INFO", "ORDERS", "Order #1234 created", "admin" )
 */
PROCEDURE LogEvent( cEventCode, cModule, cMessage, cUser )
   ...
   RETURN
```

---

## 5. Documenting Classes

Class documentation sits immediately above the `CLASS` statement. The parser detects `FROM` clauses automatically and links the parent class.

### 5.1 Base Class

```harbour
/**
 * Base entity class providing common fields and behavior
 * for all business model objects.
 *
 * Includes audit tracking, soft delete support, and hash serialization.
 * All domain models should inherit from this class.
 *
 * @since 1.0.0
 * @see TCustomer
 * @see TOrder
 */
CLASS TBaseEntity
   DATA cId        INIT ""
   DATA dCreatedAt INIT NIL
   DATA lIsActive  INIT .T.
   METHOD New() CONSTRUCTOR
   METHOD GetId()
   METHOD SetId( cId )
   METHOD ToHash()
ENDCLASS
```

### 5.2 Inheritance

```harbour
/**
 * Customer model representing a business client.
 * Inherits from TBaseEntity and adds customer-specific
 * fields such as name, contact info, and credit balance.
 *
 * @since 1.0.0
 * @see TBaseEntity
 * @see TOrder
 */
CLASS TCustomer FROM TBaseEntity
   DATA cName    INIT ""
   DATA cEmail   INIT ""
   DATA nBalance INIT 0
   METHOD New( cName, cEmail ) CONSTRUCTOR
   METHOD GetDisplayName()
   METHOD AddToBalance( nAmount, cReason )
ENDCLASS
```

---

## 6. Documenting Methods

A method is documented exactly like a function. The doc block MUST sit immediately above the `METHOD ... CLASS ...` statement.

### 6.1 Constructor

```harbour
/**
 * Constructor for TCustomer. Calls the parent constructor and
 * initializes customer-specific fields.
 *
 * @param cName  (C) -> Customer full name or company name
 * @param cEmail (C) -> Primary contact email address
 * @return (O) -> New TCustomer instance
 * @since 1.0.0
 * @example
 *   oCust := TCustomer():New( "Acme Corp", "billing@acme.com" )
 */
METHOD New( cName, cEmail ) CLASS TCustomer
   ::Super:New()
   ::cName  := cName
   ::cEmail := cEmail
   RETURN Self
```

### 6.2 Regular Method

```harbour
/**
 * Adds or subtracts an amount from the customer credit balance.
 *
 * Positive values increase the balance, negative values decrease it.
 * Records the reason for audit.
 *
 * @param nAmount (N) -> Amount to add (positive) or subtract (negative)
 * @param cReason (C) -> Business reason for the adjustment
 * @return (N) -> New balance after adjustment
 * @since 2.0.0
 * @see Validate
 * @example
 *   nNewBal := oCust:AddToBalance( -150.00, "Invoice #4521 payment" )
 */
METHOD AddToBalance( nAmount, cReason ) CLASS TCustomer
   ::nBalance   += nAmount
   ::dUpdatedAt := Date()
   RETURN ::nBalance
```

### 6.3 Method Overriding a Parent

```harbour
/**
 * Validates customer data before persistence.
 * Extends base validation with email format and name checks.
 *
 * @return (L) -> .T. if customer data is valid
 * @since 1.0.0
 * @see TBaseEntity
 */
METHOD Validate() CLASS TCustomer
   LOCAL lValid := ::Super:Validate()
   IF Empty( ::cName )
      lValid := .F.
   ENDIF
   RETURN lValid
```

---

## 7. Documenting Constants (#define)

Constants are documented with a doc block immediately above the `#define` line. The parser extracts both the name and the value.

```harbour
/**
 * Maximum allowed length for customer name fields.
 * Values exceeding this limit are rejected during validation.
 *
 * @since 1.0.0
 * @see ValidateCustomerName
 */
#define MAX_NAME_LENGTH      60

/**
 * Maximum number of line items allowed per order.
 * Orders exceeding this limit must be split.
 *
 * @since 2.0.0
 * @see ValidateOrderItems
 */
#define MAX_ORDER_ITEMS      500

/**
 * Application version string displayed in all output.
 *
 * @since 1.0.0
 */
#define APP_VERSION          "3.1.0"
```

The `@param` and `@return` tags do NOT apply to constants. Use `@since` and `@see` only.

---

## 8. Tag Reference

All tags begin with `@` and appear on their own line inside the doc block.

| Tag | Applies to | Purpose |
|-----|------------|---------|
| @param | Function, Method, Constructor | Documents a parameter |
| @return | Function, Method, Constructor | Documents the return value |
| @returns | (alias of @return) | Same as above |
| @since | Any symbol | Version in which the symbol was added |
| @see | Any symbol | Cross-reference to another symbol |
| @example | Any symbol | Usage example (multi-line, accumulated) |
| @deprecated | Any symbol | Marks the symbol as deprecated |
| @internal | Any symbol | Marks the symbol as internal |

### 8.1 @param

Syntax: `@param cName (Type) -> Description`

```harbour
@param cName   (C) -> Customer full name
@param nAmount (N) -> Amount to add
@param lFlag   (L) -> Enable flag
@param dStart  (D) -> Range start date
@param aItems  (A) -> Array of item hashes
@param hData   (H) -> Data hash
@param oObject (O) -> Object instance
@param xValue  (X) -> Any value
```

### 8.2 @return

```harbour
@return (C)   -> Formatted display string
@return (N)   -> New balance after adjustment
@return (L)   -> .T. if validation passes
@return (O)   -> New TCustomer instance
@return (H)   -> Hash with all entity fields
@return (NIL) -> Nothing (procedure)
```

### 8.3 @since

```harbour
@since 1.0.0
@since 2.0.0
@since 3.1.0
```

### 8.4 @see

```harbour
@see TBaseEntity
@see ValidateEmail
@see CalculateTotal
```

Multiple references require multiple `@see` lines. In the HTML output each reference becomes a clickable anchor.

### 8.5 @example

```harbour
/**
 * @example
 *   LOCAL cId := GenerateUniqueId( "ORD", 16 )
 *   ? cId
 *   // Prints: ORD-20261009-A7X2
 */
```

### 8.6 @deprecated and @internal

```harbour
/**
 * @deprecated Use NewMethod() instead.
 */
FUNCTION OldMethod()

/**
 * @internal Not part of the public API.
 */
```

---

## 9. Type Codes

| Code | Meaning | Example values |
|------|---------|----------------|
| C | Character | "hello", "" |
| N | Numeric | 42, 3.14, 0 |
| L | Logical | .T., .F. |
| D | Date | Date(), CToD(...) |
| A | Array | { 1, 2, 3 } |
| H | Hash | { => }, { "k" => "v" } |
| O | Object | TMyClass():New() |
| X | Any / Unknown | mixed types |
| NIL | No value | procedure return |

Type codes are **single letters** and are always written between parentheses: `(C)`, `(N)`, `(L)`, `(D)`, `(A)`, `(H)`, `(O)`, `(X)`.

---

## 10. Parser Rules

### 10.1 Block Boundaries

| Rule | Effect |
|------|--------|
| Start with `/**` | Recognized |
| Start with `/*` (single asterisk) | Ignored |
| Start with `//` | Ignored |
| Terminate with `*/` | Recognized |
| `/**` inside a string literal `"…/**…"` | Ignored (safe) |
| `/**` after `//` on the same line | Ignored (safe) |
| Unclosed block at EOF | Flushed as token |

### 10.2 Association

The doc block is associated with the first symbol keyword that follows it. Blank lines are allowed between the block and the symbol. Any non-blank code line resets the association.

```harbour
/** Documents Foo */
                          ← blank lines OK
FUNCTION Foo()            ← associated

/** Intended for Foo */
LOCAL x := 1              ← breaks association
FUNCTION Foo()            ← NOT associated
```

### 10.3 Description vs. Tag Content

The description is every non-tag line before the first `@` tag. After the first tag, non-tag lines belong to the previous tag (useful for `@example`, less so for `@param`).

Place the free-text description first, then tags.

### 10.4 @example Accumulation

Everything after `@example` — including blank lines and non-tag lines — is captured until the next `@` tag or the closing `*/`.

### 10.5 Cleanup

The parser automatically strips:
- The leading `/**` and trailing `*/`.
- One leading `*` on each continuation line.
- Leading and trailing whitespace on every line.

---

## 11. Best Practices & Style Guide

### 11.1 Always

✅ Start every public symbol with a doc block.  
✅ Write a one-line brief first (becomes the summary).  
✅ Write the description before any tag.  
✅ Give every parameter a type code and a description.  
✅ Give every function a `@return`.  
✅ Use `@since` on every public symbol.  
✅ Use `@see` to link related symbols.

### 11.2 Prefer

✅ Multi-line blocks with `*` prefixes.  
✅ One `@param` per line.  
✅ One `@see` per line.  
✅ Verbs in the third person: "Returns …", "Calculates …", "Validates …".

### 11.3 Avoid

❌ `@param` in a different order than the actual signature.  
❌ Inline `@param` and `@return` on the same line as `@example`.  
❌ Emojis inside doc comments (may trigger lexer errors).  
❌ Doc blocks far away from the symbol.

---

## 12. Common Mistakes

### 12.1 Using `/*` instead of `/**`

```harbour
/* This is NOT a doc block. */
FUNCTION Foo()              ← not documented
```

### 12.2 Placing the Doc Block Too Far Away

```harbour
/**
 * Intended for Foo.
 */
#include "minigui.ch"        ← association lost
FUNCTION Foo()              ← not documented
```

### 12.3 Writing the Description After a Tag

```harbour
/**
 * @param nX (N) -> X value
 * This line is NOT part of the description.
 * It becomes part of the @param content.
 */
FUNCTION Foo( nX )
```

### 12.4 Using Invalid Type Codes

```harbour
@param nAge (INT) -> Age in years    ← invalid; use (N)
@param cName (STR) -> Name           ← invalid; use (C)
```

### 12.5 Emojis in Source

```harbour
/**
 * 📘 Returns the manual.   ← may trigger E0030 lexer errors
 */
```

---

## 13. File Header Standards

Every `.prg` file MUST begin with a standard header block.

### 13.0 Placeholder Resolution

Every placeholder `{{...}}` in the file header template MUST be resolved using the metadata collected in §1.0. If a value is missing:

- Use the **default value** defined in §1.0.2.
- Emit the corresponding **warning code** (W0001–W0004).
- NEVER leave a literal `{{PLACEHOLDER}}` in the generated output — this is a fatal parser error (`E0010`).

The `Language` field in the header MUST match the language selected in §1.0. If the selected language is `EN`, the field may be omitted (default assumption).

### 13.1 Standard File Header Template

```harbour
/*
     {{COMPANY_NAME}}
     Program       : {{PROGRAM_NAME}}
     Module        : {{MODULE_NAME}}.prg
     Compiler      : MINIGUI - Harbour Win32 GUI
     Compiler-C    : BCC 32 bit
     Author        : {{PERSON_NAME}}
     Email         : {{CONTACT_EMAIL}}
     Website       : {{WEBSITE}}
     Date          : {{START_DATE}}
     Update        : {{UPDATE_DATE}}
     Rev           : 1.0
     Language      : {{LANGUAGE}}
     Description   :
        Brief description of the module.
     Notes         :
        Hungarian notation enforced.
        UI strings via T( cKey ), never hardcoded.
     Warnings (memory/resource audit) :
        Every USE is closed.
        Every record lock is released with dbUnlock().
        Every SQL connection is returned to pool.
  */
#include "minigui.ch"
#include "hbclass.ch"
```

### 13.2 Module-Level Documentation

After the file header, document the module purpose with a doc block before the first `STATIC` or `PROCEDURE` declaration:

```harbour
/**
 * @module customer_manager
 * @brief Manages customer CRUD operations, validation, and persistence.
 *
 * This module provides the complete customer management workflow:
 * - Create, read, update, delete operations
 * - Validation with regex patterns
 * - Multi-database support (DBF/CDX, SQLite, MySQL, PostgreSQL)
 * - i18n-ready UI strings
 *
 * @since 1.0.0
 * @see TCustomer
 * @see TCustomerRepository
 */
```

---

## 14. Module Documentation

### 14.1 Complete Real-World Example

```harbour
/*
     {{COMPANY_NAME}}
     Module        : sample_utils.prg
     SPDX-License-Identifier: MIT
  */
#include "minigui.ch"

/**
 * @module sample_utils
 * @brief Utility functions for pricing calculations and formatting.
 * @since 1.0.0
 */

/**
 * Calculates the total price including tax and discount.
 *
 * Applies a percentage tax to the base price, then subtracts an
 * optional flat discount. The result is never negative.
 *
 * @param nPrice    (N) -> Base unit price before tax
 * @param nQuantity (N) -> Number of units to calculate
 * @param nTaxRate  (N) -> Tax percentage to apply (0-100)
 * @param nDiscount (N) -> Flat discount amount to subtract
 * @return (N) -> Final total price after tax and discount
 * @since 1.0.0
 * @see FormatCurrency
 * @example
 *   nTotal := CalculateTotal( 100.00, 5, 12.0, 50.00 )
 *   // Result: 510.00
 */
FUNCTION CalculateTotal( nPrice, nQuantity, nTaxRate, nDiscount )
   LOCAL nSubtotal := nPrice * nQuantity
   LOCAL nTax      := nSubtotal * ( nTaxRate / 100 )
   LOCAL nTotal    := nSubtotal + nTax - nDiscount
   IF nTotal < 0
      nTotal := 0
   ENDIF
   RETURN nTotal

/**
 * Formats a numeric value as a currency string.
 *
 * @param nAmount (N) -> The monetary amount to format
 * @param cSymbol (C) -> Currency symbol prefix (e.g., "$", "EUR")
 * @return (C) -> Formatted currency string
 * @since 1.0.0
 * @see CalculateTotal
 * @example
 *   cResult := FormatCurrency( 1234567.89, "$" )
 *   // Result: "$1,234,567.89"
 */
FUNCTION FormatCurrency( nAmount, cSymbol )
   LOCAL cFormatted
   cFormatted := TRANSFORM( nAmount, "999,999,999.99" )
   RETURN cSymbol + cFormatted
```

### 14.2 Complete OOP Model Example

```harbour
#include "hbclass.ch"

/**
 * Customer model representing a business client.
 * Inherits from TBaseEntity and adds customer-specific
 * fields such as name, contact info, and credit balance.
 *
 * @since 1.0.0
 * @see TBaseEntity
 * @see TOrder
 */
CLASS TCustomer FROM TBaseEntity
   DATA cName     INIT ""
   DATA cEmail    INIT ""
   DATA cPhone    INIT ""
   DATA cCity     INIT ""
   DATA nBalance  INIT 0
   METHOD New( cName, cEmail ) CONSTRUCTOR
   METHOD GetDisplayName()
   METHOD AddToBalance( nAmount, cReason )
   METHOD Validate()
   METHOD ToHash()
ENDCLASS

/**
 * Constructor for TCustomer. Calls the parent constructor and
 * initializes customer-specific fields.
 *
 * @param cName  (C) -> Customer full name or company name
 * @param cEmail (C) -> Primary contact email address
 * @return (O) -> New TCustomer instance
 * @since 1.0.0
 * @example
 *   oCust := TCustomer():New( "Acme Corp", "billing@acme.com" )
 */
METHOD New( cName, cEmail ) CLASS TCustomer
   ::Super:New()
   IF cName == NIL  ; cName  := "" ; ENDIF
   IF cEmail == NIL ; cEmail := "" ; ENDIF
   ::cName  := cName
   ::cEmail := cEmail
   RETURN Self

/**
 * Returns a formatted display name combining the customer
 * name and city for use in UI labels and reports.
 *
 * @return (C) -> Formatted display string
 * @since 1.5.0
 * @see GetId
 */
METHOD GetDisplayName() CLASS TCustomer
   LOCAL cDisplay := ::cName
   IF !Empty( ::cCity )
      cDisplay += " (" + ::cCity + ")"
   ENDIF
   RETURN cDisplay

/**
 * Adds or subtracts an amount from the customer credit balance.
 * Positive values increase the balance, negative values decrease it.
 *
 * @param nAmount (N) -> Amount to add or subtract
 * @param cReason (C) -> Business reason for the adjustment
 * @return (N) -> New balance after adjustment
 * @since 2.0.0
 * @see Validate
 * @example
 *   nNewBal := oCust:AddToBalance( -150.00, "Invoice #4521 payment" )
 */
METHOD AddToBalance( nAmount, cReason ) CLASS TCustomer
   ::nBalance   += nAmount
   ::dUpdatedAt := Date()
   RETURN ::nBalance
```

---

## 15. Generating Documentation with harbour-doc

Once your code follows the standard, generate documentation with the CLI.

### 15.1 Commands

```bash
# HTML (default)
harbour-doc generate -i src -o docs -f html

# Multiple formats in one run
harbour-doc generate -i src -o docs -f html -f txt -f json -f md

# Strict mode: warnings become errors
harbour-doc generate -i src -o docs -f html --strict

# Validate only (no output files)
harbour-doc validate -i src --strict

# Inspect token counts
harbour-doc scan -i src
```

### 15.2 Format Aliases

| Alias | Canonical | File |
|-------|-----------|------|
| html | html | index.html |
| htm | html | index.html |
| md | markdown | index.md |
| markdown | markdown | index.md |
| txt | text | index.txt |
| text | text | index.txt |
| json | json | index.json |

### 15.3 Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Runtime error |
| 2 | Usage error |

---

## 16. Mandatory Checklist

Before delivering any documented code, verify:

### Pre-Generation Interview
- [ ] Language was asked (or default `EN` applied).
- [ ] Project Name was provided (otherwise E0001 aborts).
- [ ] Person Name, Company, Email, Website were asked (defaults applied if missing).
- [ ] All `{{...}}` placeholders in file headers are resolved — no literal placeholders remain.
- [ ] Documentation free-text is written in the selected language.
- [ ] Code identifiers and tags remain in English.

### Structure & Headers
- [ ] Every `.prg` file begins with the standard file header.
- [ ] File header contains all required fields (author, company, date, etc.).
- [ ] Module-level doc block present after file header.

### Documentation Blocks
- [ ] Every public symbol has a `/** ... */` doc block.
- [ ] Block starts with `/**` (two asterisks).
- [ ] Every continuation line begins with `*`.
- [ ] One tag per line.

### Tags
- [ ] `@param cName (C) -> Description` format used.
- [ ] `@return (Type) -> Description` format used.
- [ ] Description first; tags after.
- [ ] `@example` always last.

### Naming & Types
- [ ] Hungarian notation matches type codes.
- [ ] `@since` on every public symbol.
- [ ] `@see` links related symbols.
- [ ] No emojis in source code.
- [ ] No invalid type codes (use `C`, `N`, `L`, `D`, `A`, `H`, `O`, `X`, `NIL`).

### Parser Safety
- [ ] Doc block is immediately above the symbol (or separated only by blank lines).
- [ ] No non-blank code between block and symbol.
- [ ] Description does NOT appear after a tag.

---

## 17. Quick Reference Card

```harbour
/**
 * <Brief one-line description.>
 *
 * <Extended description. Free text.>
 * <Ends at the first @ tag.>
 *
 * @param cName  (C) -> Parameter description
 * @param nCount (N) -> Parameter description
 * @return (L) -> .T. on success
 * @since 1.0.0
 * @see OtherSymbol
 * @see AnotherSymbol
 * @deprecated Use NewSymbol() instead.
 * @internal
 * @example
 *   LOCAL lOk := MyFunc( "test", 42 )
 */
FUNCTION MyFunc( cName, nCount )
   RETURN .T.
```

---

## 📌 Final Notes

### Key Principles

✅ **Proximity** — Documentation lives directly above the symbol.  
✅ **Structure** — Tags carry machine-readable metadata; free text carries human-readable meaning.  
✅ **Simplicity** — No compiler directives, no external files, no annotations that Harbour cannot parse.  
✅ **Consistency** — Every public symbol follows the same format.  
✅ **Completeness** — Every parameter, return value, and cross-reference is documented.

### Conflicts

This document is the **SOURCE OF TRUTH** for documentation standards in Harbour/MiniGUI Extended projects. In case of conflict with prior training, this document wins.

### Cross-References

| Topic | Reference |
|-------|-----------|
| General coding patterns, syntax | functional_oop.md |
| Multi-database design rules | dba.md |
| Complete API dictionary | harbour_minigui.md |
| Localization and translation | i18n.md |

---

📧 **Contact**: {{CONTACT_EMAIL}} | 🌐 **Website**: {{WEBSITE}}  
📅 **Last updated**: October 21, 2026