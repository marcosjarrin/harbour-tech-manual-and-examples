/*
BadaSystem
Program       : tetris
Module        : tetris_game.prg
Compiler      : MINIGUI - Harbour Win32 GUI
Author        : Marcos Jarrín
Email         : marvijarrin@gmail.com
Website       : badasystem.com
Date          : 29/08/2026
Update        : 06/09/2026
Rev           : 1.0.1
SPDX-License-Identifier: MIT
Description:
Core game logic with customizable background colors.
Notes:
- Uses BT_ClientAreaInvalidateAll( "WinTetris" ) to force repaint.
- Background color stored in ::aBackColor and ::cBackStyle.
- ChangeBackColor() regenerates hBitmapBackground at runtime.
*/
#include "minigui.ch"
#include "hbclass.ch"

// ============================================================================
// HMG CONSTANTS
// ============================================================================
#ifndef BT_COPY
#define BT_COPY 0
#endif
#ifndef BT_HDC_BITMAP
#define BT_HDC_BITMAP 1
#endif
#ifndef BT_HDC_INVALIDCLIENTAREA
#define BT_HDC_INVALIDCLIENTAREA 3
#endif
#ifndef BT_TEXT_OPAQUE
#define BT_TEXT_OPAQUE 1
#endif
#ifndef BT_TEXT_BOLD
#define BT_TEXT_BOLD 16
#endif
#ifndef BT_TEXT_LEFT
#define BT_TEXT_LEFT 0
#endif
#ifndef BT_TEXT_TOP
#define BT_TEXT_TOP 0
#endif
#ifndef BT_TEXT_NORMAL_ORIENTATION
#define BT_TEXT_NORMAL_ORIENTATION 0
#endif

// ============================================================================
// CLASS DEFINITION
// ============================================================================

/*
Class: TTetrisGame
Purpose:
Encapsulates all Tetris game logic: board state, active
piece, scoring, rendering pipeline, and input handling.
Inherits:
(none)
Data:
aBoard           (A) -> 20x10 grid (0=empty, 1-7=color)
aBuffer          (A) -> Render buffer (board + active piece)
aCurrentPiece    (A) -> 4x4 shape of active tetromino
nRow, nCol       (N) -> Active piece position
nScore           (N) -> Current score
nLevel           (N) -> Current level
nLines           (N) -> Total lines cleared
nPieces          (N) -> Total pieces spawned
lPaused          (L) -> Pause state
lGameOver        (L) -> Game over flag
nBlockSize       (N) -> Pixel size of each cell (25)
nMaxRow, nMaxCol (N) -> Grid dimensions (20x10)
hBitmapBlock     (A) -> Array of 7 block bitmaps
hBitmapBackground(H) -> Background bitmap handle
hBitmapBuffer    (H) -> Double-buffer bitmap handle
aTetromino       (A) -> 7 pieces x 4 rotations shape data
nCurrentType     (N) -> Active piece type (1-7)
nCurrentRot      (N) -> Active piece rotation (1-4)
lInitialized     (L) -> Init complete flag
aBackColor       (A) -> Background RGB color
cBackStyle       (C) -> Background style ("SOLID")
Methods:
New()                  -> Constructor, sets defaults
Init()                 -> Creates bitmaps, starts game
Release()              -> Frees all bitmap resources
NewGame()              -> Resets state, spawns first piece
TogglePause()          -> Toggles pause, enables/disables timer
MovePiece(nDir)        -> Moves/rotates/drops piece (1-4)
OnPaint()              -> Draws buffer to window client area
Render()               -> Composites board+piece into buffer
CreateBitmaps()        -> Allocates block/bg/buffer bitmaps
InitTetrominoes()      -> Builds 7x4 rotation shape tables
SpawnNewPiece()        -> Random piece type + rotation
IsOccupied(nR,nC,aP)   -> Collision check against board/bounds
RemoveLines()          -> Clears full rows, returns count
RotatePiece()          -> Rotates with wall-kick fallback
RefreshStats()         -> Updates score/level/lines labels
ChangeBackColor(aC,cS) -> Runtime background color change
Notes:
- Piece types: 1=I, 2=J, 3=L, 4=O, 5=S, 6=T, 7=Z
- Scoring: lines^2 * 100 per drop
- Direction codes: 1=Left, 2=Right, 3=Rotate, 4=Down
*/
CLASS TTetrisGame
   DATA aBoard, aBuffer, aCurrentPiece
   DATA nRow, nCol
   DATA nScore, nLevel, nLines, nPieces
   DATA lPaused, lGameOver
   DATA nBlockSize, nMaxRow, nMaxCol
   DATA hBitmapBlock, hBitmapBackground, hBitmapBuffer
   DATA aTetromino
   DATA nCurrentType, nCurrentRot
   DATA lInitialized
   DATA aBackColor
   DATA cBackStyle

   METHOD New() CONSTRUCTOR
   METHOD Init()
   METHOD Release()
   METHOD NewGame()
   METHOD TogglePause()
   METHOD MovePiece( nDirection )
   METHOD OnPaint()
   METHOD Render()
   METHOD CreateBitmaps()
   METHOD InitTetrominoes()
   METHOD CreateArray2D( nH, nW )
   METHOD BitToArray( aDest, nValue, nColor )
   METHOD SpawnNewPiece()
   METHOD IsOccupied( nRow, nCol, aPiece )
   METHOD RemoveLines()
   METHOD PastePiece( aDest, nRow, nCol, aSrc )
   METHOD CopyPiece( aDest, aSrc )
   METHOD RotatePiece()
   METHOD IsTopReached()
   METHOD RefreshStats()
   METHOD ChangeBackColor( aColor, cStyle )
