/**
 * @file harbour_es.ch
 * @brief Preprocessor header for Harbour-ES, a Spanish metalanguage overlay on Harbour.
 * @details This file defines preprocessor directives to translate Spanish keywords and common functions
 * into standard Harbour English syntax. It allows users to write source code in Spanish while generating
 * standard Harbour code. All rules are designed for elegance and extensibility, focusing on core control
 * structures and I/O operations. Include this file via -h option during compilation.
 * @author Marcos Jarrin
 * @version 1.0
 *
 *  Copyright (C) 2025 Marcos Jarrin
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
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
