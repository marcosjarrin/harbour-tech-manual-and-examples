# Harbour MiniGUI Extended Programming Manual: Functional vs. Object-Oriented Programming

## The Definitive Guide to Choosing the Right Paradigm for Your Solution Type

---

# Introduction

Harbour is a **multi-paradigm** language par excellence. It supports imperative, functional (based on functions and procedures), object-oriented (with classes and inheritance), and reflective programming. This flexibility is a great strength, but also a responsibility: **choosing the wrong paradigm can doom a project to failure** due to technical debt, sluggishness, or unmaintainable code.

This manual aims to:
1. **Define true functional programming in Harbour** (based on `FUNCTION`/`PROCEDURE`) and its advantages for small, fast programs.
2. **Explain why Object-Oriented Programming (OOP)** is superior for large programs, highlighting its advantage in maintenance and scalability.
3. **Provide a decision guide** to know which paradigm (or mix of both) to use for each type of solution with Harbour MiniGUI Extended.

---

# Chapter 1: True Functional Programming in Harbour

## 1.1 What is Functional Programming in Harbour?

In the xBase/Harbour ecosystem, functional programming is not limited to writing `{|| ... }`. It is a **programming style where `FUNCTION` and `PROCEDURE` are the fundamental building blocks**. This style is characterized by:

- **Pure functions (or with controlled effects)**: Given the same input, they always return the same output, without modifying external variables.
- **Composition**: Building complex programs by chaining simple functions.
- **Relative immutability**: Avoid modifying global data structures; instead, create new ones.
- **Higher-order usage**: Passing functions (via `codeblocks` or references) to other functions to filter, map, or reduce data.

```harbour
// ----------------------------------------------------------
// CORRECT EXAMPLE OF FUNCTIONAL STYLE
// ----------------------------------------------------------

// Pure function: Doesn't touch anything external, only operates on its parameters
FUNCTION CalculateIVA(nPrice, nPercentage)
   RETURN nPrice * (nPercentage / 100)

// Pure function that transforms an array
FUNCTION FilterActive(aCustomers)
   LOCAL aResult := {}
   LOCAL i
   FOR i := 1 TO Len(aCustomers)
      IF aCustomers[i]:lActive  // Assuming it's an array of objects or hashes
         AAdd(aResult, aCustomers[i])
      ENDIF
   NEXT
RETURN aResult

// Higher-order usage with codeblocks (the codeblock is the "passenger", FUNCTION is the "structure")
PROCEDURE Main()
   LOCAL aNumbers := {10, 20, 30, 40, 50}
   LOCAL aDoubles
   
   // AEval is a Harbour function that receives a codeblock (behavior)
   AEval(aNumbers, {|x| QOut("Number: " + Str(x))})
   
   // AScan searches using a codeblock
   nPos := AScan(aNumbers, {|x| x > 25})
   
   ? "First number greater than 25 is at position:", nPos
RETURN
```

## 1.2 Advantages of Functional Programming in Small Programs

### 🔹 Development Speed (Rapidity)
For utilities, scripts, or isolated modules, the functional approach is **direct and concise**. You don't need to define classes, constructors, or think about inheritance hierarchies. The code flows from top to bottom.

### 🔹 Low Overhead and Performance
Functions and procedures in Harbour have **less memory and CPU overhead** than objects. There are no virtual tables (vtables) or object reference management. For massive data processing tasks, this makes a difference.

### 🔹 Ease of Debugging
In a small program, having a linear flow through functions makes following the call stack trivial. There's no need to navigate deep inheritance or overridden methods.

### 🔹 Ideal for Data Processing (Batch)
Harbour excels at database handling. Functions allow encapsulating SQL queries or filtering logic quickly and reusably without the paraphernalia of a class.

## 1.3 Practical Example: Database Cleanup Utility

