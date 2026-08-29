# 🎮 TicToc — Tic Tac Toe

> A classic two-player Tic-Tac-Toe game built with **Harbour 3.2+** and
> **MiniGUI Extended Edition**, following BadaSystem's enterprise coding
> standards.

---

## 🇬🇧 English Version

### 📋 Features

| Category        | Feature                                                          |
|-----------------|------------------------------------------------------------------|
| **Gameplay**    | Two-player, turn-based (X vs O)                                  |
| **Board**       | 3×3 grid rendered with nine styled `BUTTON` controls             |
| **Win detection** | Checks all 8 winning lines (3 rows, 3 columns, 2 diagonals)    |
| **Draw detection** | Detects a full board with no winner                            |
| **Visual feedback** | Winning cells are highlighted in green                        |
| **Score board** | Persistent counters for X wins, O wins and draws across rounds   |
| **New Game**    | Resets the board but preserves the score                         |
| **Status bar**  | Dynamic label showing the current player / round result          |
| **Look & feel** | Modern Segoe UI font, flat buttons, soft gray background         |
| **Window**      | Fixed size, non-maximizable, centered on screen                  |

### 🏗️ How It Was Developed

**Tech stack**

- **Language:** Harbour 3.2.0
- **GUI framework:** MiniGUI Extended Edition
- **Compiler C:** BCC 32-bit
- **Paradigm:** Pure functional 

# 📦 Deliverables

Below you will find:
1. **`tictoc.prg`** 
2. **`README.md`** — Bilingual (EN/ES) documentation: features, development notes, and user manual.


**Architecture**

```
┌────────────────────────────────────────────┐
│           tictoc.prg (single module)       │
├────────────────────────────────────────────┤
│  STATIC state  →  aBoard, nCurrentPlayer,  │
│                   lGameActive, scores...   │
│                                            │
│  Main()  →  defines WinMain + controls     │
│            →  CENTER / ACTIVATE            │
│                                            │
│  CellClicked()     →  handles a move       │
│  CheckWinner()     →  scans 8 lines        │
│  CheckDraw()       →  full-board test      │
│  HighlightWinningCells()  →  paints winner │
│  UpdateScore()     →  refreshes lblScore   │
│  ResetGame()       →  clears the board     │
└────────────────────────────────────────────┘
```
### 📖 User Manual

#### 1. Starting the game

Run the compiled executable (`tictoc.exe`). The main window opens
centered on the screen with an empty 3×3 board and the message
**"Player X's Turn"** in red.

#### 2. Playing a round

1. **Player X** always starts. Click any empty cell — it turns red
   with an **X**.
2. The status label switches to **"Player O's Turn"** in blue.
3. **Player O** clicks an empty cell — it turns blue with an **O**.
4. Players alternate until one of three outcomes occurs:
   - **Win** — three marks in a row / column / diagonal. The three
     winning cells turn green and the status reads
     *"Player X Wins!"* or *"Player O Wins!"*.
   - **Draw** — all nine cells are filled with no winner. The status
     reads *"It's a Draw!"* in amber.
   - **In progress** — the status label keeps showing whose turn it is.
5. Once a round ends, further clicks on the board are ignored until
   you start a new round.

#### 3. Score board

Under the board you will see:

```
X Wins: 0  |  O Wins: 0  |  Draws: 0
```

Counters are updated automatically at the end of every round and
**persist across rounds** within the same session.

#### 4. Starting a new round

Click the blue **"New Game"** button. The board is cleared, all cells
are re-enabled, the active player returns to X, and the status label
reads **"Player X's Turn"** again. The score board is preserved.

#### 5. Closing the game

Close the window with the standard title-bar close button, or press
`Alt+F4`. No data is saved to disk — the game is entirely in-memory.

#### 6. Troubleshooting

| Symptom                              | Cause / Solution                              |
|--------------------------------------|-----------------------------------------------|
| Window does not appear               | Run as a normal Windows user; no admin needed |
| Buttons don't respond                | The round has ended — click **New Game**      |
| Window looks blurry on high-DPI screens | Expected on some builds; cosmetic only      |