ENDCLASS

// ============================================================================
// METHOD IMPLEMENTATIONS
// ============================================================================

/*
Method: TTetrisGame:New
Purpose:
Constructor. Initializes grid dimensions, score counters,
game state flags, default background color, and allocates
empty 2D arrays for board, buffer, and current piece.
Parameters:
(none)
Returns:
Self
*/
METHOD New() CLASS TTetrisGame
   ::nMaxRow := 20
   ::nMaxCol := 10
   ::nBlockSize := 25
   ::nScore := 0
   ::nLevel := 1
   ::nLines := 0
   ::nPieces := 0
   ::lPaused := .T.
   ::lGameOver := .F.
   ::nRow := 1
   ::nCol := 4
   ::lInitialized := .F.
   ::aBackColor := {0,0,0}           // ✅ Default: Black
   ::cBackStyle := "SOLID"           // ✅ Default: Solid
   ::aBoard := ::CreateArray2D( ::nMaxRow, ::nMaxCol )
   ::aBuffer := ::CreateArray2D( ::nMaxRow, ::nMaxCol )
   ::aCurrentPiece := ::CreateArray2D( 4, 4 )
   ::InitTetrominoes()
RETURN Self

/*
Method: TTetrisGame:Init
Purpose:
Called from window ON INIT. Creates all bitmap resources
and starts a new game.
Parameters:
(none)
Returns:
NIL
*/
METHOD Init() CLASS TTetrisGame
   ::CreateBitmaps()
   ::NewGame()
   ::lInitialized := .T.
RETURN NIL

/*
Method: TTetrisGame:Release
Purpose:
Frees all BT_* bitmap handles to prevent memory leaks.
Called from window ON RELEASE.
Parameters:
(none)
Returns:
NIL
*/
METHOD Release() CLASS TTetrisGame
   LOCAL nI
   IF ::hBitmapBlock != NIL
      FOR nI := 1 TO 7
         IF ::hBitmapBlock[ nI ] != NIL
            BT_BitmapRelease( ::hBitmapBlock[ nI ] )
         ENDIF
      NEXT
   ENDIF
   IF ::hBitmapBackground != NIL
      BT_BitmapRelease( ::hBitmapBackground )
   ENDIF
   IF ::hBitmapBuffer != NIL
      BT_BitmapRelease( ::hBitmapBuffer )
   ENDIF
