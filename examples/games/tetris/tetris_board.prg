/*
BadaSystem
Program       : tetris
Module        : tetris_board.prg
Compiler      : MINIGUI - Harbour Win32 GUI
Author        : Marcos Jarrín
Email         : marvijarrin@gmail.com
Website       : badasystem.com
Date          : 28/08/2026
Update        : 02/09/2026
Rev           : 1.0.0
SPDX-License-Identifier: MIT
*/

/*
Class: TBoard
Purpose:
Manages the game grid (20x10), piece placement, collision detection,
and line clearing logic.
Inherits:
(none)
Data:
nRows     (N) -> Number of rows (20)
nCols     (N) -> Number of columns (10)
aGrid     (A) -> 2D array [row][col] with color values (0 = empty)
Methods:
New( nRows, nCols )        -> Constructor
Clear()                    -> Reset grid to empty
CanMove( oPiece, nDx, nDy ) -> Check if piece can move
CanPlace( oPiece, nRow, nCol ) -> Check if piece fits at position
LockPiece( oPiece )        -> Lock piece into grid
ClearLines()               -> Remove completed lines, return count
IsTopReached()             -> Check if grid is full at top
GetGrid()                  -> Return grid array
Notes:
- Grid uses 1-based indexing
- Color values: 0 = empty, 1-7 = tetromino colors
- Line clearing shifts rows down
*/
#include "hbclass.ch"

CLASS TBoard
   DATA nRows
   DATA nCols
   DATA aGrid
   METHOD New( nRows, nCols ) CONSTRUCTOR
   METHOD Clear()
   METHOD CanMove( oPiece, nDx, nDy )
   METHOD CanPlace( oPiece, nRow, nCol )
   METHOD LockPiece( oPiece )
   METHOD ClearLines()
   METHOD IsTopReached()
   METHOD GetGrid()
ENDCLASS

/*
Method: TBoard:New
Purpose:
Allocates the 2D grid array and fills with zeros.
Parameters:
nRows  (N) -> Grid height
nCols  (N) -> Grid width
Returns:
Self
*/
METHOD New( nRows, nCols ) CLASS TBoard
   LOCAL nI, nJ
   ::nRows := nRows
   ::nCols := nCols
   ::aGrid := Array( nRows )
   FOR nI := 1 TO nRows
      ::aGrid[ nI ] := Array( nCols )
      FOR nJ := 1 TO nCols
         ::aGrid[ nI ][ nJ ] := 0
      NEXT
   NEXT
RETURN Self

/*
Method: TBoard:Clear
Purpose:
Sets all grid cells to 0 (empty).
Parameters:
(none)
Returns:
NIL
*/
METHOD Clear() CLASS TBoard
   LOCAL nI, nJ
   FOR nI := 1 TO ::nRows
      FOR nJ := 1 TO ::nCols
         ::aGrid[ nI ][ nJ ] := 0
      NEXT
   NEXT
RETURN NIL

/*
Method: TBoard:CanMove
Purpose:
Tests if a piece can move by (nDx, nDy) without
colliding with walls or locked blocks.
Parameters:
oPiece (O) -> TTetromino instance
nDx    (N) -> Horizontal delta
nDy    (N) -> Vertical delta
Returns:
L -> .T. if move is valid
*/
METHOD CanMove( oPiece, nDx, nDy ) CLASS TBoard
   LOCAL nRow, nCol, nI, nJ
   LOCAL nNewRow, nNewCol
   nRow := oPiece:nRow + nDy
   nCol := oPiece:nCol + nDx
   FOR nI := 1 TO 4
      FOR nJ := 1 TO 4
         IF oPiece:aShape[ nI ][ nJ ] > 0
            nNewRow := nRow + nI - 1
            nNewCol := nCol + nJ - 1
            // Check bounds
            IF nNewRow < 1 .OR. nNewRow > ::nRows
               RETURN .F.
            ENDIF
            IF nNewCol < 1 .OR. nNewCol > ::nCols
               RETURN .F.
            ENDIF
            // Check collision with locked pieces
            IF ::aGrid[ nNewRow ][ nNewCol ] > 0
               RETURN .F.
            ENDIF
         ENDIF
      NEXT
   NEXT
