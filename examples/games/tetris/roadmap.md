# Roadmap – Tetris for Harbour + HMG

## Current Status

This project is a **solid foundation** for a modern Tetris game, written in Harbour with the HMG Extended GUI library. It already implements:

- ✅ Fully functional game loop (board, pieces, collisions, scoring)
- ✅ Double-buffered rendering (smooth, flicker-free graphics)
- ✅ Keyboard controls (arrows, F2, F5)
- ✅ Pause / Resume
- ✅ Game Over detection
- ✅ Internationalization (English, Spanish, Portuguese) with JSON language files
- ✅ Manual UTF-8 → ANSI conversion (Windows-1252) for proper accent support
- ✅ Runtime language switching
- ✅ Background color selection
- ✅ Proper resource management (bitmaps released on exit)
- ✅ Well-structured object-oriented code (classes for Board, Piece, Game)

However, the current version is **basic in terms of gameplay depth**. It lacks several features that are standard in modern Tetris implementations.

---

## What Needs Improvement (Priority Order)

### 1. **Level System & Speed Progression** (CRITICAL)
- The game currently stays at level 1 forever.
- **Action:** Increase level every 10 cleared lines. Adjust timer interval accordingly (e.g., 700ms - (level-1)*50ms, with a floor of 100ms).
- **Benefit:** Adds challenge and prevents monotony.

### 2. **Next Piece Preview**
- Players cannot plan ahead.
- **Action:** Display the upcoming piece in a small panel next to the board.
- **Benefit:** Strategic gameplay, reduces luck factor.

### 3. **Hard Drop**
- No way to instantly drop a piece.
- **Action:** Bind Spacebar or Up arrow to hard drop. Add score bonus for hard drops.
- **Benefit:** Rewards speed and precision.

### 4. **Ghost Piece**
- No visual indicator of where the piece will land.
- **Action:** Draw a semi-transparent shadow of the piece at its lowest valid position.
- **Benefit:** Improves player spatial awareness.

### 5. **Hold Piece**
- No ability to store a piece for later use.
- **Action:** Add a Hold slot and a key (e.g., C or Shift) to swap the current piece with the held one.
- **Benefit:** Adds strategic depth.

### 6. **Sound Effects & Music**
- Currently silent.
- **Action:** Add sound effects for piece movement, rotation, line clear, game over. Consider background music.
- **Benefit:** Enhances immersion and feedback.

### 7. **Line Clear Animation**
- Lines disappear instantly.
- **Action:** Implement a brief flash or dissolve animation before removing lines.
- **Benefit:** Visual satisfaction, better UX.

### 8. **Scoring Enhancements**
- Basic scoring only.
- **Action:** Implement TETRIS guideline scoring (e.g., 1 line = 100 * level, 2 lines = 300 * level, 3 lines = 500 * level, 4 lines = 800 * level). Add bonus for hard drops.
- **Benefit:** Aligns with industry standards.

### 9. **High Score Persistence**
- Score resets on every run.
- **Action:** Save the high score to an INI file and display it on the main screen.
- **Benefit:** Motivation for repeat play.

### 10. **UI Polish**
- Basic labels and status bar.
- **Action:** Improve visual design: custom fonts, better layout, score panel, next piece panel, hold panel.
- **Benefit:** Professional look and feel.

### 11. **Game Over Screen**
- Only a red "GAME OVER" text overlay.
- **Action:** Create a dedicated game-over dialog with final score, lines, level, and option to restart.
- **Benefit:** Clearer feedback, better user experience.

### 12. **Keyboard Focus Fix**
- After language change, focus might be lost.
- **Action:** Ensure `SetFocus("WinTetris")` is called after any menu action.
- **Benefit:** Smooth keyboard input.

### 13. **Additional Game Modes (Optional)**
- Marathon, Sprint, Ultra.
- **Action:** Implement alternative modes with different win conditions.
- **Benefit:** Replayability.

---

## How to Contribute

1. Fork the repository.
2. Pick an item from the list above.
3. Create a branch and implement the feature.
4. Submit a pull request with a clear description of your changes.

We welcome contributions that improve the game while keeping the codebase clean and compatible with Harbour + HMG Extended.

---

## License

This project is MIT-licensed – feel free to use and modify.

---

# Hoja de Ruta – Tetris para Harbour + HMG

## Estado Actual

Este proyecto es una **base sólida** para un juego de Tetris moderno, escrito en Harbour con la biblioteca gráfica HMG Extended. Ya implementa:

- ✅ Bucle de juego completo (tablero, piezas, colisiones, puntuación)
- ✅ Renderizado con doble búfer (gráficos suaves y sin parpadeo)
- ✅ Controles por teclado (flechas, F2, F5)
- ✅ Pausa / Reanudar
- ✅ Detección de Game Over
- ✅ Internacionalización (inglés, español, portugués) con archivos JSON
- ✅ Conversión manual UTF-8 → ANSI (Windows-1252) para soporte de acentos
- ✅ Cambio de idioma en tiempo de ejecución
- ✅ Selección de color de fondo
- ✅ Gestión adecuada de recursos (liberación de bitmaps al salir)
- ✅ Código orientado a objetos bien estructurado (clases para Tablero, Pieza, Juego)

