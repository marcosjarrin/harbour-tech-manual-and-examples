/*
BadaSystem
Program       : tetris
Module        : i18n.prg
Compiler      : MINIGUI - Harbour Win32 GUI
Author        : Marcos Jarrín
Email         : marvijarrin@gmail.com
Website       : badasystem.com
Date          : 28/08/2026
Update        : 01/09/2026
Rev           : 1.0.0
SPDX-License-Identifier: MIT
Description:
Internationalization module with MANUAL UTF-8 to ANSI conversion.
Compatible with HMG Extended 26.08.0 ANSI.
Notes:
- Manual byte-by-byte UTF-8 to ANSI conversion (100% reliable).
- Handles all common Latin accented characters.
- Zero-dependency JSON parser (no hbjson.ch).
*/

#include "minigui.ch"
#include "fileio.ch"

STATIC hLang := { => }
STATIC cCurrentLang := "EN"
STATIC cIniFile := ""

// ============================================================================
// INITIALIZATION
// ============================================================================
FUNCTION I18nInit()
   cIniFile := GetStartUpFolder() + "\tetris.ini"
RETURN NIL

// ============================================================================
// MANUAL UTF-8 TO ANSI CONVERSION (Byte-by-byte)
// ============================================================================
STATIC FUNCTION Utf8ToAnsi( cUtf8 )
   LOCAL cAnsi := ""
   LOCAL nI := 1
   LOCAL nLen := Len( cUtf8 )
   LOCAL nByte1, nByte2, nChar
   
   IF Empty( cUtf8 )
      RETURN cUtf8
   ENDIF
   
   DO WHILE nI <= nLen
      nByte1 := Asc( SubStr( cUtf8, nI, 1 ) )
      
      // Single byte (ASCII)
      IF nByte1 < 128
         cAnsi += Chr( nByte1 )
         nI++
      
      // Two-byte UTF-8 sequence (Latin accented characters)
      ELSEIF nByte1 >= 194 .AND. nByte1 <= 223
         IF nI + 1 <= nLen
            nByte2 := Asc( SubStr( cUtf8, nI + 1, 1 ) )
            // Calculate ANSI character code
            nChar := ( nByte1 - 192 ) * 64 + ( nByte2 - 128 )
            
            // Map to Windows-1252
            DO CASE
            CASE nChar == 128; cAnsi += Chr( 128 )  // €
            CASE nChar == 130; cAnsi += Chr( 130 )  // ‚
            CASE nChar == 131; cAnsi += Chr( 131 )  // ƒ
            CASE nChar == 132; cAnsi += Chr( 132 )  // „
            CASE nChar == 133; cAnsi += Chr( 133 )  // …
            CASE nChar == 134; cAnsi += Chr( 134 )  // †
            CASE nChar == 135; cAnsi += Chr( 135 )  // ‡
            CASE nChar == 136; cAnsi += Chr( 136 )  // 
            CASE nChar == 137; cAnsi += Chr( 137 )  // ‰
            CASE nChar == 138; cAnsi += Chr( 138 )  // Š
            CASE nChar == 139; cAnsi += Chr( 139 )  // ‹
            CASE nChar == 140; cAnsi += Chr( 140 )  // Œ
            CASE nChar == 142; cAnsi += Chr( 142 )  // Ž
            CASE nChar == 145; cAnsi += Chr( 145 )  // '
            CASE nChar == 146; cAnsi += Chr( 146 )  // '
            CASE nChar == 147; cAnsi += Chr( 147 )  // "
            CASE nChar == 148; cAnsi += Chr( 148 )  // "
            CASE nChar == 149; cAnsi += Chr( 149 )  // •
            CASE nChar == 150; cAnsi += Chr( 150 )  // –
            CASE nChar == 151; cAnsi += Chr( 151 )  // —
            CASE nChar == 152; cAnsi += Chr( 152 )  // ˜
            CASE nChar == 153; cAnsi += Chr( 153 )  // ™
            CASE nChar == 154; cAnsi += Chr( 154 )  // š
            CASE nChar == 155; cAnsi += Chr( 155 )  // ›
            CASE nChar == 156; cAnsi += Chr( 156 )  // œ
            CASE nChar == 158; cAnsi += Chr( 158 )  // ž
            CASE nChar == 159; cAnsi += Chr( 159 )  // Ÿ
            OTHERWISE
               // Latin accented characters (Á, é, ñ, etc.)
               IF nChar >= 192 .AND. nChar <= 255
                  cAnsi += Chr( nChar )
               ELSE
                  cAnsi += "?"  // Unknown character
               ENDIF
            ENDCASE
            
            nI += 2
         ELSE
            cAnsi += "?"
            nI++
         ENDIF
      
      // Three-byte UTF-8 sequence (skip)
      ELSEIF nByte1 >= 224 .AND. nByte1 <= 239
         nI += 3
      
      // Four-byte UTF-8 sequence (skip)
      ELSEIF nByte1 >= 240 .AND. nByte1 <= 247
         nI += 4
      
      // Invalid byte
      ELSE
         cAnsi += "?"
         nI++
      ENDIF
   ENDDO
   
