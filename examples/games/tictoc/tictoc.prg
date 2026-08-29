/*
BadaSystem
Program       : tictoc
Module        : tictoc.prg
Compiler      : MINIGUI - Harbour Win32 GUI
Compiler-C    : BCC 32 bit
Author        : Marcos Jarrín
Email         : marvijarrin@gmail.com
Website       : badasystem.com
Date          : 22/06/2026
Update        : 23/06/2026
Rev           : 1.0
License       : MIT
Description:
    Two-player Tic-Tac-Toe game built with Harbour + MiniGUI Extended.
    Implements a 3x3 board, turn-based gameplay, win/draw detection,
    winning-cell highlighting, and a persistent score board across rounds.
*/

#include "minigui.ch"

/* ============================================================
GLOBAL VARIABLES
============================================================ */
/*
Module State (Hash-free, flat STATIC variables — appropriate for
a single-window game with a small, fixed state space).

aBoard         (A) -> 9-element array. 0 = empty, 1 = X, 2 = O.
nCurrentPlayer (N) -> Active player. 1 = X, 2 = O.
lGameActive    (L) -> .T. while the round is in progress.
nScoreX        (N) -> Accumulated wins of player X.
nScoreO        (N) -> Accumulated wins of player O.
nScoreDraw     (N) -> Accumulated draws.
aWinCombos     (A) -> 8 winning lines (rows, columns, diagonals).
                     Each element is a 3-element array of board
                     positions (1..9).
*/
STATIC aBoard        := { 0, 0, 0, 0, 0, 0, 0, 0, 0 }
STATIC nCurrentPlayer := 1
STATIC lGameActive    := .T.
STATIC nScoreX        := 0
STATIC nScoreO        := 0
STATIC nScoreDraw     := 0

STATIC aWinCombos := { ;
    { 1, 2, 3 }, ;   // Row 1
    { 4, 5, 6 }, ;   // Row 2
    { 7, 8, 9 }, ;   // Row 3
    { 1, 4, 7 }, ;   // Col 1
    { 2, 5, 8 }, ;   // Col 2
    { 3, 6, 9 }, ;   // Col 3
    { 1, 5, 9 }, ;   // Diagonal \
    { 3, 5, 7 }  ;   // Diagonal /
}

