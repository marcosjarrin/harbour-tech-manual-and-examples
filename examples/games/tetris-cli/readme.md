# 📘 MyTetris — User Manual / Manual de Usuario

1. 🇬🇧 **English User Manual**
2. 🇪🇸 **Manual de Usuario en Español**

---

# 🇬🇧 ENGLISH USER MANUAL

## 🎮 MyTetris V1.00 — User Manual

**Author:** My CIS-ID: 100604,1637 Phil - Clipper
**Author-Update:** Marcos Jarrín - Harbour
**Website:** badasystem.com
**Email:** marvijarrin@gmail.com
**License:** MIT
**Compiler:** Harbour + BCC 32-bit

---

## 📖 1. Introduction

**MyTetris** is a modern terminal-based Tetris clone written in Harbour. It runs in a 28×80 character console window and features:

- 🧱 Classic Tetris block mechanics
- 👻 Ghost piece preview
- ✨ Blinking animation on line clear
- 🔊 Real WAV sound effects (via Windows API)
- 🌐 Full internationalization (English / Spanish)
- ⚙️ External `config.json` configuration
- 🏆 Persistent high score
- 🕹️ Level progression & speed increase

---

## 🚀 2. Getting Started

### 2.1 Requirements
- Windows (32/64-bit)
- The compiled `myt tetris.exe` (or equivalent binary)
- The following files/folders in the same directory:
  - `config.json` (optional — defaults used if missing)
  - `i18n\en.json` and `i18n\es.json` (optional — embedded fallback used if missing)
  - `sounds\*.wav` (optional — PC speaker fallback used if missing)
  - `data\` folder (auto-created on first run)

### 2.2 First Run
1. Double-click the executable.
2. A blue-masked game board appears with a title bar and status panel.
3. Press **ENTER** to start a new game.
4. The `data\MYTETRIS.INI` file is created automatically to store your high score.

---

## ⌨️ 3. Controls

| Key | Action |
|-----|--------|
| `ENTER` | 🆕 Start a new game |
| `SPACE` | ⏸️ Pause / Resume |
| `↑` (Up) | 🔄 Rotate piece |
| `←` (Left) | ⬅️ Move piece left |
| `→` (Right) | ➡️ Move piece right |
| `↓` (Down) | ⬇️ Soft drop (accelerated fall) |
| `F2` | 🌐 Toggle language (EN ↔ ES) |
| `ESC` | 🚪 Exit the game |

> 💡 **Tip:** The game auto-saves your high score the moment you beat it — no need to exit cleanly.

---

## 🖥️ 4. Screen Layout

```
┌───────────────────────────────────────────────────────────────┐
│                     Tetris V1.00 - 2026                       │
├──────────────────────┬────────────────────────────────────────┤
│                      │  Score:      <high score>              │
│                      │  Status:     Playing / Paused / ...    │
│      GAME BOARD      │  Result:     <current score>           │
│      (20 × 20)       │                                        │
│                      │  Level:      <level>                   │
│                      │  Lines:      <lines cleared>           │
│                      │  Blocks:     <blocks placed>           │
│                      │  Speed:      <speed level>             │
│                      │                                        │
│                      │  Next:       <preview>                 │
├──────────────────────┴────────────────────────────────────────┤
│  Esc:Exit  Enter:New  Sp:Pause  Up:Rotate  L/R:Move  ...      │
└───────────────────────────────────────────────────────────────┘
```

---

## 🕹️ 5. Gameplay

### 5.1 Objective
Arrange falling tetromino pieces to form complete horizontal lines. Completed lines disappear, awarding points.

### 5.2 Scoring
| Event | Points |
|-------|--------|
| Place a block | `level × points_per_block` (default ×1) |
| Clear 1 line | `level × points_per_line × lines` (default ×5) |

### 5.3 Levels & Speed
- Every `blocks_per_level` blocks (default 25), the level increases.
- Each level reduces `nCurWait` by `time_per_level` ms (default 100 ms), making pieces fall faster.
- After reaching `level_add_blocks` (default 3), the piece pool expands to include all 14 shapes.

### 5.4 Ghost Piece 👻
A translucent outline shows where the current piece will land. Toggle via `visual.ghost_enabled`.

### 5.5 Line Clear Blink ✨
Cleared lines flash white/black before removal. Configurable via `visual.blink_*`.

### 5.6 Game Over
The game ends when a new piece cannot spawn (collision at spawn position). A `gameover` sound plays.

---

## ⚙️ 6. Configuration (`config.json`)

The game reads `config.json` from its working directory. If missing, built-in defaults are used.

### 6.1 Full Reference

```json
{
  "game": {
    "initial_wait": 1100,
    "time_per_level": 100,
    "blocks_per_level": 25,
    "points_per_line": 5,
    "points_per_block": 1,
    "level_add_blocks": 3,
    "min_level": 1,
    "initial_max_blocks": 7
  },
  "visual": {
    "blink_enabled": true,
    "blink_count": 3,
    "blink_delay": 150,
    "ghost_enabled": true
  },
  "audio": {
    "enabled": true,
    "volume": 80,
    "sounds": {
      "rotate":   "sounds/rotate.wav",
      "move":     "sounds/move.wav",
      "drop":     "sounds/drop.wav",
      "clear":    "sounds/clear.wav",
      "gameover": "sounds/gameover.wav"
    }
  }
}
```

### 6.2 Option Descriptions

#### 🎮 `game` section

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `initial_wait` | number (ms) | `1100` | Delay between automatic piece drops at the start. Higher = slower. |
| `time_per_level` | number (ms) | `100` | Milliseconds subtracted from `initial_wait` per level. |
| `blocks_per_level` | number | `25` | Blocks placed required to advance one level. |
| `points_per_line` | number | `5` | Base points per cleared line (multiplied by level). |
| `points_per_block` | number | `1` | Base points per block placed (multiplied by level). |
| `level_add_blocks` | number | `3` | Level at which the full piece pool (all 14 shapes) unlocks. |
| `min_level` | number | `1` | Starting level for a new game. |
| `initial_max_blocks` | number | `7` | Number of distinct tetromino shapes available at game start. |

#### 🎨 `visual` section

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `blink_enabled` | boolean | `true` | Enable/disable the line-clear blink animation. |
| `blink_count` | number | `3` | Number of on/off blink cycles per cleared line. |
| `blink_delay` | number (ms) | `150` | Duration of each blink phase. |
| `ghost_enabled` | boolean | `true` | Show/hide the ghost piece preview. |

#### 🔊 `audio` section

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `enabled` | boolean | `true` | Master switch for all sound effects. |
| `volume` | number (0–100) | `80` | Reserved for future volume control (WAVs play at system volume). |
| `sounds.rotate` | string (path) | `sounds/rotate.wav` | Sound played on successful rotation. |
| `sounds.move` | string (path) | `sounds/move.wav` | Sound played on horizontal move. |
| `sounds.drop` | string (path) | `sounds/drop.wav` | Sound played on manual/automatic drop. |
| `sounds.clear` | string (path) | `sounds/clear.wav` | Sound played when lines are cleared. |
| `sounds.gameover` | string (path) | `sounds/gameover.wav` | Sound played on game over. |

> 💡 **Fallback behavior:** If a WAV file is missing, the game uses the PC speaker `Tone()` fallback automatically.

---

## 🌐 7. Internationalization (i18n)

### 7.1 Language Files
Place translation files here:

```
i18n\en.json
i18n\es.json
```

### 7.2 Switching Language
Press **F2** at any time. The UI rebuilds immediately.

### 7.3 Translation File Format

```json
{
  "app.title": "Tetris V1.00",
  "status.playing": "Playing",
  "ui.score": "Score:",
  "help.exit": "Esc: Exit"
}
```

### 7.4 Available Keys

| Key | Purpose |
|-----|---------|
| `app.title` | Window title |
| `app.year` | Year display |
| `status.finished` | "Finished" label |
| `status.playing` | "Playing" label |
| `status.paused` | "Paused" label |
| `status.unknown` | Fallback status |
| `ui.score` | High score label |
| `ui.status` | Status label |
| `ui.result` | Current score label |
| `ui.level` | Level label |
| `ui.lines` | Lines label |
| `ui.blocks` | Blocks label |
| `ui.speed` | Speed label |
| `ui.next` | Next-piece label |
| `ui.language` | Language label |
| `help.exit` | Exit help text |
| `help.new` | New game help text |
| `help.pause` | Pause help text |
| `help.rotate` | Rotate help text |
| `help.move` | Move help text |
| `help.down` | Down help text |
| `help.lang` | Language toggle help text |
| `msg.gameover` | Game over message |
| `msg.newhigh` | New high score message |
| `msg.pressenter` | "Press ENTER" prompt |

> 🌟 **No hardcoded strings:** All UI text comes from `T("key")`. If a key is missing, the key name itself is displayed.

---

## 🏆 8. High Score Persistence

- Stored in: `data\MYTETRIS.INI`
- Format: plain integer (e.g., `1234`)
- Created automatically on first run with value `0`
- **Saved instantly** when beaten (not only at exit)
- Also saved on clean exit via `RestEnv()`

---

## 🔊 9. Sound System

### 9.1 Windows WAV Playback
Uses `PlaySoundA()` from `winmm.dll` (via `#pragma BEGINDUMP`):
```
PlaySoundA(filename, NULL, SND_FILENAME | SND_ASYNC | SND_NODEFAULT)
```

