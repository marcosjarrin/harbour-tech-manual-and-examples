### 🇬🇧 ENGLISH VERSION

# Hindi Hello World - User Manual
**Version 1.0 | August 2026 | BadaSystem-Marcos Jarrin**

---

## 1. Introduction

The Hindi Hello World application is a demonstration program that showcases native Unicode rendering capabilities in Harbour/MiniGUI Extended. It displays the Hindi greeting "नमस्ते दुनिया" (Namaste Duniya - Hello World in Hindi) with proper Devanagari script rendering.

### 1.1 Features

- **Native Unicode Support**: Displays Hindi text using the Mangal font
- **Multi-language Cycling**: Switch between Hindi, English, and Spanish
- **Phonetic Guide**: Shows pronunciation help for Hindi text
- **Clean Interface**: Simple, centered window design

---

## 2. Installation

### 2.1 System Requirements

- **Operating System**: Windows 7/8/10/11 (32-bit or 64-bit)
- **Font**: Mangal font (included with Windows, supports Devanagari script)
- **Disk Space**: Less than 1 MB

### 2.2 Installation Steps

1. Locate the executable file: `hello_hindi.exe`
2. Double-click to run the application
3. No installation required - portable application

---

## 3. Using the Application

### 3.1 Main Window

When you launch the application, you'll see:

```
┌─────────────────────────────────────────┐
│  Namaste - Hello World in Hindi         │
├─────────────────────────────────────────┤
│                                         │
│         नमस्ते दुनिया                       │
│                                         │
│    ( Hello World in Hindi - India )     │
│                                         │
│      Phonetic: Namaste Duniya           │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │ Show in English / Espanol       │   │
│   └─────────────────────────────────┘   │
│                                         │
│              ┌──────────┐               │
│              │  Close   │               │
│              └──────────┘               │
└─────────────────────────────────────────┘
```

### 3.2 Interface Elements

**Main Greeting Label**
- Displays the greeting in the selected language
- Uses 28pt Mangal font for Hindi text
- Uses 26pt Arial font for English/Spanish

**Subtitle Label**
- Shows context: "( Hello World in Hindi - India )"
- Gray text, 10pt Arial

**Phonetic Label**
- Displays pronunciation guide: "Phonetic: Namaste Duniya"
- Blue italic text for easy reading

**Show in English / Espanol Button**
- Cycles through three languages:
  1. Hindi: नमस्ते दुनिया
  2. English: Hello World
  3. Spanish: Hola Mundo

**Close Button**
- Exits the application

### 3.3 Language Cycling

Click the "Show in English / Espanol" button to cycle through languages:

| Click | Language | Display |
|-------|----------|---------|
| 1st | Hindi | नमस्ते दुनिया |
| 2nd | English | Hello World |
| 3rd | Spanish | Hola Mundo |
| 4th | Hindi | नमस्ते दुनिया (cycle repeats) |

---

## 4. Troubleshooting

### 4.1 Hindi Text Not Displaying Correctly

**Problem**: Hindi characters appear as boxes or question marks

**Solution**: 
- Ensure the Mangal font is installed on your system
- Mangal is included with Windows Vista and later
- If missing, install from Windows Fonts or download from Microsoft

### 4.2 Application Won't Start

**Problem**: Error message when launching

**Solution**:
- Verify you're running on Windows 7 or later
- Check that no antivirus is blocking the executable
- Try running as Administrator

---

## 5. Technical Information

- **Compiler**: Harbour 3.2.0dev + MiniGUI Extended
- **Build Type**: ANSI (with Unicode bridge)
- **Font Rendering**: Windows API (SetWindowTextW)
- **Source Code**: Available at https://github.com/marcosjarrin/harbour-tech-manual-and-examples

---

## 6. Support

For technical support or questions:
- **Email**: marvijarrin@gmail.com
- **Website**: badasystem.com
- **Author**: Marcos Jarrín

---

### 🇪🇸 VERSIÓN EN ESPAÑOL

# Hindi Hello World - Manual de Usuario
**Versión 1.0 | Agosto 2026 | BadaSystem**

---

## 1. Introducción

La aplicación Hindi Hello World es un programa de demostración que muestra las capacidades de renderizado Unicode nativo en Harbour/MiniGUI Extended. Muestra el saludo en hindi "नमस्ते दुनिया" (Namaste Duniya - Hola Mundo en Hindi) con el renderizado adecuado del script Devanagari.