```harbour
// ----------------------------------------------------------
// SMALL FUNCTIONAL PROGRAM (Console Utility)
// ----------------------------------------------------------

PROCEDURE Main()
   LOCAL cDateLimit := Date() - 365
   LOCAL aRecords, nDeleted
   
   ? "=== CLEANUP OF OLD RECORDS ==="
   
   // Load data
   aRecords := LoadLogs()
   
   // Functional filtering (we use functions, not classes)
   aRecords := FilterByDate(aRecords, cDateLimit)
   
   // Count and delete
   nDeleted := DeleteRecords(aRecords)
   
   ? "Records deleted:", nDeleted
   ? "Process completed."
RETURN

// ----------------------------------------------------------
// PURE FUNCTIONS OR WITH CONTROLLED EFFECTS
// ----------------------------------------------------------

FUNCTION LoadLogs()
   LOCAL aLogs := {}
   USE logs ALIAS Log NEW
   DO WHILE !Log->(Eof())
      AAdd(aLogs, {;
         id := Log->id,;
         date := Log->date,;
         text := Log->text;
      })
      Log->(DbSkip())
   ENDDO
   USE
RETURN aLogs

FUNCTION FilterByDate(aArray, dLimit)
   LOCAL aFiltered := {}
   LOCAL i
   FOR i := 1 TO Len(aArray)
      IF aArray[i]['date'] < dLimit
         AAdd(aFiltered, aArray[i])
      ENDIF
   NEXT
RETURN aFiltered

FUNCTION DeleteRecords(aArray)
   LOCAL nCount := 0
   LOCAL i
   USE logs ALIAS Log NEW
   FOR i := 1 TO Len(aArray)
      IF Log->(DbSeek(aArray[i]['id']))
         Log->(DbDelete())
         nCount++
      ENDIF
   NEXT
   USE
RETURN nCount
```

---

# Chapter 2: Object-Oriented Programming in Harbour

## 2.1 What is OOP in Harbour?

OOP in Harbour is natively supported through the `CLASS ... ENDCLASS` syntax. It allows **encapsulating** data (properties) and behaviors (methods) into a single entity. Harbour supports single inheritance, polymorphism, and abstract classes.

## 2.2 Advantages of OOP in Large Programs

### 🔹 Superior Maintainability
In a program with more than 10,000 lines, the biggest cost isn't writing it, but **maintaining** it.
- **Isolation of changes**: Modifying customer logic (`TCustomer`) does not affect invoice logic (`TInvoice`), as long as the public interface is respected.
- **Semantic readability**: `oCustomer:CalculateDiscount()` is much more readable and self-documenting than a standalone function `CalculateDiscount(oCustomer)`.

### 🔹 Scalability (Organic Growth)
OOP allows an application to grow in functionality without becoming chaotic:
- **Inheritance**: Create base classes (`TEntity`) and extend behaviors in child classes (`TCustomer`, `TSupplier`).
- **Polymorphism**: You can have an array of `TEntity` and call the `Save()` method without knowing if it's a customer or supplier; each will execute its own logic.
- **Composition**: An `TInvoice` object contains an array of `TInvoiceLine` objects, delegating responsibilities.

### 🔹 Organization for Teamwork
When multiple developers work together:
- **Defined contracts**: The frontend team only needs to know the interface of backend objects.
- **Fewer merge conflicts**: Each developer works on different classes.
- **Self-documenting code**: Class and method names express business intent.

### 🔹 Facilitation of Unit Testing
With OOP, you can substitute real dependencies with **mocks** or **stubs**.
```harbour
// In your tests, instead of connecting to a real DB...
oRepo := TMockCustomerRepository():New()  // Simulates responses
oController := TCustomerController():New(oRepo, oView)
// Isolated and fast tests.
```

## 2.3 Practical Example: Invoicing System with OOP (Large)

Here's how a complete module is structured using classes.

