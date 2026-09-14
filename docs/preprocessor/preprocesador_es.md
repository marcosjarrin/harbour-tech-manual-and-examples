# Manual del Preprocesador de Harbour

**Versión del documento**: 1.0
**Idioma**: Español
**Autor**: Ing. Marcos Jarrín
**Fecha**: 05/08/2025 - dd/mm/yyyy


## Introducción 🧩

El preprocesador de Harbour es una fase fundamental en el pipeline de compilación, actuando como el primer paso antes de que el compilador procese el código. Escanea los archivos fuente (.prg), manejando directivas que comienzan con '#', realizando sustituciones de texto, inclusiones condicionales y otras transformaciones. Esto permite a los desarrolladores escribir código más flexible, portable y mantenible sin alterar directamente el comportamiento en tiempo de ejecución. Considérelo como una meta-capa para generación de código—potente para abstraer diferencias de plataforma, definir constantes, crear sintaxis personalizada mediante comandos e incrustar código de bajo nivel. Está basado en las tradiciones xBase/Clipper pero mejorado en Harbour para necesidades modernas como expresiones estilo C y soporte multiplataforma, haciéndolo indispensable para meta-programación y compilación condicional.

## Anatomía del Preprocesador

El preprocesador de Harbour opera sobre el código fuente línea por línea, reemplazando macros, incluyendo archivos y evaluando condiciones en tiempo de compilación. A continuación, diseccionamos sus componentes principales, enfocándonos en su mecánica, aplicaciones prácticas y advertencias.

### Directivas

Harbour soporta un rico conjunto de directivas de preprocesador, combinando traducciones de comandos estilo Clipper con lógica condicional y definiciones estilo C. Cada directiva comienza con '#' y se procesa antes de que el código llegue al traductor Harbour-a-C.

#### #define

Esta directiva define una constante o macro que sustituye texto durante el preprocesamiento. Puede ser simple (reemplazo de constante) o tipo función (con parámetros). **Mecánica:** El preprocesador reemplaza las ocurrencias del identificador definido con el texto de reemplazo especificado. Los parámetros en macros tipo función se sustituyen literalmente, soportando recursión con límites para prevenir bucles infinitos.

**Ejemplo de Código Práctico:**

```harbour
/** 
 * @file define_ejemplo.prg
 * @brief Demuestra #define para constantes y macros en Harbour.
 * 
 * Este ejemplo muestra cómo definir una constante para pi y una macro para calcular área.
 * Compilar con: hbmk2 define_ejemplo.prg
 */

#define PI 3.14159  ///< Constante para aproximación de pi.
#define AREA(r) (PI * (r) * (r))  ///< Macro para calcular área del círculo.

FUNCTION Main()
    LOCAL nRadio := 5
    LOCAL nArea := AREA(nRadio)
    
    ? "El area de un circulo con radio", nRadio, "es", nArea
    
    RETURN NIL
```

Resultado del preprocesador .ppo
```harbour
FUNCTION Main()
    LOCAL nRadio := 5
    LOCAL nArea := (3.14159 * (nRadio) * (nRadio))

    QOut( "El area de un circulo con radio", nRadio, "es", nArea )

    RETURN NIL
```

**Casos de Uso Comunes y Problemas:** 💡 Usar para constantes para evitar "números mágicos" o para cálculos simples para mejorar legibilidad. ⚠️ Problema: Las macros no respetan ámbito o tipos, llevando a sustituciones inesperadas (ej., si un parámetro tiene efectos secundarios como ++). Evitar redefinir identificadores estándar.

#### #undef

Anula una macro o constante previamente definida, removiéndola de la tabla de símbolos del preprocesador. **Mecánica:** Después de #undef, el identificador ya no se reemplaza, permitiendo redefinición o retroceso al comportamiento en tiempo de ejecución.

**Ejemplo de Código Práctico:**

```harbour
/** 
 * @file undef_ejemplo.prg
 * @brief Demuestra #undef para remover una definición de macro.
 * 
 * Muestra comportamiento de redefinición después de anular una macro.
 * Compilar con: hbmk2 undef_ejemplo.prg
 */

#define SALUDO "Hola, Mundo!"  ///< Macro de saludo inicial.

FUNCTION Main()
    ? SALUDO  ///< Imprime "¡Hola, Mundo!"
    
    #undef SALUDO  ///< Remueve la definición.
    
    #define SALUDO "Bonjour, Monde!"  ///< Redefine en francés.
    
    ? SALUDO  ///< Imprime "Bonjour, Monde!"
    
    RETURN NIL
```