### 9.2 PC Speaker Fallback
If a WAV is missing, `Tone()` beeps are used:

| Event | Fallback Pattern |
|-------|------------------|
| rotate | 800 Hz, 50 ms |
| move | 600 Hz, 30 ms |
| drop | 400 Hz, 100 ms |
| clear | 1200 Hz + 1600 Hz, 100 ms each |
| gameover | 800 → 600 → 400 Hz descending |

---

## 🗂️ 10. File Structure

```
MyTetris\
├── mytetris.exe          # Compiled executable
├── config.json           # Game configuration (optional)
├── i18n\
│   ├── en.json           # English translations
│   └── es.json           # Spanish translations
├── sounds\
│   ├── rotate.wav
│   ├── move.wav
│   ├── drop.wav
│   ├── clear.wav
│   └── gameover.wav
└── data\
    └── MYTETRIS.INI      # High score file (auto-created)
```

---

## 🛠️ 11. Troubleshooting

| Problem | Solution |
|---------|----------|
| ❌ No sound | Verify WAV paths in `config.json`; check `audio.enabled` is `true`. |
| ❌ High score not saved | Ensure `data\` folder is writable. |
| ❌ Text overlap after F2 | Should not occur; if it does, restart the game. |
| ❌ Game runs too fast/slow | Adjust `game.initial_wait` in `config.json`. |
| ❌ Pieces won't rotate | Some pieces (O-shape) are rotationally symmetric. |
| ❌ JSON not loaded | Check for syntax errors (trailing commas, unescaped quotes). |

---

## 📜 12. License

MIT License — see source header for details.

---

## 🙏 13. Credits

- **Author:** My CIS-ID: 100604,1637 Phil - Clipper
- **Author-Update:** Marcos Jarrín - Harbour
- **Website:** [badasystem.com](https://badasystem.com)
- **Email:** marvijarrin@gmail.com
- **Built with:** Harbour + MiniGUI + BCC 32-bit

---

# 🇪🇸 MANUAL DE USUARIO EN ESPAÑOL

## 🎮 MyTetris V1.00 — Manual de Usuario
**Autor:** My CIS-ID: 100604,1637 Phil - Clipper
**Autor-Update:** Marcos Jarrín - Harbour
**Sitio web:** badasystem.com
**Correo:** marvijarrin@gmail.com
**Licencia:** MIT
**Compilador:** Harbour + BCC 32-bit

---

## 📖 1. Introducción

**MyTetris** es un clon moderno de Tetris para terminal, escrito en Harbour. Se ejecuta en una consola de 28×80 caracteres e incluye:

- 🧱 Mecánicas clásicas de Tetris
- 👻 Pieza fantasma (vista previa de aterrizaje)
- ✨ Animación de parpadeo al eliminar líneas
- 🔊 Efectos de sonido WAV reales (vía Windows API)
- 🌐 Internacionalización completa (Inglés / Español)
- ⚙️ Configuración externa mediante `config.json`
- 🏆 Puntuación máxima persistente
- 🕹️ Progresión de niveles y aumento de velocidad

---

## 🚀 2. Primeros pasos

### 2.1 Requisitos
- Windows (32/64 bits)
- El ejecutable `myt tetris.exe` (o binario equivalente)
- Los siguientes archivos/carpetas en el mismo directorio:
  - `config.json` (opcional — se usan valores por defecto si falta)
  - `i18n\en.json` y `i18n\es.json` (opcional — diccionario embebido si faltan)
  - `sounds\*.wav` (opcional — se usa el altavoz del PC si faltan)
  - Carpeta `data\` (creada automáticamente al primer inicio)

### 2.2 Primer inicio
1. Haz doble clic en el ejecutable.
2. Aparece un tablero con máscara azul, barra de título y panel de estado.
3. Pulsa **ENTER** para comenzar una nueva partida.
4. El archivo `data\MYTETRIS.INI` se crea automáticamente para guardar tu puntuación máxima.

---

## ⌨️ 3. Controles

| Tecla | Acción |
|-------|--------|
| `ENTER` | 🆕 Iniciar nueva partida |
| `ESPACIO` | ⏸️ Pausar / Reanudar |
| `↑` (Arriba) | 🔄 Rotar pieza |
| `←` (Izquierda) | ⬅️ Mover pieza a la izquierda |
| `→` (Derecha) | ➡️ Mover pieza a la derecha |
| `↓` (Abajo) | ⬇️ Caída rápida (descenso acelerado) |
| `F2` | 🌐 Cambiar idioma (EN ↔ ES) |
| `ESC` | 🚪 Salir del juego |

> 💡 **Consejo:** La puntuación máxima se guarda automáticamente en el momento en que la superas — no necesitas salir correctamente.

---

## 🖥️ 4. Distribución de la pantalla

```
┌───────────────────────────────────────────────────────────────┐
│                     Tetris V1.00 - 2026                       │
├──────────────────────┬────────────────────────────────────────┤
│                      │  Score:      <puntuación máxima>       │
│                      │  Status:     Playing / Paused / ...    │
│      TABLERO DE      │  Result:     <puntuación actual>       │
│      JUEGO (20×20)   │                                        │
│                      │  Level:      <nivel>                   │
│                      │  Lines:      <líneas eliminadas>       │
│                      │  Blocks:     <bloques colocados>       │
│                      │  Speed:      <nivel de velocidad>      │
│                      │                                        │
│                      │  Next:       <vista previa>            │
├──────────────────────┴────────────────────────────────────────┤
│  Esc:Exit  Enter:New  Sp:Pause  Up:Rotate  L/R:Move  ...      │
└───────────────────────────────────────────────────────────────┘
```

---

## 🕹️ 5. Jugabilidad

### 5.1 Objetivo
Organiza las piezas tetrominó que caen para formar líneas horizontales completas. Las líneas completas desaparecen y otorgan puntos.

### 5.2 Puntuación
| Evento | Puntos |
|--------|--------|
| Colocar un bloque | `nivel × points_per_block` (por defecto ×1) |
| Eliminar 1 línea | `nivel × points_per_line × líneas` (por defecto ×5) |

### 5.3 Niveles y velocidad
- Cada `blocks_per_level` bloques (por defecto 25), el nivel aumenta.
- Cada nivel reduce `nCurWait` en `time_per_level` ms (por defecto 100 ms), haciendo caer las piezas más rápido.
- Tras alcanzar `level_add_blocks` (por defecto 3), el conjunto de piezas se amplía a las 14 formas.

### 5.4 Pieza fantasma 👻
Un contorno translúcido muestra dónde aterrizará la pieza actual. Se activa/desactiva con `visual.ghost_enabled`.

### 5.5 Parpadeo al eliminar líneas ✨
Las líneas eliminadas parpadean en blanco/negro antes de desaparecer. Configurable con `visual.blink_*`.

### 5.6 Fin del juego
El juego termina cuando una nueva pieza no puede aparecer (colisión en la posición de aparición). Se reproduce el sonido `gameover`.

---

## ⚙️ 6. Configuración (`config.json`)

El juego lee `config.json` desde su directorio de trabajo. Si no existe, se usan los valores por defecto.

### 6.1 Referencia completa

```json
{
  "game": {
    "initial_wait": 1100,
    "time_per_level": 100,
    "blocks_per_level": 25,
    "points_per_line": 5,
    "points_per_block": 1,
    "level_add_blocks": 3,
    "min_level": 1,
    "initial_max_blocks": 7
  },
  "visual": {
    "blink_enabled": true,
    "blink_count": 3,
    "blink_delay": 150,
    "ghost_enabled": true
  },
  "audio": {
    "enabled": true,
    "volume": 80,
    "sounds": {
      "rotate":   "sounds/rotate.wav",
      "move":     "sounds/move.wav",
      "drop":     "sounds/drop.wav",
      "clear":    "sounds/clear.wav",
      "gameover": "sounds/gameover.wav"
    }
  }
}
```

### 6.2 Descripción de opciones

#### 🎮 Sección `game`

| Clave | Tipo | Defecto | Descripción |
|-------|------|---------|-------------|
| `initial_wait` | número (ms) | `1100` | Retardo entre caídas automáticas al inicio. Más alto = más lento. |
| `time_per_level` | número (ms) | `100` | Milisegundos que se restan a `initial_wait` por nivel. |
| `blocks_per_level` | número | `25` | Bloques colocados necesarios para subir un nivel. |
| `points_per_line` | número | `5` | Puntos base por línea eliminada (multiplicado por nivel). |
| `points_per_block` | número | `1` | Puntos base por bloque colocado (multiplicado por nivel). |
| `level_add_blocks` | número | `3` | Nivel en el que se desbloquea el conjunto completo (14 formas). |
| `min_level` | número | `1` | Nivel inicial de una nueva partida. |
| `initial_max_blocks` | número | `7` | Cantidad de formas distintas disponibles al inicio. |

#### 🎨 Sección `visual`

| Clave | Tipo | Defecto | Descripción |
|-------|------|---------|-------------|
| `blink_enabled` | booleano | `true` | Activa/desactiva la animación de parpadeo. |
| `blink_count` | número | `3` | Número de ciclos de parpadeo por línea eliminada. |
| `blink_delay` | número (ms) | `150` | Duración de cada fase de parpadeo. |
| `ghost_enabled` | booleano | `true` | Mostrar/ocultar la pieza fantasma. |

#### 🔊 Sección `audio`

| Clave | Tipo | Defecto | Descripción |
|-------|------|---------|-------------|
| `enabled` | booleano | `true` | Interruptor maestro de todos los sonidos. |
| `volume` | número (0–100) | `80` | Reservado para control futuro (los WAV se reproducen al volumen del sistema). |
| `sounds.rotate` | cadena (ruta) | `sounds/rotate.wav` | Sonido al rotar exitosamente. |
| `sounds.move` | cadena (ruta) | `sounds/move.wav` | Sonido al mover horizontalmente. |
| `sounds.drop` | cadena (ruta) | `sounds/drop.wav` | Sonido al caer manual/automáticamente. |
| `sounds.clear` | cadena (ruta) | `sounds/clear.wav` | Sonido al eliminar líneas. |
| `sounds.gameover` | cadena (ruta) | `sounds/gameover.wav` | Sonido al terminar la partida. |

> 💡 **Comportamiento de reserva:** Si falta un WAV, el juego usa automáticamente el altavoz del PC con `Tone()`.

---

## 🌐 7. Internacionalización (i18n)

### 7.1 Archivos de idioma
Coloca los archivos de traducción aquí:

```
i18n\en.json
i18n\es.json
```

### 7.2 Cambiar de idioma
Pulsa **F2** en cualquier momento. La interfaz se reconstruye inmediatamente.

### 7.3 Formato del archivo de traducción

```json
{
  "app.title": "Tetris V1.00",
  "status.playing": "Jugando",
  "ui.score": "Puntos:",
  "help.exit": "Esc: Salir"
}
```

### 7.4 Claves disponibles

| Clave | Propósito |
|-------|-----------|
| `app.title` | Título de la ventana |
| `app.year` | Año mostrado |
| `status.finished` | Etiqueta "Finalizado" |
| `status.playing` | Etiqueta "Jugando" |
| `status.paused` | Etiqueta "Pausado" |
| `status.unknown` | Estado por defecto |
| `ui.score` | Etiqueta de puntuación máxima |
| `ui.status` | Etiqueta de estado |
| `ui.result` | Etiqueta de puntuación actual |
| `ui.level` | Etiqueta de nivel |
| `ui.lines` | Etiqueta de líneas |
| `ui.blocks` | Etiqueta de bloques |
| `ui.speed` | Etiqueta de velocidad |
| `ui.next` | Etiqueta de siguiente pieza |
| `ui.language` | Etiqueta de idioma |
| `help.exit` | Texto de ayuda para salir |
| `help.new` | Texto de ayuda para nueva partida |
| `help.pause` | Texto de ayuda para pausa |
| `help.rotate` | Texto de ayuda para rotar |
| `help.move` | Texto de ayuda para mover |
| `help.down` | Texto de ayuda para bajar |
| `help.lang` | Texto de ayuda para cambiar idioma |
| `msg.gameover` | Mensaje de fin de juego |
| `msg.newhigh` | Mensaje de nuevo récord |
| `msg.pressenter` | Mensaje "Pulsa ENTER" |

> 🌟 **Sin cadenas fijas:** Todo el texto de la interfaz proviene de `T("clave")`. Si falta una clave, se muestra el nombre de la clave.

---

## 🏆 8. Persistencia de la puntuación máxima

- Ubicación: `data\MYTETRIS.INI`
- Formato: entero plano (ej. `1234`)
- Se crea automáticamente en el primer inicio con valor `0`
- **Se guarda al instante** cuando se supera (no solo al salir)
- También se guarda en la salida limpia vía `RestEnv()`

---

## 🔊 9. Sistema de sonido

### 9.1 Reproducción WAV en Windows
Usa `PlaySoundA()` de `winmm.dll` (vía `#pragma BEGINDUMP`):
```
PlaySoundA(filename, NULL, SND_FILENAME | SND_ASYNC | SND_NODEFAULT)
```

