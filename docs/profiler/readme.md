# 🚀 Why a Profiler in Harbour Matters — And Why Industry Standards Are Non-Negotiable

## 📖 Introduction

If you have ever shipped a Harbour application that felt sluggish — a window that takes three seconds to open, a report that hangs the UI, a loop that mysteriously eats CPU — you already know the pain of **not knowing where the time goes**. That is exactly the problem a profiler solves.

A profiler is not a luxury. It is the equivalent of an X-ray machine for your code. Without it, you are debugging performance blindly, guessing, and often optimizing the wrong thing. In the Harbour ecosystem — where many applications are decades old, mission-critical, and still running on enterprise desktops — this gap is particularly painful.

This article explains **why profiling matters in Harbour**, **why building your own profiler is worth the effort**, and **why it must follow industry standards** to be truly useful.

---

## 🔍 What Is a Profiler, Really?

A profiler is a tool that **measures the runtime behavior of a program**. It answers questions like:

- 🕐 How long does each function take?
- 🔁 How many times is each function called?
- 🐢 Which function is the bottleneck?
- 🧠 How much memory is allocated and when?
- 🖱️ Which UI event is slowing down the user experience?
- 📉 Which code path is never executed (dead code)?

There are two main families:

| Type | How it works | Example |
|------|--------------|---------|
| **Instrumenting profiler** | Injects counters/timers into each function | Harbour's built-in `HB_USE_PROFILER` |
| **Sampling profiler** | Periodically snapshots the call stack | `perf`, `VTune`, `py-spy` |

Both are valid. The best tools combine both.

---

## 🧱 Why Harbour Needs a Modern Profiler

Harbour ships with a **basic built-in profiler**. It is activated with:

```harbour
__SetProfiler( .T. )
```

And you can retrieve per-function data with:

```harbour
__dynsGetPRF( ndsIndex )   // returns { nCalls, nTime }
```

That's useful — but it has **serious limitations**:

1. ⏱️ **Poor time resolution** — it uses `clock()` with granularity in the tens of milliseconds. Useless for measuring fast functions.
2. 🧩 **No structured output** — reports are plain text, not JSON or CSV. You cannot feed them into dashboards, CI pipelines, or APM systems.
3. 🎛️ **No UI integration** — MiniGUI Extended callbacks (`ON CLICK`, `ON INIT`, etc.) are invisible to it.
4. 🔨 **Requires recompiling Harbour itself** with `HB_USE_PROFILER`, which most production environments do not do.
5. 📉 **No self-time** — you cannot distinguish time spent in a function from time spent in its children.

In short: the native profiler is a good foundation, but it is **not enough for modern development workflows**.

---

## 🏗️ Why Build a Custom Profiler?

Building a profiler for Harbour is not reinventing the wheel — it is **extending the wheel with a modern rim**.

### ✅ Reasons to build one:

1. **Zero-cost visibility** — You get insights without paying for commercial tools.
2. **Framework awareness** — It can understand MiniGUI Extended, `TWindow`, `TButton`, event loops, etc.
3. **CI/CD integration** — JSON and CSV outputs plug directly into Jenkins, GitHub Actions, GitLab CI.
4. **Regression detection** — Compare profiles across commits to catch performance regressions automatically.
5. **Production-safe** — Configurable overhead (e.g., sampling every N calls) makes it safe even in live deployments.
6. **Portability** — A Harbour-based profiler runs wherever Harbour runs: Windows, Linux, macOS, embedded.

---

## 📏 Why Follow Industry Standards?

A profiler that speaks its own language is a **silo**. A profiler that speaks industry standards is a **platform**.

### 🎯 The standards that matter:

| Standard | What it gives you |
|----------|-------------------|
| **OpenTelemetry Profiles** (emerging) | A common schema for profiles, spans, and attributes. Compatible with Jaeger, Grafana, Tempo. |
| **pprof** (Google) | The de-facto format for CPU/heap profiles. Supported by Go, Python, Rust, Java. |
| **Chrome Trace Format (JSON)** | Open directly in `chrome://tracing` or `perfetto`. |
| **RFC 4180 CSV** | Universal tabular interchange. Readable by Excel, pandas, R. |
| **JSON Schema** | Machine-validatable profiles. |

### 📌 Why this matters for Harbour:

- 🧑‍💻 **Interoperability** — You can compare a Harbour profile with a C# profile from the same system.
- 📊 **Tooling reuse** — You do not need to build a viewer; existing tools already parse these formats.
- 🧪 **Automated testing** — CI scripts can parse JSON and fail the build if a threshold is exceeded.
- 📚 **Longevity** — Standards outlive frameworks. Your profiler data will still be readable in ten years.
- 🤝 **Collaboration** — Teams from different stacks can share results without translation.

---

## 🛠️ The Hybrid Approach: Harbour + Minimal C

Pure Harbour is powerful, but a **profiler has one non-negotiable requirement**: high-resolution, monotonic timing. Harbour's `hb_MilliSeconds()` is not enough.

The pragmatic solution:

| Component | Language | Why |
|-----------|----------|-----|
| Timer (`ProfilerNow`) | **C** | Needs `QueryPerformanceCounter` (Windows) / `clock_gettime(CLOCK_MONOTONIC)` (Linux) |
| Aggregation, storage, class logic | **Harbour** | Portable, maintainable, no ABI headaches |
| JSON/CSV generation | **Harbour** | `hb_JsonEncode()` is fast enough; CSV is trivial |
| MiniGUI event hooks | **Harbour** | Direct access to `TWindow`, `TControl` |
| Sampling hook (optional) | **C** | Only if you need stack-walking at opcode level |

This gives you **95% Harbour code** with just the timer and (optionally) the sampler in C. The result is portable, testable, and fast.

---

## 📐 What a Good Profile Report Looks Like

### JSON (OpenTelemetry-inspired)

```json
{
  "profile_id": "550e8400-e29b-41d4-a716-446655440000",
  "start_time": "2026-03-26T10:00:00Z",
  "end_time": "2026-03-26T10:00:05Z",
  "duration_us": 5000000,
  "samples": [
    {
      "function": "MAIN",
      "file": "main.prg",
      "line": 10,
      "calls": 1,
      "total_time_us": 1200000,
      "self_time_us": 800000,
      "min_time_us": 1200000,
      "max_time_us": 1200000,
      "avg_time_us": 1200000
    }
  ]
}
```

### CSV (RFC 4180)

```
Function,File,Line,Calls,TotalTime_us,MinTime_us,MaxTime_us,AvgTime_us,SelfTime_us
MAIN,main.prg,10,1,1200000,1200000,1200000,1200000,800000
```

Both formats are trivial to parse, diff, graph, and archive. That is the whole point.

---

## 🧭 Practical Workflow

A modern Harbour profiling workflow looks like this:

1. 🔧 Build with `HB_USE_PROFILER` enabled.
2. 🎬 `ProfilerStart()` at application entry.
3. 🖱️ Let the user exercise the app (or run an automated UI script).
4. 🛑 `ProfilerStop()`.
5. 💾 `ProfilerSaveToFile( "run.json", "json" )`.
6. 📊 Load into Grafana / Chrome Tracing / pandas.
7. 🎯 Find the top-N slowest functions.
8. 🔁 Optimize. Re-profile. Compare.
9. 🤖 Automate: run this in CI on every commit.

That is the difference between **guessing** and **engineering**.

---

## 🏁 Conclusion

A profiler is not a "nice to have." It is the **microscope of performance engineering**. For Harbour — a language with decades of production code, complex UIs, and enterprise expectations — a modern profiler is the missing piece that turns "it works" into "it works fast, and we can prove it."

Building it in Harbour (with a pinch of C for timing) is not only feasible — it is the right choice. And following industry standards (OpenTelemetry, pprof, Chrome Trace, RFC 4180) is what turns your profiler from a personal script into a **professional tool**.

> 🎯 **Measure first. Optimize second. Standardize always.**

---

# 🚀 Por Qué un Profiler en Harbour es Importante — Y Por Qué los Estándares de la Industria No Son Negociables

## 📖 Introducción

Si alguna vez has entregado una aplicación Harbour que se siente lenta — una ventana que tarda tres segundos en abrir, un reporte que congela la interfaz, un bucle que se come la CPU misteriosamente — ya conoces el dolor de **no saber dónde se va el tiempo**. Ese es exactamente el problema que resuelve un profiler.

Un profiler no es un lujo. Es el equivalente a una máquina de rayos X para tu código. Sin él, depuras el rendimiento a ciegas, adivinas, y a menudo optimizas lo que no debes. En el ecosistema Harbour — donde muchas aplicaciones tienen décadas de antigüedad, son críticas para el negocio y siguen corriendo en escritorios empresariales — esta carencia es especialmente dolorosa.