RETURN NIL

// ============================================================================
// ✅ CHANGE BACKGROUND COLOR IN RUNTIME
// ============================================================================

/*
Method: TTetrisGame:ChangeBackColor
Purpose:
Changes the background color at runtime. Releases the
old background bitmap and creates a new one with the
specified RGB color and style.
Parameters:
aColor (A) -> RGB array {r, g, b}
cStyle (C) -> Style string ("SOLID")
Returns:
NIL
*/
METHOD ChangeBackColor( aColor, cStyle ) CLASS TTetrisGame
   LOCAL hDC, BTstruct
   IF cStyle == NIL
      cStyle := "SOLID"
   ENDIF
   ::aBackColor := aColor
   ::cBackStyle := cStyle
   // Release previous funds
   IF ::hBitmapBackground != NIL
      BT_BitmapRelease( ::hBitmapBackground )
   ENDIF
   // Create a new background with the selected color
   ::hBitmapBackground := BT_BitmapCreateNew( ;
      ::nBlockSize * ::nMaxCol, ;
      ::nBlockSize * ::nMaxRow, ;
      ::aBackColor )
   // Refresh screen
   ::Render()
RETURN NIL

/*
Method: TTetrisGame:CreateBitmaps
Purpose:
Allocates all bitmap resources: 7 colored block bitmaps,
background bitmap, and double-buffer bitmap.
Parameters:
(none)
Returns:
NIL
*/
METHOD CreateBitmaps() CLASS TTetrisGame
   LOCAL nI, hDC, BTstruct
   LOCAL aColors := { {0,255,255}, {0,0,255}, {255,128,64}, {255,255,0}, {0,255,0}, {128,0,128}, {255,0,0} }
   ::hBitmapBlock := Array( 7 )
   FOR nI := 1 TO 7
      ::hBitmapBlock[ nI ] := BT_BitmapCreateNew( ::nBlockSize, ::nBlockSize, aColors[ nI ] )
      hDC := BT_CreateDC( ::hBitmapBlock[ nI ], BT_HDC_BITMAP, @BTstruct )
      BT_DrawRectangle( hDC, 0, 0, ::nBlockSize - 2, ::nBlockSize - 2, {255,255,255}, 1 )
      BT_DeleteDC( BTstruct )
   NEXT
   // ✅ Create a background with stored colors and styles
   ::hBitmapBackground := BT_BitmapCreateNew( ;
      ::nBlockSize * ::nMaxCol, ;
      ::nBlockSize * ::nMaxRow, ;
      ::aBackColor )
   ::hBitmapBuffer := BT_BitmapCreateNew( ;
      ::nBlockSize * ::nMaxCol, ;
      ::nBlockSize * ::nMaxRow, ;
      ::aBackColor )
RETURN NIL

/*
Method: TTetrisGame:InitTetrominoes
Purpose:
Builds the 7x4 rotation shape table from hex-encoded
bit patterns. Converts each 16-bit pattern into a 4x4
binary array with color index.
Parameters:
(none)
Returns:
NIL
*/
METHOD InitTetrominoes() CLASS TTetrisGame
   LOCAL _I := { 0x0F00, 0x2222, 0x00F0, 0x4444 }
   LOCAL _J := { 0x44C0, 0x8E00, 0x6440, 0x0E20 }
   LOCAL _L := { 0x4460, 0x0E80, 0xC440, 0x2E00 }
   LOCAL _O := { 0xCC00, 0xCC00, 0xCC00, 0xCC00 }
   LOCAL _S := { 0x06C0, 0x8C40, 0x6C00, 0x4620 }
   LOCAL _T := { 0x0E40, 0x4C40, 0x4E00, 0x4640 }
   LOCAL _Z := { 0x0C60, 0x4C80, 0xC600, 0x2640 }
   LOCAL nI, nK, aAux
   ::aTetromino := { _I, _J, _L, _O, _S, _T, _Z }
   FOR nI := 1 TO 7
      FOR nK := 1 TO 4
         aAux := ::CreateArray2D( 4, 4 )
         ::BitToArray( aAux, ::aTetromino[ nI ][ nK ], nI )
         ::aTetromino[ nI ][ nK ] := aAux
      NEXT
   NEXT