### 9.2 Reserva con altavoz del PC
Si falta un WAV, se usan pitidos con `Tone()`:

| Evento | Patrón de reserva |
|--------|-------------------|
| rotate | 800 Hz, 50 ms |
| move | 600 Hz, 30 ms |
| drop | 400 Hz, 100 ms |
| clear | 1200 Hz + 1600 Hz, 100 ms cada uno |
| gameover | 800 → 600 → 400 Hz descendente |

---

## 🗂️ 10. Estructura de archivos

```
MyTetris\
├── mytetris.exe          # Ejecutable compilado
├── config.json           # Configuración del juego (opcional)
├── i18n\
│   ├── en.json           # Traducciones al inglés
│   └── es.json           # Traducciones al español
├── sounds\
│   ├── rotate.wav
│   ├── move.wav
│   ├── drop.wav
│   ├── clear.wav
│   └── gameover.wav
└── data\
    └── MYTETRIS.INI      # Archivo de puntuación (auto-creado)
```

---

## 🛠️ 11. Solución de problemas

| Problema | Solución |
|----------|----------|
| ❌ Sin sonido | Verifica las rutas WAV en `config.json`; comprueba que `audio.enabled` sea `true`. |
| ❌ No se guarda la puntuación | Asegúrate de que la carpeta `data\` sea escribible. |
| ❌ Texto superpuesto tras F2 | No debería ocurrir; si pasa, reinicia el juego. |
| ❌ El juego va muy rápido/lento | Ajusta `game.initial_wait` en `config.json`. |
| ❌ Las piezas no rotan | Algunas piezas (forma O) son simétricas rotacionalmente. |
| ❌ El JSON no se carga | Revisa errores de sintaxis (comas sobrantes, comillas sin escapar). |

---

## 📜 12. Licencia

Licencia MIT — ver el encabezado del código fuente para más detalles.

---

## 🙏 13. Créditos

- **Author:** My CIS-ID: 100604,1637 Phil - Clipper
- **Author-Update:** Marcos Jarrín - Harbour
- **Sitio web:** [badasystem.com](https://badasystem.com)
- **Correo:** marvijarrin@gmail.com
- **Construido con:** Harbour + MiniGUI + BCC 32-bit

---

✅ **Fin de ambos manuales / End of both manuals**
