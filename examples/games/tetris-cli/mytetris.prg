/*
BadaSystem
Program       : mytetris
Module        : mytetris.prg
Compiler      : Harbour
Compiler-C    : BCC 32 bit
Author        : My CIS-ID: 100604,1637 Phil-Clipper
Author-Update : Marcos Jarrín-Harbour
Email         : marvijarrin@gmail.com
Website       : badasystem.com
Date          : 18/09/2026
Update        : 20/09/2026
Rev           : 1.00
SPDX-License-Identifier: MIT

Description:
Modern Tetris game with config.json, WAV sound effects (Windows API),
blink animation on line clear, and ghost piece. Full i18n support (EN/ES).

*/

#include "minigui.ch"
#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "fileio.ch"

// Windows API for real WAV sound playback
#pragma BEGINDUMP
#include <windows.h>
#include <hbapi.h>

HB_FUNC( PLAYWAVFILE )
{
   PlaySoundA( hb_parc( 1 ), NULL, SND_FILENAME | SND_ASYNC | SND_NODEFAULT );
}

#pragma ENDDUMP

// Constants - Window dimensions
#define WIN_UP                  2
#define WIN_LEFT                17
#define BD_HEIGHT               20
#define BD_WIDTH                20
#define ST_WIDTH                23
#define N_ROW_TEXT              WIN_UP + 2
#define N_COL_TEXT              WIN_LEFT + BD_WIDTH + 3
#define N_COL_SCORE             N_COL_TEXT + 12
#define N_LEN_DISP              ST_WIDTH - 13
#define N_NEXT_BLOCK_ROW        WIN_UP + 8

// Game states
#define N_GAME_OVER             1
#define N_PLAYING               2
#define N_PAUSED                3

// Visual elements
#define C_ELEMENT               Chr( 219 ) + Chr( 219 )
#define C_GHOST_ELEMENT         Chr( 176 ) + Chr( 176 )
#define N_EMPTY                 0
#define N_BORDURE               -1
#define C_MASK                  Replicate( Chr( 177 ) + Chr( 113 ), 9 )
#define C_BOARD_CLR             'N'
#define C_FILE_NAME             'MYTETRIS.INI'
#define C_DATA_FOLDER           'data'

// Helper macro
#define NPADL( nVal )           PadR( LTrim( Str( nVal ) ), N_LEN_DISP )

// Static variables (ALL at the top - E0004 prevention)
STATIC hConfig := { => }
STATIC hLang := { => }
STATIC cCurrentLang := "EN"

/*
Procedure: Main
Purpose:
Mandatory entry point for the executable.
CRITICAL: The Harbour linker strictly requires this exact name (Main).
Parameters:
(none)
Returns:
NIL
Notes:
Initializes configuration, language system, and starts game.
Creates data folder and initial high score file if missing.
*/
PROCEDURE Main()
   LOCAL cConfigFile := "config.json"
   
   SetMode( 28, 80 )
   
   // Load configuration from JSON
   IF File( cConfigFile )
      hConfig := LoadConfig( cConfigFile )
   ELSE
      hConfig := DefaultConfig()
   ENDIF
   
   // Ensure data folder and initial high score file exist
   EnsureDataFolder()
   
   SetLanguage( "EN" )
   MyTetris()
   RETURN

/*
Procedure: EnsureDataFolder
Purpose:
Create the data folder and initialize MYTETRIS.INI if it doesn't exist.
Parameters:
(none)
Returns:
NIL
Notes:
Creates file with value "0" if missing, ensuring it exists from first run.
*/
STATIC PROCEDURE EnsureDataFolder()
   LOCAL cDataPath := "\"+CurDir() + "\" + C_DATA_FOLDER
   LOCAL cSaveFile := cDataPath + "\" + C_FILE_NAME

   //? C_DATA_FOLDER
   //? cDataPath
   //wait

   // Create data folder if it doesn't exist
   IF !IsDir( cDataPath )
      DirMake( cDataPath )
   ENDIF

   // Create initial high score file if it doesn't exist
   IF !File( cSaveFile )
      hb_MemoWrit( cSaveFile, "0", .F. )
   ENDIF

   RETURN

/*
Function: LoadConfig
Purpose:
Load and parse configuration from JSON file using zero-dependency parser.
Parameters:
cFile (C) -> Config file path
Returns:
H -> Configuration hash
Notes:
Uses ParseJsonDictionary() - no hbjson.ch dependency.
*/
STATIC FUNCTION LoadConfig( cFile )
   LOCAL cJson := MemoRead( cFile )
   LOCAL hConfig := { => }
   
   IF !Empty( cJson )
      hConfig := ParseJsonDictionary( cJson )
   ENDIF
   
   RETURN hConfig

/*
Function: DefaultConfig
Purpose:
Return default configuration if JSON not found.
Returns:
H -> Default config hash
Notes:
Ensures game works even without config.json file.
*/
STATIC FUNCTION DefaultConfig()
   LOCAL hConfig := { => }
   
   hConfig[ "game.initial_wait" ]     := 1100
   hConfig[ "game.time_per_level" ]   := 100
   hConfig[ "game.blocks_per_level" ] := 25
   hConfig[ "game.points_per_line" ]  := 5
   hConfig[ "game.points_per_block" ] := 1
   hConfig[ "game.level_add_blocks" ] := 3
   hConfig[ "game.min_level" ]        := 1
   hConfig[ "game.initial_max_blocks" ] := 7
   
   hConfig[ "visual.blink_enabled" ] := .T.
   hConfig[ "visual.blink_count" ]   := 3
   hConfig[ "visual.blink_delay" ]   := 150
   hConfig[ "visual.ghost_enabled" ] := .T.
   
   hConfig[ "audio.enabled" ] := .T.
   hConfig[ "audio.volume" ]  := 80
   hConfig[ "audio.sounds.rotate" ] := "sounds/rotate.wav"
   hConfig[ "audio.sounds.move" ]   := "sounds/move.wav"
   hConfig[ "audio.sounds.drop" ]   := "sounds/drop.wav"
   hConfig[ "audio.sounds.clear" ]  := "sounds/clear.wav"
   hConfig[ "audio.sounds.gameover" ] := "sounds/gameover.wav"
   
   RETURN hConfig

/*
Function: GetConfig
Purpose:
Get configuration value with dot notation.
Parameters:
cPath (C) -> Path like "game.initial_wait"
xDefault (X) -> Default value if not found
Returns:
X -> Configuration value
Notes:
Uses hb_HHasKey() to prevent BASE/1132 on empty hashes.
*/
STATIC FUNCTION GetConfig( cPath, xDefault )
   LOCAL xValue := xDefault
   
   IF hb_HHasKey( hConfig, cPath )
      xValue := hConfig[ cPath ]
   ENDIF
   
   RETURN xValue

