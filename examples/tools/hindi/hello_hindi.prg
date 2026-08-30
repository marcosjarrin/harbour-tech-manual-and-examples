/*
BadaSystem
Program       : hello_hindi
Module        : hello_hindi.prg
Compiler      : MINIGUI - Harbour Win32 GUI (ANSI BUILD)
Compiler-C    : BCC 32 bit
Author        : Marcos Jarrín
Email         : marvijarrin@gmail.com
Website       : badasystem.com
Date          : 21/08/2026
Update        : 21/08/2026
Rev           : 1.0
SPDX-License-Identifier: MIT
Description:
    Hindi "Hello World" with native Unicode rendering via embedded C code.
*/

#include "minigui.ch"

// ============================================================================
// 1. STATIC VARIABLES AT THE VERY TOP
// ============================================================================
STATIC nLangMode := 0  // 0=Hindi, 1=English, 2=Spanish


// ============================================================================
// 2. DEVANAGARI TEXT BUILDER (UTF-8 byte sequences)
// ============================================================================
STATIC FUNCTION GetHindiGreeting()
    LOCAL cText := ""

    // "नमस्ते" (Namaste)
    cText += Chr( 0xE0 ) + Chr( 0xA4 ) + Chr( 0xA8 )   // न
    cText += Chr( 0xE0 ) + Chr( 0xA4 ) + Chr( 0xAE )   // म
    cText += Chr( 0xE0 ) + Chr( 0xA4 ) + Chr( 0xB8 )   // स
    cText += Chr( 0xE0 ) + Chr( 0xA5 ) + Chr( 0x8D )   // ् (virama)
    cText += Chr( 0xE0 ) + Chr( 0xA4 ) + Chr( 0xA4 )   // त
    cText += Chr( 0xE0 ) + Chr( 0xA5 ) + Chr( 0x87 )   // े (matra)

    cText += " "                                          // Space

    // "दुनिया" (Duniya)
    cText += Chr( 0xE0 ) + Chr( 0xA4 ) + Chr( 0xA6 )   // द
    cText += Chr( 0xE0 ) + Chr( 0xA4 ) + Chr( 0x89 )   // ु (u matra)
    cText += Chr( 0xE0 ) + Chr( 0xA4 ) + Chr( 0xA8 )   // न
    cText += Chr( 0xE0 ) + Chr( 0xA4 ) + Chr( 0xBF )   // ि (i matra)
    cText += Chr( 0xE0 ) + Chr( 0xA4 ) + Chr( 0xAF )   // य
    cText += Chr( 0xE0 ) + Chr( 0xA4 ) + Chr( 0xBE )   // ा (aa matra)

    RETURN cText

// ============================================================================
// 3. APPLY INITIAL UNICODE TEXT (called from ON INIT)
// ============================================================================
STATIC PROCEDURE ApplyInitialText()
    LOCAL nHWnd := 0

    // Get HWND of the label control
    nHWnd := GetProperty( "WinHello", "LblGreeting", "Handle" )

    IF nHWnd != 0
        SetUnicodeText( nHWnd, GetHindiGreeting() )
        SetUnicodeFont( nHWnd, "Mangal", 28 )
    ENDIF

    RETURN

// ============================================================================
// 4. LANGUAGE CYCLE ACTION
// ============================================================================
STATIC PROCEDURE CycleLanguage()
    LOCAL nHWnd := 0
    LOCAL cGreeting := ""

    nLangMode := nLangMode + 1
    IF nLangMode > 2
        nLangMode := 0
    ENDIF

    DO CASE
        CASE nLangMode == 0
            cGreeting := GetHindiGreeting()
        CASE nLangMode == 1
            cGreeting := "Hello World"
        CASE nLangMode == 2
            cGreeting := "Hola Mundo"
    ENDCASE

    nHWnd := GetProperty( "WinHello", "LblGreeting", "Handle" )
    IF nHWnd != 0
        SetUnicodeText( nHWnd, cGreeting )
        IF nLangMode == 0
            SetUnicodeFont( nHWnd, "Mangal", 28 )
        ELSE
            SetUnicodeFont( nHWnd, "Arial", 26 )
        ENDIF
    ENDIF

    RETURN

// ============================================================================
// 5. ENTRY POINT (MANDATORY NAME: Main)
// ============================================================================
PROCEDURE Main()

    HB_SetCodePage( "UTF8" )

    DEFINE WINDOW WinHello ;
        AT 0, 0 ;
        WIDTH  520 ;
        HEIGHT 320 ;
        TITLE  "Namaste - Hello World in Hindi" ;
        MAIN ;
        FONT "Arial" SIZE 11 ;
        NOSIZE ;
        ON INIT ApplyInitialText()

        @ 040, 040 LABEL LblGreeting ;
            VALUE "Loading..." ;
            WIDTH  440 ;
            HEIGHT 60 ;
            CENTERALIGN

        @ 120, 040 LABEL LblSubtitle ;
            VALUE "( Hello World in Hindi - India )" ;
            WIDTH  440 ;
            HEIGHT 25 ;
            FONT "Arial" SIZE 10 ;
            FONTCOLOR { 80, 80, 80 } ;
            CENTERALIGN

        @ 155, 040 LABEL LblPhonetic ;
            VALUE "Phonetic: Namaste Duniya" ;
            WIDTH  440 ;
            HEIGHT 25 ;
            FONT "Arial" SIZE 10 ITALIC ;
            FONTCOLOR { 0, 80, 160 } ;
            CENTERALIGN

        @ 210, 120 BUTTON BtnCycle ;
            CAPTION "Show in English / Espanol" ;
            WIDTH  280 ;
            HEIGHT 30 ;
            ACTION CycleLanguage()

        @ 250, 210 BUTTON BtnClose ;
            CAPTION "Close" ;
            WIDTH  100 ;
            HEIGHT 28 ;
            ACTION WinHello.Release

    END WINDOW

    CENTER WINDOW WinHello
    ACTIVATE WINDOW WinHello

    RETURN