### 1.1 Características

- **Soporte Unicode Nativo**: Muestra texto en hindi usando la fuente Mangal
- **Ciclo Multi-idioma**: Cambia entre hindi, inglés y español
- **Guía Fonética**: Muestra ayuda de pronunciación para texto en hindi
- **Interfaz Limpia**: Diseño de ventana simple y centrado

---

## 2. Instalación

### 2.1 Requisitos del Sistema

- **Sistema Operativo**: Windows 7/8/10/11 (32-bit o 64-bit)
- **Fuente**: Fuente Mangal (incluida con Windows, soporta script Devanagari)
- **Espacio en Disco**: Menos de 1 MB

### 2.2 Pasos de Instalación

1. Localiza el archivo ejecutable: `hello_hindi.exe`
2. Haz doble clic para ejecutar la aplicación
3. No requiere instalación - aplicación portátil

---

## 3. Uso de la Aplicación

### 3.1 Ventana Principal

Cuando inicies la aplicación, verás:

```
┌─────────────────────────────────────────┐
│  Namaste - Hello World in Hindi         │
├─────────────────────────────────────────┤
│                                         │
│         नमस्ते दुनिया                       │
│                                         │
│    ( Hello World in Hindi - India )     │
│                                         │
│      Phonetic: Namaste Duniya           │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │ Show in English / Espanol       │   │
│   └─────────────────────────────────┘   │
│                                         │
│              ┌──────────┐               │
│              │  Close   │               │
│              └──────────┘               │
└─────────────────────────────────────────┘
```

### 3.2 Elementos de la Interfaz

**Etiqueta de Saludo Principal**
- Muestra el saludo en el idioma seleccionado
- Usa fuente Mangal de 28pt para texto en hindi
- Usa fuente Arial de 26pt para inglés/español

**Etiqueta de Subtítulo**
- Muestra el contexto: "( Hello World in Hindi - India )"
- Texto gris, Arial de 10pt

**Etiqueta Fonética**
- Muestra la guía de pronunciación: "Phonetic: Namaste Duniya"
- Texto azul en itálica para fácil lectura

**Botón Show in English / Espanol**
- Cicla a través de tres idiomas:
  1. Hindi: नमस्ते दुनिया
  2. Inglés: Hello World
  3. Español: Hola Mundo

**Botón Close**
- Sale de la aplicación

### 3.3 Ciclo de Idiomas

Haz clic en el botón "Show in English / Espanol" para ciclar entre idiomas:

| Clic | Idioma | Visualización |
|------|--------|---------------|
| 1ro | Hindi | नमस्ते दुनिया |
| 2do | Inglés | Hello World |
| 3ro | Español | Hola Mundo |
| 4to | Hindi | नमस्ते दुनिया (el ciclo se repite) |

---

## 4. Solución de Problemas

### 4.1 Texto en Hindi No se Muestra Correctamente

**Problema**: Los caracteres en hindi aparecen como cuadros o signos de interrogación

**Solución**: 
- Asegúrate de que la fuente Mangal esté instalada en tu sistema
- Mangal está incluida con Windows Vista y posterior
- Si falta, instálala desde Fuentes de Windows o descárgala de Microsoft

### 4.2 La Aplicación No Inicia

**Problema**: Mensaje de error al iniciar

**Solución**:
- Verifica que estés ejecutando en Windows 7 o posterior
- Comprueba que ningún antivirus esté bloqueando el ejecutable
- Intenta ejecutar como Administrador

---

## 5. Información Técnica

- **Compilador**: Harbour 3.2.0dev + MiniGUI Extended
- **Tipo de Build**: ANSI (con puente Unicode)
- **Renderizado de Fuentes**: Windows API (SetWindowTextW)
- **Código Fuente**: Disponible en https://github.com/marcosjarrin/harbour-tech-manual-and-examples

---

## 6. Soporte

Para soporte técnico o preguntas:
- **Email**: marvijarrin@gmail.com
- **Sitio Web**: badasystem.com
- **Autor**: Marcos Jarrín

---

## 📗 TECHNICAL MANUAL / MANUAL TÉCNICO

### 🇬🇧 ENGLISH VERSION

# Hindi Hello World - Technical Manual
**Version 1.0 | August 2026 | BadaSystem**

---

## 1. Architecture Overview