Resultado del preprocesador .ppo
```harbour
FUNCTION Main()
    QOut( "Hola, Mundo!" )

    QOut( "Bonjour, Monde!" )

    RETURN NIL

```
**Casos de Uso Comunes y Problemas:** 💡 Usar para anular definiciones condicionalmente en archivos incluidos o para depuración. ⚠️ Problema: Anular símbolos inexistentes es inofensivo pero puede enmascarar errores; asegurar el orden de directivas para evitar remociones no intencionadas.

#### #ifdef, #ifndef

Estas verifican si una macro está definida (#ifdef) o no (#ifndef), incluyendo o excluyendo bloques de código. **Mecánica:** Verificación simple de existencia, sin evaluación de valor—ideal para interruptores de características.

**Ejemplo de Código Práctico:**

```harbour
/**
 * @file ifdef_ejemplo.prg
 * @brief Demuestra #ifdef y #ifndef para inclusión condicional.
 *
 * Activar/desactivar MODO_DEPURACIÓN externamente (ej., mediante bandera del compilador -DMODO_DEPURACIÓN).
 * Compilar con: hbmk2 ifdef_ejemplo.prg
 */

#define MODO_DEPURACION  ///< Definir para salida de depuración (comentar para deshabilitar).

FUNCTION Main()
    #ifdef MODO_DEPURACION
        ? "Modo depuracion habilitado."  ///< Mensaje de depuración.
    #endif

    #ifndef MODO_DEPURACION
        ? "Modo depuracion deshabilitado."  ///< Mensaje de release.
    #endif

    RETURN NIL
```

Resultado del preprocesador .ppo
```harbour
FUNCTION Main()
        QOut( "Modo depuracion habilitado." )
    RETURN NIL
```

**Casos de Uso Comunes y Problemas:** 💡 Usar para características opcionales como logging. ⚠️ Problema: Las condiciones anidadas pueden llevar a código ilegible; siempre emparejar con #endif.

#### if, else, endif, elseif

Condicionales avanzados que evalúan expresiones en tiempo de compilación. **Mecánica:** if evalúa una expresión constante (soportando operaciones aritméticas, lógicas); elseif para alternativas; else para retroceso; endif cierra. Las expresiones pueden usar macros definidas.

**Ejemplo de Código Práctico:**

```harbour
/**
 * @file if_ejemplo.prg
 * @brief Demuestra if, elseif, else para código basado en versión.
 *
 * Asume VERSION definida externamente (ej., -DVERSION=2).
 * Compilar con: hbmk2 if_ejemplo.prg
 */

#define VERSION  2  // < Número de versión simulado.

FUNCTION Main()
    if VERSION == 1
        ? "Caracteristica version 1."
    elseif VERSION == 2
        ? "Caracteristica mejorada version 2."
    else
        ? "Caracteristica por defecto."
    endif
    wait
    RETURN NIL

```
Resultado del preprocesador .ppo
```harbour
FUNCTION Main()
    if 2 == 1
        QOut( "Caracteristica version 1." )
    elseif 2 == 2
        QOut( "Caracteristica mejorada version 2." )
    else
        QOut( "Caracteristica por defecto." )
    endif
    __Wait( )
    RETURN NIL
```
**Casos de Uso Comunes y Problemas:** 💡 Usar para código específico de plataforma (ej., #if defined(__PLATFORM__WINDOWS)). ⚠️ Problema: Las expresiones deben ser constantes en tiempo de compilación; división por cero u operaciones inválidas causan errores.

#### #include

Inserta el contenido de otro archivo en el fuente actual. **Mecánica:** Busca en las rutas de inclusión; soporta inclusiones anidadas con límites de profundidad (típicamente 32).

**Ejemplo de Código Práctico:**

Asumir que `constantes.prg` contiene: `#define MAX_USUARIOS 100`
```harbour
#define MAX_USUARIOS 100
```

prueba_5.prg
```harbour
/**
 * @file include_ejemplo.prg
 * @brief Demuestra #include para constantes modulares.
 *
 * Requiere constants.prg en el mismo directorio.
 * Compilar con: hbmk2 include_ejemplo.prg
 */

#include "constantes.prg"  ///< Incluir definiciones externas.

FUNCTION Main()
    ? "Máximo de usuarios permitidos:", MAX_USUARIOS  ///< Usa define incluido.
    WAIT
    RETURN NIL
```

Resultado del preprocesador .ppo
```harbour
#line 11 "prueba_5.prg"
FUNCTION Main()
    QOut( "Máximo de usuarios permitidos:", 100 )
    __Wait( )
    RETURN NIL
```
**Casos de Uso Comunes y Problemas:** 💡 Usar para headers con macros/comandos compartidos. ⚠️ Problema: Las inclusiones circulares causan bucles infinitos; usar guardas como #ifndef GUARDA_HEADER.

#### #command, #translate

Define comandos de usuario (#command) o traducciones (#translate) que reescriben sintaxis en tiempo de preprocesamiento. **Mecánica:** Los patrones de coincidencia reemplazan la entrada con patrones de resultado; #command para tipo sentencia, #translate para tipo expresión. Soporta comodines como <* *> para cadenas.

**Ejemplo de Código Práctico:**

```harbour
/**
 * @file command_ejemplo.prg
 * @brief Demuestra #command para sintaxis personalizada.
 *
 * Crea un comando tipo DSL para logging.
 * Compilar con: hbmk2 command_ejemplo.prg
 */

#command LOG <msg> => ? "Log:", <msg>  ///< Comando log personalizado.

FUNCTION Main()
    LOG "AplicaciOn iniciada."  ///< Se expande a ? "Log:", "Aplicación iniciada."
    WAIT
    RETURN NIL
```
Resultado del preprocesador .ppo
```harbour
FUNCTION Main()
    QOut( "Log:", "AplicaciOn iniciada." )
    __Wait( )
    RETURN NIL
```

**Casos de Uso Comunes y Problemas:** 💡 Usar para crear DSLs o emular palabras clave faltantes. ⚠️ Problema: Patrones demasiado complejos pueden conflictuar; probar con bandera de compilador -p para salida .ppo.

#### #xcommand, #xtranslate

Versiones extendidas de #command/#translate, permitiendo coincidencias más flexibles (ej., comodines extendidos, partes opcionales). **Mecánica:** Similar pero con ^ para comillas inteligentes, | para alternativas.

**Ejemplo de Código Práctico:**

```harbour
/**
 * @file xcommand_ejemplo.prg
 * @brief Demuestra #xcommand para reescritura de sintaxis avanzada.
 *
 * Maneja parámetros opcionales.
 * Compilar con: hbmk2 xcommand_ejemplo.prg
 */

#xcommand SALUDAR [USUARIO <user>] => ? "Hola" [ + <user>]  ///< Usuario opcional.

FUNCTION Main()
    SALUDAR  //< "Hola"
    SALUDAR USUARIO " Alicia"  //< "Hola Alicia"
    WAIT
    RETURN NIL
```

Resultado del preprocesador .ppo
```harbour
FUNCTION Main()
    QOut( "Hola" )
    QOut( "Hola" + " Alicia" )
    __Wait( )
    RETURN NIL
```
**Casos de Uso Comunes y Problemas:** 💡 Usar para código portable entre dialectos. ⚠️ Problema: Conflictos de sintaxis con el lenguaje base; preferir sobre #command para complejidad.

### Macros

Las macros en Harbour vienen en dos sabores: tiempo de compilación (sustituciones de preprocesador vía #define) y tiempo de ejecución (usando el operador '&' para evaluación dinámica). Las macros de tiempo de compilación son reemplazos de texto antes de la compilación, rápidas pero inseguras (sin verificación de tipos). Las macros de tiempo de ejecución evalúan cadenas como código en ejecución, flexibles pero más lentas y propensas a errores.

**Ejemplo de Código Práctico:**

```harbour
// Ejemplo de macros en tiempo de compilación
#define PI 3.1415926535
#define MAX(a, b) IIF(a > b, a, b)
#define SALUDO "Hola desde Harbour"

PROCEDURE Main()
    LOCAL nRadio := 5
    LOCAL nArea
    
    // Uso de macros definidas
    nArea := PI * (nRadio ^ 2)
    
    ? SALUDO
    ? "Área del círculo:", nArea
    ? "Máximo entre 10 y 20:", MAX(10, 20)
    
    // Macro condicional
    #ifdef DEBUG
        ? "Modo depuración activado"
    #else
        ? "Modo producción"
    #endif
    
RETURN
```
Resultado del preprocesador .ppo
```harbour
PROCEDURE Main()
    LOCAL nRadio := 5
    LOCAL nArea

    nArea := 3.1415926535 * (nRadio ^ 2)

    QOut( "Hola desde Harbour" )
    QOut( "Area del circulo:", nArea )
    QOut( "Maximo entre 10 y 20:", IIF(10 > 20, 10, 20) )

        QOut( "Modo depuracion activado" )

    __Wait( )
RETURN
```

```harbour
// Ejemplo de macros en tiempo de ejecución
#define VERDAD .T.

PROCEDURE Main()
    LOCAL cMacro, cCampo, cValor
    LOCAL aDatos := {"Nombre", "Edad", "Ciudad"}
    LOCAL nOpcion

    WHILE VERDAD
        CLS
        ? "1. Crear macro dinamica"
        ? "2. Evaluar expresion"
        ? "3. Acceso dinamico a variables"
        ? "4. Salir"
        ACCEPT "Seleccione opcion: " TO nOpcion
        nOpcion := val(nOpcion)

        DO CASE
            CASE nOpcion == 1
                // Crear macro dinámicamente
                ACCEPT "Ingrese expresion (ej: 2+3*4): " TO cMacro
                ? "Resultado: ", &cMacro

            CASE nOpcion == 2
                // Acceso dinámico a array
                ? "Campos disponibles:"
                AEval(aDatos, {|c| QOut(c)})
                ACCEPT "Seleccione campo (1-3):  " TO cCampo
                cCampo := aDatos[Val( cCampo )]

                ACCEPT "Valor para " + cCampo + ": " TO cValor

                // Crear variable dinámicamente
                &cCampo := cValor
                ? "Variable creada:", &cCampo

            CASE nOpcion == 3
                // Macro con función dinámica
                ACCEPT "Ingrese funcion (P2, LOG, EXP): " TO cFuncion

                ACCEPT "Ingrese valor: " TO cValor
                cMacro := cFuncion + "(" + cValor + ")"
                ? "Resultado de " + cMacro + ": ", &cMacro

            CASE nOpcion == 4
                Break
            OTHERWISE
                Break
        ENDCASE
        WAIT
    ENDDO

RETURN

// Función auxiliar
FUNCTION P2(n)
RETURN n * n

```
Resultado del preprocesador .ppo
```harbour
PROCEDURE Main()
    LOCAL cMacro, cCampo, cValor
    LOCAL aDatos := {"Nombre", "Edad", "Ciudad"}
    LOCAL nOpcion

    WHILE .T.
        Scroll() ; SetPos( 0, 0 )
        QOut( "1. Crear macro dinamica" )
        QOut( "2. Evaluar expresion" )
        QOut( "3. Acceso dinamico a variables" )
        QOut( "4. Salir" )
        nOpcion := __Accept( "Seleccione opcion: " )
        nOpcion := val(nOpcion)

        DO CASE
            CASE nOpcion == 1

                cMacro := __Accept( "Ingrese expresion (ej: 2+3*4): " )
                QOut( "Resultado: ", &cMacro )

            CASE nOpcion == 2

                QOut( "Campos disponibles:" )
                AEval(aDatos, {|c| QOut(c)})
                cCampo := __Accept( "Seleccione campo (1-3):  " )
                cCampo := aDatos[Val( cCampo )]

                cValor := __Accept( "Valor para " + cCampo + ": " )


                &cCampo := cValor
                QOut( "Variable creada:", &cCampo )

            CASE nOpcion == 3

                cFuncion := __Accept( "Ingrese funcion (P2, LOG, EXP): " )

                cValor := __Accept( "Ingrese valor: " )
                cMacro := cFuncion + "(" + cValor + ")"
                QOut( "Resultado de " + cMacro + ": ", &cMacro )

            CASE nOpcion == 4
                Break
            OTHERWISE
                Break
        ENDCASE
        __Wait( )
    ENDDO

RETURN


FUNCTION P2(n)
RETURN n * n
```

**Casos de Uso Comunes y Problemas:** 💡 Tiempo de compilación para constantes críticas de rendimiento; tiempo de ejecución para código dinámico. ⚠️ Problema: Las macros de tiempo de ejecución pueden causar problemas de seguridad (inyección de código); las de tiempo de compilación pueden expandirse inesperadamente sin paréntesis.

### Directivas Pragma

#pragma controla comportamientos específicos del compilador, como incrustar código C. **Mecánica:** #pragma BEGINDUMP inicia un bloque C compilado directamente; #pragma ENDDUMP lo termina. Útil para extender Harbour con C nativo.

**Ejemplo de Código Práctico:**

```harbour
/** 
 * @file pragma_ejemplo.prg
 * @brief Demuestra #pragma BEGINDUMP para incrustar código C.
 * 
 * Llama a una función C desde Harbour.
 * Compilar con: hbmk2 pragma_ejemplo.prg
 */

#pragma BEGINDUMP
#include <hbapi.h>

HB_FUNC( HOLA_C )
{
   printf("¡Hola desde C!\n");
}
#pragma ENDDUMP

FUNCTION Main()
    HOLA_C()  ///< Llama a la función C incrustada.
    
    RETURN NIL
```

```harbour
// Programa para comparar velocidad de bucles: Harbour vs C
#pragma BEGINDUMP

#include <hbapi.h>
#include <time.h>

// Función en C que ejecuta el bucle vacío
HB_FUNC( BUCLE_VACIO_C )
{
    clock_t inicio, fin;
    double tiempo_cpu;
    int i;

    inicio = clock();

    // Bucle for vacío de 10,000 iteraciones en C
    for (i = 0; i < 80000000; i++) {
        // Instrucción vacía
    }

    fin = clock();
    tiempo_cpu = ((double) (fin - inicio)) / CLOCKS_PER_SEC;

    hb_retnd(tiempo_cpu);
}
#pragma ENDDUMP

PROCEDURE Main()
    LOCAL nInicio, nFin, nTiempoHarbour
    LOCAL nTiempoC

    ? "Comparacion de velocidad: Harbour vs C"
    ? "======================================"
    ? "Bucle for vacio de 80,000,000 iteraciones"
    ?

    // Medir tiempo en Harbour
    nInicio := Seconds()

    // Bucle for vacío en Harbour
    FOR i := 1 TO 80000000
        // Instrucción vacía
    NEXT

    nFin := Seconds()
    nTiempoHarbour := nFin - nInicio

    // Medir tiempo en C
    nTiempoC := BUCLE_VACIO_C()

    // Mostrar resultados
    ? "Tiempo Harbour:", AllTrim(Str(nTiempoHarbour, 12, 8)), "segundos"
    ? "Tiempo C:      ", AllTrim(Str(nTiempoC, 12, 8)), "segundos"
    ?

    // Calcular relación de velocidad
    IF nTiempoHarbour > 0 .AND. nTiempoC > 0
        ? "Relacion C/Harbour:", AllTrim(Str(nTiempoHarbour / nTiempoC, 12, 2)), "veces mas rapido"
    ELSE
        ? "No se pudo calcular la relacion (tiempos demasiado pequenios)"
    ENDIF

    ?
    ? "Nota: Los resultados pueden variar segun el sistema y compilador"
    ? "      Harbour puede estar optimizado con -O3 para mejor rendimiento"
    WAIT
RETURN
```

Salida 
```text
Comparacion de velocidad: Harbour vs C
======================================
Bucle for vacio de 80,000,000 iteraciones

Tiempo Harbour: 5.67600000 segundos
Tiempo C:       0.01600000 segundos

Relacion C/Harbour: 354.75 veces mas rapido

Nota: Los resultados pueden variar segun el sistema y compilador
      Harbour puede estar optimizado con -O3 para mejor rendimiento
Press any key to continue...
```

**Casos de Uso Comunes y Problemas:** 💡 Usar para cuellos de botella de rendimiento o integraciones de API. ⚠️ Problema: El código C debe interactuar via hbapi.h; desajustes causan caídas.

### Defines Estándar

Harbour predefine varias macros para portabilidad y metadatos:

- `__HARBOUR__`: Definido como 1, identifica entorno Harbour.
- `__DATE__`: Fecha de compilación como "MMM DD YYYY".
- `__TIME__`: Hora de compilación como "HH:MM:SS".
- `__PLATFORM__<OS>__`: Ej., `__PLATFORM__WINDOWS__`, `__PLATFORM__LINUX__` para detección de SO.
- `__ARCH<ARCH>__`: Ej., `__ARCH32BIT__`, `__ARCH64BIT__` para arquitectura.

Usar estas en condicionales para código multiplataforma.

### Ejemplo Sofisticado 🚀

Implementación de referencia que muestra el uso de las capacidades del preprocesador de Harbour para desarrollar una capa sintáctica en español sobre código Harbour estándar.

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
```

**Programa con sintaxis Harbour en español**

```harbour
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

**Salida del Preprocesador**
```harbour
#line 16 "test.prg"
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

Salida
```text
Bienvenido a Harbour-ES
Fecha actual: 08/27/25
Calculando factorial de          5...
Resultado:        120
Iterando sobre arreglo:
Elemento          1: Manzana
Elemento          2: Banana
Elemento          3: Cereza
El factorial es mayor que 100.
Bucle infinito simulado; saliendo...
Presione una tecla
```