/*
Procedure: PlaySound
Purpose:
Play a sound effect. Uses Windows API for WAV files, falls back to Tone().
Parameters:
cSoundKey (C) -> Sound key from config (rotate, move, etc.)
Notes:
If WAV file exists, uses PlayWavFile() (Windows PlaySoundA).
Otherwise, falls back to PC speaker Tone() for compatibility.
*/
STATIC PROCEDURE PlaySound( cSoundKey )
   LOCAL lEnabled := GetConfig( "audio.enabled", .T. )
   LOCAL cSoundFile := ""
   
   IF !lEnabled
      RETURN
   ENDIF
   
   cSoundFile := GetConfig( "audio.sounds." + cSoundKey, "" )
   
   // Try to play real WAV file first
   IF !Empty( cSoundFile ) .AND. File( cSoundFile )
      PlayWavFile( cSoundFile )
   ELSE
      // Fallback to PC speaker Tone() if WAV file is missing
      DO CASE
         CASE cSoundKey == "rotate"
            Tone( 800, 0.05 )
         CASE cSoundKey == "move"
            Tone( 600, 0.03 )
         CASE cSoundKey == "drop"
            Tone( 400, 0.10 )
         CASE cSoundKey == "clear"
            Tone( 1200, 0.10 )
            hb_IdleSleep( 0.05 )
            Tone( 1600, 0.10 )
         CASE cSoundKey == "gameover"
            Tone( 800, 0.20 )
            hb_IdleSleep( 0.10 )
            Tone( 600, 0.20 )
            hb_IdleSleep( 0.10 )
            Tone( 400, 0.40 )
      ENDCASE
   ENDIF
   
   RETURN

/*
Procedure: BlinkLines
Purpose:
Create blink effect when lines are cleared.
Parameters:
aBoard (A) -> Game board
nLines (N) -> Number of lines cleared
nTopRow (N) -> Top row of cleared lines
Notes:
Configurable via config.json (blink_count, blink_delay, blink_enabled).
*/
STATIC PROCEDURE BlinkLines( aBoard, nLines, nTopRow )
   LOCAL nBlinkCount := GetConfig( "visual.blink_count", 3 )
   LOCAL nBlinkDelay := GetConfig( "visual.blink_delay", 150 )
   LOCAL lEnabled := GetConfig( "visual.blink_enabled", .T. )
   LOCAL i, j, nRow, nCol
   
   IF !lEnabled
      RETURN
   ENDIF
   
   FOR i := 1 TO nBlinkCount * 2
      DispBegin()
      
      FOR j := 1 TO nLines
         nRow := nTopRow + j - 1
         
         IF i % 2 == 1
            SetColor( "W+/N" )
         ELSE
            SetColor( "N/N" )
         ENDIF
         
         FOR nCol := 2 TO BD_WIDTH STEP 2
            IF aBoard[ nRow, nCol ] != N_EMPTY
               @ WIN_UP + nRow, WIN_LEFT + nCol - 1 SAY C_ELEMENT
            ENDIF
         NEXT
      NEXT
      
      DispEnd()
      hb_IdleSleep( nBlinkDelay / 1000 )
   NEXT
   
   RETURN

/*
Function: MyTetris
Purpose:
Main game loop - follows HandleInput/Update/Render pattern.
Parameters:
(none)
Returns:
NIL
Notes:
Architectural separation: Input -> Update -> Render per frame.
*/
FUNCTION MyTetris()
   LOCAL nKey
   LOCAL wHK
   LOCAL lLoop := .T.
   LOCAL aEnv := MakeEnvWin()
   LOCAL hState := CreateGameState()
   
   wHK := LastKey()
   IF wHK == 0
      wHK := 9999
   ENDIF
   
   DO WHILE lLoop
      nKey := InKey( 0.01, INKEY_KEYBOARD )
      lLoop := HandleInput( hState, nKey, wHK )
      
      DispBegin()
      UpdateGame( hState )
      RenderGame( hState )
      DispEnd()
   ENDDO
   
   RestEnv( aEnv, hState )
   
   RETURN NIL

/*
Function: HandleInput
Purpose:
Process keyboard input and update game state.
Parameters:
hState (H) -> Game state hash
nKey (N) -> Key code
wHK (N) -> Hotkey to exit
Returns:
L -> .T. to continue, .F. to exit
Notes:
ONLY sets flags - does NOT perform drawing operations.
*/
STATIC FUNCTION HandleInput( hState, nKey, wHK )
   LOCAL lContinue := .T.
   
   DO CASE
      CASE nKey == K_ESC .OR. nKey == wHK
         lContinue := .F.

      CASE nKey == K_F2
         ToggleLanguage()
         FullUIRebuild( hState )

      CASE nKey == K_ENTER
         InitGame( hState )

      CASE hState[ "nGame" ] != N_GAME_OVER
         DO CASE
         CASE hState[ "nGame" ] == N_PAUSED .AND. nKey != 0
            hState[ "nGame" ] := N_PLAYING

         CASE nKey == K_SPACE
            hState[ "nGame" ] := N_PAUSED

         CASE nKey == K_UP
            hState[ "lRotateRequested" ] := .T.

         CASE nKey == K_LEFT .OR. nKey == K_RIGHT
            hState[ "lMoveRequested" ] := .T.
            hState[ "nMoveDirection" ] := IF( nKey == K_LEFT, -2, 2 )

         CASE nKey == K_DOWN
            hState[ "lDropRequested" ] := .T.
         ENDCASE
   ENDCASE
   
   RETURN lContinue

/*
Procedure: ProcessRotation
Purpose:
Handle piece rotation with collision check.
Parameters:
hState (H) -> Game state hash
Returns:
NIL
Notes:
Original proven logic: rotate and revert on collision.
*/
STATIC PROCEDURE ProcessRotation( hState )
   LOCAL aPrevBlock
   
   IF !hb_HHasKey( hState, "lRotateRequested" ) .OR. !hState[ "lRotateRequested" ]
      RETURN
   ENDIF
   
   hState[ "lRotateRequested" ] := .F.
   
   EraseGhostPiece( hState )
   DrawBlock( hState[ "aCurBlock" ], hState[ "aColor" ], hState, .F. )
   
   // Save state before rotation
   aPrevBlock := AClone( hState[ "aCurBlock" ] )
   
   // Rotate
   hState[ "aCurBlock" ] := RotateBlock( hState[ "aCurBlock" ], hState, K_LEFT )
   
   // If collision, revert to previous state
   IF HitBlock( hState[ "aBoard" ], hState[ "aCurBlock" ], hState )
      hState[ "aCurBlock" ] := aPrevBlock
   ELSE
      PlaySound( "rotate" )
   ENDIF
   
   DrawBlock( hState[ "aCurBlock" ], hState[ "aColor" ], hState, .T. )
   
   RETURN

/*
Procedure: ProcessMovement
Purpose:
Handle horizontal movement.
Parameters:
hState (H) -> Game state hash
Returns:
NIL
*/
STATIC PROCEDURE ProcessMovement( hState )
   IF !hb_HHasKey( hState, "lMoveRequested" ) .OR. !hState[ "lMoveRequested" ]
      RETURN
   ENDIF
   
   hState[ "lMoveRequested" ] := .F.
   
   EraseGhostPiece( hState )
   DrawBlock( hState[ "aCurBlock" ], hState[ "aColor" ], hState, .F. )
   hState[ "nBlockCol" ] += hState[ "nMoveDirection" ]
   IF HitBlock( hState[ "aBoard" ], hState[ "aCurBlock" ], hState )
      hState[ "nBlockCol" ] -= hState[ "nMoveDirection" ]
   ELSE
      PlaySound( "move" )
   ENDIF
   DrawBlock( hState[ "aCurBlock" ], hState[ "aColor" ], hState, .T. )
   
   RETURN