The Hindi Hello World application demonstrates native Unicode rendering in Harbour/MiniGUI Extended's ANSI build through a C bridge layer.

### 1.1 System Architecture

```
┌─────────────────────────────────────────────────────┐
│              Application Layer (Harbour)            │
│  hello_hindi.prg - Main UI and language cycling     │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│           Unicode Bridge Layer (C Code)             │
│  unicode_bridge.prg - UTF-8 → UTF-16 conversion     │
│  ansi2unicode.prg - Code point → UTF-8 builder      │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│              Windows API Layer (Win32)              │
│  SetWindowTextW() - Native Unicode window text      │
│  CreateFontA() - Font creation with Unicode support │
└─────────────────────────────────────────────────────┘
```

### 1.2 Component Breakdown

| Component | File | Purpose |
|-----------|------|---------|
| Main Application | hello_hindi.prg | UI definition, language state, control flow |
| Unicode Bridge | unicode_bridge.prg | C functions for UTF-8→UTF-16 and font setting |
| Unicode Converter | ansi2unicode.prg | Code point to UTF-8 string builder |

---

## 2. Technical Implementation

### 2.1 Unicode Rendering Strategy

**Challenge**: MiniGUI Extended ANSI build cannot natively display Unicode characters.

**Solution**: Three-layer approach:

1. **Code Point Storage**: Hindi characters stored as Unicode code points (e.g., 0x0928 for न)
2. **UTF-8 Encoding**: Code points converted to UTF-8 byte sequences
3. **Windows API**: UTF-8 converted to UTF-16 and rendered via SetWindowTextW()

### 2.2 Devanagari Text Construction

Hindi text is built from Unicode code points using the `BuildUnicodeString()` function:

```harbour
// "नमस्ते" (Namaste)
cText := BuildUnicodeString( { ;
   0x0928, ;  // न (na)
   0x092E, ;  // म (ma)
   0x0938, ;  // स (sa)
   0x094D, ;  // ् (virama - suppresses vowel)
   0x0924, ;  // त (ta)
   0x0947  ;  // े (e matra)
} )
```

**UTF-8 Encoding Process**:
- Code points U+0800 to U+FFFF use 3-byte UTF-8 sequences
- Formula: `Chr(0xE0 + shift) + Chr(0x80 + mask) + Chr(0x80 + mask)`

### 2.3 C Bridge Functions

#### SetUnicodeText(nHWnd, cText)

**Purpose**: Display UTF-8 text in a window control

**Parameters**:
- `nHWnd` (N): Window handle of the control
- `cText` (C): UTF-8 encoded string

**Process**:
1. Validate window handle
2. Calculate required UTF-16 buffer size using `MultiByteToWideChar()`
3. Allocate memory for UTF-16 string
4. Convert UTF-8 → UTF-16
5. Call `SetWindowTextW()` to display text
6. Invalidate and update window
7. Free allocated memory

**Returns**: Logical (.T. on success, .F. on failure)

#### SetUnicodeFont(nHWnd, cFontName, nSize)

**Purpose**: Set a Unicode-capable font on a control

**Parameters**:
- `nHWnd` (N): Window handle
- `cFontName` (C): Font name (e.g., "Mangal")
- `nSize` (N): Font size in points

**Process**:
1. Get device context (HDC)
2. Calculate font height using `MulDiv()`
3. Create font with `CreateFontA()`
4. Send `WM_SETFONT` message to control
5. Invalidate and update window

**Returns**: Logical (.T. on success, .F. on failure)

### 2.4 Language Cycling Implementation

```harbour
STATIC nLangMode := 0  // 0=Hindi, 1=English, 2=Spanish

STATIC PROCEDURE CycleLanguage()
   nLangMode := nLangMode + 1
   IF nLangMode > 2
      nLangMode := 0
   ENDIF
   
   DO CASE
   CASE nLangMode == 0
      cGreeting := GetHindiGreeting()
      SetUnicodeFont( nHWnd, "Mangal", 28 )
   CASE nLangMode == 1
      cGreeting := "Hello World"
      SetUnicodeFont( nHWnd, "Arial", 26 )
   CASE nLangMode == 2
      cGreeting := "Hola Mundo"
      SetUnicodeFont( nHWnd, "Arial", 26 )
   ENDCASE
   
   SetUnicodeText( nHWnd, cGreeting )
RETURN
```

---

## 3. Code Structure