/* ============================================================
ENTRY POINT (MANDATORY NAME: Main)
============================================================ */
/*
Procedure: Main
Purpose:
    Mandatory entry point for the executable.
    ⚠️ CRITICAL: The Harbour linker strictly requires this exact
    name (`Main`). Any other name compiles but the program will
    not run.

Parameters:
    (none)

Returns:
    NIL

Notes:
    - Initializes application-wide SET commands (CENTURY, DATE).
    - Builds the main window with title, subtitle, status label,
      3x3 button grid, score board and "New Game" button.
    - Closes the window structure with END WINDOW before calling
      CENTER WINDOW and ACTIVATE WINDOW (MGERROR/0 prevention).
    - Does NOT call HB_SetCodePage( "UTF8" ) nor RddSetDefault().
      Acceptable because the module uses only ASCII literals and
      performs no DBF operations. For a localized production build,
      add HB_SetCodePage( "UTF8" ) at the top of Main().
*/
FUNCTION Main()

    // Set application properties
    SET CENTURY ON
    SET DATE FORMAT "DD/MM/YYYY"

    // Define main window
    DEFINE WINDOW WinMain ;
        AT 0, 0 ;
        WIDTH 420 ;
        HEIGHT 540 ;
        TITLE "TicToc - Tic Tac Toe" ;
        MAIN ;
        NOMAXIMIZE ;
        NOSIZE ;
        BACKCOLOR { 245, 245, 245 }

        // Title Label
        DEFINE LABEL lblTitle
            ROW 10
            COL 10
            WIDTH 400
            HEIGHT 40
            VALUE "TicToc"
            FONTNAME "Segoe UI"
            FONTSIZE 24
            FONTBOLD .T.
            TRANSPARENT .T.
            FONTCOLOR { 33, 37, 41 }
        END LABEL

        // Subtitle
        DEFINE LABEL lblSubtitle
            ROW 50
            COL 10
            WIDTH 400
            HEIGHT 20
            VALUE "Tic Tac Toe Game"
            FONTNAME "Segoe UI"
            FONTSIZE 11
            TRANSPARENT .T.
            FONTCOLOR { 108, 117, 125 }
        END LABEL

        // Status Label - shows current player or game result
        DEFINE LABEL lblStatus
            ROW 80
            COL 10
            WIDTH 400
            HEIGHT 30
            VALUE "Player X's Turn"
            FONTNAME "Segoe UI"
            FONTSIZE 14
            FONTBOLD .T.
            TRANSPARENT .T.
            FONTCOLOR { 220, 53, 69 }
            ALIGNMENT CENTER
        END LABEL

        // ============================================
        // GAME BOARD - 3x3 Grid of Buttons
        // ============================================

        // Row 1
        DEFINE BUTTON btnCell1
            ROW 120
            COL 60
            WIDTH 80
            HEIGHT 80
            CAPTION ""
            FONTNAME "Segoe UI"
            FONTSIZE 36
            FONTBOLD .T.
            BACKCOLOR { 255, 255, 255 }
            FONTCOLOR { 33, 37, 41 }
            ACTION CellClicked( 1 )
        END BUTTON

        DEFINE BUTTON btnCell2
            ROW 120
            COL 150
            WIDTH 80
            HEIGHT 80
            CAPTION ""
            FONTNAME "Segoe UI"
            FONTSIZE 36
            FONTBOLD .T.
            BACKCOLOR { 255, 255, 255 }
            FONTCOLOR { 33, 37, 41 }
            ACTION CellClicked( 2 )
        END BUTTON

        DEFINE BUTTON btnCell3
            ROW 120
            COL 240
            WIDTH 80
            HEIGHT 80
            CAPTION ""
            FONTNAME "Segoe UI"
            FONTSIZE 36
            FONTBOLD .T.
            BACKCOLOR { 255, 255, 255 }
            FONTCOLOR { 33, 37, 41 }
            ACTION CellClicked( 3 )
        END BUTTON

        // Row 2
        DEFINE BUTTON btnCell4
            ROW 210
            COL 60
            WIDTH 80
            HEIGHT 80
            CAPTION ""
            FONTNAME "Segoe UI"
            FONTSIZE 36
            FONTBOLD .T.
            BACKCOLOR { 255, 255, 255 }
            FONTCOLOR { 33, 37, 41 }
            ACTION CellClicked( 4 )
        END BUTTON

        DEFINE BUTTON btnCell5
            ROW 210
            COL 150
            WIDTH 80
            HEIGHT 80
            CAPTION ""
            FONTNAME "Segoe UI"
            FONTSIZE 36
            FONTBOLD .T.
            BACKCOLOR { 255, 255, 255 }
            FONTCOLOR { 33, 37, 41 }
            ACTION CellClicked( 5 )
        END BUTTON

        DEFINE BUTTON btnCell6
            ROW 210
            COL 240
            WIDTH 80
            HEIGHT 80
            CAPTION ""
            FONTNAME "Segoe UI"
            FONTSIZE 36
            FONTBOLD .T.
            BACKCOLOR { 255, 255, 255 }
            FONTCOLOR { 33, 37, 41 }
            ACTION CellClicked( 6 )
        END BUTTON

        // Row 3
        DEFINE BUTTON btnCell7
            ROW 300
            COL 60
            WIDTH 80
            HEIGHT 80
            CAPTION ""
            FONTNAME "Segoe UI"
            FONTSIZE 36
            FONTBOLD .T.
            BACKCOLOR { 255, 255, 255 }
            FONTCOLOR { 33, 37, 41 }
            ACTION CellClicked( 7 )
        END BUTTON

        DEFINE BUTTON btnCell8
            ROW 300
            COL 150
            WIDTH 80
            HEIGHT 80
            CAPTION ""
            FONTNAME "Segoe UI"
            FONTSIZE 36
            FONTBOLD .T.
            BACKCOLOR { 255, 255, 255 }
            FONTCOLOR { 33, 37, 41 }
            ACTION CellClicked( 8 )
        END BUTTON

        DEFINE BUTTON btnCell9
            ROW 300
            COL 240
            WIDTH 80
            HEIGHT 80
            CAPTION ""
            FONTNAME "Segoe UI"
            FONTSIZE 36
            FONTBOLD .T.
            BACKCOLOR { 255, 255, 255 }
            FONTCOLOR { 33, 37, 41 }
            ACTION CellClicked( 9 )
        END BUTTON

        // ============================================
        // SCORE DISPLAY
        // ============================================
        DEFINE LABEL lblScoreTitle
            ROW 395
            COL 10
            WIDTH 400
            HEIGHT 22
            VALUE "Score Board"
            FONTNAME "Segoe UI"
            FONTSIZE 12
            FONTBOLD .T.
            TRANSPARENT .T.
            FONTCOLOR { 33, 37, 41 }
            ALIGNMENT CENTER
        END LABEL

        DEFINE LABEL lblScore
            ROW 420
            COL 10
            WIDTH 400
            HEIGHT 25
            VALUE "X Wins: 0  |  O Wins: 0  |  Draws: 0"
            FONTNAME "Segoe UI"
            FONTSIZE 12
            TRANSPARENT .T.
            FONTCOLOR { 73, 80, 87 }
            ALIGNMENT CENTER
        END LABEL

        // ============================================
        // NEW GAME BUTTON
        // ============================================
        DEFINE BUTTON btnNewGame
            ROW 460
            COL 130
            WIDTH 160
            HEIGHT 35
            CAPTION "New Game"
            FONTNAME "Segoe UI"
            FONTSIZE 12
            FONTBOLD .T.
            BACKCOLOR { 0, 123, 255 }
            FONTCOLOR { 255, 255, 255 }
            ACTION ResetGame()
        END BUTTON

    END WINDOW   // ✅ MANDATORY — closes structure before ACTIVATE

    // Center window on screen and activate
    CENTER WINDOW WinMain
    ACTIVATE WINDOW WinMain

