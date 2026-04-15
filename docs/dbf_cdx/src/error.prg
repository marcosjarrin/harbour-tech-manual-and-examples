/*
 *
 *  Project : Low-Level DBF CRUD (OOP) in Harbour
 *  File    : error.prg
 *  Author  : Marcos Jarrin
 *  Version : 1.0.0
 *  Date    : 2025-08-21
 *  Summary : Error Manager
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

/**
 * @class TErrorMgr
 * @brief Minimal error manager to centralize messages and fail-fast checks.
 */
CLASS TErrorMgr
   DATA cLastError AS CHARACTER INIT ""

   /**
    * @brief Set last error and optionally display it.
    * @param cMsg Error message
    * @param lShow If .T., display on console
    * @return Self
    */
   METHOD SetError( cMsg, lShow )

   /**
    * @brief Ensure condition is true, otherwise set error and return .F.
    * @param lCond Condition
    * @param cMsg Error message on failure
    * @return .T. if ok, .F. if failed
    */
   METHOD Ensure( lCond, cMsg )
ENDCLASS

METHOD SetError( cMsg, lShow ) CLASS TErrorMgr

   ::cLastError := cMsg

   IF HB_DEFAULTVALUE( lShow, .T. )
      ? "[Error]", cMsg
   ENDIF

   RETURN Self

METHOD Ensure( lCond, cMsg ) CLASS TErrorMgr

   IF ! lCond
      ::SetError( cMsg, .T. )
      RETURN .F.
   ENDIF

   RETURN .T.
