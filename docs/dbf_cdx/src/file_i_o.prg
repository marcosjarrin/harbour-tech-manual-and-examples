/*
 *  Project : Low-Level DBF CRUD (OOP) in Harbour
 *  File    : file_i_o.prg
 *  Author  : Marcos Jarrin
 *  Version : 1.0.0
 *  Date    : 2025-08-22
 *  Summary : DBF File I/O
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
#include "FILEIO.CH"


/**
 * @class TDBFFile
 * @brief Low-level DBF handler for schema-specific table.
 */
CLASS TDBFFile FROM TPersonRec
   DATA cPath    AS CHARACTER
   DATA hFile    AS NUMERIC   INIT -1
   DATA nRecs    AS NUMERIC   INIT 0
   DATA nHdrLen  AS NUMERIC   INIT 193
   DATA nRecLen  AS NUMERIC   INIT 73
   DATA lOpen    AS LOGICAL   INIT .F.
   DATA oErr     AS OBJECT

   /**
    * @brief Constructor
    * @param cPath Path to DBF file
    * @param oErr  Error manager instance
    */
   METHOD New( cPath, oErr ) CONSTRUCTOR

   /**
    * @brief Create brand-new DBF file with fixed schema
    * @return .T. if success
    */
   METHOD Create()

   /**
    * @brief Open existing DBF file
    * @return .T. if success
    */
   METHOD Open()

   /**
    * @brief Close DBF file (and flush header counts)
    * @return .T. if success
    */
   METHOD Close()

   /**
    * @brief Append a record (logical not deleted)
    * @param oRec TPersonRec instance (validated)
    * @return .T. if success
    */
   METHOD Append( oRec )

   /**
    * @brief Read record by 1-based record number (skips nothing)
    * @param nRecNo 1..nRecs
    * @param oOut   Optional TPersonRec to fill
    * @param lDeletedReturn If .T., return deleted status too
    * @return Hash with keys: DELETED (L), REC (TPersonRec)  OR NIL on error
    */
   METHOD ReadAt( nRecNo, oOut, lDeletedReturn )

   /**
    * @brief Update a record in-place (keeps same deletion flag)
    * @param nRecNo 1..nRecs
    * @param oRec   New data (validated)
    * @return .T. if success
    */
   METHOD UpdateAt( nRecNo, oRec )

   /**
    * @brief Mark a record as logically deleted ('*')
    * @param nRecNo 1..nRecs
    * @return .T. if success
    */
   METHOD DeleteAt( nRecNo )

   /**
    * @brief Iterate and display all non-deleted records
    * @return .T.
    */
   METHOD ListAll()

   /**
    * @brief Internal: write header according to current counts
    */
   METHOD WriteHeader()
ENDCLASS

METHOD New( cPath, oErr ) CLASS TDBFFile
   ::cPath := IIF( Empty( cPath ), "people.dbf", cPath )
   ::oErr  := IIF( oErr == NIL, TErrorMgr():New(), oErr )
   RETURN Self

METHOD Create() CLASS TDBFFile

   LOCAL h, cHdr, d := Date(), yy := Year( d ) - 1900, mm := Month( d ), dd := Day( d )
   LOCAL aFields := {}
   LOCAL i, cFd
   LOCAL cName
   LOCAL cType
   LOCAL nLen
   LOCAL nDec

   IF FILE( ::cPath)
   	  RETURN .F.
   ENDIF

   // Open (create) file
   h := FCreate( ::cPath )

   IF h == -1
      RETURN ::oErr:SetError( "Cannot create file: " + ::cPath ):Ensure( .F., "" )
   ENDIF

   ::hFile := h
   ::lOpen := .T.

   // Build header (32 bytes)
   cHdr := ""
   cHdr += Chr( 0x03 )                    // version dBase III
   cHdr += Chr( yy ) + Chr( mm ) + Chr( dd ) // last update
   cHdr += LE32( 0 )                      // number of records (filled on close/append)
   cHdr += LE16( ::nHdrLen )              // header length
   cHdr += LE16( ::nRecLen )              // record length
   cHdr += Replicate( Chr(0), 20 )        // reserved zeros (bytes 12..31)

   // Write main header
   IF FWrite( ::hFile, cHdr ) != Len( cHdr )
      RETURN ::oErr:SetError( "Failed writing main header" ):Ensure( .F., "" )
   ENDIF

   // Prepare field descriptors (5 fields)
   AAdd( aFields, { "name",      "C", 30, 0 } )
   AAdd( aFields, { "last_name", "C", 30, 0 } )
   AAdd( aFields, { "age",       "N",  3, 0 } )
   AAdd( aFields, { "birth_date","D",  8, 0 } )
   AAdd( aFields, { "status",    "L",  1, 0 } )

   FOR i := 1 TO Len( aFields )
      cName  := PadRight( aFields[i][1], 11 )
      cType  := aFields[i][2]
      nLen   := aFields[i][3]
      nDec   := aFields[i][4]
      cFd := ""
      cFd += Left( cName, 11 )
      cFd += cType
      cFd += LE32( 0 )            // data address (unused)
      cFd += Chr( nLen )
      cFd += Chr( nDec )
      cFd += Replicate( Chr(0), 14 ) // reserved
      IF FWrite( ::hFile, cFd ) != 32
         RETURN ::oErr:SetError( "Failed writing field descriptor #" + LTrim(Str(i)) ):Ensure( .F., "" )
      ENDIF
   NEXT

   // Terminator 0x0D
   IF FWrite( ::hFile, Chr(0x0D) ) != 1
      RETURN ::oErr:SetError( "Failed writing header terminator" ):Ensure( .F., "" )
   ENDIF

   // Position at end (ready to append records)
   FSeek( ::hFile, 0, FS_END )

   RETURN .T.