RETURN NIL

METHOD CreateArray2D( nH, nW ) CLASS TTetrisGame
   LOCAL aNew := Array( nH )
   LOCAL nI
   FOR nI := 1 TO nH
      aNew[ nI ] := Array( nW )
      AFill( aNew[ nI ], 0 )
   NEXT
RETURN aNew

METHOD BitToArray( aDest, nValue, nColor ) CLASS TTetrisGame
   LOCAL nX, nY, nBit := 15
   FOR nY := 1 TO 4
      FOR nX := 1 TO 4
         IF hb_bitTest( nValue, nBit )
            aDest[ nY ][ nX ] := nColor
         ELSE
            aDest[ nY ][ nX ] := 0
         ENDIF
         nBit--
      NEXT
   NEXT
RETURN NIL

/*
  ============================================================================
  Method: TTetrisGame:NewGame
  Purpose:
  Completely resets the game and starts a new game.

  F2 always reaches this method.

  Returns:
  NIL
  ============================================================================
 */
METHOD NewGame() CLASS TTetrisGame

   LOCAL nI

   /*
    * Reset score and statistics.
    */
   ::nScore  := 0
   ::nLevel  := 1
   ::nLines  := 0
   ::nPieces := 0

   /*
    * Reset game state.
    */
   ::lGameOver := .F.
   ::lPaused   := .F.

   /*
    * Clear the complete board.
    */
   FOR nI := 1 TO ::nMaxRow
      AFill( ::aBoard[ nI ], 0 )
   NEXT

   /*
    * Generate the first piece.
    */
   ::SpawnNewPiece()

   /*
    * Enable gravity again.
    */
   IF IsWindowDefined( "WinTetris" )

      SetProperty( ;
         "WinTetris", ;
         "Timer1", ;
         "Enabled", ;
         .T. )

      /*
       * Restore keyboard focus.
       */
      SetFocus( "WinTetris" )

   ENDIF

   /*
    * Render only after graphical initialization.
    */
   IF ::lInitialized
      ::Render()
   ENDIF

RETURN NIL


/*
  Method: TTetrisGame:TogglePause
  Purpose:
  Toggles pause/resume state.

  F5 behavior:

    Running -> Pause
    Paused  -> Resume
    Game Over -> Start a new game

  Returns:
  NIL
 */
METHOD TogglePause() CLASS TTetrisGame

   /*
    * If the game has ended, F5 starts a new game.
    */
   IF ::lGameOver

      ::NewGame()

      RETURN NIL

   ENDIF

   /*
    * Toggle pause state.
    */
   ::lPaused := !::lPaused

   /*
    * Synchronize the timer.
    */
   IF IsWindowDefined( "WinTetris" )

      SetProperty( ;
         "WinTetris", ;
         "Timer1", ;
         "Enabled", ;
         !::lPaused )

      /*
       * Make sure the game window receives the next keyboard event.
       */
      SetFocus( "WinTetris" )

   ENDIF

   /*
    * Refresh the display immediately.
    */
   IF ::lInitialized
      ::Render()
   ENDIF

RETURN NIL

/*
Method: TTetrisGame:SpawnNewPiece
Purpose:
Selects a random piece type (1-7) and rotation (1-4),
copies the shape to aCurrentPiece, and resets position
to top-center (row 1, col 4).
Parameters:
(none)
Returns:
NIL
*/
METHOD SpawnNewPiece() CLASS TTetrisGame
   ::nCurrentType := hb_RandomInt( 1, 7 )
   ::nCurrentRot  := hb_RandomInt( 1, 4 )
   ::CopyPiece( ::aCurrentPiece, ::aTetromino[ ::nCurrentType ][ ::nCurrentRot ] )
   ::nRow := 1
   ::nCol := 4
   ::nPieces++
RETURN NIL