Sin embargo, la versión actual es **básica en términos de profundidad jugable**. Carece de varias características que son estándar en las implementaciones modernas de Tetris.

---

## Qué necesita mejorar (por orden de prioridad)

### 1. **Sistema de niveles y progresión de velocidad** (CRÍTICO)
- El juego se queda siempre en el nivel 1.
- **Acción:** Aumentar el nivel cada 10 líneas eliminadas. Ajustar el intervalo del temporizador en consecuencia (ej. 700ms - (nivel-1)*50ms, con un mínimo de 100ms).
- **Beneficio:** Añade desafío y evita la monotonía.

### 2. **Vista previa de la siguiente pieza**
- El jugador no puede planificar con antelación.
- **Acción:** Mostrar la siguiente pieza en un panel pequeño al lado del tablero.
- **Beneficio:** Jugabilidad estratégica, reduce el factor suerte.

### 3. **Caída instantánea (Hard Drop)**
- No hay forma de dejar caer la pieza al instante.
- **Acción:** Asignar la barra espaciadora o la flecha arriba para la caída instantánea. Añadir bonificación de puntuación por hard drop.
- **Beneficio:** Recompensa la velocidad y precisión.

### 4. **Pieza fantasma (Ghost Piece)**
- No hay indicador visual de dónde caerá la pieza.
- **Acción:** Dibujar una sombra semitransparente de la pieza en su posición más baja válida.
- **Beneficio:** Mejora la conciencia espacial del jugador.

### 5. **Guardar pieza (Hold)**
- No se puede almacenar una pieza para usarla después.
- **Acción:** Añadir un slot de Hold y una tecla (ej. C o Shift) para intercambiar la pieza actual con la guardada.
- **Beneficio:** Añade profundidad estratégica.

### 6. **Efectos de sonido y música**
- Actualmente silencioso.
- **Acción:** Añadir efectos de sonido para movimiento, rotación, eliminación de líneas, game over. Considerar música de fondo.
- **Beneficio:** Mejora la inmersión y la retroalimentación.

### 7. **Animación al eliminar líneas**
- Las líneas desaparecen instantáneamente.
- **Acción:** Implementar una breve animación de destello o disolución antes de eliminar las líneas.
- **Beneficio:** Satisfacción visual, mejor UX.

### 8. **Mejoras en la puntuación**
- Puntuación básica únicamente.
- **Acción:** Implementar el sistema de puntuación estándar de Tetris (ej. 1 línea = 100 * nivel, 2 líneas = 300 * nivel, 3 líneas = 500 * nivel, 4 líneas = 800 * nivel). Añadir bonificación por hard drop.
- **Beneficio:** Se alinea con los estándares de la industria.

### 9. **Persistencia de la puntuación más alta (High Score)**
- La puntuación se reinicia en cada ejecución.
- **Acción:** Guardar la puntuación más alta en un archivo INI y mostrarla en la pantalla principal.
- **Beneficio:** Motivación para repetir partidas.

### 10. **Pulido de la interfaz de usuario**
- Etiquetas básicas y barra de estado.
- **Acción:** Mejorar el diseño visual: fuentes personalizadas, mejor distribución, panel de puntuación, panel de siguiente pieza, panel de hold.
- **Beneficio:** Aspecto profesional.

### 11. **Pantalla de Game Over**
- Solo un texto "GAME OVER" superpuesto en rojo.
- **Acción:** Crear un diálogo de game over dedicado con la puntuación final, líneas, nivel y opción de reiniciar.
- **Beneficio:** Retroalimentación más clara, mejor experiencia de usuario.

### 12. **Corrección del foco del teclado**
- Después de cambiar de idioma, el foco puede perderse.
- **Acción:** Asegurar que se llame a `SetFocus("WinTetris")` después de cualquier acción de menú.
- **Beneficio:** Entrada de teclado fluida.

### 13. **Modos de juego adicionales (Opcional)**
- Maratón, Sprint, Ultra.
- **Acción:** Implementar modos alternativos con diferentes condiciones de victoria.
- **Beneficio:** Rejugabilidad.

---

## Cómo contribuir

1. Haz un fork del repositorio.
2. Elige un elemento de la lista anterior.
3. Crea una rama y desarrolla la funcionalidad.
4. Envía un pull request con una descripción clara de tus cambios.

Agradecemos contribuciones que mejoren el juego manteniendo el código limpio y compatible con Harbour + HMG Extended.

---

## Licencia

Este proyecto está bajo licencia MIT – siéntete libre de usarlo y modificarlo.

**📧 Contact / Contacto:** marvijarrin@gmail.com  
**🌐 Website / Sitio Web:** badasystem.com  
**📅 Last Updated / Última Actualización:** September 6, 2026