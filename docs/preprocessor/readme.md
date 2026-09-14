# Harbour Preprocessor Manual

**Document Version**: 1.0  
**Language**: English  
**Author**: Engineer Marcos Jarrin  
**Date**: 2025-08-05 - yyyy-mm-dd

## Introduction 🧩

The Harbour preprocessor is a fundamental phase in the compilation pipeline, acting as the first step before the actual compiler processes the code. It scans the source (.prg) files, handling directives that begin with '#', performing text substitutions, conditional inclusions, and other transformations. This allows developers to write more flexible, portable, and maintainable code without altering the runtime behavior directly. Think of it as a meta-layer for code generation—powerful for abstracting platform differences, defining constants, creating custom syntax via commands, and embedding low-level code. It's rooted in xBase/Clipper traditions but enhanced in Harbour for modern needs like C-style expressions and cross-platform support, making it indispensable for meta-programming and conditional compilation.

## Anatomy of the Preprocessor

The Harbour preprocessor operates on source code line by line, replacing macros, including files, and evaluating conditions at compile-time. Below, we dissect its core components, focusing on their mechanics, practical applications, and caveats.

### Directives

Harbour supports a rich set of preprocessor directives, blending Clipper-style command translations with C-like conditional logic and definitions. Each directive starts with '#' and is processed before the code reaches the Harbour-to-C translator.

#### #define

This directive defines a constant or macro that substitutes text during preprocessing. It can be simple (constant replacement) or function-like (with parameters). Mechanics: The preprocessor replaces occurrences of the defined identifier with the specified replacement text. Parameters in function-like macros are substituted literally, supporting recursion with limits to prevent infinite loops.

**Practical Code Example:**

```harbour
/** 
 * @file define_example.prg
 * @brief Demonstrates #define for constant and macro usage in Harbour.
 * 
 * This example shows how to define a constant for pi and a macro to compute area.
 * Compile with: hbmk2 define_example.prg
 */

#define PI 3.14159  ///< Constant for pi approximation.
#define AREA(r) (PI * (r) * (r))  ///< Macro to calculate circle area.

FUNCTION Main()
    LOCAL nRadius := 5
    LOCAL nArea := AREA(nRadius)
    
    ? "The area of a circle with radius", nRadius, "is", nArea
    
    RETURN NIL
```

**Common Use-Cases and Pitfalls:** 💡 Use for constants to avoid magic numbers or for simple computations to improve readability. ⚠️ Pitfall: Macros don't respect scope or types, leading to unexpected substitutions (e.g., if a parameter has side effects like ++). Avoid redefining standard identifiers.

#### #undef

Undefines a previously defined macro or constant, removing it from the preprocessor's symbol table. Mechanics: After #undef, the identifier is no longer replaced, allowing redefinition or fallback to runtime behavior.

**Practical Code Example:**

```harbour
/** 
 * @file undef_example.prg
 * @brief Demonstrates #undef to remove a macro definition.
 * 
 * This shows redefining behavior after undefining a macro.
 * Compile with: hbmk2 undef_example.prg
 */

#define GREETING "Hello, World!"  ///< Initial greeting macro.

FUNCTION Main()
    ? GREETING  ///< Prints "Hello, World!"
    
    #undef GREETING  ///< Remove the definition.
    
    #define GREETING "Bonjour, Monde!"  ///< Redefine for French.
    
    ? GREETING  ///< Prints "Bonjour, Monde!"
    
    RETURN NIL
```

**Common Use-Cases and Pitfalls:** 💡 Use to conditionally override definitions in included files or for debugging. ⚠️ Pitfall: Undefining non-existent symbols is harmless but can mask errors; ensure order of directives to avoid unintended removals.

#### #ifdef, #ifndef