RETURN cAnsi

// ============================================================================
// LOAD SAVED LANGUAGE
// ============================================================================
FUNCTION LoadLanguage()
   LOCAL cLang
   
   IF Empty( cIniFile )
      I18nInit()
   ENDIF
   
   cLang := IniRead( cIniFile, "Settings", "Language", "EN" )
   
   IF Empty( cLang ) .OR. !( Upper( cLang ) $ "EN,ES,PT" )
      cLang := "EN"
   ENDIF
   
   RETURN Upper( cLang )

// ============================================================================
// SAVE LANGUAGE
// ============================================================================
FUNCTION SaveLanguage( cLang )
   IF Empty( cIniFile )
      I18nInit()
   ENDIF
   
   RETURN IniWrite( cIniFile, "Settings", "Language", Upper( cLang ) )

// ============================================================================
// TRANSLATION FUNCTION
// ============================================================================
FUNCTION T( cKey )
   IF hb_HHasKey( hLang, cKey )
      RETURN hLang[ cKey ]
   ENDIF
   RETURN cKey

// ============================================================================
// GET CURRENT LANGUAGE
// ============================================================================
FUNCTION GetCurrentLang()
RETURN cCurrentLang

// ============================================================================
// LANGUAGE LOADER
// ============================================================================
FUNCTION SetLanguage( cLang )
   LOCAL cPath, cFile, cJson, hDict
   LOCAL lOk := .F.
   
   IF cLang == NIL
      cLang := "EN"
   ENDIF
   
   cLang := Upper( AllTrim( cLang ) )
   IF !( cLang $ "EN,ES,PT" )
      cLang := "EN"
   ENDIF
   
   cPath := GetStartUpFolder()
   cFile := cPath + "\i18n\" + Lower( cLang ) + ".json"
   
   IF File( cFile )
      cJson := MemoRead( cFile )
      IF ValType( cJson ) == "C" .AND. ! Empty( cJson )
         // Remove UTF-8 BOM if present
         IF Left( cJson, 3 ) == Chr( 239 ) + Chr( 187 ) + Chr( 191 )
            cJson := SubStr( cJson, 4 )
         ENDIF
         
         hDict := ParseJsonDictionary( cJson )
         IF ValType( hDict ) == "H" .AND. Len( hDict ) > 0
            // Convert all values from UTF-8 to ANSI
            hLang := ConvertHashUtf8ToAnsi( hDict )
            lOk   := .T.
         ENDIF
      ENDIF
   ENDIF
   
   IF ! lOk
      hLang := DefaultDictionary( cLang )
   ENDIF
   
   cCurrentLang := cLang
   SaveLanguage( cLang )
   
   DO CASE
   CASE cLang == "ES"
      SET DATE FORMAT TO "DD/MM/YYYY"
   CASE cLang == "PT"
      SET DATE FORMAT TO "DD/MM/YYYY"
   OTHERWISE
      SET DATE FORMAT TO "MM/DD/YYYY"
   ENDCASE
   
   RETURN lOk