RETURN NIL

/* ============================================================
CELL CLICKED - Handles player moves
============================================================ */
/*
Function: CellClicked
Purpose:
    Handles a click on one of the nine board cells. Validates
    that the round is still active and the cell is empty, writes
    the current player's mark, updates the UI, checks for a
    winner or a draw, and switches the turn if the game continues.

Parameters:
    nCell (N) -> Board position clicked (1..9).

Returns:
    NIL

Notes:
    - Guard clause: ignores the click if lGameActive == .F. or
      the cell is already occupied (aBoard[ nCell ] != 0).
    - Mutates module state (aBoard, nCurrentPlayer, lGameActive).
    - Uses SetProperty() to update Caption / FontColor / BackColor
      / Enabled of the target button — all documented properties.
    - Button names are built dynamically ("btnCell" + hb_ntos( nCell ))
      and used as the control identifier in SetProperty().
    - Calls CheckWinner() and CheckDraw() to decide the next state.
    - On win: highlights the three winning cells in green and
      updates the score. On draw: increments nScoreDraw.
    - On continue: toggles nCurrentPlayer between 1 and 2 and
      updates the status label color to match the active player.
*/
FUNCTION CellClicked( nCell )

    LOCAL cPlayerSymbol
    LOCAL nColorPlayer
    LOCAL cBtnName
    LOCAL nWinCombo

    // Ignore clicks if game is not active or cell is occupied
    IF ! lGameActive .OR. aBoard[ nCell ] != 0
        RETURN NIL
    ENDIF

    // Set cell value based on current player
    aBoard[ nCell ] := nCurrentPlayer

    // Determine symbol and color
    IF nCurrentPlayer == 1
        cPlayerSymbol := "X"
        nColorPlayer  := { 220, 53, 69 }    // Red for X
    ELSE
        cPlayerSymbol := "O"
        nColorPlayer  := { 0, 123, 255 }    // Blue for O
    ENDIF

    // Update button caption and color
    cBtnName := "btnCell" + hb_ntos( nCell )
    SetProperty( "WinMain", cBtnName, "Caption",   cPlayerSymbol )
    SetProperty( "WinMain", cBtnName, "FontColor", nColorPlayer  )
    SetProperty( "WinMain", cBtnName, "Enabled",   .F.           )

    // Check for winner
    nWinCombo := CheckWinner()

    IF nWinCombo > 0
        // We have a winner!
        lGameActive := .F.
        HighlightWinningCells( nWinCombo )
        UpdateScore( nCurrentPlayer )

        IF nCurrentPlayer == 1
            SetProperty( "WinMain", "lblStatus", "Value",     "Player X Wins!" )
            SetProperty( "WinMain", "lblStatus", "FontColor", { 40, 167, 69 }  )
        ELSE
            SetProperty( "WinMain", "lblStatus", "Value",     "Player O Wins!" )
            SetProperty( "WinMain", "lblStatus", "FontColor", { 40, 167, 69 }  )
        ENDIF

    ELSEIF CheckDraw()
        // Game is a draw
        lGameActive := .F.
        nScoreDraw++
        UpdateScore( 0 )
        SetProperty( "WinMain", "lblStatus", "Value",     "It's a Draw!"  )
        SetProperty( "WinMain", "lblStatus", "FontColor", { 255, 193, 7 } )
    ELSE
        // Switch player
        IF nCurrentPlayer == 1
            nCurrentPlayer := 2
            SetProperty( "WinMain", "lblStatus", "Value",     "Player O's Turn" )
            SetProperty( "WinMain", "lblStatus", "FontColor", { 0, 123, 255 }   )
        ELSE
            nCurrentPlayer := 1
            SetProperty( "WinMain", "lblStatus", "Value",     "Player X's Turn" )
            SetProperty( "WinMain", "lblStatus", "FontColor", { 220, 53, 69 }   )
        ENDIF
    ENDIF

