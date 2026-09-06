# 🎮 HMG Tetris

[![Harbour](https://img.shields.io/badge/Harbour-3.2.0dev-blue)](https://harbour.github.io/)
[![HMG Extended](https://img.shields.io/badge/HMG%20Extended-26.08.0-green)](https://github.com/HMG-Extended)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)
[![Languages](https://img.shields.io/badge/Languages-EN%20%7C%20ES%20%7C%20PT-orange)]()

A modern, object-oriented implementation of the classic **Tetris** game built with **Harbour** and **MiniGUI Extended**. Features runtime language switching (EN/ES/PT), persistent settings, and a clean MVC-inspired architecture.

Based on the original algorithm by **Dr. Claudio Soto** (Uruguay, 2020), refactored to modern Harbour standards with zero global variables, bitmap rendering, and full i18n support.

---

## 🇬🇧 English Version

### 📖 About the Game

Tetris is a timeless puzzle game where geometric shapes (tetrominoes) fall from the top of a 20×10 grid. The player must rotate and move them to form complete horizontal lines, which then disappear and award points. The game ends when the stack reaches the top of the board.

###  Features

- 🎯 Classic Tetris gameplay with 7 tetrominoes (I, J, L, O, S, T, Z) and 4 rotations each
- 🌐 **Runtime language switching** — English, Spanish, Portuguese (no restart required)
- 💾 **Persistent settings** — language saved in `tetris.ini`
- 🎨 **Customizable background** — solid colors
- 📊 Real-time stats: Score, Level, Lines
- ️ Pause/Resume (F5)
- 🏆 Progressive difficulty (speed increases every 10 lines)
-  Bitmap-based rendering (smooth 25×25 pixel blocks)

### 🎮 How to Play

#### Controls

| Key | Action |
|-----|--------|
| ← Left Arrow | Move piece left |
| → Right Arrow | Move piece right |
| ↓ Down Arrow | Soft drop (move down faster) |
| ↑ Up Arrow | Rotate piece clockwise |
| **F2** | New Game |
| **F5** | Pause / Resume |

#### Gameplay Rules

1. A new tetromino spawns at the top center of the board.
2. Use the arrow keys to move and rotate it before it lands.
3. When a piece lands, it locks in place and a new one spawns.
4. Complete a full horizontal line to clear it and earn points.
5. The game ends when a new piece cannot spawn (stack reached the top).

#### Scoring System

| Lines Cleared | Points Formula |
|---------------|----------------|
| 1 line | 100 × Level |
| 2 lines | 300 × Level |
| 3 lines | 500 × Level |
| 4 lines (Tetris!) | 800 × Level |

- **Level** increases every 10 cleared lines.
- **Speed** increases with each level (interval decreases by 50 ms, minimum 100 ms).

#### Menu Structure

```
┌──────────────────────────────────────────────┐
│  Game          Options          Help         │
│  ├─ New Game   ├─ Language      ├─ Keys      │
│  ├─ Pause      │  ├─ English    └─ About     │
│  └─ Exit       │  ├─ Español                 │
│                │  └─ Português               │
│                └─ Background                 │
│                   ├─ Black                   │
│                   ├─ Navy Blue               │
│                   ├─ Dark Green              │
│                   └─ Dark Red                │
└──────────────────────────────────────────────┘
```

### ️ Installation & Build

#### Prerequisites

- **Harbour** 3.2.0dev (r2503200530) or later
- **MiniGUI Extended** 26.08.0 (ANSI build)
- **hbmk2** (Harbour build tool)

#### Build Steps

```bash
# 1. Clone the repository
git clone https://github.com/marcosjarrin/harbour-tech-manual-and-examples

# 2. Compile
hbmk2 tetris.hbp

# 3. Run
tetris.exe
```
---

### 📘 Technical Manual

#### Architecture Overview

The project follows a **hybrid architecture**: OOP for game logic, procedural for the HMG window layer (required by MiniGUI Extended).

```
┌──────────────────┐      ┌──────────────────┐
│  main.prg        │─────▶│  TTetrisGame     │
│  (Window + Menu) │      │  (Game Logic)    │
└──────────────────┘      └────────┬─────────┘
                                   │
                            ┌──────▼──────┐
                            │  i18n.prg   │
                            │  (T() + INI)│
                            └─────────────┘
```

#### Core Class: `TTetrisGame`

| Data | Type | Description |
|------|------|-------------|
| `aBoard` | Array[20,10] | Locked pieces grid |
| `aBuffer` | Array[20,10] | Temporary render buffer |
| `aCurrentPiece` | Array[4,4] | Active tetromino shape |
| `nRow`, `nCol` | Numeric | Current piece position |
| `nScore`, `nLevel`, `nLines` | Numeric | Game stats |
| `hBitmapBlock[7]` | HBitmap | Colored block bitmaps |
| `hBitmapBackground` | HBitmap | Background bitmap |
| `hBitmapBuffer` | HBitmap | Frame buffer |
| `aTetromino[7,4]` | Array | All 7 pieces × 4 rotations |

#### Key Methods

| Method | Responsibility |
|--------|----------------|
| `New()` | Constructor — initializes board and tetrominoes |
| `Init()` | Creates bitmaps and starts first game |
| `MovePiece(nDirection)` | Handles input (1=left, 2=right, 3=rotate, 4=down) |
| `RotatePiece()` | Rotates with collision rollback |
| `RemoveLines()` | Clears full lines, shifts rows down |
| `Render()` | Draws buffer → invalidates window |
| `OnPaint()` | Copies buffer to window client area |
| `ChangeBackColor(aColor, cStyle)` | Runtime background change |

#### Rendering Pipeline

```
aBoard + aCurrentPiece
         │
         ▼
   PastePiece() → aBuffer
         │
         ▼
BT_BitmapPaste(buffer, background)
         │
         ▼
   Draw blocks (BT_BitmapPaste per cell)
         │
         ▼
BT_ClientAreaInvalidateAll("WinTetris")
         │
         ▼
   ON PAINT → BT_DrawBitmap(hBitmapBuffer)
```

#### i18n System

- **Zero-dependency JSON parser** (`ParseJsonDictionary()`) — no `hbjson.ch` required.
- **Fallback dictionary** embedded in `DefaultDictionary()` if JSON files are missing.
- **Runtime switching** via `ChangeLanguage("ES")` → reloads hash → calls `RefreshTetrisUI()`.
- **Persistence** via `tetris.ini` using `IniRead()` / `IniWrite()`.

```
┌─────────────────────────────────────────────┐
│  ChangeLanguage("ES")                       │
│     │                                       │
│     ├─ SetLanguage("ES")                    │
│     │    ├─ Load i18n/es.json               │
│     │    └─ SaveLanguage("ES") → tetris.ini │
│     │                                       │
│     └─ RefreshTetrisUI()                    │
│          ├─ SetProperty(..., "Caption", ...)│
│          └─ DoMethod("WinTetris", "Redraw") │
└─────────────────────────────────────────────┘
```
## 🇸 Versión en Español

###  Acerca del Juego

Tetris es un clásico juego de puzzle donde figuras geométricas (tetrominós) caen desde la parte superior de una cuadrícula de 20×10. El jugador debe rotarlas y moverlas para formar líneas horizontales completas, las cuales desaparecen y otorgan puntos. El juego termina cuando la pila alcanza la parte superior del tablero.

### ✨ Características

- 🎯 Jugabilidad clásica con 7 tetrominós (I, J, L, O, S, T, Z) y 4 rotaciones cada uno
-  **Cambio de idioma en tiempo real** — Inglés, Español, Portugués (sin reiniciar)
- 💾 **Configuración persistente** — idioma guardado en `tetris.ini`
- 🎨 **Fondo personalizable** — colores sólidos
- 📊 Estadísticas en tiempo real: Puntuación, Nivel, Líneas
- ⏸️ Pausar/Reanudar (F5)
- 🏆 Dificultad progresiva (velocidad aumenta cada 10 líneas)
- 🧱 Renderizado por bitmaps (bloques suaves de 25×25 píxeles)

###  Cómo Jugar

#### Controles

| Tecla | Acción |
|-------|--------|
| ← Flecha Izquierda | Mover pieza a la izquierda |
| → Flecha Derecha | Mover pieza a la derecha |
| ↓ Flecha Abajo | Caída suave (bajar más rápido) |
| ↑ Flecha Arriba | Rotar pieza en sentido horario |
| **F2** | Nuevo Juego |
| **F5** | Pausar / Reanudar |

#### Reglas del Juego

1. Un nuevo tetrominó aparece en la parte superior central del tablero.
2. Usa las flechas para moverlo y rotarlo antes de que aterrice.
3. Cuando una pieza aterriza, se bloquea y aparece una nueva.
4. Completa una línea horizontal completa para eliminarla y ganar puntos.
5. El juego termina cuando una nueva pieza no puede aparecer (la pila llegó arriba).

#### Sistema de Puntuación

| Líneas Eliminadas | Fórmula de Puntos |
|-------------------|-------------------|
| 1 línea | 100 × Nivel |
| 2 líneas | 300 × Nivel |
| 3 líneas | 500 × Nivel |
| 4 líneas (¡Tetris!) | 800 × Nivel |

- El **Nivel** aumenta cada 10 líneas eliminadas.
- La **Velocidad** aumenta con cada nivel (el intervalo disminuye 50 ms, mínimo 100 ms).

### 🛠️ Instalación y Compilación

#### Requisitos Previos

- **Harbour** 3.2.0dev (r2503200530) o superior
- **MiniGUI Extended** 26.08.0 (compilación ANSI)
- **hbmk2** (herramienta de compilación de Harbour)

#### Pasos de Compilación

```bash
# 1. Clonar el repositorio
git clone https://github.com/marcosjarrin/harbour-tech-manual-and-examples

# 2. Compilar
hbmk2 tetris.hbp

# 3. Ejecutar
tetris.exe
```

---

### 📘 Manual Técnico

#### Arquitectura

El proyecto sigue una **arquitectura híbrida**: OOP para la lógica del juego, procedural para la capa de ventana HMG (requerido por MiniGUI Extended).

#### Clase Principal: `TTetrisGame`

| Dato | Tipo | Descripción |
|------|------|-------------|
| `aBoard` | Array[20,10] | Cuadrícula de piezas bloqueadas |
| `aBuffer` | Array[20,10] | Buffer temporal de renderizado |
| `aCurrentPiece` | Array[4,4] | Forma del tetrominó activo |
| `nRow`, `nCol` | Numérico | Posición actual de la pieza |
| `nScore`, `nLevel`, `nLines` | Numérico | Estadísticas del juego |
| `hBitmapBlock[7]` | HBitmap | Bitmaps de bloques coloreados |
| `hBitmapBackground` | HBitmap | Bitmap del fondo |
| `hBitmapBuffer` | HBitmap | Buffer de fotograma |
| `aTetromino[7,4]` | Array | 7 piezas × 4 rotaciones |

#### Métodos Clave

| Método | Responsabilidad |
|--------|-----------------|
| `New()` | Constructor — inicializa tablero y tetrominós |
| `Init()` | Crea bitmaps e inicia primera partida |
| `MovePiece(nDirection)` | Maneja entrada (1=izq, 2=der, 3=rotar, 4=abajo) |
| `RotatePiece()` | Rota con rollback por colisión |
| `RemoveLines()` | Elimina líneas completas, desplaza filas |
| `Render()` | Dibuja buffer → invalida ventana |
| `OnPaint()` | Copia buffer al área cliente de la ventana |
| `ChangeBackColor(aColor, cStyle)` | Cambio de fondo en tiempo real |

#### Sistema i18n

- **Parser JSON sin dependencias** (`ParseJsonDictionary()`) — no requiere `hbjson.ch`.
- **Diccionario de respaldo** embebido en `DefaultDictionary()` si faltan los archivos JSON.
- **Cambio en tiempo real** vía `ChangeLanguage("ES")` → recarga hash → llama `RefreshTetrisUI()`.
- **Persistencia** vía `tetris.ini` usando `IniRead()` / `IniWrite()`.

---

## 📜 Credits

- **Original Algorithm**: Dr. Claudio Soto (Uruguay, 2020) — srvet@adinet.com.uy
- **Refactoring & Modernization**: Marcos Jarrín — BadaSystem (2026)
- **Framework**: Harbour MiniGUI Extended Edition 26.08.0
- **Version**: Harbour 3.2.0dev (r2503200530)

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

* ***Website: [badasystem.com](https://badasystem.com)***
* ***📧 Contact: marvijarrin@gmail.com***
---
