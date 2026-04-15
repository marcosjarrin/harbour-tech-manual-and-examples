/*
 *  Project : Low-Level DBF CRUD (OOP) in Harbour
 *  File    : utility.prg
 *  Author  : Marcos Jarrin
 *  Version : 1.0.0
 *  Date    : 2025-08-20
 *  Summary : Utility Functions
 *
 *   Low-Level DBF CRUD (OOP) in Harbour
 *   Complete CRUD over a .DBF file using ONLY low-level file I/O
 *
 *   Copyright (C) 2025 Marcos Jarrin
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
*/

/**
 * @brief Portable modulo function replacement for environments lacking HB_MOD()/Mod().
 * @param n Numerator (non-negative recommended)
 * @param d Denominator (> 0)
 * @return n mod d in the range [0, d-1]
 */
FUNCTION HB_MOD( n, d )

   LOCAL q

   IF d <= 0
      d := 1
   ENDIF

   // Use integer division to avoid FP drift; works for non-negative n.
   q := Int( n / d )

   RETURN n - q * d


/**
 * @brief Convert a 16-bit integer to little-endian 2-byte string
 * @param n 16-bit unsigned value (0..65535)
 * @return 2-char string (little-endian)
 */
FUNCTION LE16( n )

   LOCAL b1 := Chr( hb_mod( n, 256 ) )
   LOCAL b2 := Chr( hb_mod( Int( n / 256 ), 256 ) )

   RETURN b1 + b2

/**
 * @brief Convert a 32-bit integer to little-endian 4-byte string
 * @param n 32-bit unsigned value
 * @return 4-char string (little-endian)
 */
FUNCTION LE32( n )

   LOCAL b1 := Chr( hb_mod( n, 256 ) )
   LOCAL b2 := Chr( hb_mod( Int( n / 256 ), 256 ) )
   LOCAL b3 := Chr( hb_mod( Int( n / 65536 ), 256 ) )
   LOCAL b4 := Chr( hb_mod( Int( n / 16777216 ), 256 ) )

   RETURN b1 + b2 + b3 + b4

/**
 * @brief Left-pad a string with spaces to len n (for Numeric fields)
 */
FUNCTION PadLeft( c, n )
   RETURN Replicate( " ", Max( 0, n - Len( c ) ) ) + c

/**
 * @brief Right-pad a string with spaces to len n (for Character fields)
 */
FUNCTION PadRight( c, n )
   RETURN c + Replicate( " ", Max( 0, n - Len( c ) ) )

/**
 * @brief Validate YYYYMMDD string and return .T./.F.
 */
FUNCTION IsYYYYMMDD( cDate )

   IF Len( cDate ) != 8 .OR. ! HB_ISNUMERIC( Val( cDate ) )
      RETURN .F.
   ENDIF

   RETURN HB_ISDATE( STOD( cDate ) )
