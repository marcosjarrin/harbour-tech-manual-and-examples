/*
 *  Project : Low-Level DBF CRUD (OOP) in Harbour
 *  File    : application.prg
 *  Author  : Marcos Jarrin
 *  Version : 1.0.0
 *  Date    : 2025-08-22
 *  Summary : Application
 *
 *  Low-Level DBF CRUD (OOP) in Harbour
 *  Complete CRUD over a .DBF file using ONLY low-level file I/O
 *
 *  Copyright (C) 2025 Marcos Jarrin
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
*/

#include "hbclass.ch"

/**
 * @class TApp
 * @brief CLI app with numbered English menu for CRUD operations.
 */
CLASS TApp FROM TPersonRec
   DATA oErr AS OBJECT
   DATA oDBF AS OBJECT

   /** @brief Constructor */
   METHOD New( cPath ) CONSTRUCTOR

   /** @brief Run main menu loop */
   METHOD Run()

   // Menu handlers
   METHOD DoCreate()
   METHOD DoOpen()
   METHOD DoAdd()
   METHOD DoList()
   METHOD DoUpdate()
   METHOD DoDelete()
   METHOD DoReadOne()
   METHOD DoClose()
ENDCLASS

METHOD New( cPath ) CLASS TApp
   ::oErr := TErrorMgr():New()
   ::oDBF := TDBFFile():New( cPath, ::oErr )
   RETURN Self

METHOD Run() CLASS TApp

   LOCAL cOpt

   DO WHILE .T.
      CLS
      ? "==== Low-Level DBF CRUD (OOP) ===="
      ? "1) Create DBF"
      ? "2) Open DBF"
      ? "3) Add record"
      ? "4) List records"
      ? "5) Update record"
      ? "6) Delete record (logical)"
      ? "7) Read one record"
      ? "8) Close DBF"
      ? "9) Exit"
      ACCEPT "Select option: " TO cOpt

      DO CASE
         CASE cOpt == "1" ; ::DoCreate()
         CASE cOpt == "2" ; ::DoOpen()
         CASE cOpt == "3" ; ::DoAdd()
         CASE cOpt == "4" ; ::DoList()
         CASE cOpt == "5" ; ::DoUpdate()
         CASE cOpt == "6" ; ::DoDelete()
         CASE cOpt == "7" ; ::DoReadOne()
         CASE cOpt == "8" ; ::DoClose()
         CASE cOpt == "9" ; EXIT
         OTHERWISE
            ? "Invalid option"
      ENDCASE

   ENDDO

   IF ::oDBF:lOpen
      ::oDBF:Close()
   ENDIF

   RETURN NIL

METHOD DoCreate() CLASS TApp

   IF ::oDBF:lOpen
      ::oDBF:Close()
   ENDIF

   IF ::oDBF:Create()
      ? "Created DBF:", ::oDBF:cPath
   ELSE
   	  ? "File already exists:", ::oDBF:cPath
   ENDIF
   WAIT
   RETURN NIL

METHOD DoOpen() CLASS TApp

   IF ::oDBF:Open()
      ? "Opened DBF:", ::oDBF:cPath, " Records:", ::oDBF:nRecs
      WAIT
   ENDIF

   RETURN NIL

METHOD DoAdd() CLASS TApp

   LOCAL oR := TPersonRec():New()
   LOCAL c

   IF ! ::oDBF:lOpen
      ? "Open or create the DBF first"
      RETURN NIL
   ENDIF

   ACCEPT "Name (1..30): " TO oR:name
   ACCEPT "Last name (1..30): " TO oR:last_name
   ACCEPT "Age (0..999): " TO c ; oR:age := Val( c )
   ACCEPT "Birth date YYYYMMDD: " TO oR:birth_date
   ACCEPT "Status (T/F): " TO c ; oR:status := Upper( c ) == "T"

   IF ::oDBF:Append( oR )
      ? "Record appended. New count:", ::oDBF:nRecs
   ENDIF

   RETURN NIL

METHOD DoList() CLASS TApp

   IF ! ::oDBF:lOpen
      ? "Open or create the DBF first"
      WAIT
      RETURN NIL
   ENDIF
   ::oDBF:ListAll()

   RETURN NIL

METHOD DoUpdate() CLASS TApp

   LOCAL n, c, oR := TPersonRec():New()
   LOCAL h

   IF ! ::oDBF:lOpen
      ? "Open or create the DBF first"
      RETURN NIL
   ENDIF

   ACCEPT "Record number to update: " TO c ; n := Val( c )
   // Preload existing to show current values
   h := ::oDBF:ReadAt( n )

   IF h == NIL
      RETURN NIL
   ENDIF
   IF h["DELETED"]
      ? "Warning: record is marked as deleted. Updating will keep it deleted."
   ENDIF

   WITH OBJECT h["REC"]
      ? "Current -> Name:", :name, ", Last name:", :last_name, ", Age:", :age, ;
        ", Birth:", :birth_date, ", Status:", IIF(:status,"T","F")
   ENDWITH

   ACCEPT "New Name (blank=keep): " TO c ; IF !Empty(c) ; oR:name := c ; ELSE ; oR:name := h["REC"]:name ; ENDIF
   ACCEPT "New Last name (blank=keep): " TO c ; IF !Empty(c) ; oR:last_name := c ; ELSE ; oR:last_name := h["REC"]:last_name ; ENDIF
   ACCEPT "New Age (blank=keep): " TO c ; IF !Empty(c) ; oR:age := Val(c) ; ELSE ; oR:age := h["REC"]:age ; ENDIF
   ACCEPT "New Birth date YYYYMMDD (blank=keep): " TO c ; IF !Empty(c) ; oR:birth_date := c ; ELSE ; oR:birth_date := h["REC"]:birth_date ; ENDIF
   ACCEPT "New Status T/F (blank=keep): " TO c ; IF !Empty(c) ; oR:status := Upper(c)=="T" ; ELSE ; oR:status := h["REC"]:status ; ENDIF

   IF ::oDBF:UpdateAt( n, oR )
      ? "Record #" + LTrim(Str(n)) + " updated."
   ENDIF

   RETURN NIL

METHOD DoDelete() CLASS TApp

   LOCAL n, c

   IF ! ::oDBF:lOpen
      ? "Open or create the DBF first"
      RETURN NIL
   ENDIF

   ACCEPT "Record number to delete (logical): " TO c ; n := Val( c )

   IF ::oDBF:DeleteAt( n )
      ? "Record #" + LTrim(Str(n)) + " logically deleted (*)"
   ENDIF
   WAIT
   RETURN NIL

METHOD DoReadOne() CLASS TApp

   LOCAL n, c, h

   IF ! ::oDBF:lOpen
      ? "Open or create the DBF first"
      RETURN NIL
   ENDIF

   ACCEPT "Record number to read: " TO c ; n := Val( c )
   h := ::oDBF:ReadAt( n )

   IF h != NIL
      ? "Deleted: ", IIF( h["DELETED"], "YES", "NO" )
      WITH OBJECT h["REC"]
         ? "Name:", :name
         ? "Last name:", :last_name
         ? "Age:", :age
         ? "Birth date (YYYYMMDD):", :birth_date
         ? "Status (T/F):", IIF(:status,"T","F")
      ENDWITH
   ENDIF
   WAIT

   RETURN NIL

METHOD DoClose() CLASS TApp

   IF ::oDBF:lOpen
      ::oDBF:Close()
      ? "DBF closed."
   ELSE
      ? "DBF not open."
   ENDIF

   RETURN NIL