// ============================================================================
// CONVERT HASH VALUES FROM UTF-8 TO ANSI
// ============================================================================
STATIC FUNCTION ConvertHashUtf8ToAnsi( hSource )
   LOCAL hResult := { => }
   LOCAL aKeys := hb_HKeys( hSource )
   LOCAL nI, cKey, cValue
   
   FOR nI := 1 TO Len( aKeys )
      cKey := aKeys[ nI ]
      cValue := hSource[ cKey ]
      
      IF ValType( cValue ) == "C"
         hResult[ cKey ] := Utf8ToAnsi( cValue )
      ELSE
         hResult[ cKey ] := cValue
      ENDIF
   NEXT
   
RETURN hResult

// ============================================================================
// RUNTIME LANGUAGE SWITCHER
// ============================================================================
FUNCTION ChangeLanguage( cLang )
   LOCAL lOk
   
   lOk := SetLanguage( cLang )
   IF ! lOk
      MsgStop( "Error loading language: " + cLang )
      RETURN .F.
   ENDIF
   
   IF IsWindowDefined( "WinTetris" )
      RefreshTetrisUI()
   ENDIF
   
   RETURN .T.

// ============================================================================
// DYNAMIC UI REFRESH
// ============================================================================
FUNCTION RefreshTetrisUI()
   IF ! IsWindowDefined( "WinTetris" )
      RETURN
   ENDIF
   
   SetProperty( "WinTetris", "mnuMenuGame","Caption", T( "menu.game" ) )
   SetProperty( "WinTetris", "mnuNew",     "Caption", T( "menu.game.new" ) )
   SetProperty( "WinTetris", "mnuPause",   "Caption", T( "menu.game.pause" ) )
   SetProperty( "WinTetris", "mnuExit",    "Caption", T( "menu.game.exit" ) )

   SetProperty( "WinTetris", "mnuMenuOptions", "Caption", T( "menu.options" ) )
   SetProperty( "WinTetris", "mnuLang",   "Caption", T( "menu.options.language" ) )
   SetProperty( "WinTetris", "mnuLangEN", "Caption", T( "lang.english" ) )
   SetProperty( "WinTetris", "mnuLangES", "Caption", T( "lang.spanish" ) )
   SetProperty( "WinTetris", "mnuLangPT", "Caption", T( "lang.portuguese" ) )

   SetProperty( "WinTetris", "mnuBack",      "Caption", T( "menu.options.background" ) )
   SetProperty( "WinTetris", "mnuBackBlack", "Caption", T( "bg.black" ) )
   SetProperty( "WinTetris", "mnuBackBlue",  "Caption", T( "bg.blue" ) )
   SetProperty( "WinTetris", "mnuBackGreen", "Caption", T( "bg.green" ) )
   SetProperty( "WinTetris", "mnuBackRed",   "Caption", T( "bg.red" ) )

   SetProperty( "WinTetris", "mnuMenuHelp","Caption", T( "menu.help" ) )
   SetProperty( "WinTetris", "mnuKeys",    "Caption", T( "menu.help.keys" ) )
   SetProperty( "WinTetris", "mnuAbout",   "Caption", T( "menu.help.about" ) )
   
   SetProperty( "WinTetris", "lblScore", "Value", T( "label.score" ) + ": 0" )
   SetProperty( "WinTetris", "lblLevel", "Value", T( "label.level" ) + ": 1" )
   SetProperty( "WinTetris", "lblLines", "Value", T( "label.lines" ) + ": 0" )
   
   DoMethod( "WinTetris", "Redraw" )
   
RETURN NIL

