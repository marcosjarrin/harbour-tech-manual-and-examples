/*
BadaSystem
Program       : tetris
Module        : tetris_piece.prg
Compiler      : MINIGUI - Harbour Win32 GUI
Author        : Marcos Jarrín
Email         : marvijarrin@gmail.com
Website       : badasystem.com
Date          : 28/08/2026
Update        : 02/09/2026
Rev           : 1.0.0
SPDX-License-Identifier: MIT
Description:
Represents a single tetromino piece with shape, rotation, and color.
*/
#include "hbclass.ch"

/*
Class: TTetromino
Purpose:
Represents a single tetromino with type, rotation,
color, shape matrix, and grid position.
Inherits:
(none)
Data:
nType  (N) -> Piece type (1-7)
nRot   (N) -> Rotation state (0-3)
nColor (N) -> Color index (matches nType)
aShape (A) -> 4x4 binary matrix
nRow   (N) -> Grid row position
nCol   (N) -> Grid column position
Methods:
New(nType, nRot)  -> Constructor
Rotate()          -> Returns new rotated piece instance
GetShape()        -> Returns 4x4 shape array
CLASSMETHOD NewRandom() -> Factory: random piece
*/
CLASS TTetromino

   DATA nType
   DATA nRot
   DATA nColor
   DATA aShape
   DATA nRow
   DATA nCol

   METHOD New( nType, nRot ) CONSTRUCTOR
   METHOD Rotate()
   METHOD GetShape()

   // CLASSMETHOD declaration inside CLASS block (single-word token)
   CLASSMETHOD NewRandom()

ENDCLASS

/*
Method: TTetromino:New
Purpose:
Constructor. Sets type, rotation, color, and loads
the corresponding 4x4 shape from the static table.
Parameters:
nType  (N) -> Piece type (1-7)
nRot   (N) -> Rotation state (0-3)
Returns:
Self
*/
METHOD New( nType, nRot ) CLASS TTetromino
   LOCAL aShapes := TTetromino:GetShapes()
   ::nType  := nType
   ::nRot   := nRot
   ::nColor := nType
   ::aShape := aShapes[ nType ][ nRot + 1 ]
   ::nRow   := 1
   ::nCol   := 1
RETURN Self

// Implementation of CLASSMETHOD uses standard METHOD command outside the block

/*
Method: TTetromino:NewRandom (CLASSMETHOD)
Purpose:
Factory method. Creates a piece with random type and rotation.
Parameters:
(none)
Returns:
O -> New TTetromino instance
*/
METHOD NewRandom() CLASS TTetromino
   LOCAL nType := hb_RandomInt( 1, 7 )
   LOCAL nRot  := hb_RandomInt( 0, 3 )
RETURN TTetromino():New( nType, nRot )

/*
Method: TTetromino:Rotate
Purpose:
Returns a new TTetromino instance with rotation advanced
by 90 degrees (wraps 3 -> 0). Immutable pattern.
Parameters:
(none)
Returns:
O -> New rotated TTetromino instance
*/
METHOD Rotate() CLASS TTetromino
   LOCAL nNewRot := ::nRot + 1
   IF nNewRot > 3
      nNewRot := 0
   ENDIF
RETURN TTetromino():New( ::nType, nNewRot )

/*
Method: TTetromino:GetShape
Purpose:
Returns the 4x4 shape array for this piece.
Parameters:
(none)
Returns:
A -> 4x4 binary matrix
*/
METHOD GetShape() CLASS TTetromino
RETURN ::aShape

// ============================================================================
// STATIC: Shape definitions (all 7 pieces × 4 rotations)
// ============================================================================