```harbour
// ==============================================================
// 1. ENTITY LAYER (Domain Model)
// ==============================================================

CLASS TEntity
   DATA nId
   DATA lDeleted
   METHOD New()
   METHOD Validate() VIRTUAL
   METHOD ToHash()
ENDCLASS

CLASS TCustomer FROM TEntity
   DATA cName
   DATA cPhone
   DATA cEmail
   DATA nCreditLimit
   METHOD New(cName, cPhone, cEmail)
   METHOD Validate() OVERRIDE
   METHOD GetDiscount(nTotal)
ENDCLASS

METHOD Validate() CLASS TCustomer
   IF Empty(::cName)
      RETURN .F.
   ENDIF
   IF !Empty(::cEmail) .AND. !("@" $ ::cEmail)
      RETURN .F.
   ENDIF
RETURN .T.

// ==============================================================
// 2. DATA ACCESS LAYER (Repositories)
// ==============================================================

CLASS TCustomerRepository
   DATA oDBConnection
   METHOD New(oDB)
   METHOD FindById(nId)
   METHOD FindByCriteria(cFilter)
   METHOD Save(oCustomer)
   METHOD Delete(nId)
ENDCLASS

METHOD Save(oCustomer) CLASS TCustomerRepository
   IF !oCustomer:Validate()
      RETURN .F.
   ENDIF
   IF oCustomer:nId == 0
      ::oDBConnection:Execute("INSERT INTO customers (name, phone, email, credit) VALUES (?, ?, ?, ?)",;
         oCustomer:cName, oCustomer:cPhone, oCustomer:cEmail, oCustomer:nCreditLimit)
      oCustomer:nId := ::oDBConnection:LastInsertId()
   ELSE
      ::oDBConnection:Execute("UPDATE customers SET name=?, phone=?, email=?, credit=? WHERE id=?",;
         oCustomer:cName, oCustomer:cPhone, oCustomer:cEmail, oCustomer:nCreditLimit, oCustomer:nId)
   ENDIF
RETURN .T.

// ==============================================================
// 3. BUSINESS LOGIC LAYER (Services / Controllers)
// ==============================================================

CLASS TInvoiceService
   DATA oCustomerRepo
   DATA oInvoiceRepo
   DATA oProductRepo
   METHOD New(oCustomerRepo, oInvoiceRepo, oProductRepo)
   METHOD CreateInvoice(nCustomerId, aItems)
   METHOD CalculateTotal(aItems)
ENDCLASS

METHOD CreateInvoice(nCustomerId, aItems) CLASS TInvoiceService
   LOCAL oCustomer := ::oCustomerRepo:FindById(nCustomerId)
   IF oCustomer == NIL
      RETURN NIL
   ENDIF
   
   // Business logic: validate credit limit
   LOCAL nTotal := ::CalculateTotal(aItems)
   IF nTotal > oCustomer:nCreditLimit
      RETURN NIL
   ENDIF
   
   // Create the invoice
   LOCAL oInvoice := TInvoice():New(oCustomer, aItems, nTotal)
   ::oInvoiceRepo:Save(oInvoice)
   
   // Decrease stock
   FOR EACH oItem IN aItems
      ::oProductRepo:DecreaseStock(oItem:ProductId, oItem:Quantity)
   NEXT
   
RETURN oInvoice

// ==============================================================
// 4. PRESENTATION LAYER (MiniGUI)
// ==============================================================

CLASS TInvoiceView
   DATA oWindow
   DATA oController
   DATA oGrid
   METHOD New(oController)
   METHOD CreateWindow()
   METHOD RefreshGrid(aData)
   METHOD GetSelectedCustomer()
ENDCLASS

METHOD CreateWindow() CLASS TInvoiceView
   ::oWindow := TWindow():New( "InvoiceForm", "New Invoice", 0, 0, 800, 600 )
   ::oWindow:SetMain()
   
   // ... Creating controls using OOHG ...
   // (Buttons call ::oController:OnSave(), etc.)
   
   ::oWindow:Center()
   ::oWindow:Activate()
RETURN
```

---

# Chapter 3: Technical Comparison and Decision Guide

## 3.1 Comparative Table

| Aspect | Functional Programming (FUNCTION/PROCEDURE) | Object-Oriented Programming (CLASS) |
|--------|---------------------------------------------|--------------------------------------|
| **Building unit** | Function / Procedure | Object / Class |
| **Initial complexity** | Very Low | Medium (learning curve) |
| **Writing speed (<2K lines)** | **Excellent** | Good |
| **Writing speed (>10K lines)** | Poor (becomes spaghetti) | **Excellent** (organized) |
| **5-year maintainability** | Very Poor | **Excellent** |
| **Scalability (adding modules)** | Difficult (global coupling) | **Easy** (new classes) |
| **Reusability across projects** | Low (copy/paste functions) | **High** (class libraries) |
| **Unit Testing** | Difficult (complex mocks) | **Easy** (dependency injection) |
| **Teamwork** | Chaotic (conflicts) | **Organized** (by modules) |
| **Performance (CPU/Memory)** | **Excellent** (less overhead) | Good (slight overhead) |

## 3.2 When to Use Pure Functional Programming?

| Scenario | Example in MiniGUI Extended |
|-----------|----------------------------|
| **Maintenance scripts** | Index cleanup, automatic backup |
| **Migration tools** | Moving data from DBF to PostgreSQL |
| **Disposable prototypes** | Proof of concept for an algorithm |
| **Simple report module** | Generate a PDF with aggregated data |
| **Isolated plugins or extensions** | A button that executes a specific routine |

**Golden rule**: If the program **won't grow** and **doesn't require long-term maintenance**, use functional.

## 3.3 When to Use Object-Oriented Programming?

| Scenario | Example in MiniGUI Extended |
|-----------|----------------------------|
| **ERP / CRM / Invoicing** | Complete system with customers, products, orders |
| **Application with multiple windows** | Dashboard, master-detail forms |
| **Projects with lifecycle > 2 years** | Software that will be constantly updated |
| **Teams of 2+ developers** | Frontend and backend separated into classes |
| **Need for automated testing** | CI/CD with unit and integration tests |

