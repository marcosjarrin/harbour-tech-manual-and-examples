/*
 *  Project : Low-Level DBF CRUD (OOP) in Harbour
 *  File    : recordmodel.prg
 *  Author  : Marcos Jarrin
 *  Version : 1.0.0
 *  Date    : 2025-08-22
 *  Summary : Record Model
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
#include "hbclass.ch"

/* ========================= DBF ON-DISK CONSTANTS ==========================
   dBASE III header layout (little-endian):
   Byte  0:  Version (0x03 = dBase III)
   Byte  1:  YY (year-1900)
   Byte  2:  MM
   Byte  3:  DD
   Byte 4-7: Number of records (32-bit LE)
   Byte 8-9: Header length (16-bit LE) -> 32 + (FieldCount * 32) + 1 (0x0D)
   Byte10-11:Record length (16-bit LE) -> 1 (deletion flag) + sum(field lengths)
   ... rest: reserved zeros

   Each field descriptor = 32 bytes:
     0-10 : Name (ASCII, null-terminated within 11 bytes)
     11   : Type ('C','N','D','L', ...)
     12-15: Data address (not used, set 0)
     16   : Length (1 byte)
     17   : Decimal count (for 'N')
     18-31: Reserved (zeros)

   After all field descriptors: 0x0D terminator.

   Record storage:
     Byte 0 : Deletion flag (space = active, '*' = deleted)
     Bytes 1..n: Fields concatenated
        - C(n): ASCII, padded with spaces on the RIGHT to length n
        - N(n): ASCII, padded with spaces on the LEFT to length n
        - D(8): ASCII "YYYYMMDD"
        - L(1): ASCII 'T'/'F' (or 'Y'/'N')

   For this table:
     Fields and lengths:  name C(30), last_name C(30), age N(3), birth_date D(8), status L(1)
     Sum field lengths = 30 + 30 + 3 + 8 + 1 = 72
     Record length     = 1 (deletion flag) + 72 = 73 bytes
     Field count       = 5
     Header length     = 32 + (5 * 32) + 1 = 193 bytes
*/


/**
 * @class TPersonRec
 * @brief In-memory representation of a record.
 *
 * Fields:
 *  - name       : Character(30)
 *  - last_name  : Character(30)
 *  - age        : Numeric(3)
 *  - birth_date : Date stored as char(8) "YYYYMMDD"
 *  - status     : Logical(1) 'T'/'F'
 */
CLASS TPersonRec
   DATA name       AS CHARACTER INIT ""
   DATA last_name  AS CHARACTER INIT ""
   DATA age        AS NUMERIC   INIT 0
   DATA birth_date AS CHARACTER INIT ""
   DATA status     AS LOGICAL   INIT .T.

   /**
    * @brief Validate the fields according to the DBF spec for this table.
    * @param oErr Error manager
    * @return .T. if valid, .F. otherwise
    */
   METHOD Validate( oErr )

   /**
    * @brief Serialize to a 72-byte field area (without deletion flag)
    * @return 72-char string
    */
   METHOD ToFieldBuffer()

   /**
    * @brief Deserialize from a 72-byte field area
    * @param cBuf 72-char string
    * @return Self
    */
   METHOD FromFieldBuffer( cBuf )
ENDCLASS

METHOD Validate( oErr ) CLASS TPersonRec

   LOCAL lOK := .T.

   lOK := lOK .AND. oErr:Ensure( HB_ISSTRING( ::name ) .AND. Len( ::name ) > 0 .AND. Len( ::name ) <= 30, ;
                               "Name must be 1..30 characters" )
   lOK := lOK .AND. oErr:Ensure( HB_ISSTRING( ::last_name ) .AND. Len( ::last_name ) > 0 .AND. Len( ::last_name ) <= 30, ;
                               "Last name must be 1..30 characters" )
   lOK := lOK .AND. oErr:Ensure( HB_ISNUMERIC( ::age ) .AND. ::age >= 0 .AND. ::age <= 999, ;
                               "Age must be 0..999" )
   lOK := lOK .AND. oErr:Ensure( HB_ISSTRING( ::birth_date ) .AND. IsYYYYMMDD( ::birth_date ), ;
                               "Birth date must be valid YYYYMMDD" )
   lOK := lOK .AND. oErr:Ensure( HB_ISLOGICAL( ::status ), "Status must be logical" )
   RETURN lOK

METHOD ToFieldBuffer() CLASS TPersonRec

   LOCAL c := ""

   c += PadRight( ::name, 30 )
   c += PadRight( ::last_name, 30 )
   c += PadLeft( LTrim( Str( ::age, 3, 0 ) ), 3 )
   c += ::birth_date  // already YYYYMMDD (8)
   c += IIF( ::status, "T", "F" )

   RETURN c  // length must be 72

METHOD FromFieldBuffer( cBuf ) CLASS TPersonRec

   ::name       := RTrim( SubStr( cBuf, 1, 30 ) )
   ::last_name  := RTrim( SubStr( cBuf, 31, 30 ) )
   ::age        := Val( SubStr( cBuf, 61, 3 ) )
   ::birth_date := SubStr( cBuf, 64, 8 )
   ::status     := Upper( SubStr( cBuf, 72, 1 ) ) $ "TY"

   RETURN Self