/*
Procedure: ApplyGravity
Purpose:
Move piece down.
Parameters:
hState (H) -> Game state hash
Returns:
NIL
*/
STATIC PROCEDURE ApplyGravity( hState )
   EraseGhostPiece( hState )
   DrawBlock( hState[ "aCurBlock" ], hState[ "aColor" ], hState, .F. )
   hState[ "nBlockRow" ]++
   
   IF HitBlock( hState[ "aBoard" ], hState[ "aCurBlock" ], hState )
      hState[ "nBlockRow" ]--
      DrawBlock( hState[ "aCurBlock" ], hState[ "aColor" ], hState, .T. )
      PlaceBlock( hState )
      hState[ "lDropRequested" ] := .F.
   ELSE
      DrawBlock( hState[ "aCurBlock" ], hState[ "aColor" ], hState, .T. )
      IF hState[ "lDropRequested" ]
         PlaySound( "drop" )
      ENDIF
   ENDIF
   
   RETURN

/*
Procedure: UpdateGame
Purpose:
Update game logic.
Parameters:
hState (H) -> Game state hash
Returns:
NIL
*/
STATIC PROCEDURE UpdateGame( hState )
   IF hState[ "nGame" ] != N_PLAYING
      RETURN
   ENDIF
   
   ProcessRotation( hState )
   ProcessMovement( hState )
   
   IF GetConfig( "visual.ghost_enabled", .T. )
      DrawGhostPiece( hState )
   ENDIF
   
   IF hState[ "lDropRequested" ] .OR. TicTac( hState[ "nCurWait" ], hState[ "nInitTik" ] )
      ApplyGravity( hState )
      hState[ "nInitTik" ] := Seconds()
   ENDIF
   
   RETURN

/*
Procedure: RenderGame
Purpose:
Render game elements.
Parameters:
hState (H) -> Game state hash
Returns:
NIL
*/
STATIC PROCEDURE RenderGame( hState )
   DispScore( hState )
   RETURN

/*
Procedure: EraseGhostPiece
Purpose:
Erase ghost piece by drawing black spaces.
Parameters:
hState (H) -> Game state hash
Returns:
NIL
Notes:
Uses "N/N" color (black on black) to hide previous ghost.
*/
STATIC PROCEDURE EraseGhostPiece( hState )
   LOCAL i, j
   LOCAL nGhostRow, nGhostCol
   
   IF !hb_HHasKey( hState, "nGhostRow" )
      RETURN
   ENDIF
   
   nGhostRow := hState[ "nGhostRow" ]
   nGhostCol := hState[ "nGhostCol" ]
   
   IF nGhostRow == hState[ "nBlockRow" ] .AND. nGhostCol == hState[ "nBlockCol" ]
      RETURN
   ENDIF
   
   SetColor( "N/N" )
   
   FOR i := 0 TO hState[ "nBlockSize" ] - 1
      FOR j := 0 TO hState[ "nBlockSize" ] - 1
         IF hState[ "aCurBlock" ][ i * hState[ "nBlockSize" ] + j + 1 ]
            @ nGhostRow + WIN_UP + i + 1, ;
              nGhostCol + WIN_LEFT + j * 2 - 1 SAY "  "
         ENDIF
      NEXT
   NEXT
   
   RETURN

/*
Function: CalculateGhostRow
Purpose:
Calculate landing position for ghost piece.
Parameters:
hState (H) -> Game state hash
Returns:
N -> Ghost row position
*/
STATIC FUNCTION CalculateGhostRow( hState )
   LOCAL nGhostRow := hState[ "nBlockRow" ]
   LOCAL aTestBlock := AClone( hState[ "aCurBlock" ] )
   LOCAL nOriginalRow
   
   nOriginalRow := hState[ "nBlockRow" ]
   
   DO WHILE .T.
      nGhostRow++
      hState[ "nBlockRow" ] := nGhostRow
      IF HitBlock( hState[ "aBoard" ], aTestBlock, hState )
         nGhostRow--
         EXIT
      ENDIF
   ENDDO
   
   hState[ "nBlockRow" ] := nOriginalRow
   
   RETURN nGhostRow

/*
Procedure: DrawGhostPiece
Purpose:
Draw ghost piece at landing position.
Parameters:
hState (H) -> Game state hash
Returns:
NIL
*/
STATIC PROCEDURE DrawGhostPiece( hState )
   LOCAL i, j
   LOCAL nGhostRow
   LOCAL nOriginalRow
   
   IF hState[ "nGame" ] != N_PLAYING
      RETURN
   ENDIF
   
   nOriginalRow := hState[ "nBlockRow" ]
   nGhostRow := CalculateGhostRow( hState )
   
   IF nGhostRow == hState[ "nBlockRow" ]
      RETURN
   ENDIF
   
   hState[ "nGhostRow" ] := nGhostRow
   hState[ "nGhostCol" ] := hState[ "nBlockCol" ]
   
   SetColor( "W/N" )
   
   FOR i := 0 TO hState[ "nBlockSize" ] - 1
      FOR j := 0 TO hState[ "nBlockSize" ] - 1
         IF hState[ "aCurBlock" ][ i * hState[ "nBlockSize" ] + j + 1 ]
            @ nGhostRow + WIN_UP + i + 1, ;
              hState[ "nBlockCol" ] + WIN_LEFT + j * 2 - 1 SAY C_GHOST_ELEMENT
         ENDIF
      NEXT
   NEXT
   
   hState[ "nBlockRow" ] := nOriginalRow
   
   RETURN

/*
Function: CreateGameState
Purpose:
Create game state hash.
Parameters:
(none)
Returns:
H -> Game state
Notes:
High score path now points to project's data folder.
All state encapsulated in hash - zero globals.
*/
STATIC FUNCTION CreateGameState()
   LOCAL hState := { => }
   LOCAL cDataPath := CurDir() + "\" + C_DATA_FOLDER
   LOCAL cSaveFile := cDataPath + "\" + C_FILE_NAME
   
   hState[ "nGame" ]         := N_GAME_OVER
   hState[ "nScore" ]        := 0
   hState[ "nHighScore" ]    := 0
   hState[ "nInitScore" ]    := 0
   hState[ "nCountLines" ]   := 0
   hState[ "nCountBlocks" ]  := 0
   hState[ "nLevel" ]        := GetConfig( "game.min_level", 1 )
   hState[ "nCurWait" ]      := GetConfig( "game.initial_wait", 1100 )
   hState[ "nCurBlock" ]     := 0
   hState[ "nNextBlock" ]    := 0
   hState[ "nBlockSize" ]    := 0
   hState[ "nBlockRow" ]     := 0
   hState[ "nBlockCol" ]     := 0
   hState[ "nRandom" ]       := Int( Seconds() * 1000 )
   hState[ "nInitTik" ]      := 0
   hState[ "nMaxBlocks" ]    := GetConfig( "game.initial_max_blocks", 7 )
   
   hState[ "nGhostRow" ]     := -1
   hState[ "nGhostCol" ]     := -1
   
   hState[ "lDropRequested" ]    := .F.
   hState[ "lRotateRequested" ]  := .F.
   hState[ "lMoveRequested" ]    := .F.
   hState[ "nMoveDirection" ]    := 0
   
   // Store save path in state (project's data folder)
   hState[ "cSavePath" ]     := cDataPath
   hState[ "cSaveFile" ]     := cSaveFile
   
   hState[ "aBlocks" ] := CreateBlocks()
   hState[ "aBoard" ]  := Array( BD_HEIGHT + 1, BD_WIDTH + 3 )
   hState[ "aColor" ]  := { "W+", "G+", "GR+", "R+", "BG+", "B+", "RB+", ;
                            "RB", "B", "BG", "R", "GR", "G", "B" }
   hState[ "aCurBlock" ] := {}
   
   // Load high score from project's data folder
   // File is guaranteed to exist thanks to EnsureDataFolder()
   IF File( cSaveFile )
      hState[ "nHighScore" ] := Val( MemoRead( cSaveFile ) )
   ENDIF
   hState[ "nInitScore" ] := hState[ "nHighScore" ]
   
   RETURN hState