**Golden rule**: If the project **will grow** or **will be maintained by multiple people**, invest in OOP from day one.

## 3.4 The Hybrid Approach (Recommended for MiniGUI Extended)

The most successful practice in Harbour MiniGUI Extended is **using OOP for architecture and Functional for internal operations**:

1. **OOP Architecture**: Windows, Controllers, Repositories, and Services.
2. **Internal functional logic**: Inside methods, use pure functions for calculations, data transformation, and filtering.

```harbour
// PERFECT HYBRID EXAMPLE
CLASS TReportService
   METHOD GenerateSalesReport(dFrom, dTo)
ENDCLASS

METHOD GenerateSalesReport(dFrom, dTo) CLASS TReportService
   LOCAL aRawData := ::oRepo:GetSales(dFrom, dTo)
   LOCAL aGrouped, nTotal
   
   // 1. Functional: Group and sum with helper functions
   aGrouped := GroupByProduct(aRawData)   // <-- Pure function
   nTotal := SumArray(aGrouped, "amount") // <-- Pure function
   
   // 2. OOP: Create the report object and save it
   oReport := TSalesReport():New(aGrouped, nTotal, dFrom, dTo)
   ::oRepo:SaveReport(oReport)
   
   // 3. OOP: Display in the view
   ::oView:DisplayReport(oReport)
RETURN
```

---

# Chapter 4: Specific Recommendations for MiniGUI Extended

## 4.1 Project Classification by Size

| Size | Approx. Lines | Recommended Paradigm | MiniGUI Style |
|------|---------------|----------------------|---------------|
| **Micro** | < 500 | Pure Functional | Classic syntax (DEFINE WINDOW) |
| **Small** | 500 - 3,000 | Functional + pseudo-OOP | Standard MiniGUI with events |
| **Medium** | 3,000 - 10,000 | **Hybrid (OOP + Functional)** | MiniGUI for windows, Functional for data |
| **Large** | > 10,000 | **Pure OOP** (MVC) | OOP with Controllers and Services |

## 4.2 Essential OOP Patterns for Large Projects

1. **Repository Pattern**: Isolates database logic. Switching from DBF to SQL only requires changing the repository.
2. **Service Layer**: Centralizes business logic. GUI controllers only call services.
3. **Dependency Injection (DI)**: Pass dependencies (repositories) via constructor, facilitating testing.
4. **Observer (Events)**: To decouple GUI from logic (using `EventManager`).

## 4.3 Decision Checklist for Your Next Project

Check these boxes before writing the first line:

- [ ] Will the project exceed **5,000 lines**? → If **YES**, **MANDATORY** to use OOP.
- [ ] Will **more than 2 developers** participate? → If **YES**, **MANDATORY** to use OOP.
- [ ] Is the software expected to **live more than 2 years**? → If **YES**, **MANDATORY** to use OOP.
- [ ] Is it a **single-execution script** or minor utility? → If **YES**, use FUNCTIONAL.
- [ ] Does the user interface have **multiple interactive windows**? → If **YES**, use OOP.
- [ ] Do you need to **reuse** this code in another future project? → If **YES**, use OOP.

If you have a mix of "YES" and "NO", prioritize OOP, because **migrating from functional to OOP when the project is already large is extremely costly**. Conversely, starting with OOP and using internal functions is always cheaper and safer.

---

# Final Conclusion

> **Functional programming (based on `FUNCTION`/`PROCEDURE`) is the queen of speed and simplicity for small, utilitarian, short-lived programs.**
>
> **Object-Oriented Programming (based on `CLASS`) is the royal architecture for large, maintainable, scalable, and team-developed programs.**

In Harbour MiniGUI Extended, you are not a prisoner of a single paradigm. Wisdom lies in **using OOP to structure the castle (the overall architecture) and using functions to build the bricks (the internal logic of each module)**.

Remember: Code is written once but read and modified for years. Invest the initial time in designing a good OOP architecture for your main application, and leave the functional style for auxiliary tasks and internal calculations. Your future self (and your team) will thank you.

---

# Appendix: Additional Resources

- **Design Patterns in Harbour**: Reference repository on GitHub: [angelvisionwin/design-patterns-harbour](https://github.com/angelvisionwin/design-patterns-harbour).
- **Official Forum**: [https://groups.google.com/g/minigui-forum](https://groups.google.com/g/minigui-forum) - Active community for architecture questions.
- **Harbour Documentation**: https://github.com/marcosjarrin/Harbour_oop_manual