METHOD Open() CLASS TDBFFile

   LOCAL h := FOpen( ::cPath, FO_READWRITE )
   LOCAL c32, c16

   IF h == -1
      RETURN ::oErr:SetError( "Cannot open file: " + ::cPath ):Ensure( .F., "" )
   ENDIF

   ::hFile := h
   ::lOpen := .T.

   // Read number of records
   FSeek( ::hFile, 4, FS_SET )
   c32 := Space(4)
   FRead( ::hFile, @c32, 4 )
   ::nRecs := Asc( SubStr(c32,1,1) ) + Asc( SubStr(c32,2,1) ) * 256 + ;
              Asc( SubStr(c32,3,1) ) * 65536 + Asc( SubStr(c32,4,1) ) * 16777216

   // Read header and record lengths (defensive)
   FSeek( ::hFile, 8, FS_SET )
   c16 := Space(2)
   FRead( ::hFile, @c16, 2 )
   ::nHdrLen := Asc(SubStr(c16,1,1)) + Asc(SubStr(c16,2,1))*256

   FRead( ::hFile, @c16, 2 )
   ::nRecLen := Asc(SubStr(c16,1,1)) + Asc(SubStr(c16,2,1))*256

   RETURN .T.

METHOD Close() CLASS TDBFFile

   IF ::lOpen .AND. ::hFile != -1
      ::WriteHeader()
      FClose( ::hFile )
      ::hFile := -1
      ::lOpen := .F.
   ENDIF

   RETURN .T.

METHOD WriteHeader() CLASS TDBFFile

   LOCAL d := Date(), yy := Year( d ) - 1900, mm := Month( d ), dd := Day( d )

   // Update last update date
   FSeek( ::hFile, 1, FS_SET )
   FWrite( ::hFile, Chr(yy) + Chr(mm) + Chr(dd) )
   // Update number of records
   FSeek( ::hFile, 4, FS_SET )
   FWrite( ::hFile, LE32( ::nRecs ) )

   RETURN .T.

METHOD Append( oRec ) CLASS TDBFFile

   LOCAL cBuf

   IF ! oRec:Validate( ::oErr )
      RETURN .F.
   ENDIF

   // Deletion flag + fields
   cBuf := " " + oRec:ToFieldBuffer()
   FSeek( ::hFile, 0, FS_END )

   IF FWrite( ::hFile, cBuf ) != ::nRecLen
      RETURN ::oErr:SetError( "Failed to append record" ):Ensure( .F., "" )
   ENDIF

   ::nRecs++

   RETURN .T.

METHOD ReadAt( nRecNo, oOut, lDeletedReturn ) CLASS TDBFFile

   LOCAL nOff, cRec := Space( ::nRecLen ), nRead, cDel, cFields

   IF nRecNo < 1 .OR. nRecNo > ::nRecs
      ::oErr:SetError( "Record number out of range" )
      RETURN NIL
   ENDIF

   nOff := ::nHdrLen + ( nRecNo - 1 ) * ::nRecLen
   FSeek( ::hFile, nOff, FS_SET )
   nRead := FRead( ::hFile, @cRec, ::nRecLen )

   IF nRead != ::nRecLen
      ::oErr:SetError( "Failed to read record" )
      RETURN NIL
   ENDIF

   cDel    := SubStr( cRec, 1, 1 )
   cFields := SubStr( cRec, 2 )

   IF oOut == NIL
      oOut := TPersonRec():New()
   ENDIF

   oOut:FromFieldBuffer( cFields )

   RETURN {"DELETED" => ( cDel == "*" ), "REC" => oOut }

METHOD UpdateAt( nRecNo, oRec ) CLASS TDBFFile

   LOCAL nOff

   IF ! oRec:Validate( ::oErr )
      RETURN .F.
   ENDIF

   IF nRecNo < 1 .OR. nRecNo > ::nRecs
      RETURN ::oErr:SetError( "Record number out of range" ):Ensure( .F., "" )
   ENDIF

   nOff := ::nHdrLen + ( nRecNo - 1 ) * ::nRecLen
   // Preserve deletion flag
   FSeek( ::hFile, nOff, FS_SET )

   IF FWrite( ::hFile, " " + oRec:ToFieldBuffer() ) != ::nRecLen
      RETURN ::oErr:SetError( "Failed to update record" ):Ensure( .F., "" )
   ENDIF

   RETURN .T.

METHOD DeleteAt( nRecNo ) CLASS TDBFFile

   LOCAL nOff

   IF nRecNo < 1 .OR. nRecNo > ::nRecs
      RETURN ::oErr:SetError( "Record number out of range" ):Ensure( .F., "" )
   ENDIF

   nOff := ::nHdrLen + ( nRecNo - 1 ) * ::nRecLen
   FSeek( ::hFile, nOff, FS_SET )
   IF FWrite( ::hFile, "*" ) != 1
      RETURN ::oErr:SetError( "Failed to mark as deleted" ):Ensure( .F., "" )
   ENDIF

   RETURN .T.

METHOD ListAll() CLASS TDBFFile

   LOCAL i, h

   ? "-- Active records --"

   FOR i := 1 TO ::nRecs
      h := ::ReadAt( i )
      IF h != NIL .AND. ! h["DELETED"]
         WITH OBJECT h["REC"]
            ?? "#" + LTrim(Str(i)) + ": " + :name + ", " + :last_name + ;
               " | age= " + LTrim(Str(:age)) + ;
               " | birth_date= " + :birth_date + ;
               " | status= " + IIF(:status,"T","F")
            ?
         ENDWITH
      ENDIF
   NEXT

   WAIT

   RETURN .T.