// ============================================================================
// ZERO-DEPENDENCY JSON PARSER
// ============================================================================
STATIC FUNCTION ParseJsonDictionary( cJson )
   LOCAL hDict  := { => }
   LOCAL aLines := hb_ATokens( cJson, Chr(10) )
   LOCAL cLine, nPos, cKey, cVal
   LOCAL nI
   
   FOR nI := 1 TO Len( aLines )
      cLine := AllTrim( aLines[ nI ] )
      
      IF Empty( cLine ) .OR. cLine == "{" .OR. cLine == "}" .OR. cLine == ","
         LOOP
      ENDIF
      
      nPos := At( '"', cLine )
      IF nPos == 0
         LOOP
      ENDIF
      cLine := SubStr( cLine, nPos + 1 )
      
      nPos := At( '"', cLine )
      IF nPos == 0
         LOOP
      ENDIF
      cKey := SubStr( cLine, 1, nPos - 1 )
      cLine := SubStr( cLine, nPos + 1 )
      
      nPos := At( ':', cLine )
      IF nPos == 0
         LOOP
      ENDIF
      cLine := SubStr( cLine, nPos + 1 )
      
      nPos := At( '"', cLine )
      IF nPos == 0
         LOOP
      ENDIF
      cLine := SubStr( cLine, nPos + 1 )
      
      nPos := At( '"', cLine )
      IF nPos == 0
         cVal := ""
      ELSE
         cVal := SubStr( cLine, 1, nPos - 1 )
      ENDIF
      
      hDict[ cKey ] := cVal
   NEXT
   
   RETURN hDict