---

## 🇪🇸 Versión en Español

### 📋 Características

| Categoría        | Característica                                                    |
|------------------|-------------------------------------------------------------------|
| **Jugabilidad**  | Dos jugadores, turnos alternos (X contra O)                       |
| **Tablero**      | Cuadrícula 3×3 renderizada con nueve controles `BUTTON`           |
| **Detección de victoria** | Revisa las 8 líneas ganadoras (3 filas, 3 columnas, 2 diagonales) |
| **Detección de empate**   | Detecta tablero lleno sin ganador                           |
| **Retroalimentación visual** | Las celdas ganadoras se resaltan en verde               |
| **Marcador**     | Contadores persistentes de victorias de X, O y empates entre rondas |
| **Nuevo juego**  | Reinicia el tablero pero conserva el marcador                     |
| **Barra de estado** | Etiqueta dinámica que muestra el jugador actual / resultado     |
| **Apariencia**   | Fuente Segoe UI, botones planos, fondo gris suave                 |
| **Ventana**      | Tamaño fijo, no maximizable, centrada en pantalla                 |

### 🏗️ Cómo fue desarrollado

**Stack tecnológico**

- **Language:** Harbour 3.2.0
- **GUI framework:** MiniGUI Extended Edition
- **Compiler C:** BCC 32-bit
- **Paradigm:** Pure funcional 


# 📦 Entregables

A continuación encontrará:
1. **`tictoc.prg`**  
2. **`README.md`** — Documentación bilingüe (inglés/español): características, notas de desarrollo y manual de usuario.

---


### 📖 Manual de Usuario

#### 1. Iniciar el juego

Ejecute el binario compilado (`tictoc.exe`). La ventana principal se
abre centrada en la pantalla con un tablero 3×3 vacío y el mensaje
**"Player X's Turn"** en rojo.

#### 2. Jugar una ronda

1. **El jugador X** siempre empieza. Haga clic en cualquier celda
   vacía — se pone roja con una **X**.
2. La etiqueta de estado cambia a **"Player O's Turn"** en azul.
3. **El jugador O** hace clic en una celda vacía — se pone azul con
   una **O**.
4. Los jugadores se alternan hasta que ocurre uno de tres resultados:
   - **Victoria** — tres marcas en fila / columna / diagonal. Las tres
     celdas ganadoras se ponen verdes y el estado muestra
     *"Player X Wins!"* o *"Player O Wins!"*.
   - **Empate** — las nueve celdas están llenas sin ganador. El estado
     muestra *"It's a Draw!"* en ámbar.
   - **En curso** — la etiqueta de estado sigue indicando de quién es
     el turno.
5. Cuando una ronda termina, los clics adicionales sobre el tablero se
   ignoran hasta que inicie una nueva ronda.

#### 3. Marcador

Bajo el tablero verá:

```
X Wins: 0  |  O Wins: 0  |  Draws: 0
```

Los contadores se actualizan automáticamente al final de cada ronda y
**persisten entre rondas** dentro de la misma sesión.

#### 4. Iniciar una nueva ronda

Haga clic en el botón azul **"New Game"**. El tablero se limpia, todas
las celdas se rehabilitan, el jugador activo vuelve a ser X y la
etiqueta de estado muestra **"Player X's Turn"** de nuevo. El marcador
se conserva.

#### 5. Cerrar el juego

Cierre la ventana con el botón estándar de la barra de título, o
presione `Alt+F4`. No se guardan datos en disco — el juego es
enteramente en memoria.

#### 6. Solución de problemas

| Síntoma                                  | Causa / Solución                             |
|------------------------------------------|----------------------------------------------|
| La ventana no aparece                    | Ejecute como usuario Windows normal; no requiere admin |
| Los botones no responden                 | La ronda terminó — haga clic en **New Game** |
| La ventana se ve borrosa en pantallas de alto DPI | Esperado en algunas compilaciones; solo cosmético |

---

## 📄 License

MIT

© 2026 BadaSystem — Marcos Jarrín.
Contact: marvijarrin@gmail.com · badasystem.com
