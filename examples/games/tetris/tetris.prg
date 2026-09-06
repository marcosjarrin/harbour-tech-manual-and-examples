/*
BadaSystem
Program       : tetris
Module        : tetris.prg
Compiler      : MINIGUI - Harbour Win32 GUI
Author        : Marcos Jarrín
Email         : marvijarrin@gmail.com
Website       : badasystem.com
Date          : 29/08/2026
Update        : 06/09/2026
Rev           : 1.0.1
SPDX-License-Identifier: MIT
Description:
Entry point with background color selection menu.
Notes:
- All MENUITEM have NAME clause for Caption property updates.
- Background colors: Black, Blue, Green, Red.
*/
#include "minigui.ch"
#include "hbclass.ch"

STATIC oGame

/*
Procedure: Main
Purpose:
Mandatory entry point. Sets UTF-8 codepage, initializes the
i18n subsystem, loads the persisted language, creates the
TTetrisGame singleton, and launches the main window.
Parameters:
(none)
Returns:
NIL
*/
PROCEDURE Main()
   HB_SetCodePage( "UTF8" )
   I18nInit()
   IF ! SetLanguage( LoadLanguage() )
      MsgStop( "Warning: Could not load language file." )
   ENDIF
   oGame := TTetrisGame():New()
   BuildTetrisWindow()
RETURN NIL

/*
Procedure: BuildTetrisWindow
Purpose:
Defines and activates the main game window (400x620).
Contains the menu bar (Game, Options, Help), keyboard
bindings (arrows, F2, F5), the game timer (700ms),
and three LABEL controls for score/level/lines display.
Parameters:
(none)
Returns:
NIL
Notes:
- ON INIT calls oGame:Init() to create bitmaps and start game.
- ON PAINT delegates to oGame:OnPaint() for double-buffer render.
- ON RELEASE calls oGame:Release() to free bitmap resources.
- Timer interval controls gravity speed (700ms = level 1).
*/
PROCEDURE BuildTetrisWindow()

   DEFINE WINDOW WinTetris ;
      AT 0, 0 ;
      WIDTH 400 ;
      HEIGHT 620 ;
      TITLE T( "app.title" ) ;
      MAIN ;
      NOMAXIMIZE ;
      NOSIZE ;
      ON INIT oGame:Init() ;
      ON PAINT oGame:OnPaint() ;
      ON RELEASE oGame:Release()

      DEFINE MAIN MENU

         DEFINE POPUP T( "menu.game" ) NAME mnuMenuGame

            MENUITEM T( "menu.game.new" ) ;
               NAME mnuNew ;
               ACTION oGame:NewGame()

            SEPARATOR

            MENUITEM T( "menu.game.pause" ) ;
               NAME mnuPause ;
               ACTION oGame:TogglePause()

            SEPARATOR

            MENUITEM T( "menu.game.exit" ) ;
               NAME mnuExit ;
               ACTION DoMethod( "WinTetris", "Release" )

         END POPUP


         DEFINE POPUP T( "menu.options" ) NAME mnuMenuOptions

            DEFINE POPUP T( "menu.options.language" ) NAME mnuLang

               MENUITEM T( "lang.english" ) ;
                  NAME mnuLangEN ;
                  ACTION ChangeLanguage( "EN" )

               MENUITEM T( "lang.spanish" ) ;
                  NAME mnuLangES ;
                  ACTION ChangeLanguage( "ES" )

               MENUITEM T( "lang.portuguese" ) ;
                  NAME mnuLangPT ;
                  ACTION ChangeLanguage( "PT" )

            END POPUP

            SEPARATOR

            DEFINE POPUP T( "menu.options.background" ) NAME mnuBack

               MENUITEM T( "bg.black" ) ;
                  NAME mnuBackBlack ;
                  ACTION oGame:ChangeBackColor( {0,0,0}, "SOLID" )

               MENUITEM T( "bg.blue" ) ;
                  NAME mnuBackBlue ;
                  ACTION oGame:ChangeBackColor( {0,0,128}, "SOLID" )

               MENUITEM T( "bg.green" ) ;
                  NAME mnuBackGreen ;
                  ACTION oGame:ChangeBackColor( {0,128,0}, "SOLID" )

               MENUITEM T( "bg.red" ) ;
                  NAME mnuBackRed ;
                  ACTION oGame:ChangeBackColor( {128,0,0}, "SOLID" )

            END POPUP

         END POPUP


         DEFINE POPUP T( "menu.help" ) NAME mnuMenuHelp

            MENUITEM T( "menu.help.keys" ) ;
               NAME mnuKeys ;
               ACTION MsgInfo( ;
                  T( "msg.keys" ), ;
                  T( "menu.help.keys" ) )

            SEPARATOR

            MENUITEM T( "menu.help.about" ) ;
               NAME mnuAbout ;
               ACTION MsgInfo( ;
                  T( "msg.about" ), ;
                  T( "menu.help.about" ) )

         END POPUP

      END MENU


      /*
       * ========================================================================
       * Keyboard handling
       * ========================================================================
       *
       * Explicit OF WinTetris is intentional.
       * It guarantees that these shortcuts belong to the main game window.
       */

      ON KEY LEFT  OF WinTetris ACTION TetrisKeyLeft()
      ON KEY RIGHT OF WinTetris ACTION TetrisKeyRight()
      ON KEY UP    OF WinTetris ACTION TetrisKeyUp()
      ON KEY DOWN  OF WinTetris ACTION TetrisKeyDown()

      ON KEY F2 OF WinTetris ACTION TetrisKeyF2()
      ON KEY F5 OF WinTetris ACTION TetrisKeyF5()


      /*
       * ========================================================================
       * Game timer
       * ========================================================================
       */
      DEFINE TIMER Timer1 ;
         INTERVAL 700 ;
         ACTION oGame:MovePiece( 4 )


      /*
       * ========================================================================
       * Statistics
       * ========================================================================
       */
      @ 520,  10 LABEL lblScore OF WinTetris ;
         VALUE "" ;
         WIDTH 90

      @ 520, 180 LABEL lblLevel OF WinTetris ;
         VALUE "" ;
         WIDTH 90

      @ 520, 300 LABEL lblLines OF WinTetris ;
         VALUE "" ;
         WIDTH 90


      DEFINE STATUSBAR

         STATUSITEM T( "status.ready" ) WIDTH 200

      END STATUSBAR

   END WINDOW


   CENTER WINDOW WinTetris

   ACTIVATE WINDOW WinTetris

