/*
BadaSystem
Program       : unicode_bridge
Module        : unicode_bridge.prg
Compiler      : MINIGUI - Harbour Win32 GUI
Compiler-C    : BCC 32 bit (C89 Strict)
Author        : Marcos Jarrín
Date          : 21/08/2026
Rev           : 1.2
SPDX-License-Identifier: MIT
Description:
    Native C bridge for Unicode (UTF-16) rendering in ANSI MiniGUI builds.
    Uses Windows API SetWindowTextW() to bypass ANSI limits.
Notes:
    - ALL variables declared at the VERY TOP of each function block (C89 rule).
    - No mixed declarations and code (prevents Borland E2140).
    - Simplified SETUNICODEFONT to remove unused color params (prevents W8004).
*/

#include "minigui.ch"

#pragma BEGINDUMP

#include <windows.h>
#include <hbapi.h>

/*
 * HB_FUNC: SETUNICODETEXT
 * Parameters: nHWnd (Numeric), cText (String UTF-8)
 * Returns: Logical (.T. on success)
 */
HB_FUNC( SETUNICODETEXT )
{
    /* 1. DECLARATIONS MUST BE AT THE VERY TOP (C89 Rule) */
    HWND hWnd;
    LPCSTR pszUtf8;
    int nWideLen;
    LPWSTR pWideText;
    BOOL bResult;

    /* 2. EXECUTABLE STATEMENTS BELOW */
    hWnd = (HWND) hb_parnl( 1 );
    pszUtf8 = hb_parc( 2 );

    if ( !IsWindow( hWnd ) || pszUtf8 == NULL ) {
        hb_retl( FALSE );
        return;
    }

    nWideLen = MultiByteToWideChar( CP_UTF8, 0, pszUtf8, -1, NULL, 0 );
    if ( nWideLen == 0 ) {
        hb_retl( FALSE );
        return;
    }

    pWideText = (LPWSTR) hb_xgrab( nWideLen * sizeof( WCHAR ) );
    if ( pWideText == NULL ) {
        hb_retl( FALSE );
        return;
    }

    MultiByteToWideChar( CP_UTF8, 0, pszUtf8, -1, pWideText, nWideLen );

    bResult = SetWindowTextW( hWnd, pWideText );

    if ( bResult ) {
        InvalidateRect( hWnd, NULL, TRUE );
        UpdateWindow( hWnd );
    }

    hb_xfree( pWideText );

    hb_retl( bResult ? TRUE : FALSE );
}

/*
 * HB_FUNC: SETUNICODEFONT
 * Parameters: nHWnd (Numeric), cFontName (String), nSize (Numeric)
 * Returns: Logical (.T. on success)
 */
HB_FUNC( SETUNICODEFONT )
{
    /* 1. DECLARATIONS MUST BE AT THE VERY TOP (C89 Rule) */
    HWND hWnd;
    LPCSTR pszFontName;
    int nSize;
    int nHeight;
    HDC hDC;
    HFONT hFont;

    /* 2. EXECUTABLE STATEMENTS BELOW */
    hWnd = (HWND) hb_parnl( 1 );
    pszFontName = hb_parc( 2 );
    nSize = hb_parni( 3 );

    if ( !IsWindow( hWnd ) || pszFontName == NULL || nSize <= 0 ) {
        hb_retl( FALSE );
        return;
    }

    hDC = GetDC( hWnd );
    nHeight = -MulDiv( nSize, GetDeviceCaps( hDC, LOGPIXELSY ), 72 );
    ReleaseDC( hWnd, hDC );

    hFont = CreateFontA(
        nHeight,                    /* height */
        0,                          /* width */
        0,                          /* escapement */
        0,                          /* orientation */
        FW_NORMAL,                  /* weight */
        FALSE,                      /* italic */
        FALSE,                      /* underline */
        FALSE,                      /* strikeout */
        DEFAULT_CHARSET,            /* charset */
        OUT_TT_ONLY_PRECIS,         /* output precision (TrueType only) */
        CLIP_DEFAULT_PRECIS,        /* clip precision */
        CLEARTYPE_QUALITY,          /* quality */
        DEFAULT_PITCH | FF_DONTCARE,/* pitch and family */
        pszFontName                 /* font name */
    );

    if ( hFont != NULL ) {
        SendMessage( hWnd, WM_SETFONT, (WPARAM) hFont, MAKELPARAM( TRUE, 0 ) );
        InvalidateRect( hWnd, NULL, TRUE );
        UpdateWindow( hWnd );
        hb_retl( TRUE );
    } else {
        hb_retl( FALSE );
    }
}