Este artículo explica **por qué el profiling importa en Harbour**, **por qué vale la pena construir tu propio profiler**, y **por qué debe seguir estándares de la industria** para ser realmente útil.

---

## 🔍 ¿Qué es Realmente un Profiler?

Un profiler es una herramienta que **mide el comportamiento en tiempo de ejecución de un programa**. Responde preguntas como:

- 🕐 ¿Cuánto tarda cada función?
- 🔁 ¿Cuántas veces se llama cada función?
- 🐢 ¿Cuál función es el cuello de botella?
- 🧠 ¿Cuánta memoria se asigna y cuándo?
- 🖱️ ¿Qué evento de UI está ralentizando la experiencia del usuario?
- 📉 ¿Qué ruta de código nunca se ejecuta (código muerto)?

Hay dos familias principales:

| Tipo | Cómo funciona | Ejemplo |
|------|---------------|---------|
| **Profiler por instrumentación** | Inyecta contadores/temporizadores en cada función | El profiler nativo de Harbour (`HB_USE_PROFILER`) |
| **Profiler por muestreo** | Captura periódicamente la pila de llamadas | `perf`, `VTune`, `py-spy` |

Ambos son válidos. Las mejores herramientas combinan los dos.

---

## 🧱 Por Qué Harbour Necesita un Profiler Moderno

Harbour incluye un **profiler básico**. Se activa con:

```harbour
__SetProfiler( .T. )
```

Y puedes recuperar datos por función con:

```harbour
__dynsGetPRF( ndsIndex )   // devuelve { nCalls, nTime }
```

Eso es útil — pero tiene **limitaciones serias**:

1. ⏱️ **Mala resolución temporal** — usa `clock()` con granularidad de decenas de milisegundos. Inútil para medir funciones rápidas.
2. 🧩 **Sin salida estructurada** — los reportes son texto plano, no JSON o CSV. No puedes alimentar dashboards, pipelines de CI o sistemas APM.
3. 🎛️ **Sin integración con UI** — los callbacks de MiniGUI Extended (`ON CLICK`, `ON INIT`, etc.) son invisibles para él.
4. 🔨 **Requiere recompilar Harbour** con `HB_USE_PROFILER`, algo que la mayoría de entornos de producción no hace.
5. 📉 **Sin self-time** — no puedes distinguir el tiempo dentro de una función del tiempo en sus hijos.

En resumen: el profiler nativo es una buena base, pero **no es suficiente para flujos de trabajo modernos**.

---

## 🏗️ ¿Por Qué Construir un Profiler Propio?

Construir un profiler para Harbour no es reinventar la rueda — es **extender la rueda con un rin moderno**.

### ✅ Razones para construirlo:

1. **Visibilidad sin costo** — Obtienes información sin pagar herramientas comerciales.
2. **Conocimiento del framework** — Puede entender MiniGUI Extended, `TWindow`, `TButton`, bucles de eventos, etc.
3. **Integración con CI/CD** — Salidas JSON y CSV se conectan directamente a Jenkins, GitHub Actions, GitLab CI.
4. **Detección de regresiones** — Compara perfiles entre commits para atrapar regresiones de rendimiento automáticamente.
5. **Seguro en producción** — Overhead configurable (ej. muestreo cada N llamadas) lo hace viable incluso en despliegues en vivo.
6. **Portabilidad** — Un profiler en Harbour corre donde corre Harbour: Windows, Linux, macOS, embebido.

---

## 📏 ¿Por Qué Seguir Estándares de la Industria?

Un profiler que habla su propio idioma es un **silo**. Un profiler que habla estándares es una **plataforma**.

### 🎯 Los estándares que importan:

| Estándar | Qué te aporta |
|----------|---------------|
| **OpenTelemetry Profiles** (emergente) | Esquema común para perfiles, spans y atributos. Compatible con Jaeger, Grafana, Tempo. |
| **pprof** (Google) | Formato de facto para perfiles de CPU/memoria. Soportado por Go, Python, Rust, Java. |
| **Chrome Trace Format (JSON)** | Se abre directamente en `chrome://tracing` o `perfetto`. |
| **RFC 4180 CSV** | Intercambio tabular universal. Legible por Excel, pandas, R. |
| **JSON Schema** | Perfiles validables por máquina. |