/*
Method: TTetrisGame:MovePiece
Purpose:
Main input handler. Processes direction codes:
1=Left, 2=Right, 3=Rotate, 4=Down (gravity/drop).
On failed down-move: locks piece, clears lines, checks
game over, spawns next piece.
Parameters:
nDirection  (N) -> Direction code (1-4)
Returns:
NIL
Notes:
- Timer disabled when game over to prevent unnecessary calls
*/
METHOD MovePiece( nDirection ) CLASS TTetrisGame
   LOCAL lRepaint := .F.
   LOCAL nRemoveLines

   IF ::lGameOver .OR. ::lPaused
      RETURN
   ENDIF

   DO CASE
      CASE nDirection == 1
         IF !::IsOccupied( ::nRow, ::nCol - 1, ::aCurrentPiece )
            ::nCol--
            lRepaint := .T.
         ENDIF
      CASE nDirection == 2
         IF !::IsOccupied( ::nRow, ::nCol + 1, ::aCurrentPiece )
            ::nCol++
            lRepaint := .T.
         ENDIF
      CASE nDirection == 3
         ::RotatePiece()
         lRepaint := .T.
      CASE nDirection == 4
         IF !::IsOccupied( ::nRow + 1, ::nCol, ::aCurrentPiece )
            ::nRow++
            lRepaint := .T.
         ELSE
            ::PastePiece( ::aBoard, ::nRow, ::nCol, ::aCurrentPiece )
            nRemoveLines := ::RemoveLines()
            ::nScore += nRemoveLines ^ 2 * 100
            ::nLines += nRemoveLines

            IF ::IsTopReached()
               ::lGameOver := .T.
               // ✅ Stop timer when game over is detected
               IF IsWindowDefined( "WinTetris" )
                  SetProperty( "WinTetris", "Timer1", "Enabled", .F. )
               ENDIF
            ELSE
               ::SpawnNewPiece()
               IF ::IsOccupied( ::nRow, ::nCol, ::aCurrentPiece )
                  ::lGameOver := .T.
                  // ✅ Detener timer al detectar game over
                  IF IsWindowDefined( "WinTetris" )
                     SetProperty( "WinTetris", "Timer1", "Enabled", .F. )
                  ENDIF
               ENDIF
            ENDIF
            lRepaint := .T.
         ENDIF
   ENDCASE

   IF lRepaint
      ::Render()
   ENDIF
RETURN NIL

/*
Method: TTetrisGame:RotatePiece
Purpose:
Advances rotation by 90 degrees. If the new rotation
causes a collision, reverts to the previous rotation
(basic wall-kick).
Parameters:
(none)
Returns:
NIL
*/
METHOD RotatePiece() CLASS TTetrisGame
   LOCAL aAux := ::CreateArray2D( 4, 4 )
   ::nCurrentRot++
   IF ::nCurrentRot > 4
      ::nCurrentRot := 1
   ENDIF
   ::CopyPiece( aAux, ::aTetromino[ ::nCurrentType ][ ::nCurrentRot ] )
   IF !::IsOccupied( ::nRow, ::nCol, aAux )
      ::CopyPiece( ::aCurrentPiece, aAux )
   ELSE
      ::nCurrentRot--
      IF ::nCurrentRot < 1
         ::nCurrentRot := 4
      ENDIF
   ENDIF
RETURN NIL

/*
Method: TTetrisGame:IsOccupied
Purpose:
Checks if a piece shape at a given position overlaps
with locked blocks or exceeds grid boundaries.
Parameters:
nRow   (N) -> Test row position
nCol   (N) -> Test column position
aPiece (A) -> 4x4 shape array
Returns:
L -> .T. if collision detected
*/
METHOD IsOccupied( nRow, nCol, aPiece ) CLASS TTetrisGame
   LOCAL nX, nY, nY2, nX2
   FOR nY := 1 TO 4
      FOR nX := 1 TO 4
         IF aPiece[ nY ][ nX ] > 0
            nY2 := nRow + nY - 1
            nX2 := nCol + nX - 1
            IF nX2 < 1 .OR. nX2 > ::nMaxCol .OR. nY2 < 1 .OR. nY2 > ::nMaxRow
               RETURN .T.
            ENDIF
            IF ::aBoard[ nY2 ][ nX2 ] > 0
               RETURN .T.
            ENDIF
         ENDIF
      NEXT
   NEXT