RETURN NIL

/* ============================================================
CHECK WINNER - Returns winning combo index or 0
============================================================ */
/*
Function: CheckWinner
Purpose:
    Scans the eight winning combinations in aWinCombos and returns
    the 1-based index of the first combination whose three cells
    are all occupied by the current player. Returns 0 if no winner
    is found.

Parameters:
    (none — reads module state: aBoard, nCurrentPlayer, aWinCombos)

Returns:
    N -> Index (1..8) into aWinCombos if a winning line exists,
         or 0 if no player has won yet.

Notes:
    - Uses a traditional FOR loop (FOR EACH is safe on arrays of
      arrays, but the traditional FOR is used here for symmetry
      with the rest of the module).
    - Does NOT mutate module state — pure read operation.
    - The returned index is consumed by HighlightWinningCells()
      to paint the three winning buttons.
*/
FUNCTION CheckWinner()

    LOCAL nCombo
    LOCAL nI, nJ
    LOCAL nP1, nP2, nP3
    LOCAL nPlayer

    nPlayer := nCurrentPlayer

    // Check all winning combinations
    FOR nI := 1 TO LEN( aWinCombos )
        nP1 := aWinCombos[ nI ][ 1 ]
        nP2 := aWinCombos[ nI ][ 2 ]
        nP3 := aWinCombos[ nI ][ 3 ]

        IF aBoard[ nP1 ] == nPlayer .AND. ;
           aBoard[ nP2 ] == nPlayer .AND. ;
           aBoard[ nP3 ] == nPlayer
            RETURN nI
        ENDIF
    NEXT nI

RETURN 0

/* ============================================================
CHECK DRAW - Returns .T. if all cells are filled
============================================================ */
/*
Function: CheckDraw
Purpose:
    Returns .T. when every cell of the board is occupied (no 0
    left in aBoard). Used by CellClicked() after CheckWinner()
    returns 0, to decide whether the round ends in a draw.

Parameters:
    (none — reads module state: aBoard)

Returns:
    L -> .T. if the board is full (draw), .F. otherwise.

Notes:
    - Pure read operation, does not mutate state.
    - Called only when no winner has been detected yet.
*/
FUNCTION CheckDraw()

    LOCAL nI

    FOR nI := 1 TO 9
        IF aBoard[ nI ] == 0
            RETURN .F.
        ENDIF
    NEXT nI

RETURN .T.