RETURN NIL

/*
 * ============================================================================
 * Procedure: TetrisKeyF2
 * Purpose:
 * Starts a completely new Tetris game.
 *
 * F2 = New Game
 *
 * Returns:
 * NIL
 * ============================================================================
 */
PROCEDURE TetrisKeyF2()

   IF oGame != NIL

      /*
       * F2 always starts a new game.
       * This also works after GAME OVER.
       */
      oGame:NewGame()

   ENDIF

   /*
    * Restore keyboard focus to the game window.
    */
   IF IsWindowDefined( "WinTetris" )
      SetFocus( "WinTetris" )
   ENDIF

RETURN NIL


/*
 * ============================================================================
 * Procedure: TetrisKeyF5
 * Purpose:
 * Toggles pause/resume.
 *
 * F5 = Pause / Resume
 *
 * Returns:
 * NIL
 * ============================================================================
 */
PROCEDURE TetrisKeyF5()

   IF oGame != NIL

      oGame:TogglePause()

   ENDIF

   /*
    * Restore keyboard focus to the game window.
    */
   IF IsWindowDefined( "WinTetris" )
      SetFocus( "WinTetris" )
   ENDIF

RETURN NIL


/*
 * ============================================================================
 * Procedure: TetrisKeyLeft
 * Purpose:
 * Moves the active piece to the left.
 *
 * Returns:
 * NIL
 * ============================================================================
 */
PROCEDURE TetrisKeyLeft()

   IF oGame != NIL
      oGame:MovePiece( 1 )
   ENDIF

RETURN NIL


/*
 * ============================================================================
 * Procedure: TetrisKeyRight
 * Purpose:
 * Moves the active piece to the right.
 *
 * Returns:
 * NIL
 * ============================================================================
 */
PROCEDURE TetrisKeyRight()

   IF oGame != NIL
      oGame:MovePiece( 2 )
   ENDIF

RETURN NIL


/*
 * ============================================================================
 * Procedure: TetrisKeyUp
 * Purpose:
 * Rotates the active piece.
 *
 * Returns:
 * NIL
 * ============================================================================
 */
PROCEDURE TetrisKeyUp()

   IF oGame != NIL
      oGame:MovePiece( 3 )
   ENDIF

RETURN NIL


/*
 * ============================================================================
 * Procedure: TetrisKeyDown
 * Purpose:
 * Moves the active piece down.
 *
 * Returns:
 * NIL
 * ============================================================================
 */
PROCEDURE TetrisKeyDown()

   IF oGame != NIL
      oGame:MovePiece( 4 )
   ENDIF

RETURN NIL
