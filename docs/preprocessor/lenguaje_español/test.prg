/*
BadaSystem
Program       : test
Module        : test.prg
Compiler      : MINIGUI - Harbour Win32 GUI
Author        : Marcos Jarrín
Email         : marvijarrin@gmail.com
Website       : badasystem.com
Date          : 27/08/2025
Update        : 27/08/2025
Rev           : 1.0
SPDX-License-Identifier: MIT

Description:
  Demonstration program for Harbour-ES, showcasing Spanish syntax.
  This program uses the Harbour-ES preprocessor to write logic in Spanish.
  It demonstrates function declaration, control structures, console I/O,
  and data manipulation.

  Compile with: hbmk2 prueba.prg -h harbour_es.ch
*/

/**
* @file test.prg
* @brief Demonstration program for Harbour-ES, showcasing Spanish syntax.
* @details This program uses the Harbour-ES preprocessor to write logic in Spanish.
* It demonstrates function declaration, control structures, console I/O, and data manipulation.
* Compile with: hbmk2 prueba.prg -h harbour_es.ch
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
* @details Greets the user, displays current date, computes factorial, and iterates over an array.
*/

/*
Function: Principal
Purpose:
  Main demonstration function that showcases Harbour-ES Spanish syntax.
  Performs the following operations:
  1. Greets the user with a welcome message
  2. Displays the current system date
  3. Computes the factorial of a hardcoded number (5)
  4. Iterates over a sample array of fruit names
  5. Demonstrates conditional logic (IF/ELSE)
  6. Demonstrates loop control (WHILE with EXIT)

Parameters:
  (none)

Returns:
  NIL (implicit — procedure semantics)

Example:
  Principal()
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

devolver NIL

/*
Function: Factorial
Purpose:
  Computes the factorial of a given number using an iterative approach.
  The factorial of n (written as n!) is the product of all positive
  integers less than or equal to n.

  Formula: n! = n × (n-1) × (n-2) × ... × 1
  Special case: 0! = 1

Parameters:
  n (N) -> The number to compute factorial for. Must be >= 0.

Returns:
  N -> The factorial value. Returns 0 if input is negative (error case).

Example:
  nResult := Factorial( 5 )  // Returns 120 (5! = 5×4×3×2×1 = 120)
  nResult := Factorial( 0 )  // Returns 1
  nResult := Factorial( -1 ) // Returns 0 (error)

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
Procedure: main
Purpose:
  Entry point for the Harbour-ES demonstration program.
  Calls the main demonstration function and waits for user input
  before terminating.

Parameters:
  (none)

Returns:
  NIL

Example:
  // Automatically called by Harbour runtime at program start
  // Execution flow: main() → Principal() → esperar (wait for keypress)
*/
funcion main()
   Principal()
   esperar "Presione una tecla"
   devolver NIL