RETURN .T.

/*
Method: TBoard:CanPlace
Purpose:
Tests if a piece shape fits at an absolute position.
Parameters:
oPiece (O) -> TTetromino instance
nRow   (N) -> Target row
nCol   (N) -> Target column
Returns:
L -> .T. if placement is valid
*/
METHOD CanPlace( oPiece, nRow, nCol ) CLASS TBoard
   LOCAL nI, nJ, nNewRow, nNewCol
   FOR nI := 1 TO 4
      FOR nJ := 1 TO 4
         IF oPiece:aShape[ nI ][ nJ ] > 0
            nNewRow := nRow + nI - 1
            nNewCol := nCol + nJ - 1
            IF nNewRow < 1 .OR. nNewRow > ::nRows
               RETURN .F.
            ENDIF
            IF nNewCol < 1 .OR. nNewCol > ::nCols
               RETURN .F.
            ENDIF
            IF ::aGrid[ nNewRow ][ nNewCol ] > 0
               RETURN .F.
            ENDIF
         ENDIF
      NEXT
   NEXT
RETURN .T.

/*
Method: TBoard:LockPiece
Purpose:
Writes the piece color values into the grid at the
piece's current position.
Parameters:
oPiece (O) -> TTetromino instance
Returns:
NIL
*/
METHOD LockPiece( oPiece ) CLASS TBoard
   LOCAL nI, nJ, nRow, nCol
   FOR nI := 1 TO 4
      FOR nJ := 1 TO 4
         IF oPiece:aShape[ nI ][ nJ ] > 0
            nRow := oPiece:nRow + nI - 1
            nCol := oPiece:nCol + nJ - 1
            IF nRow >= 1 .AND. nRow <= ::nRows
               IF nCol >= 1 .AND. nCol <= ::nCols
                  ::aGrid[ nRow ][ nCol ] := oPiece:nColor
               ENDIF
            ENDIF
         ENDIF
      NEXT
   NEXT
RETURN NIL

/*
Method: TBoard:ClearLines
Purpose:
Scans rows bottom-to-top. Removes full rows and shifts
rows above downward. Returns the count of cleared lines.
Parameters:
(none)
Returns:
N -> Number of lines cleared
*/
METHOD ClearLines() CLASS TBoard
   LOCAL nCleared := 0
   LOCAL nI, nJ
   LOCAL lFull
   FOR nI := ::nRows TO 1 STEP -1
      lFull := .T.
      FOR nJ := 1 TO ::nCols
         IF ::aGrid[ nI ][ nJ ] == 0
            lFull := .F.
            EXIT
         ENDIF
      NEXT
      IF lFull
         // Clear this line
         FOR nJ := 1 TO ::nCols
            ::aGrid[ nI ][ nJ ] := 0
         NEXT
         // Shift all lines above down
         ::ShiftLinesDown( nI )
         nCleared++
         nI++  // Recheck this row (shifted down)
      ENDIF
   NEXT
RETURN nCleared

METHOD ShiftLinesDown( nRow ) CLASS TBoard
   LOCAL nI, nJ
   FOR nI := nRow TO 2 STEP -1
      FOR nJ := 1 TO ::nCols
         ::aGrid[ nI ][ nJ ] := ::aGrid[ nI - 1 ][ nJ ]
      NEXT
   NEXT
   // Clear top row
   FOR nJ := 1 TO ::nCols
      ::aGrid[ 1 ][ nJ ] := 0
   NEXT
RETURN NIL

/*
Method: TBoard:IsTopReached
Purpose:
Returns .T. if any cell in row 1 is occupied (game over).
Parameters:
(none)
Returns:
L -> .T. if top row has blocks
*/
METHOD IsTopReached() CLASS TBoard
   LOCAL nJ
   FOR nJ := 1 TO ::nCols
      IF ::aGrid[ 1 ][ nJ ] > 0
         RETURN .T.
      ENDIF
   NEXT
RETURN .F.

/*
Method: TBoard:GetGrid
Purpose:
Returns the internal grid array reference.
Parameters:
(none)
Returns:
A -> 2D grid array
*/
METHOD GetGrid() CLASS TBoard
RETURN ::aGrid