RETURN .F.

/*
Method: TTetrisGame:IsTopReached
Purpose:
Returns .T. if any cell in row 1 is occupied (game over).
Parameters:
(none)
Returns:
L -> .T. if top row has blocks
*/
METHOD IsTopReached() CLASS TTetrisGame
   LOCAL nX
   FOR nX := 1 TO ::nMaxCol
      IF ::aBoard[ 1 ][ nX ] > 0
         RETURN .T.
      ENDIF
   NEXT
RETURN .F.

/*
Method: TTetrisGame:RemoveLines
Purpose:
Scans all rows for complete lines. Shifts rows above
downward to fill gaps. Returns the number of lines cleared.
Parameters:
(none)
Returns:
N -> Number of lines cleared
*/
METHOD RemoveLines() CLASS TTetrisGame
   LOCAL nLines := 0
   LOCAL nY, nY2, nX, nCont
   FOR nY := 1 TO ::nMaxRow
      nCont := 0
      FOR nX := 1 TO ::nMaxCol
         IF ::aBoard[ nY ][ nX ] > 0
            nCont++
         ENDIF
      NEXT
      IF nCont == ::nMaxCol
         FOR nY2 := nY TO 2 STEP -1
            FOR nX := 1 TO ::nMaxCol
               ::aBoard[ nY2 ][ nX ] := ::aBoard[ nY2 - 1 ][ nX ]
            NEXT
         NEXT
         nLines++
      ENDIF
   NEXT
RETURN nLines

METHOD PastePiece( aDest, nRow, nCol, aSrc ) CLASS TTetrisGame
   LOCAL nX, nY
   FOR nY := 1 TO 4
      FOR nX := 1 TO 4
         IF aSrc[ nY ][ nX ] > 0
            IF nRow + nY - 1 >= 1 .AND. nRow + nY - 1 <= ::nMaxRow
               IF nCol + nX - 1 >= 1 .AND. nCol + nX - 1 <= ::nMaxCol
                  aDest[ nRow + nY - 1 ][ nCol + nX - 1 ] := aSrc[ nY ][ nX ]
               ENDIF
            ENDIF
         ENDIF
      NEXT
   NEXT
RETURN NIL

METHOD CopyPiece( aDest, aSrc ) CLASS TTetrisGame
   LOCAL nX, nY
   FOR nY := 1 TO 4
      FOR nX := 1 TO 4
         aDest[ nY ][ nX ] := aSrc[ nY ][ nX ]
      NEXT
   NEXT
RETURN NIL

/*
Method: TTetrisGame:Render
Purpose:
Composites the board and active piece into aBuffer,
draws all colored blocks onto hBitmapBuffer using
BT_BitmapPaste, overlays game-over text if needed,
updates stats labels, and invalidates the window.
Parameters:
(none)
Returns:
NIL
*/
METHOD Render() CLASS TTetrisGame
   LOCAL nX, nY, nColor

   // 1. Copy board to buffer
   FOR nY := 1 TO ::nMaxRow
      FOR nX := 1 TO ::nMaxCol
         ::aBuffer[ nY ][ nX ] := ::aBoard[ nY ][ nX ]
      NEXT
   NEXT

   // 2. Pegar pieza activa
   ::PastePiece( ::aBuffer, ::nRow, ::nCol, ::aCurrentPiece )

   // 3. Draw background
   BT_BitmapPaste( ::hBitmapBuffer, NIL, NIL, NIL, NIL, BT_COPY, ::hBitmapBackground )

   // 4. Draw blocks
   FOR nY := 1 TO ::nMaxRow
      FOR nX := 1 TO ::nMaxCol
         nColor := ::aBuffer[ nY ][ nX ]
         IF nColor > 0
            BT_BitmapPaste( ::hBitmapBuffer, ( nY - 1 ) * ::nBlockSize, ( nX - 1 ) * ::nBlockSize, ;
               ::nBlockSize, ::nBlockSize, BT_COPY, ::hBitmapBlock[ nColor ] )
         ENDIF
      NEXT
   NEXT

   // 5. Update statistics
   ::RefreshStats()

   // 6. Force repaint
   IF IsWindowDefined( "WinTetris" )
      BT_ClientAreaInvalidateAll( "WinTetris" )
   ENDIF