### 3.1 File Organization

```
hello_hindi/
├── hello_hindi.prg       (Main application )
├── unicode_bridge.prg    (C bridge )
└── ansi2unicode.prg      (UTF-8 builder)
```

### 3.2 Module Dependencies

```
hello_hindi.prg
    ├── Uses: unicode_bridge.prg (SetUnicodeText, SetUnicodeFont)
    └── Uses: ansi2unicode.prg (BuildUnicodeString, GetDevanagariText)

unicode_bridge.prg
    └── Uses: Windows API (SetWindowTextW, CreateFontA, MultiByteToWideChar)

ansi2unicode.prg
    └── Standalone utility (no dependencies)
```

### 3.3 Key Functions

| Function | File | Purpose |
|----------|------|---------|
| `Main()` | hello_hindi.prg | Entry point, window definition |
| `GetHindiGreeting()` | hello_hindi.prg | Builds "नमस्ते दुनिया" string |
| `ApplyInitialText()` | hello_hindi.prg | Sets initial Hindi text on window init |
| `CycleLanguage()` | hello_hindi.prg | Handles language button click |
| `SetUnicodeText()` | unicode_bridge.prg | C bridge for UTF-8 text display |
| `SetUnicodeFont()` | unicode_bridge.prg | C bridge for Unicode font setting |
| `UnicodeToUTF8()` | ansi2unicode.prg | Converts code point to UTF-8 bytes |
| `BuildUnicodeString()` | ansi2unicode.prg | Builds UTF-8 string from code point array |

---

## 4. Build Instructions

### 4.1 Prerequisites

- Harbour 3.2.0dev or later
- MiniGUI Extended Edition
- Borland C++ Compiler 5.82 (BCC32)
- Windows SDK

### 4.2 Compilation Steps

```bash
# Using hbmk2 (Harbour Make)
hbmk2 hello_hindi.hbp

# Or manual compilation
harbour hello_hindi.prg -n -l
harbour unicode_bridge.prg -n -l
harbour ansi2unicode.prg -n -l
bcc32 @hello_hindi.lnk
```
---

## 5. Critical Implementation Notes

### 5.1 C89 Strict Compliance

The C bridge code (`unicode_bridge.prg`) follows C89 standard:
- **ALL variable declarations at the TOP of each function**
- No mixed declarations and code
- Prevents Borland E2140 error

```c
// ✅ CORRECT - C89 compliant
HB_FUNC( SETUNICODETEXT )
{
   HWND hWnd;           // Declaration at top
   LPCSTR pszUtf8;
   int nWideLen;
   
   hWnd = (HWND) hb_parnl( 1 );  // Code after declarations
   // ...
}
```

### 5.2 Memory Management

- UTF-16 buffer allocated with `hb_xgrab()`
- Must be freed with `hb_xfree()` after use
- No memory leaks on error paths

### 5.3 Font Requirements

- **Mangal font**: Required for Devanagari script
- Ships with Windows Vista and later
- Falls back to Arial for English/Spanish text

---

## 6. Performance Considerations

### 6.1 UTF-8 Conversion Overhead

- Each `SetUnicodeText()` call performs UTF-8→UTF-16 conversion
- Conversion time: < 1ms for typical strings
- Acceptable for UI updates, not for bulk operations

### 6.2 Font Creation

- `CreateFontA()` called on each language change
- Font handle not cached (acceptable for demo)
- Production apps should cache font handles

---

## 7. Known Limitations

1. **ANSI Build Only**: This solution works around ANSI build limitations
2. **Font Dependency**: Requires Mangal font for Hindi text
3. **No Dynamic Font Loading**: Font must be system-installed
4. **C Bridge Required**: Cannot be done in pure Harbour

---

## 8. Extension Points

### 8.1 Adding New Languages

1. Add language mode to `nLangMode` cycle
2. Create text builder function (like `GetHindiGreeting()`)
3. Add case to `CycleLanguage()` DO CASE block
4. Set appropriate font for the language

### 8.2 Supporting Additional Scripts

The `UnicodeToUTF8()` function supports:
- 1-byte UTF-8 (U+0000 to U+007F) - ASCII
- 2-byte UTF-8 (U+0080 to U+07FF) - Latin, Greek, Cyrillic, Arabic
- 3-byte UTF-8 (U+0800 to U+FFFF) - Devanagari, CJK, etc.
- 4-byte UTF-8 (U+10000 to U+10FFFF) - Emoji, historic scripts

