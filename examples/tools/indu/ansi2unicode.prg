/*
BadaSystem
Program       : ansi2unicode
Author        : Marcos Jarrín
Date          : 21/08/2026
Module        : ansi2unicode.prg
Purpose:
    Generic ANSI→Unicode converter for Harbour ANSI builds.
    Converts Unicode code points (U+XXXX) to UTF-8 strings.
Notes:
    - All LOCAL declarations at top
    - Proper semicolon continuation
    - DO CASE/ENDCASE balanced
SPDX-License-Identifier: MIT
*/

#include "hbclass.ch"

// ─────────────────────────────────────────────────────────────────────────
// Unicode to UTF-8 Converter
// ─────────────────────────────────────────────────────────────────────────

/*
FUNCTION UnicodeToUTF8( nCodePoint )
Purpose:
    Converts a Unicode code point (U+0000 to U+FFFF) to UTF-8 encoding.
Parameters:
    nCodePoint (N) -> Unicode code point (e.g., 0x0928 for Devanagari Na)
Returns:
    C -> UTF-8 encoded character string
*/
FUNCTION UnicodeToUTF8( nCodePoint )
    LOCAL cUTF8 := ""

    DO CASE
        // 1-byte UTF-8 (U+0000 to U+007F)
        CASE nCodePoint <= 0x007F
            cUTF8 := Chr( nCodePoint )

        // 2-byte UTF-8 (U+0080 to U+07FF)
        CASE nCodePoint <= 0x07FF
            cUTF8 := Chr( 0xC0 + HB_BitShift( nCodePoint, -6 ) ) + ;
                     Chr( 0x80 + HB_BitAnd( nCodePoint, 0x3F ) )

        // 3-byte UTF-8 (U+0800 to U+FFFF) — Devanagari is here
        CASE nCodePoint <= 0xFFFF
            cUTF8 := Chr( 0xE0 + HB_BitShift( nCodePoint, -12 ) ) + ;
                     Chr( 0x80 + HB_BitAnd( HB_BitShift( nCodePoint, -6 ), 0x3F ) ) + ;
                     Chr( 0x80 + HB_BitAnd( nCodePoint, 0x3F ) )

        // 4-byte UTF-8 (U+10000 to U+10FFFF)
        OTHERWISE
            cUTF8 := Chr( 0xF0 + HB_BitShift( nCodePoint, -18 ) ) + ;
                     Chr( 0x80 + HB_BitAnd( HB_BitShift( nCodePoint, -12 ), 0x3F ) ) + ;
                     Chr( 0x80 + HB_BitAnd( HB_BitShift( nCodePoint, -6 ), 0x3F ) ) + ;
                     Chr( 0x80 + HB_BitAnd( nCodePoint, 0x3F ) )
    ENDCASE

    RETURN cUTF8

/*
FUNCTION BuildUnicodeString( aCodePoints )
Purpose:
    Builds a UTF-8 string from an array of Unicode code points.
Parameters:
    aCodePoints (A) -> Array of numeric code points { 0x0928, 0x092E, ... }
Returns:
    C -> UTF-8 encoded string
Example:
    cHindi := BuildUnicodeString( { 0x0928, 0x092E, 0x0938, 0x094D, 0x0924, 0x0947 } )
    // Returns: "नमस्ते"
*/
FUNCTION BuildUnicodeString( aCodePoints )
    LOCAL cResult := ""
    LOCAL nI

    FOR nI := 1 TO Len( aCodePoints )
        cResult += UnicodeToUTF8( aCodePoints[ nI ] )
    NEXT

    RETURN cResult

/*
FUNCTION GetDevanagariText( cTextType )
Purpose:
    Returns common Devanagari texts pre-built from code points.
Parameters:
    cTextType (C) -> Type of text: "NAMASTE", "DUNIYA", "HELLO_WORLD"
Returns:
    C -> UTF-8 encoded Devanagari string
*/
FUNCTION GetDevanagariText( cTextType )
    LOCAL cText := ""

    DO CASE

        CASE cTextType == "DUNIYA"
            // दुनिया
            cText := BuildUnicodeString( { ;
                0x0926, ; // द
                0x0909, ; // ु (u matra)
                0x0928, ; // न
                0x093F, ; // ि (i matra)
                0x092F, ; // य
                0x093E  ;  // ा (aa matra)
            } )

        CASE cTextType == "HELLO_WORLD"
            // नमस्ते दुनिया
            cText := GetDevanagariText( "NAMASTE" ) + " " + ;
                     GetDevanagariText( "DUNIYA" )

        OTHERWISE
            cText := ""
    ENDCASE

    RETURN cText

/*
FUNCTION UnicodeTest()
Purpose:
    Test function to verify ANSI→Unicode conversion works.
*/
PROCEDURE UnicodeTest()
    LOCAL cHindi := ""
    LOCAL nI

    cHindi := GetDevanagariText( "HELLO_WORLD" )

    ? "Devanagari Text:"
    ? cHindi
    ? "Length:", Len( cHindi )
    ? "Hex dump:"

    FOR nI := 1 TO Len( cHindi )
        ?? StrZero( Asc( SubStr( cHindi, nI, 1 ) ), 2 ), " "
    NEXT
    ?
    
    RETURN