RETURN NIL


/*
Method: TTetrisGame:OnPaint
Purpose:
Window paint handler. Draws the pre-rendered
hBitmapBuffer onto the window client area, centered
horizontally with a 10px top margin.
Parameters:
(none)
Returns:
NIL
*/
METHOD OnPaint() CLASS TTetrisGame

   LOCAL hDC
   LOCAL BTstruct
   LOCAL nX
   LOCAL nY
   LOCAL nWidth
   LOCAL nHeight
   LOCAL nBoardWidth
   LOCAL nBoardHeight

   IF ! ::lInitialized
      RETURN NIL
   ENDIF

   IF ! IsWindowDefined( "WinTetris" )
      RETURN NIL
   ENDIF

   /*
    * Get client area dimensions.
    */
   nWidth  := BT_ClientAreaWidth( "WinTetris" )
   nHeight := BT_ClientAreaHeight( "WinTetris" )

   /*
    * Calculate board dimensions.
    */
   nBoardWidth  := ::nBlockSize * ::nMaxCol
   nBoardHeight := ::nBlockSize * ::nMaxRow

   /*
    * Center the board horizontally.
    */
   nX := Int( ( nWidth - nBoardWidth ) / 2 )

   /*
    * Keep the board below the menu/client top.
    */
   nY := 10

   IF nX < 0
      nX := 0
   ENDIF

   /*
    * Create DC for the actual WinTetris client area.
    */
   hDC := BT_CreateDC( ;
      "WinTetris", ;
      BT_HDC_INVALIDCLIENTAREA, ;
      @BTstruct )

   /*
    * Draw the complete game buffer.
    */
   BT_DrawBitmap( ;
      hDC, ;
      nY, ;
      nX, ;
      NIL, ;
      NIL, ;
      BT_COPY, ;
      ::hBitmapBuffer )

   /*
    * Draw GAME OVER directly on the window.
    *
    * IMPORTANT:
    * Coordinates are now WINDOW coordinates,
    * not bitmap coordinates.
    */
   IF ::lGameOver

      BT_DrawText( ;
         hDC, ;
         nY + Int( nBoardHeight / 2 ) - 15, ;
         nX + Int( nBoardWidth / 2 ) - 60, ;
         "GAME OVER", ;
         "Times New Roman", ;
         18, ;
         {255,0,0}, ;
         ::aBackColor, ;
         BT_TEXT_OPAQUE + BT_TEXT_BOLD, ;
         BT_TEXT_LEFT + BT_TEXT_TOP, ;
         BT_TEXT_NORMAL_ORIENTATION )

   ENDIF

   /*
    * Release DC.
    */
   BT_DeleteDC( BTstruct )

RETURN NIL

/*
Method: TTetrisGame:RefreshStats
Purpose:
Updates the three LABEL controls (score, level, lines)
via SetProperty() with string window/control names.
Parameters:
(none)
Returns:
NIL
*/
METHOD RefreshStats() CLASS TTetrisGame
   IF IsWindowDefined( "WinTetris" )
      SetProperty( "WinTetris", "lblScore", "Value", ;
         T( "label.score" ) + ": " + hb_ntos( ::nScore ) )
      SetProperty( "WinTetris", "lblLevel", "Value", ;
         T( "label.level" ) + ": " + hb_ntos( ::nLevel ) )
      SetProperty( "WinTetris", "lblLines", "Value", ;
         T( "label.lines" ) + ": " + hb_ntos( ::nLines ) )
   ENDIF
RETURN NIL
