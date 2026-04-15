/*
 *  Project : Low-Level DBF CRUD (OOP) in Harbour
 *  File    : dbf_crud.prg
 *  Author  : Marcos Jarrin
 *  Version : 1.0.0
 *  Date    : 2025-08-20
 *  Summary : Complete CRUD over a .DBF file using ONLY low-level file I/O
 *            (FOpen(), FWrite(), FRead(), FSeek(), FClose()) with OOP design,
 *            robust validation and error handling.
 *
 *  Requirements covered:
 *   - Low-level file manipulation
 *   - Create DBF with fields:
 *       name (C,30), last_name (C,30), age (N,3), birth_date (D,8 YYYYMMDD),
 *       status (L,1)
 *   - Full CRUD (Create, Read, Update, Delete [logical mark '*'])
 *   - Interactive numbered menu
 *   - OOP in Harbour
 *   - Data validation and error handling
 *   - Doxygen comments on classes and methods
 *   - Date format: YYYYMMDD
 *   - Examples of record structure (see long header comments and constants)
 *
 *
 *  ----------------------- EXAMPLES OF RECORD STRUCTURE ----------------------
 *  Example serialized record (73 bytes total):
 *    [0]   : ' '   (space) => active (or '*' => deleted)
 *    [1-30]: name         (C,30) right-padded with spaces
 *    [31-60]:last_name    (C,30) right-padded with spaces
 *    [61-63]:age          (N,3)  left-padded with spaces, e.g. " 25"
 *    [64-71]:birth_date   (D,8)  ASCII "YYYYMMDD", e.g. "19991231"
 *    [72]  :status        (L,1)  'T' or 'F'
 *
 *   To compute byte offsets for record N (1-based):
 *    offset = HeaderLength (193) + (N-1) * RecordLength (73)
 *
 *   Header fields updated on append/close:
 *     - Last update date (YY,MM,DD) at bytes [1..3]
 *     - Number of records (4 bytes LE) at bytes [4..7]
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
 * @brief Program entry point
 * @param cPath Optional command-line DBF path
 * @return NIL
 */
PROCEDURE Main( cPath )

   LOCAL o := TApp():New( cPath )

   o:Run()

   RETURN