/*
Function: GetShapes (STATIC)
Purpose:
Returns the complete shape table: 7 pieces x 4 rotations,
each as a 4x4 array of 0/1 values.
Parameters:
(none)
Returns:
A -> 3D array [type][rotation][row][col]
*/
STATIC FUNCTION GetShapes()
   LOCAL aShapes := {}
   // I piece
   AAdd( aShapes, { ;
      { { 0,0,0,0 }, { 1,1,1,1 }, { 0,0,0,0 }, { 0,0,0,0 } }, ;
      { { 0,0,1,0 }, { 0,0,1,0 }, { 0,0,1,0 }, { 0,0,1,0 } }, ;
      { { 0,0,0,0 }, { 0,0,0,0 }, { 1,1,1,1 }, { 0,0,0,0 } }, ;
      { { 0,1,0,0 }, { 0,1,0,0 }, { 0,1,0,0 }, { 0,1,0,0 } } ;
   } )
   // J piece
   AAdd( aShapes, { ;
      { { 1,0,0,0 }, { 1,1,1,0 }, { 0,0,0,0 }, { 0,0,0,0 } }, ;
      { { 0,1,1,0 }, { 0,1,0,0 }, { 0,1,0,0 }, { 0,0,0,0 } }, ;
      { { 0,0,0,0 }, { 1,1,1,0 }, { 0,0,1,0 }, { 0,0,0,0 } }, ;
      { { 0,1,0,0 }, { 0,1,0,0 }, { 1,1,0,0 }, { 0,0,0,0 } } ;
   } )
   // L piece
   AAdd( aShapes, { ;
      { { 0,0,1,0 }, { 1,1,1,0 }, { 0,0,0,0 }, { 0,0,0,0 } }, ;
      { { 0,1,0,0 }, { 0,1,0,0 }, { 0,1,1,0 }, { 0,0,0,0 } }, ;
      { { 0,0,0,0 }, { 1,1,1,0 }, { 1,0,0,0 }, { 0,0,0,0 } }, ;
      { { 1,1,0,0 }, { 0,1,0,0 }, { 0,1,0,0 }, { 0,0,0,0 } } ;
   } )
   // O piece
   AAdd( aShapes, { ;
      { { 0,1,1,0 }, { 0,1,1,0 }, { 0,0,0,0 }, { 0,0,0,0 } }, ;
      { { 0,1,1,0 }, { 0,1,1,0 }, { 0,0,0,0 }, { 0,0,0,0 } }, ;
      { { 0,1,1,0 }, { 0,1,1,0 }, { 0,0,0,0 }, { 0,0,0,0 } }, ;
      { { 0,1,1,0 }, { 0,1,1,0 }, { 0,0,0,0 }, { 0,0,0,0 } } ;
   } )
   // S piece
   AAdd( aShapes, { ;
      { { 0,1,1,0 }, { 1,1,0,0 }, { 0,0,0,0 }, { 0,0,0,0 } }, ;
      { { 0,1,0,0 }, { 0,1,1,0 }, { 0,0,1,0 }, { 0,0,0,0 } }, ;
      { { 0,0,0,0 }, { 0,1,1,0 }, { 1,1,0,0 }, { 0,0,0,0 } }, ;
      { { 1,0,0,0 }, { 1,1,0,0 }, { 0,1,0,0 }, { 0,0,0,0 } } ;
   } )
   // T piece
   AAdd( aShapes, { ;
      { { 0,1,0,0 }, { 1,1,1,0 }, { 0,0,0,0 }, { 0,0,0,0 } }, ;
      { { 0,1,0,0 }, { 0,1,1,0 }, { 0,1,0,0 }, { 0,0,0,0 } }, ;
      { { 0,0,0,0 }, { 1,1,1,0 }, { 0,1,0,0 }, { 0,0,0,0 } }, ;
      { { 0,1,0,0 }, { 1,1,0,0 }, { 0,1,0,0 }, { 0,0,0,0 } } ;
   } )
   // Z piece
   AAdd( aShapes, { ;
      { { 1,1,0,0 }, { 0,1,1,0 }, { 0,0,0,0 }, { 0,0,0,0 } }, ;
      { { 0,0,1,0 }, { 0,1,1,0 }, { 0,1,0,0 }, { 0,0,0,0 } }, ;
      { { 0,0,0,0 }, { 1,1,0,0 }, { 0,1,1,0 }, { 0,0,0,0 } }, ;
      { { 0,1,0,0 }, { 1,1,0,0 }, { 1,0,0,0 }, { 0,0,0,0 } } ;
   } )
RETURN aShapes