### 8.3 Performance Optimization

For production use:
- Cache font handles
- Batch UTF-8 conversions
- Use UTF-16 natively if possible

---

## 9. Debugging

### 9.1 Common Issues

**Issue**: Hindi text shows as boxes
**Cause**: Mangal font not installed
**Fix**: Install Mangal font or use alternative Devanagari font

**Issue**: Application crashes on startup
**Cause**: Window structure not closed properly
**Fix**: Ensure `END WINDOW` before `ACTIVATE WINDOW`

**Issue**: C bridge compilation errors
**Cause**: Variables not declared at top (C89 violation)
**Fix**: Move all declarations to function start

### 9.2 Debug Output

Add debug output in C bridge:

```c
if ( !IsWindow( hWnd ) ) {
   hb_printf( "Invalid window handle: %p\n", hWnd );
   hb_retl( FALSE );
   return;
}
```

---

## 10. References

- **Harbour Documentation**: harbour.github.io
- **MiniGUI Extended Manual**: Included in distribution
- **Windows API**: docs.microsoft.com/windows/win32
- **Unicode Standard**: unicode.org/versions
- **UTF-8 Encoding**: RFC 3629

---

### 🇪🇸 VERSIÓN EN ESPAÑOL

# Hindi Hello World - Manual Técnico
**Versión 1.0 | Agosto 2026 | BadaSystem**

---

## 1. Visión General de la Arquitectura

La aplicación Hindi Hello World demuestra el renderizado Unicode nativo en el build ANSI de Harbour/MiniGUI Extended a través de una capa puente en C.

### 1.1 Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────┐
│              Capa de Aplicación (Harbour)           │
│  hello_hindi.prg - UI principal y ciclo de idiomas  │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│           Capa Puente Unicode (Código C)            │
│  unicode_bridge.prg - Conversión UTF-8 → UTF-16     │
│  ansi2unicode.prg - Constructor code point → UTF-8  │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│              Capa Windows API (Win32)               │
│  SetWindowTextW() - Texto Unicode nativo            │
│  CreateFontA() - Creación de fuente con Unicode     │
└─────────────────────────────────────────────────────┘
```

### 1.2 Desglose de Componentes

| Componente | Archivo | Propósito |
|------------|---------|-----------|
| Aplicación Principal | hello_hindi.prg | Definición de UI, estado de idioma, flujo de control |
| Puente Unicode | unicode_bridge.prg | Funciones C para UTF-8→UTF-16 y configuración de fuente |
| Conversor Unicode | ansi2unicode.prg | Constructor de string UTF-8 desde code points |

---

## 2. Implementación Técnica

### 2.1 Estrategia de Renderizado Unicode

**Desafío**: El build ANSI de MiniGUI Extended no puede mostrar caracteres Unicode nativamente.

**Solución**: Enfoque de tres capas:

1. **Almacenamiento de Code Points**: Caracteres hindi almacenados como code points Unicode (ej., 0x0928 para न)
2. **Codificación UTF-8**: Code points convertidos a secuencias de bytes UTF-8
3. **Windows API**: UTF-8 convertido a UTF-16 y renderizado vía SetWindowTextW()

### 2.2 Construcción de Texto Devanagari

El texto hindi se construye desde code points Unicode usando la función `BuildUnicodeString()`:

```harbour
// "नमस्ते" (Namaste)
cText := BuildUnicodeString( { ;
   0x0928, ;  // न (na)
   0x092E, ;  // म (ma)
   0x0938, ;  // स (sa)
   0x094D, ;  // ् (virama - suprime vocal)
   0x0924, ;  // त (ta)
   0x0947  ;  // े (e matra)
} )
```

**Proceso de Codificación UTF-8**:
- Code points U+0800 a U+FFFF usan secuencias UTF-8 de 3 bytes
- Fórmula: `Chr(0xE0 + shift) + Chr(0x80 + mask) + Chr(0x80 + mask)`

### 2.3 Funciones del Puente C

#### SetUnicodeText(nHWnd, cText)

**Propósito**: Mostrar texto UTF-8 en un control de ventana

**Parámetros**:
- `nHWnd` (N): Handle de ventana del control
- `cText` (C): String codificado en UTF-8

**Proceso**:
1. Validar handle de ventana
2. Calcular tamaño de buffer UTF-16 requerido usando `MultiByteToWideChar()`
3. Asignar memoria para string UTF-16
4. Convertir UTF-8 → UTF-16
5. Llamar `SetWindowTextW()` para mostrar texto
6. Invalidar y actualizar ventana
7. Liberar memoria asignada

**Retorna**: Lógico (.T. en éxito, .F. en fallo)

#### SetUnicodeFont(nHWnd, cFontName, nSize)

**Propósito**: Establecer una fuente compatible con Unicode en un control

**Parámetros**:
- `nHWnd` (N): Handle de ventana
- `cFontName` (C): Nombre de fuente (ej., "Mangal")
- `nSize` (N): Tamaño de fuente en puntos

**Proceso**:
1. Obtener contexto de dispositivo (HDC)
2. Calcular altura de fuente usando `MulDiv()`
3. Crear fuente con `CreateFontA()`
4. Enviar mensaje `WM_SETFONT` al control
5. Invalidar y actualizar ventana

**Retorna**: Lógico (.T. en éxito, .F. en fallo)

### 2.4 Implementación del Ciclo de Idiomas

```harbour
STATIC nLangMode := 0  // 0=Hindi, 1=Inglés, 2=Español