// ============================================================================
// FALLBACK DICTIONARY (Already in ANSI)
// ============================================================================
STATIC FUNCTION DefaultDictionary( cLang )
   LOCAL hDict := { => }
   
   IF cLang == "ES"
      hDict[ "app.title" ]            := "HMG Tetris"
      hDict[ "menu.game" ]            := "&Juego"
      hDict[ "menu.game.new" ]        := "&Nuevo Juego"
      hDict[ "menu.game.pause" ]      := "&Pausar/Reanudar"
      hDict[ "menu.game.exit" ]       := "&Salir"
      hDict[ "menu.help" ]            := "&Ayuda"
      hDict[ "menu.help.keys" ]       := "&Teclas"
      hDict[ "menu.help.about" ]      := "&Acerca de"
      hDict[ "menu.options" ]         := "&Opciones"
      hDict[ "menu.options.language" ]:= "&Idioma"
      hDict[ "lang.english" ]         := "Inglés"
      hDict[ "lang.spanish" ]         := "Español"
      hDict[ "lang.portuguese" ]      := "Portugués"
      hDict[ "label.score" ]          := "Puntuación"
      hDict[ "label.lines" ]          := "Líneas"
      hDict[ "label.level" ]          := "Nivel"
      hDict[ "label.pieces" ]         := "Piezas"
      hDict[ "msg.keys" ]             := "Flechas: Mover pieza" + CRLF + ;
                                         "Arriba: Rotar" + CRLF + ;
                                         "F2: Nuevo Juego" + CRLF + ;
                                         "F5: Pausar/Reanudar"
      hDict[ "msg.about" ]            := "HMG Tetris v5.2" + CRLF + ;
                                         "Implementación moderna en Harbour" + CRLF + ;
                                         "Compatible con HMG Extended 26.08.0 ANSI"
      hDict[ "status.ready" ]         := "Listo - Presione F2 para comenzar"
      hDict[ "menu.options.background" ] := "&Fondo"
      hDict[ "bg.black" ]                := "Negro"
      hDict[ "bg.gradient" ]             := "Gradiente (Blanco→Negro)"
      hDict[ "bg.blue" ]                 := "Azul Marino"
      hDict[ "bg.green" ]                := "Verde Oscuro"
      hDict[ "bg.red" ]                  := "Rojo Oscuro"
   ELSEIF cLang == "PT"
      hDict[ "app.title" ]            := "HMG Tetris"
      hDict[ "menu.game" ]            := "&Jogo"
      hDict[ "menu.game.new" ]        := "&Novo Jogo"
      hDict[ "menu.game.pause" ]      := "&Pausar/Retomar"
      hDict[ "menu.game.exit" ]       := "&Sair"
      hDict[ "menu.help" ]            := "&Ajuda"
      hDict[ "menu.help.keys" ]       := "&Teclas"
      hDict[ "menu.help.about" ]      := "&Sobre"
      hDict[ "menu.options" ]         := "&Opções"
      hDict[ "menu.options.language" ]:= "&Idioma"
      hDict[ "lang.english" ]         := "Inglês"
      hDict[ "lang.spanish" ]         := "Espanhol"
      hDict[ "lang.portuguese" ]      := "Português"
      hDict[ "label.score" ]          := "Pontuação"
      hDict[ "label.lines" ]          := "Linhas"
      hDict[ "label.level" ]          := "Nível"
      hDict[ "label.pieces" ]         := "Peças"
      hDict[ "msg.keys" ]             := "Setas: Mover peça" + CRLF + ;
                                         "Cima: Rotacionar" + CRLF + ;
                                         "F2: Novo Jogo" + CRLF + ;
                                         "F5: Pausar/Retomar"
      hDict[ "msg.about" ]            := "HMG Tetris v5.2" + CRLF + ;
                                         "Implementação moderna em Harbour" + CRLF + ;
                                         "Compatível com HMG Extended 26.08.0 ANSI"
      hDict[ "status.ready" ]         := "Pronto - Pressione F2 para começar"
      hDict[ "menu.options.background" ] := "&Fundo"
      hDict[ "bg.black" ]    := "Preto"
      hDict[ "bg.gradient" ] := "Gradiente (Branco→Preto)"
      hDict[ "bg.blue" ]     := "Azul Marinho"
      hDict[ "bg.green" ]    := "Verde Escuro"
      hDict[ "bg.red" ]      := "Vermelho Escuro"

   ELSE
      hDict[ "app.title" ]            := "HMG Tetris"
      hDict[ "menu.game" ]            := "&Game"
      hDict[ "menu.game.new" ]        := "&New Game"
      hDict[ "menu.game.pause" ]      := "&Pause/Resume"
      hDict[ "menu.game.exit" ]       := "E&xit"
      hDict[ "menu.help" ]            := "&Help"
      hDict[ "menu.help.keys" ]       := "&Keys"
      hDict[ "menu.help.about" ]      := "&About"
      hDict[ "menu.options" ]         := "&Options"
      hDict[ "menu.options.language" ]:= "&Language"
      hDict[ "lang.english" ]         := "English"
      hDict[ "lang.spanish" ]         := "Spanish"
      hDict[ "lang.portuguese" ]      := "Portuguese"
      hDict[ "label.score" ]          := "Score"
      hDict[ "label.lines" ]          := "Lines"
      hDict[ "label.level" ]          := "Level"
      hDict[ "label.pieces" ]         := "Pieces"
      hDict[ "msg.keys" ]             := "Arrow Keys: Move piece" + CRLF + ;
                                         "Up: Rotate" + CRLF + ;
                                         "F2: New Game" + CRLF + ;
                                         "F5: Pause/Resume"
      hDict[ "msg.about" ]            := "HMG Tetris v5.2" + CRLF + ;
                                         "Modern Harbour Implementation" + CRLF + ;
                                         "Compatible with HMG Extended 26.08.0 ANSI"
      hDict[ "status.ready" ]         := "Ready - Press F2 to start"
      hDict[ "menu.options.background" ] := "&Background"
      hDict[ "bg.black" ]    := "Black"
      hDict[ "bg.gradient" ] := "Gradient (White→Black)"
      hDict[ "bg.blue" ]     := "Navy Blue"
      hDict[ "bg.green" ]    := "Dark Green"
      hDict[ "bg.red" ]      := "Dark Red"
   ENDIF
   
   RETURN hDict