### 📌 Por qué importa para Harbour:

- 🧑‍💻 **Interoperabilidad** — Puedes comparar un perfil Harbour con un perfil C# del mismo sistema.
- 📊 **Reutilización de herramientas** — No necesitas construir un visor; ya existen.
- 🧪 **Pruebas automatizadas** — Scripts de CI pueden parsear JSON y fallar el build si se excede un umbral.
- 📚 **Longevidad** — Los estándares sobreviven a los frameworks. Tus datos serán legibles en diez años.
- 🤝 **Colaboración** — Equipos de distintos stacks comparten resultados sin traducción.

---

## 🛠️ El Enfoque Híbrido: Harbour + C Mínimo

Harbour puro es potente, pero un **profiler tiene un requisito no negociable**: temporización monotónica de alta resolución. `hb_MilliSeconds()` de Harbour no basta.

La solución pragmática:

| Componente | Lenguaje | Por qué |
|------------|----------|---------|
| Timer (`ProfilerNow`) | **C** | Necesita `QueryPerformanceCounter` (Windows) / `clock_gettime(CLOCK_MONOTONIC)` (Linux) |
| Agregación, almacenamiento, lógica de clases | **Harbour** | Portable, mantenible, sin dolores de ABI |
| Generación JSON/CSV | **Harbour** | `hb_JsonEncode()` es suficientemente rápido; CSV es trivial |
| Hooks de eventos MiniGUI | **Harbour** | Acceso directo a `TWindow`, `TControl` |
| Hook de muestreo (opcional) | **C** | Solo si necesitas recorrer la pila a nivel de opcode |

Esto te da **95% de código Harbour** con solo el timer y (opcionalmente) el sampler en C. El resultado es portable, testeable y rápido.

---

## 📐 Cómo se Ve un Buen Reporte de Perfil

### JSON (inspirado en OpenTelemetry)

```json
{
  "profile_id": "550e8400-e29b-41d4-a716-446655440000",
  "start_time": "2026-03-26T10:00:00Z",
  "end_time": "2026-03-26T10:00:05Z",
  "duration_us": 5000000,
  "samples": [
    {
      "function": "MAIN",
      "file": "main.prg",
      "line": 10,
      "calls": 1,
      "total_time_us": 1200000,
      "self_time_us": 800000,
      "min_time_us": 1200000,
      "max_time_us": 1200000,
      "avg_time_us": 1200000
    }
  ]
}
```

### CSV (RFC 4180)

```
Function,File,Line,Calls,TotalTime_us,MinTime_us,MaxTime_us,AvgTime_us,SelfTime_us
MAIN,main.prg,10,1,1200000,1200000,1200000,1200000,800000
```

Ambos formatos son triviales de parsear, comparar, graficar y archivar. Ese es exactamente el punto.

---

## 🧭 Flujo de Trabajo Práctico

Un flujo moderno de profiling en Harbour se ve así:

1. 🔧 Compila con `HB_USE_PROFILER` habilitado.
2. 🎬 `ProfilerStart()` al arrancar la aplicación.
3. 🖱️ Deja que el usuario ejercite la app (o corre un script automatizado de UI).
4. 🛑 `ProfilerStop()`.
5. 💾 `ProfilerSaveToFile( "run.json", "json" )`.
6. 📊 Carga en Grafana / Chrome Tracing / pandas.
7. 🎯 Encuentra las N funciones más lentas.
8. 🔁 Optimiza. Re-perfila. Compara.
9. 🤖 Automatiza: corre esto en CI en cada commit.

Esa es la diferencia entre **adivinar** e **ingeniería**.

---

## 🏁 Conclusión

Un profiler no es un "nice to have". Es el **microscopio de la ingeniería de rendimiento**. Para Harbour — un lenguaje con décadas de código en producción, interfaces complejas y expectativas empresariales — un profiler moderno es la pieza que falta para convertir "funciona" en "funciona rápido, y podemos probarlo".

Construirlo en Harbour (con una pizca de C para el timing) no solo es factible — es la decisión correcta. Y seguir estándares de la industria (OpenTelemetry, pprof, Chrome Trace, RFC 4180) es lo que transforma tu profiler de un script personal en una **herramienta profesional**.

> 🎯 **Mide primero. Optimiza después. Estandariza siempre.**