STATIC PROCEDURE CycleLanguage()
   nLangMode := nLangMode + 1
   IF nLangMode > 2
      nLangMode := 0
   ENDIF
   
   DO CASE
   CASE nLangMode == 0
      cGreeting := GetHindiGreeting()
      SetUnicodeFont( nHWnd, "Mangal", 28 )
   CASE nLangMode == 1
      cGreeting := "Hello World"
      SetUnicodeFont( nHWnd, "Arial", 26 )
   CASE nLangMode == 2
      cGreeting := "Hola Mundo"
      SetUnicodeFont( nHWnd, "Arial", 26 )
   ENDCASE
   
   SetUnicodeText( nHWnd, cGreeting )
RETURN
```

---

## 3. Estructura del Código

### 3.1 Organización de Archivos

```
hello_hindi/
├── hello_hindi.prg       (Aplicación principal )
├── unicode_bridge.prg    (Puente C )
└── ansi2unicode.prg      (Constructor UTF-8 )
```

### 3.2 Dependencias de Módulos

```
hello_hindi.prg
    ├── Usa: unicode_bridge.prg (SetUnicodeText, SetUnicodeFont)
    └── Usa: ansi2unicode.prg (BuildUnicodeString, GetDevanagariText)

unicode_bridge.prg
    └── Usa: Windows API (SetWindowTextW, CreateFontA, MultiByteToWideChar)

ansi2unicode.prg
    └── Utilidad independiente (sin dependencias)
```

### 3.3 Funciones Clave

| Función | Archivo | Propósito |
|---------|---------|-----------|
| `Main()` | hello_hindi.prg | Punto de entrada, definición de ventana |
| `GetHindiGreeting()` | hello_hindi.prg | Construye string "नमस्ते दुनिया" |
| `ApplyInitialText()` | hello_hindi.prg | Establece texto Hindi inicial en init de ventana |
| `CycleLanguage()` | hello_hindi.prg | Maneja clic de botón de idioma |
| `SetUnicodeText()` | unicode_bridge.prg | Puente C para mostrar texto UTF-8 |
| `SetUnicodeFont()` | unicode_bridge.prg | Puente C para configuración de fuente Unicode |
| `UnicodeToUTF8()` | ansi2unicode.prg | Convierte code point a bytes UTF-8 |
| `BuildUnicodeString()` | ansi2unicode.prg | Construye string UTF-8 desde array de code points |

---

## 4. Instrucciones de Compilación

### 4.1 Prerrequisitos

- Harbour 3.2.0dev o posterior
- MiniGUI Extended Edition
- Compilador Borland C++ 5.82 (BCC32)
- Windows SDK

### 4.2 Pasos de Compilación

```bash
# Usando hbmk2 (Harbour Make)
hbmk2 hello_hindi.hbp