/* ============================================================
HIGHLIGHT WINNING CELLS - Green background for winners
============================================================ */
/*
Function: HighlightWinningCells
Purpose:
    Paints the three cells belonging to the winning combination
    with a green background and white foreground, providing a
    visual cue of the winning line.

Parameters:
    nCombo (N) -> Index (1..8) into aWinCombos identifying the
                  winning line.

Returns:
    NIL

Notes:
    - Reads the three cell positions from aWinCombos[ nCombo ].
    - Uses SetProperty() to change BackColor to green
      { 40, 167, 69 } and FontColor to white { 255, 255, 255 }.
    - Button names are built dynamically as in CellClicked().
*/
FUNCTION HighlightWinningCells( nCombo )

    LOCAL nP1, nP2, nP3
    LOCAL cBtnName

    nP1 := aWinCombos[ nCombo ][ 1 ]
    nP2 := aWinCombos[ nCombo ][ 2 ]
    nP3 := aWinCombos[ nCombo ][ 3 ]

    // Highlight each winning cell with green background
    cBtnName := "btnCell" + hb_ntos( nP1 )
    SetProperty( "WinMain", cBtnName, "BackColor",  { 40, 167, 69 }     )
    SetProperty( "WinMain", cBtnName, "FontColor",  { 255, 255, 255 }   )

    cBtnName := "btnCell" + hb_ntos( nP2 )
    SetProperty( "WinMain", cBtnName, "BackColor",  { 40, 167, 69 }     )
    SetProperty( "WinMain", cBtnName, "FontColor",  { 255, 255, 255 }   )

    cBtnName := "btnCell" + hb_ntos( nP3 )
    SetProperty( "WinMain", cBtnName, "BackColor",  { 40, 167, 69 }     )
    SetProperty( "WinMain", cBtnName, "FontColor",  { 255, 255, 255 }   )

RETURN NIL

/* ============================================================
UPDATE SCORE - Update score display label
============================================================ */
/*
Function: UpdateScore
Purpose:
    Increments the appropriate score counter (nScoreX, nScoreO,
    or leaves them unchanged on a draw) and refreshes the
    lblScore label with the new tally.

Parameters:
    nWinner (N) -> 1 = X won, 2 = O won, 0 = draw.

Returns:
    NIL

Notes:
    - Mutates module state (nScoreX / nScoreO; nScoreDraw is
      incremented directly in CellClicked() before calling this
      function with nWinner == 0).
    - Builds the display string with hb_ntos() and writes it to
      lblScore.Value via SetProperty().
*/
FUNCTION UpdateScore( nWinner )

    LOCAL cScoreText

    IF nWinner == 1
        nScoreX++
    ELSEIF nWinner == 2
        nScoreO++
    ENDIF

    cScoreText := "X Wins: "  + hb_ntos( nScoreX )    + ;
                  "  |  O Wins: " + hb_ntos( nScoreO ) + ;
                  "  |  Draws: "  + hb_ntos( nScoreDraw )

    SetProperty( "WinMain", "lblScore", "Value", cScoreText )

RETURN NIL

/* ============================================================
RESET GAME - Clear board and start new game
============================================================ */
/*
Function: ResetGame
Purpose:
    Resets the board to the initial empty state, re-enables all
    nine buttons, restores their default white background and
    dark foreground, sets the active player back to X, and
    refreshes the status label. The score counters are preserved
    across rounds.

Parameters:
    (none)

Returns:
    NIL

Notes:
    - Mutates module state: aBoard, lGameActive, nCurrentPlayer.
    - Does NOT reset nScoreX / nScoreO / nScoreDraw (scores are
      persistent across rounds within the same session).
    - Iterates 1..9 with a traditional FOR loop to reset every
      cell button via SetProperty().
*/
FUNCTION ResetGame()

    LOCAL nI
    LOCAL cBtnName

    // Reset board state
    FOR nI := 1 TO 9
        aBoard[ nI ] := 0
    NEXT nI

    // Reset game active flag and player
    lGameActive    := .T.
    nCurrentPlayer := 1

    // Reset all buttons
    FOR nI := 1 TO 9
        cBtnName := "btnCell" + hb_ntos( nI )
        SetProperty( "WinMain", cBtnName, "Caption",   ""                 )
        SetProperty( "WinMain", cBtnName, "BackColor", { 255, 255, 255 }  )
        SetProperty( "WinMain", cBtnName, "FontColor", { 33, 37, 41 }     )
        SetProperty( "WinMain", cBtnName, "Enabled",   .T.                )
    NEXT nI

    // Reset status label
    SetProperty( "WinMain", "lblStatus", "Value",     "Player X's Turn" )
    SetProperty( "WinMain", "lblStatus", "FontColor", { 220, 53, 69 }   )

RETURN NIL