/*
Function: CreateBlocks
Purpose:
Create block shapes.
Parameters:
(none)
Returns:
A -> Array of blocks
*/
STATIC FUNCTION CreateBlocks()
   LOCAL aBlocks := {}
   
   AAdd( aBlocks, { .F., .T., .F., .F., ;
                    .F., .T., .F., .F., ;
                    .F., .T., .F., .F., ;
                    .F., .T., .F., .F. } )
   
   AAdd( aBlocks, { .F., .T., .T., ;
                    .F., .T., .F., ;
                    .F., .T., .F. } )
   
   AAdd( aBlocks, { .T., .T., .F., ;
                    .F., .T., .F., ;
                    .F., .T., .F. } )
   
   AAdd( aBlocks, { .F., .T., .F., ;
                    .T., .T., .T., ;
                    .F., .F., .F. } )
   
   AAdd( aBlocks, { .T., .T., .F., ;
                    .F., .T., .T., ;
                    .F., .F., .F. } )
   
   AAdd( aBlocks, { .F., .T., .T., ;
                    .T., .T., .F., ;
                    .F., .F., .F. } )
   
   AAdd( aBlocks, { .T., .T., .F., ;
                    .T., .T., .F., ;
                    .F., .F., .F. } )
   
   AAdd( aBlocks, { .F., .T., .T., ;
                    .F., .T., .F., ;
                    .F., .T., .T. } )
   
   AAdd( aBlocks, { .F., .T., .T., ;
                    .F., .T., .F., ;
                    .T., .T., .F. } )
   
   AAdd( aBlocks, { .F., .T., .T., ;
                    .F., .T., .T., ;
                    .F., .T., .F. } )
   
   AAdd( aBlocks, { .F., .T., .F., ;
                    .F., .T., .F., ;
                    .F., .T., .F. } )
   
   AAdd( aBlocks, { .T., .T., .F., ;
                    .F., .T., .T., ;
                    .F., .F., .T. } )
   
   AAdd( aBlocks, { .F., .T., .F., ;
                    .F., .T., .F., ;
                    .T., .T., .T. } )
   
   AAdd( aBlocks, { .F., .T., .F., ;
                    .T., .T., .F., ;
                    .F., .T., .T. } )
   
   RETURN aBlocks

/*
Function: MakeEnvWin
Purpose:
Create game window with proper initialization.
Parameters:
(none)
Returns:
A -> Environment array
*/
STATIC FUNCTION MakeEnvWin()
   LOCAL aEnv := Array( 5 )
   LOCAL aStatus := GetStatusArray()
   LOCAL nRow

   DispBegin()

   aEnv[ 1 ] := SaveScreen( 0, 0, MaxRow(), MaxCol() )
   aEnv[ 2 ] := SetCursor( SC_NONE )
   aEnv[ 3 ] := SetColor( "GR+/B" )
   aEnv[ 4 ] := Row()
   aEnv[ 5 ] := Col()

   // Title bar
   @ 0, 0 SAY PadC( T( "app.title" ) + " - " + LTrim( Str( Year( Date() ) ) ), MaxCol() + 1 )

   // Help text at bottom
   @ MaxRow(), 0 SAY PadC( "Esc:Exit  Enter:New  Sp:Pause  Up:Rotate  L/R:Move  Down:Down  F2:Lang", MaxCol() + 1 )

   // Clear game area with mask pattern
   RestScreen( 1, 0, MaxRow() - 1, MaxCol(), ;
               Replicate( C_MASK, ( ( MaxCol() + 1 ) * ( MaxRow() - 1 ) ) / 2 ) )

   // Draw shadow and borders
   SetColor( "BG/" + C_BOARD_CLR )
   Shadow( WIN_UP + 1, WIN_LEFT + 1, WIN_UP + BD_HEIGHT + 2, WIN_LEFT + BD_WIDTH + ST_WIDTH + 3 )
   @ WIN_UP, WIN_LEFT, WIN_UP + BD_HEIGHT + 1, ;
     WIN_LEFT + BD_WIDTH + ST_WIDTH + 2 BOX B_SINGLE + " "
   @ WIN_UP, WIN_LEFT, WIN_UP + BD_HEIGHT + 1, WIN_LEFT + BD_WIDTH + 1 BOX B_SINGLE
   @ WIN_UP, WIN_LEFT + BD_WIDTH + 1 SAY Chr( 218 )
   @ WIN_UP + BD_HEIGHT + 1, WIN_LEFT + BD_WIDTH + 1 SAY Chr( 192 )

   // Clear status panel with black background (labels + values area)
   SetColor( "N/N" )
   FOR nRow := 0 TO 14
      @ N_ROW_TEXT + nRow, N_COL_TEXT SAY Replicate( " ", ST_WIDTH - 2 )
   NEXT

   // Draw labels ONLY ONCE with explicit black background
   SetColor( "W+/N" )
   FOR nRow := 1 TO Len( aStatus )
      @ N_ROW_TEXT + aStatus[ nRow ][ 1 ], N_COL_TEXT SAY aStatus[ nRow ][ 2 ]
   NEXT

   // "Next:" label
   @ N_NEXT_BLOCK_ROW, N_COL_TEXT SAY T( "ui.next" )

   DispEnd()
   
   RETURN aEnv