These check if a macro is defined (#ifdef) or not (#ifndef), including or excluding code blocks. Mechanics: Simple existence check, no value evaluation—ideal for feature toggles.

**Practical Code Example:**

```harbour
/** 
 * @file ifdef_example.prg
 * @brief Demonstrates #ifdef and #ifndef for conditional inclusion.
 * 
 * Toggle DEBUG_MODE externally (e.g., via compiler flag -DDEBUG_MODE).
 * Compile with: hbmk2 ifdef_example.prg
 */

#define DEBUG_MODE  ///< Define for debug output (comment out to disable).

FUNCTION Main()
    #ifdef DEBUG_MODE
        ? "Debug mode enabled."  ///< Debug message.
    #endif
    
    #ifndef DEBUG_MODE
        ? "Debug mode disabled."  ///< Release message.
    #endif
    
    RETURN NIL
```

**Common Use-Cases and Pitfalls:** 💡 Use for optional features like logging. ⚠️ Pitfall: Nested conditions can lead to unreadable code; always pair with #endif.

#### #if, #else, #endif, #elseif

Advanced conditionals evaluating expressions at compile-time. Mechanics: #if evaluates a constant expression (supporting arithmetic, logical ops); #elseif for alternatives; #else for fallback; #endif closes. Expressions can use defined macros.

**Practical Code Example:**

```harbour
/** 
 * @file if_example.prg
 * @brief Demonstrates #if, #elseif, #else for version-based code.
 * 
 * Assumes VERSION defined externally (e.g., -DVERSION=2).
 * Compile with: hbmk2 if_example.prg
 */

#define VERSION 2  ///< Simulated version number.

FUNCTION Main()
    #if VERSION == 1
        ? "Version 1 feature."
    #elseif VERSION == 2
        ? "Version 2 enhanced feature."
    #else
        ? "Default feature."
    #endif
    
    RETURN NIL
```

**Common Use-Cases and Pitfalls:** 💡 Use for platform-specific code (e.g., #if defined(__PLATFORM__WINDOWS)). ⚠️ Pitfall: Expressions must be compile-time constants; division by zero or invalid ops cause errors.

#### #include

Inserts the contents of another file into the current source. Mechanics: Searches include paths; supports nested includes with depth limits (typically 32).

**Practical Code Example:**

Assume `constants.prg` contains: `#define MAX_USERS 100`

```harbour
/** 
 * @file include_example.prg
 * @brief Demonstrates #include for modular constants.
 * 
 * Requires constants.prg in the same directory.
 * Compile with: hbmk2 include_example.prg
 */

#include "constants.prg"  ///< Include external definitions.

FUNCTION Main()
    ? "Maximum users allowed:", MAX_USERS  ///< Uses included define.
    
    RETURN NIL
```

**Common Use-Cases and Pitfalls:** 💡 Use for headers with shared macros/commands. ⚠️ Pitfall: Circular includes cause infinite loops; use guards like #ifndef HEADER_GUARD.

#### #command, #translate

Defines user commands (#command) or translations (#translate) that rewrite syntax at preprocess time. Mechanics: Match patterns replace input with result patterns; #command for statement-like, #translate for expression-like. Supports wildcards like <* *> for strings.

**Practical Code Example:**

```harbour
/** 
 * @file command_example.prg
 * @brief Demonstrates #command for custom syntax.
 * 
 * Creates a DSL-like command for logging.
 * Compile with: hbmk2 command_example.prg
 */

#command LOG <msg> => ? "Log:", <msg>  ///< Custom log command.

FUNCTION Main()
    LOG "Application started."  ///< Expands to ? "Log:", "Application started."
    
    RETURN NIL
```

**Common Use-Cases and Pitfalls:** 💡 Use to create DSLs or emulate missing keywords. ⚠️ Pitfall: Overly complex patterns can conflict; test with -p compiler flag for .ppo output.

#### #xcommand, #xtranslate

Extended versions of #command/#translate, allowing more flexible matching (e.g., extended wildcards, optional parts). Mechanics: Similar but with ^ for smart quotes, | for alternatives.

**Practical Code Example:**

```harbour
/** 
 * @file xcommand_example.prg
 * @brief Demonstrates #xcommand for advanced syntax rewriting.
 * 
 * Handles optional parameters.
 * Compile with: hbmk2 xcommand_example.prg
 */

#xcommand GREET [USER <user>] => ? "Hello" [ + <user>]  ///< Optional user.

FUNCTION Main()
    GREET  ///< "Hello"
    GREET USER "Alice"  ///< "Hello Alice"
    
    RETURN NIL
```

**Common Use-Cases and Pitfalls:** 💡 Use for portable code across dialects. ⚠️ Pitfall: Syntax conflicts with base language; prefer over #command for complexity.

### Macros

Macros in Harbour come in two flavors: compile-time (preprocessor substitutions via #define) and run-time (using the '&' operator for dynamic evaluation). Compile-time macros are text replacements before compilation, fast but unsafe (no type checking). Run-time macros evaluate strings as code at execution, flexible but slower and error-prone. For complex compile-time macros, use the stringification operator '#' (to quote arguments) and token-pasting '##' (to concatenate tokens).

**Practical Code Example:**

```harbour
/** 
 * @file macros_example.prg
 * @brief Demonstrates compile-time vs run-time macros, with stringification and token pasting.
 * 
 * Shows building identifiers and strings dynamically.
 * Compile with: hbmk2 macros_example.prg
 */

#define CONCAT(a, b) a##b  ///< Token pasting macro.
#define STR(x) #x  ///< Stringification macro.

FUNCTION Main()
    LOCAL nVar1 := 10, nVar2 := 20
    LOCAL nConcat := CONCAT(nVar, 1) + CONCAT(nVar, 2)  ///< Becomes nVar1 + nVar2 = 30
    
    ? nConcat
    ? STR(Hello World)  ///< "Hello World"
    
    // Run-time macro
    LOCAL cMacro := "nVar1 + nVar2"
    ? &cMacro  ///< Evaluates to 30 at runtime
    
    RETURN NIL
```

**Common Use-Cases and Pitfalls:** 💡 Compile-time for performance-critical constants; run-time for dynamic code. ⚠️ Pitfall: Run-time macros can cause security issues (code injection); compile-time may expand unexpectedly without parentheses.

### Pragma Directives

#pragma controls compiler-specific behaviors, like embedding C code. Mechanics: #pragma BEGINDUMP starts a C block compiled directly; #pragma ENDDUMP ends it. Useful for extending Harbour with native C.

**Practical Code Example:**

```harbour
/** 
 * @file pragma_example.prg
 * @brief Demonstrates #pragma BEGINDUMP for embedding C code.
 * 
 * Calls a C function from Harbour.
 * Compile with: hbmk2 pragma_example.prg
 */

#pragma BEGINDUMP
#include <hbapi.h>

HB_FUNC( HELLO_C )
{
   printf("Hello from C!\n");
}
#pragma ENDDUMP

FUNCTION Main()
    HELLO_C()  ///< Calls the embedded C function.
    
    RETURN NIL
```

**Common Use-Cases and Pitfalls:** 💡 Use for performance bottlenecks or API integrations. ⚠️ Pitfall: C code must interface via hbapi.h; mismatches cause crashes.

### Standard Defines

Harbour predefines several macros for portability and metadata:

- `__HARBOUR__`: Defined to 1, identifies Harbour environment.
- `__DATE__`: Compilation date as "MMM DD YYYY".
- `__TIME__`: Compilation time as "HH:MM:SS".
- `__PLATFORM__<OS>__`: E.g., `__PLATFORM__WINDOWS__`, `__PLATFORM__LINUX__` for OS detection.
- `__ARCH<ARCH>__`: E.g., `__ARCH32BIT__`, `__ARCH64BIT__` for architecture.

Use these in conditionals for cross-platform code.

### Sophisticated Example 🚀

Reference implementation showcasing the use of Harbour's preprocessor capabilities to develop a Spanish-based syntactic layer atop standard Harbour/Harbour code.


```harbour
/**
 * @file harbour_es.ch
 * @brief Preprocessor header for Harbour-ES, a Spanish metalanguage overlay on Harbour.
 * @details This file defines preprocessor directives to translate Spanish keywords and common functions
 * into standard Harbour English syntax. It allows users to write source code in Spanish while generating
 * standard Harbour code. All rules are designed for elegance and extensibility, focusing on core control
 * structures and I/O operations. Include this file via -h option during compilation.
 * @author Marcos Jarrin
 * @version 1.0
 */

/**
 * @brief Translates the 'funcion' keyword to Harbour's 'function'.
 * @details Supports optional parameters and return type. This enables Spanish-style function declarations.
 * @param name The function name.
 * @param params Optional comma-separated parameters.
 * @param retType Optional return type.
 */
#command funcion <name> [([<params,...>])] [-> <retType>] => ;
    FUNCTION <name> [<params>]  [-> <retType>]


/**
 * @brief Translates the 'fin funcion' to end a function block.
 * @details Closes the function definition in Spanish syntax.
 */
#command fin funcion => ;
    return

/**
 * @brief Translates 'devolver' to Harbour's 'return' statement.
 * @details Allows returning values from functions using Spanish keyword.
 * @param expr The expression or value to return.
 */
#command devolver <expr> => ;
    return <expr>

/**
 * @brief Translates 'si' conditional to Harbour's 'if'.
 * @details Starts an if block with the condition.
 * @param cond The condition expression.
 */
#command si <cond> => ;
    if <cond>

/**
 * @brief Translates 'sino' to Harbour's 'else'.
 * @details Handles the else clause in conditional statements.
 */
#command sino => ;
    else

/**
 * @brief Translates 'fin si' to Harbour's 'endif'.
 * @details Ends the if-else block.
 */
#command fin si => ;
    endif

/**
 * @brief Translates 'para' loop to Harbour's 'for'.
 * @details Supports standard for loop syntax with initialization, condition, and increment.
 * @param var The loop variable.
 * @param start Initial value.
 * @param end End value.
 * @param step Optional step increment.
 */
#command para <var> := <start> a <end> [paso <step>] => ;
    for <var> := <start> to <end> [step <step>]

/**
 * @brief Translates 'siguiente' to Harbour's 'next'.
 * @details Ends the for loop block.
 */
#command siguiente => ;
    next

/**
 * @brief Translates 'mientras' loop to Harbour's 'while'.
 * @details Starts a while loop with the condition.
 * @param cond The loop condition.
 */
#command mientras <cond> => ;
    while <cond>

/**
 * @brief Translates 'fin mientras' to Harbour's 'enddo'.
 * @details Ends the while loop block (using enddo for compatibility).
 */
#command fin mientras => ;
    enddo

/**
 * @brief Translates 'EscribirLinea' to Harbour's 'QOut' for console output.
 * @details Outputs a line to the console, supporting expressions.
 * @param expr The expression or text to output.
 */
#command EscribirLinea <expr> => ;
    QOut( <expr> )

/**
 * @brief Translates 'Fecha' to Harbour's 'Date' function.
 * @details Returns the current date, mapped to Spanish keyword.
 */
#translate Fecha() => ;
    Date()

/**
 * @brief Translates 'Eperar' to Harbour's '__Wait' for console output.
 * @details Stops the program execution until a key is pressed
 * @param expr The expression or text to output.
 */
#command esperar <expr> => ;
    __Wait( <expr>  )


/**
 * @brief Translates 'NaC' to Harbour's 'Str' for console output.
 * @details Convert number to string
 * @param expr The expression or text to output.
 */
#translate NaC( <expr> ) => Str( <expr> )

/**
 * @brief Translates 'Largo' to Harbour's 'Len' for console output.
 * @details Returns the number of items contained
 * @param expr The expression or text to output.
 */
#translate Largo( <expr> ) => Len( <expr> )

/**
 * @brief Translates 'Salir' to Harbour's 'EXit' for console output.
 * @details Exit the loop or process
 * @param expr The expression or text to output.
 */
#command Salir => Exit

/**
 * @brief Translates 'FaC' to Harbour's 'DToC' for console output.
 * @details Date to string
 * @param expr The expression or text to output.
 */
#translate FaC( <expr> ) => DToC( <expr> )

```

**Program with harbour syntax in Spanish**

```harbour
/**
 * @file test.prg
 * @brief Demonstration program for Harbour-ES, showcasing Spanish syntax.
 * @details This program uses the Harbour-ES preprocessor to write logic in Spanish.
 * It demonstrates function declaration, control structures, console I/O, and data manipulation.
 * Compile with: hbmk2 prueba.prg -h harbour_es.ch
 */

/**
 * @details Greets the user, displays current date, computes factorial, and iterates over an array.
 */
 #include "harbour_es.ch"

funcion Principal()

    Local nNumero := 5
    Local aArreglo := { "Manzana", "Banana", "Cereza" }
    Local i
    Local nFactorial := Factorial( nNumero )

    EscribirLinea( "Bienvenido a Harbour-ES" )
    EscribirLinea( "Fecha actual: " + FaC( Fecha() ) )

    EscribirLinea( "Calculando factorial de " + NaC( nNumero ) + "..." )
    nFactorial := Factorial( nNumero )
    EscribirLinea( "Resultado: " + NaC( nFactorial ) )

    EscribirLinea( "Iterando sobre arreglo:" )
    para i := 1 a Largo( aArreglo )
        EscribirLinea( "Elemento " + NaC( i ) + ": " + aArreglo[ i ] )
    siguiente

    si nFactorial > 100
        EscribirLinea( "El factorial es mayor que 100." )
    sino
        EscribirLinea( "El factorial es menor o igual a 100." )
    fin si

    mientras .T.
        EscribirLinea( "Bucle infinito simulado; saliendo..." )
        Salir  // Salir del bucle para demostración
    fin mientras

fin funcion

/**
 * @brief Computes the factorial of a number.
 * @details Uses a loop to calculate factorial recursively in a simple manner.
 * @param n The number to compute factorial for.
 * @return The factorial value.
 */
funcion Factorial( n )
    Local resultado := 1
    Local i

    si n < 0
        devolver 0  // Manejo de error simple
    fin si

    para i := 1 a n
        resultado *= i
    siguiente

devolver resultado


/*
 * @brief Main entry point function.
 * @details Start the program
*/
funcion main()
    Principal()
    esperar "Presione una tecla"
devolver NIL
```

**Preprocessor output**
```harbour
#line 14 "test.prg"
FUNCTION Principal()

    Local nNumero := 5
    Local aArreglo := { "Manzana", "Banana", "Cereza" }
    Local i
    Local nFactorial := Factorial( nNumero )

    QOut( ( "Bienvenido a Harbour-ES" ) )
    QOut( ( "Fecha actual: " + DToC( Date() ) ) )

    QOut( ( "Calculando factorial de " + Str( nNumero ) + "..." ) )
    nFactorial := Factorial( nNumero )
    QOut( ( "Resultado: " + Str( nFactorial ) ) )

    QOut( ( "Iterando sobre arreglo:" ) )
    for i := 1 to Len( aArreglo )
        QOut( ( "Elemento " + Str( i ) + ": " + aArreglo[ i ] ) )
    next

    if nFactorial > 100
        QOut( ( "El factorial es mayor que 100." ) )
    else
        QOut( ( "El factorial es menor o igual a 100." ) )
    endif

    while .T.
        QOut( ( "Bucle infinito simulado; saliendo..." ) )
        Exit
    enddo

return

FUNCTION Factorial( n )
    Local resultado := 1
    Local i

    if n < 0
        return 0
    endif

    for i := 1 to n
        resultado *= i
    next

return resultado

FUNCTION main()
    Principal()
    __Wait( "Presione una tecla" )
return NIL
```