# O compilación manual
harbour hello_hindi.prg -n -l
harbour unicode_bridge.prg -n -l
harbour ansi2unicode.prg -n -l
bcc32 @hello_hindi.lnk
```
---

## 5. Notas Críticas de Implementación

### 5.1 Cumplimiento Estricto C89

El código puente C (`unicode_bridge.prg`) sigue el estándar C89:
- **TODAS las declaraciones de variables al INICIO de cada función**
- Sin mezclar declaraciones y código
- Previene error E2140 de Borland

```c
// ✅ CORRECTO - Compatible con C89
HB_FUNC( SETUNICODETEXT )
{
   HWND hWnd;           // Declaración al inicio
   LPCSTR pszUtf8;
   int nWideLen;
   
   hWnd = (HWND) hb_parnl( 1 );  // Código después de declaraciones
   // ...
}
```

### 5.2 Gestión de Memoria

- Buffer UTF-16 asignado con `hb_xgrab()`
- Debe liberarse con `hb_xfree()` después de usar
- Sin fugas de memoria en rutas de error

### 5.3 Requisitos de Fuentes

- **Fuente Mangal**: Requerida para script Devanagari
- Incluida con Windows Vista y posterior
- Usa Arial como fallback para texto en inglés/español

---

## 6. Consideraciones de Rendimiento

### 6.1 Sobrecarga de Conversión UTF-8

- Cada llamada a `SetUnicodeText()` realiza conversión UTF-8→UTF-16
- Tiempo de conversión: < 1ms para strings típicos
- Aceptable para actualizaciones de UI, no para operaciones masivas

### 6.2 Creación de Fuentes

- `CreateFontA()` llamado en cada cambio de idioma
- Handle de fuente no cacheado (aceptable para demo)
- Apps de producción deberían cachear handles de fuentes

---

## 7. Limitaciones Conocidas

1. **Solo Build ANSI**: Esta solución trabaja alrededor de limitaciones del build ANSI
2. **Dependencia de Fuente**: Requiere fuente Mangal para texto hindi
3. **Sin Carga Dinámica de Fuentes**: La fuente debe estar instalada en el sistema
4. **Puente C Requerido**: No puede hacerse en Harbour puro

---

## 8. Puntos de Extensión

### 8.1 Agregar Nuevos Idiomas

1. Agregar modo de idioma al ciclo `nLangMode`
2. Crear función constructora de texto (como `GetHindiGreeting()`)
3. Agregar caso al bloque DO CASE de `CycleLanguage()`
4. Establecer fuente apropiada para el idioma

### 8.2 Soportar Scripts Adicionales

La función `UnicodeToUTF8()` soporta:
- UTF-8 de 1-byte (U+0000 a U+007F) - ASCII
- UTF-8 de 2-bytes (U+0080 a U+07FF) - Latín, Griego, Cirílico, Árabe
- UTF-8 de 3-bytes (U+0800 a U+FFFF) - Devanagari, CJK, etc.
- UTF-8 de 4-bytes (U+10000 a U+10FFFF) - Emojis, scripts históricos

### 8.3 Optimización de Rendimiento

Para uso en producción:
- Cachear handles de fuentes
- Conversión UTF-8 en lotes
- Usar UTF-16 nativamente si es posible

---

## 9. Depuración

### 9.1 Problemas Comunes

**Problema**: Texto hindi muestra como cuadros
**Causa**: Fuente Mangal no instalada
**Solución**: Instalar fuente Mangal o usar fuente Devanagari alternativa

**Problema**: Aplicación falla al iniciar
**Causa**: Estructura de ventana no cerrada apropiadamente
**Solución**: Asegurar `END WINDOW` antes de `ACTIVATE WINDOW`

**Problema**: Errores de compilación en puente C
**Causa**: Variables no declaradas al inicio (violación C89)
**Solución**: Mover todas las declaraciones al inicio de la función

### 9.2 Salida de Depuración

Agregar salida de depuración en puente C:

```c
if ( !IsWindow( hWnd ) ) {
   hb_printf( "Handle de ventana inválido: %p\n", hWnd );
   hb_retl( FALSE );
   return;
}
```

---

## 10. Referencias

- **Documentación Harbour**: harbour.github.io
- **Manual MiniGUI Extended**: Incluido en la distribución
- **Windows API**: docs.microsoft.com/windows/win32
- **Estándar Unicode**: unicode.org/versions
- **Codificación UTF-8**: RFC 3629

---

**Fin de los Manuales | End of Manuals**

📧 **Contacto | Contact**: marvijarrin@gmail.com  
🌐 **Web**: badasystem.com  
📅 **Fecha | Date**: 22 de Agosto de 2026 | August 22, 2026
SPDX-License-Identifier: MIT