/*
Procedure: RestEnv
Purpose:
Restore environment and ensure high score is saved.
Parameters:
aEnv (A) -> Environment
hState (H) -> Game state
Returns:
NIL
Always saves high score on exit as backup safety net.
*/
STATIC PROCEDURE RestEnv( aEnv, hState )

   hb_MemoWrit( "\"+hState[ "cSaveFile" ], LTrim( Str( hState[ "nHighScore" ] ) ) , .F. )
   
   RestScreen( 0, 0, MaxRow(), MaxCol(), aEnv[ 1 ] )
   SetCursor( aEnv[ 2 ] )
   SetColor( aEnv[ 3 ] )
   SetPos( aEnv[ 4 ], aEnv[ 5 ] )
   
   RETURN

/*
Procedure: FullUIRebuild
Purpose:
Completely rebuild the UI after language change.
Parameters:
hState (H) -> Game state hash
Returns:
NIL
Notes:
Redraws entire UI from scratch to avoid text overlap.
*/
STATIC PROCEDURE FullUIRebuild( hState )
   DispBegin()
   
   SetColor( "GR+/B" )
   @ 0, 0 SAY PadC( " ", MaxCol() + 1 )
   @ 0, 0 SAY PadC( T( "app.title" ) + " - " + LTrim( Str( Year( Date() ) ) ), MaxCol() + 1 )
   
   @ MaxRow(), 0 SAY PadC( " ", MaxCol() + 1 )
   @ MaxRow(), 0 SAY PadC( T( "help.exit" ) + "  " + T( "help.new" ) + "  " + ;
                           T( "help.pause" ) + "  " + T( "help.rotate" ) + "  " + ;
                           T( "help.move" ) + "  " + T( "help.down" ) + "  " + ;
                           T( "help.lang" ), MaxCol() + 1 )
   
   RestScreen( 1, 0, MaxRow() - 1, MaxCol(), ;
               Replicate( C_MASK, ( ( MaxCol() + 1 ) * ( MaxRow() - 1 ) ) / 2 ) )
   
   SetColor( "BG/" + C_BOARD_CLR )
   Shadow( WIN_UP + 1, WIN_LEFT + 1, WIN_UP + BD_HEIGHT + 2, WIN_LEFT + BD_WIDTH + ST_WIDTH + 3 )
   
   @ WIN_UP, WIN_LEFT, WIN_UP + BD_HEIGHT + 1, ;
     WIN_LEFT + BD_WIDTH + ST_WIDTH + 2 BOX B_SINGLE + " "
   @ WIN_UP, WIN_LEFT, WIN_UP + BD_HEIGHT + 1, WIN_LEFT + BD_WIDTH + 1 BOX B_SINGLE
   @ WIN_UP, WIN_LEFT + BD_WIDTH + 1 SAY Chr( 218 )
   @ WIN_UP + BD_HEIGHT + 1, WIN_LEFT + BD_WIDTH + 1 SAY Chr( 192 )
   
   SetColor( "W+/" + C_BOARD_CLR )
   AEval( GetStatusArray(), { |aStatus| ;
      SetPos( N_ROW_TEXT + aStatus[ 1 ], N_COL_TEXT ), ;
      QQOut( aStatus[ 2 ] ) } )
   
   @ N_NEXT_BLOCK_ROW, N_COL_TEXT SAY T( "ui.next" )
   
   DispScore( hState )
   
   IF hState[ "nGame" ] == N_PLAYING .OR. hState[ "nGame" ] == N_PAUSED
      DrawBlock( hState[ "aCurBlock" ], hState[ "aColor" ], hState, .T. )
   ENDIF
   
   DispEnd()
   
   RETURN

/*
Procedure: RefreshUI
Purpose:
Refresh all UI text after language change.
Parameters:
hState (H) -> Game state hash
Returns:
NIL
*/
STATIC PROCEDURE RefreshUI( hState )
   FullUIRebuild( hState )
   RETURN

/*
Function: GetStatusArray
Purpose:
Get status display array.
Parameters:
(none)
Returns:
A -> Status array
*/
STATIC FUNCTION GetStatusArray()
   RETURN { ;
      { 00, T( "ui.score" ),   "R/",   { |h| NPADL( h[ "nHighScore" ] ) } }, ;
      { 02, T( "ui.status" ),  "R/",   { |h| PadR( GetStatusText( h[ "nGame" ] ), N_LEN_DISP ) } }, ;
      { 04, T( "ui.result" ),  "R+/",  { |h| NPADL( h[ "nScore" ] ) } }, ;
      { 11, T( "ui.level" ),   "GR+/", { |h| NPADL( h[ "nLevel" ] ) } }, ;
      { 13, T( "ui.lines" ),   "G+/",  { |h| NPADL( h[ "nCountLines" ] ) } }, ;
      { 14, T( "ui.blocks" ),  "G+/",  { |h| NPADL( h[ "nCountBlocks" ] ) } }, ;
      { 15, T( "ui.speed" ),   "G+/",  { |h| NPADL( 1 + Int( ( GetConfig( "game.initial_wait", 1100 ) - h[ "nCurWait" ] ) / 100 ) ) } } ;
   }

/*
Function: GetStatusText
Purpose:
Get translated status text.
Parameters:
nGame (N) -> Game state code
Returns:
C -> Status text
*/
STATIC FUNCTION GetStatusText( nGame )
   LOCAL cText := ""
   LOCAL nState := 0
   
   IF ValType( nGame ) == "C"
      nState := Val( nGame )
   ELSEIF ValType( nGame ) == "N"
      nState := nGame
   ELSE
      RETURN T( "status.unknown" )
   ENDIF
   
   DO CASE
   CASE nState == N_GAME_OVER
      cText := T( "status.finished" )
   CASE nState == N_PLAYING
      cText := T( "status.playing" )
   CASE nState == N_PAUSED
      cText := T( "status.paused" )
   OTHERWISE
      cText := T( "status.unknown" )
   ENDCASE
   
   RETURN cText

/*
Procedure: DispScore
Purpose:
Display score and status.
Parameters:
hState (H) -> Game state
Returns:
NIL
*/
STATIC PROCEDURE DispScore( hState )
   LOCAL aStatus := GetStatusArray()
   
   AEval( aStatus, { |aItem| ;
      SetColor( aItem[ 3 ] + C_BOARD_CLR ), ;
      SetPos( N_ROW_TEXT + aItem[ 1 ], N_COL_SCORE ), ;
      QQOut( Eval( aItem[ 4 ], hState ) ) } )
   
   IF hState[ "nLevel" ] >= GetConfig( "game.level_add_blocks", 3 )
      DrawNextBlock( hState )
   ENDIF
   
   RETURN

/*
Procedure: InitGame
Purpose:
Initialize new game.
Parameters:
hState (H) -> Game state
Returns:
NIL
*/
STATIC PROCEDURE InitGame( hState )
   LOCAL i, j
   
   @ WIN_UP + 1, WIN_LEFT + 1 CLEAR TO WIN_UP + BD_HEIGHT, WIN_LEFT + BD_WIDTH
   
   FOR i := 1 TO BD_HEIGHT
      FOR j := 2 TO BD_WIDTH + 1
         hState[ "aBoard" ][ i, j ] := N_EMPTY
      NEXT
      hState[ "aBoard" ][ i, 1 ] := N_BORDURE
      hState[ "aBoard" ][ i, BD_WIDTH + 2 ] := N_BORDURE
      hState[ "aBoard" ][ i, BD_WIDTH + 3 ] := N_BORDURE
   NEXT
   
   hState[ "nGame" ]       := N_PLAYING
   hState[ "nCurWait" ]    := GetConfig( "game.initial_wait", 1100 )
   hState[ "nMaxBlocks" ]  := GetConfig( "game.initial_max_blocks", 7 )
   hState[ "nNextBlock" ]  := RandomBlock( hState, hState[ "nMaxBlocks" ] )
   hState[ "nScore" ]      := 0
   hState[ "nCountLines" ] := 0
   hState[ "nCountBlocks" ]:= 0
   hState[ "nLevel" ]      := GetConfig( "game.min_level", 1 )
   
   hState[ "nGhostRow" ]   := -1
   hState[ "nGhostCol" ]   := -1
   
   hState[ "lDropRequested" ]    := .F.
   hState[ "lRotateRequested" ]  := .F.
   hState[ "lMoveRequested" ]    := .F.
   hState[ "nMoveDirection" ]    := 0
   
   @ N_NEXT_BLOCK_ROW, N_COL_SCORE CLEAR TO N_NEXT_BLOCK_ROW + 3, N_COL_SCORE + 7
   NewBlock( hState )
   hState[ "nInitTik" ] := Seconds()
   
   RETURN

/*
Procedure: NewBlock
Purpose:
Create new block and save high score immediately when beaten.
Parameters:
hState (H) -> Game state
Returns:
NIL
Saves high score immediately when beaten, not just at game end.
*/
STATIC PROCEDURE NewBlock( hState )
   hState[ "nCurBlock" ]  := hState[ "nNextBlock" ]
   hState[ "nNextBlock" ] := RandomBlock( hState, hState[ "nMaxBlocks" ] )

   hState[ "nCountBlocks" ]++
   IF hState[ "nCountBlocks" ] % GetConfig( "game.blocks_per_level", 25 ) == 0 .AND. hState[ "nCurWait" ] > 0
      IF hState[ "nLevel" ]++ == GetConfig( "game.level_add_blocks", 3 )
         hState[ "nCurWait" ]   := GetConfig( "game.initial_wait", 1100 ) - GetConfig( "game.time_per_level", 100 )
         hState[ "nMaxBlocks" ] := Len( hState[ "aBlocks" ] )
      ELSE
         hState[ "nCurWait" ] -= GetConfig( "game.time_per_level", 100 )
      ENDIF
   ENDIF

   hState[ "nScore" ] += hState[ "nLevel" ] * GetConfig( "game.points_per_block", 1 )

   // Save immediately when high score is beaten
   IF hState[ "nScore" ] > hState[ "nHighScore" ]
      hState[ "nHighScore" ] := hState[ "nScore" ]
      // Save to file immediately
      hb_MemoWrit( hState[ "cSaveFile" ], LTrim( Str( hState[ "nHighScore" ] ) ), .F. )
   ENDIF
   
   hState[ "nBlockSize" ] := Int( Len( hState[ "aBlocks" ][ hState[ "nCurBlock" ] ] ) ^ 0.5 )
   hState[ "nBlockRow" ]  := 0
   hState[ "nBlockCol" ]  := BD_WIDTH / 2
   hState[ "aCurBlock" ]  := AClone( hState[ "aBlocks" ][ hState[ "nCurBlock" ] ] )
   
   hState[ "nGhostRow" ]  := -1
   hState[ "nGhostCol" ]  := -1
   
   IF HitBlock( hState[ "aBoard" ], hState[ "aCurBlock" ], hState )
      hState[ "nGame" ] := N_GAME_OVER
      PlaySound( "gameover" )
   ENDIF
   
   RETURN


/*
Procedure: DrawBlock
Purpose:
Draw block.
Parameters:
aCurBlock (A) -> Block
aColor (A) -> Colors
hState (H) -> State
lDraw (L) -> Draw flag
Returns:
NIL
*/
STATIC PROCEDURE DrawBlock( aCurBlock, aColor, hState, lDraw )
   LOCAL i, j
   
   SetColor( IF( lDraw, aColor[ hState[ "nCurBlock" ] ], 'I' ) )
   
   FOR i := 0 TO hState[ "nBlockSize" ] - 1
      FOR j := 0 TO hState[ "nBlockSize" ] - 1
         IF aCurBlock[ i * hState[ "nBlockSize" ] + j + 1 ]
            @ hState[ "nBlockRow" ] + WIN_UP + i + 1, ;
              hState[ "nBlockCol" ] + WIN_LEFT + j * 2 - 1 SAY C_ELEMENT
         ENDIF
      NEXT
   NEXT
   
   RETURN

/*
Procedure: DrawNextBlock
Purpose:
Draw next block preview.
Parameters:
hState (H) -> Game state
Returns:
NIL
*/
STATIC PROCEDURE DrawNextBlock( hState )
   LOCAL i, j, nSize
   LOCAL aNextBlock := hState[ "aBlocks" ][ hState[ "nNextBlock" ] ]
   
   SetColor( hState[ "aColor" ][ hState[ "nNextBlock" ] ] )
   nSize := Int( Len( aNextBlock ) ^ 0.5 )
   
   @ N_NEXT_BLOCK_ROW, N_COL_SCORE CLEAR TO N_NEXT_BLOCK_ROW + 3, N_COL_SCORE + 7
   
   FOR i := 0 TO nSize - 1
      FOR j := 0 TO nSize - 1
         IF aNextBlock[ i * nSize + j + 1 ]
            @ N_NEXT_BLOCK_ROW + i, N_COL_SCORE + j * 2 SAY C_ELEMENT
         ENDIF
      NEXT
   NEXT
   
   RETURN

/*
Function: RotateBlock
Purpose:
Rotate block and return the rotated array.
Parameters:
aCurBlock (A) -> Block
hState (H) -> State
nSens (N) -> Direction
Returns:
A -> Rotated block
Notes:
Arrays pass by value in Harbour - must return new array.
*/
STATIC FUNCTION RotateBlock( aCurBlock, hState, nSens )
   LOCAL i, j
   LOCAL aTmpBlock
   LOCAL nSize := hState[ "nBlockSize" ]
   
   DO CASE
   CASE nSize == 4
      aTmpBlock := Array( Len( aCurBlock ) )
      IF nSens == K_LEFT
         FOR i := 0 TO 3
            FOR j := 0 TO 3
               aTmpBlock[ i * 4 + j + 1 ] := aCurBlock[ j * 4 + i + 1 ]
            NEXT
         NEXT
      ELSE
         FOR i := 0 TO 3
            FOR j := 0 TO 3
               aTmpBlock[ j * 4 + i + 1 ] := aCurBlock[ i * 4 + j + 1 ]
            NEXT
         NEXT
      ENDIF
      aCurBlock := aTmpBlock
      
   CASE nSize == 3
      aTmpBlock := Array( Len( aCurBlock ) )
      IF nSens == K_LEFT
         FOR i := 0 TO 2
            FOR j := 0 TO 2
               aTmpBlock[ ( 2 - j ) * 3 + i + 1 ] := aCurBlock[ i * 3 + j + 1 ]
            NEXT
         NEXT
      ELSE
         FOR i := 0 TO 2
            FOR j := 0 TO 2
               aTmpBlock[ i * 3 + j + 1 ] := aCurBlock[ ( 2 - j ) * 3 + i + 1 ]
            NEXT
         NEXT
      ENDIF
      aCurBlock := aTmpBlock
   ENDCASE
   
   RETURN aCurBlock

/*
Function: HitBlock
Purpose:
Check collision with defensive bounds checking to prevent BASE/1132.
Parameters:
aBoard (A) -> Board
aCurBlock (A) -> Block
hState (H) -> State
Returns:
L -> Collision flag
Notes:
Added defensive bounds checking to prevent array access errors.
*/
STATIC FUNCTION HitBlock( aBoard, aCurBlock, hState )
   LOCAL i, j
   LOCAL nRow, nCol
   
   FOR i := 0 TO hState[ "nBlockSize" ] - 1
      FOR j := 0 TO hState[ "nBlockSize" ] - 1
         IF aCurBlock[ i * hState[ "nBlockSize" ] + j + 1 ]
            nRow := hState[ "nBlockRow" ] + i + 1
            nCol := hState[ "nBlockCol" ] + j * 2 + 1
            
            // Defensive bounds check to guarantee no BASE/1132 errors
            IF nRow < 1 .OR. nRow > (BD_HEIGHT + 1) .OR. nCol < 1 .OR. nCol > (BD_WIDTH + 2)
               RETURN .T. // Out of bounds is treated as a collision
            ENDIF
            
            IF aBoard[ nRow, nCol ] != N_EMPTY
               RETURN .T.
            ENDIF
         ENDIF
      NEXT
   NEXT
   
   RETURN .F.

/*
Procedure: PlaceBlock
Purpose:
Place block on board.
Parameters:
hState (H) -> State
Returns:
NIL
*/
STATIC PROCEDURE PlaceBlock( hState )
   LOCAL i, j, nLines := 0
   LOCAL nTopRow := 0
   
   FOR i := 0 TO hState[ "nBlockSize" ] - 1
      FOR j := 0 TO hState[ "nBlockSize" ] - 1
         IF hState[ "aCurBlock" ][ i * hState[ "nBlockSize" ] + j + 1 ]
            hState[ "aBoard" ][ hState[ "nBlockRow" ] + i + 1, hState[ "nBlockCol" ] + j * 2 ] := ;
               hState[ "nCurBlock" ]
            hState[ "aBoard" ][ hState[ "nBlockRow" ] + i + 1, hState[ "nBlockCol" ] + j * 2 + 1 ] := ;
               hState[ "nCurBlock" ]
         ENDIF
      NEXT
   NEXT
   
   IF RemoveLines( hState[ "aBoard" ], @nLines, @nTopRow )
      PlaySound( "clear" )
      BlinkLines( hState[ "aBoard" ], nLines, nTopRow )
      DrawBackground( hState[ "aBoard" ], hState[ "aColor" ] )
      hState[ "nScore" ] += ( hState[ "nLevel" ] * GetConfig( "game.points_per_line", 5 ) ) * nLines
      hState[ "nCountLines" ] += nLines
   ELSE
      DrawBlock( hState[ "aCurBlock" ], hState[ "aColor" ], hState, .T. )
   ENDIF
   
   NewBlock( hState )
   
   RETURN

/*
Procedure: DrawBackground
Purpose:
Draw board background.
Parameters:
aBoard (A) -> Board
aColor (A) -> Colors
Returns:
NIL
*/
STATIC PROCEDURE DrawBackground( aBoard, aColor )
   LOCAL i, j
   
   FOR i := 1 TO BD_HEIGHT
      FOR j := 2 TO BD_WIDTH STEP 2
         SetColor( IF( aBoard[ i, j ] != N_EMPTY, aColor[ aBoard[ i, j ] ], 'I' ) )
         @ WIN_UP + i, WIN_LEFT + j - 1 SAY C_ELEMENT
      NEXT
   NEXT
   
   RETURN

/*
Function: RemoveLines
Purpose:
Remove completed lines.
Parameters:
aBoard (A) -> Board
nLines (N) -> Lines count (output)
nTopRow (N) -> Top row of cleared lines (output)
Returns:
L -> Removed flag
*/
STATIC FUNCTION RemoveLines( aBoard, nLines, nTopRow )
   LOCAL j, k, l
   LOCAL bRemove := .F.
   LOCAL i := BD_HEIGHT
   
   nLines := 0
   nTopRow := BD_HEIGHT
   
   DO WHILE i >= 1
      FOR j := 2 TO BD_WIDTH + 1
         IF aBoard[ i, j ] == N_EMPTY
            EXIT
         ENDIF
      NEXT
      
      IF j > BD_WIDTH + 1
         IF nTopRow == BD_HEIGHT
            nTopRow := i
         ENDIF
         
         FOR k := i TO 2 STEP -1
            FOR l := 2 TO BD_WIDTH + 1
               aBoard[ k, l ] := aBoard[ k - 1, l ]
            NEXT
         NEXT
         FOR l := 2 TO BD_WIDTH + 1
            aBoard[ 1, l ] := N_EMPTY
         NEXT
         bRemove := .T.
         nLines++
      ELSE
         i--
      ENDIF
   ENDDO
   
   RETURN bRemove

/*
Function: RandomBlock
Purpose:
Generate random block.
Parameters:
hState (H) -> State
nMax (N) -> Max blocks
Returns:
N -> Block number
*/
STATIC FUNCTION RandomBlock( hState, nMax )
   #define IA  421
   #define IC  1663
   #define IM  7875
   
   hState[ "nRandom" ] := ( hState[ "nRandom" ] * IA + IC ) % IM
   
   RETURN Int( ( hState[ "nRandom" ] / IM ) * nMax ) + 1

/*
Function: TicTac
Purpose:
Check timer.
Parameters:
nXms (N) -> Milliseconds
nTop (N) -> Start time
Returns:
L -> Elapsed flag
*/
STATIC FUNCTION TicTac( nXms, nTop )
   LOCAL nTic, nTac, nElapsed
   
   nTac     := Int( ( nXms / 55 ) + IF( nXms % 55 > 0, 1, 0 ) )
   nElapsed := Int( ( Seconds() - nTop ) * 1000 )
   nTic     := Int( ( IF( nElapsed < 0, nElapsed += 86400000, nElapsed ) / 55 ) + ;
                    IF( nElapsed % 55 > 0, 1, 0 ) )
   
   RETURN ( nTic >= nTac )

/*
Procedure: Shadow
Purpose:
Draw shadow.
Parameters:
nTop (N) -> Top
nLeft (N) -> Left
nBottom (N) -> Bottom
nRight (N) -> Right
cCol (C) -> Color
Returns:
NIL
*/
STATIC PROCEDURE Shadow( nTop, nLeft, nBottom, nRight, cCol )
   LOCAL wScr
   
   IF cCol == NIL
      cCol := Chr( 8 )
   ENDIF
   
   DispBegin()
   wScr := SaveScreen( nTop, nLeft, nBottom, nRight )
   RestScreen( nTop, nLeft, nBottom, nRight, ;
               Transform( wScr, Replicate( 'X' + cCol, Len( wScr ) ) ) )
   DispEnd()
   
   RETURN

/*
Function: ParseJsonDictionary
Purpose:
Parse JSON with support for nested structures.
Converts nested keys to dot notation (e.g., "audio.sounds.rotate").
Parameters:
cJson (C) -> JSON string content
Returns:
H -> Flat hash dictionary with dot-notation keys
Notes:
Zero-dependency JSON parser (no hbjson.ch, no hb_json2hash).
Uses stack-based approach to handle nested objects.
*/
STATIC FUNCTION ParseJsonDictionary( cJson )
   LOCAL hDict := { => }
   LOCAL aLines := hb_ATokens( cJson, Chr( 10 ) )
   LOCAL cLine, cKey, cVal, cFullKey, nPos, nI, nJ
   LOCAL aKeyStack := {}
   
   FOR nI := 1 TO Len( aLines )
      cLine := AllTrim( aLines[ nI ] )
      
      IF Empty( cLine ) .OR. cLine == "{" .OR. cLine == "}" .OR. ;
         Left( cLine, 2 ) == "//"
         LOOP
      ENDIF
      
      IF Right( cLine, 1 ) == ","
         cLine := Left( cLine, Len( cLine ) - 1 )
      ENDIF
      
      IF cLine == "}"
         IF Len( aKeyStack ) > 0
            ASize( aKeyStack, Len( aKeyStack ) - 1 )
         ENDIF
         LOOP
      ENDIF
      
      nPos := At( '"', cLine )
      IF nPos == 0
         LOOP
      ENDIF
      
      cLine := SubStr( cLine, nPos + 1 )
      nPos := At( '"', cLine )
      IF nPos == 0
         LOOP
      ENDIF
      
      cKey := SubStr( cLine, 1, nPos - 1 )
      cLine := SubStr( cLine, nPos + 1 )
      
      nPos := At( ':', cLine )
      IF nPos == 0
         LOOP
      ENDIF
      
      cLine := AllTrim( SubStr( cLine, nPos + 1 ) )
      
      IF Left( cLine, 1 ) == "{"
         AAdd( aKeyStack, cKey )
         LOOP
      ENDIF
      
      nPos := At( '"', cLine )
      IF nPos == 0
         cVal := cLine
      ELSE
         cLine := SubStr( cLine, nPos + 1 )
         nPos := At( '"', cLine )
         IF nPos == 0
            cVal := ""
         ELSE
            cVal := SubStr( cLine, 1, nPos - 1 )
         ENDIF
      ENDIF
      
      cFullKey := ""
      FOR nJ := 1 TO Len( aKeyStack )
         IF !Empty( cFullKey )
            cFullKey += "."
         ENDIF
         cFullKey += aKeyStack[ nJ ]
      NEXT
      
      IF !Empty( cFullKey )
         cFullKey += "." + cKey
      ELSE
         cFullKey := cKey
      ENDIF
      
      IF cVal == "true"
         hDict[ cFullKey ] := .T.
      ELSEIF cVal == "false"
         hDict[ cFullKey ] := .F.
      ELSEIF !IsAlpha( Left( cVal, 1 ) ) .AND. Left( cVal, 1 ) != '"'
         hDict[ cFullKey ] := Val( cVal )
      ELSE
         hDict[ cFullKey ] := cVal
      ENDIF
   NEXT
   
   RETURN hDict

/*
Function: SetLanguage
Purpose:
Load language file and set current language.
Parameters:
cLang (C) -> Language code ("EN" or "ES")
Returns:
L -> .T. on success, .F. on failure
Notes:
Uses IF-guards (no TRY/CATCH) per build quirk §2.12.3.
*/
STATIC FUNCTION SetLanguage( cLang )
   LOCAL cFile, cJson, hDict
   LOCAL lOk := .F.
   
   IF cLang == NIL
      cLang := "EN"
   ENDIF
   
   cLang := Upper( AllTrim( cLang ) )
   IF !( cLang $ "EN,ES" )
      cLang := "EN"
   ENDIF
   
   cFile := hb_DirBase() + "i18n\" + Lower( cLang ) + ".json"
   
   IF File( cFile )
      cJson := MemoRead( cFile )
      IF ValType( cJson ) == "C" .AND. !Empty( cJson )
         hDict := ParseJsonDictionary( cJson )
         IF ValType( hDict ) == "H" .AND. Len( hDict ) > 0
            hLang := hDict
            cCurrentLang := cLang
            lOk := .T.
         ENDIF
      ENDIF
   ENDIF
   
   IF !lOk
      hLang := DefaultEnDictionary()
      cCurrentLang := "EN"
   ENDIF
   
   DO CASE
   CASE cCurrentLang == "ES"
      SET DATE FORMAT TO "DD/MM/YYYY"
   OTHERWISE
      SET DATE FORMAT TO "MM/DD/YYYY"
   ENDCASE
   
   RETURN lOk

/*
Function: GetLanguage
Purpose:
Get current language code.
Parameters:
(none)
Returns:
C -> Current language code ("EN" or "ES")
*/
STATIC FUNCTION GetLanguage()
   RETURN cCurrentLang

/*
Function: ToggleLanguage
Purpose:
Toggle between EN and ES languages.
Parameters:
(none)
Returns:
C -> New language code
*/
STATIC FUNCTION ToggleLanguage()
   LOCAL cNewLang
   
   IF cCurrentLang == "EN"
      cNewLang := "ES"
   ELSE
      cNewLang := "EN"
   ENDIF
   
   SetLanguage( cNewLang )
   
   RETURN cNewLang

/*
Function: T
Purpose:
Translation function - single entry point for all UI strings.
Parameters:
cKey (C) -> Translation key
Returns:
C -> Translated string or key if not found
Notes:
NEVER hardcode UI strings. Always use T( "key" ).
*/
STATIC FUNCTION T( cKey )
   IF hb_HHasKey( hLang, cKey )
      RETURN hLang[ cKey ]
   ENDIF
   RETURN cKey

/*
Function: DefaultEnDictionary
Purpose:
Embedded fallback English dictionary.
Parameters:
(none)
Returns:
H -> Hash with default English translations
Notes:
Used when JSON file cannot be loaded.
*/
STATIC FUNCTION DefaultEnDictionary()
   LOCAL hDict := { => }
   
   hDict[ "app.title" ]       := "Tetris V1.00"
   hDict[ "app.year" ]        := "2026"
   hDict[ "status.finished" ] := "Finished"
   hDict[ "status.playing" ]  := "Playing"
   hDict[ "status.paused" ]   := "Paused"
   hDict[ "status.unknown" ]  := "Unknown"
   hDict[ "ui.score" ]        := "Score:"
   hDict[ "ui.status" ]       := "Status:"
   hDict[ "ui.result" ]       := "Result:"
   hDict[ "ui.level" ]        := "Level:"
   hDict[ "ui.lines" ]        := "Lines:"
   hDict[ "ui.blocks" ]       := "Blocks:"
   hDict[ "ui.speed" ]        := "Speed:"
   hDict[ "ui.next" ]         := "Next:"
   hDict[ "ui.language" ]     := "Language:"
   hDict[ "help.exit" ]       := "Esc: Exit"
   hDict[ "help.new" ]        := "Enter: New"
   hDict[ "help.pause" ]      := "Sp: Pause"
   hDict[ "help.rotate" ]     := "Up: Rotate"
   hDict[ "help.move" ]       := "Left/Right: Move"
   hDict[ "help.down" ]       := "Down: Down"
   hDict[ "help.lang" ]       := "F2: Language"
   hDict[ "msg.gameover" ]    := "Game Over!"
   hDict[ "msg.newhigh" ]     := "New High Score!"
   hDict[ "msg.pressenter" ]  := "Press ENTER to start"
   
   RETURN hDict