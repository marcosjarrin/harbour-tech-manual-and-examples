# Harbour Tech Manual & Examples

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Harbour](https://img.shields.io/badge/Language-Harbour-xBase-blue)](https://harbour.github.io/)
[![Status](https://img.shields.io/badge/Status-Active-success)](.)

## 📘 About This Repository

Welcome to **Harbour Tech Manual & Examples**, a comprehensive educational resource dedicated to the **Harbour** programming language. 

Harbour is a modern, open-source xBase compiler that maintains compatibility with Clipper while offering advanced features like object-oriented programming, multi-platform support (Windows, Linux, macOS, etc.), and integration with modern technologies.

This project bridges the gap between legacy knowledge and modern development practices. It is designed to help developers—especially those migrating from **Clipper/xBase**—understand how to leverage Harbour in real-world scenarios. Whether you are writing procedural scripts, functional logic, or object-oriented applications, this repository provides curated notes, mini-manuals, and working code examples.

> **🌍 Bilingual Content:** This repository contains documentation and examples in both **English** and **Spanish** to support a wider community of developers.

---

## 🎯 Objectives

1.  **Educational Foundation:** Provide clear, step-by-step manuals for beginners and reference guides for experts.
2.  **Practical Application:** Move beyond theory with runnable code snippets ranging from simple functions to small, complete applications.
3.  **Modern Integration:** Demonstrate how Harbour interacts with JSON, REST APIs, SQL databases, and modern GUI toolkits.
4.  **Community Driven:** Maintain a "living manual" that evolves through community contributions, suggestions, and corrections.

---

## 📚 What's Inside?

The repository is organized into logical sections to facilitate learning. Here is what you will find:

### 1. Technical Manuals (`/docs`)
Detailed documentation covering core concepts.
*   **Getting Started:** Installation, environment setup, and compilation.
*   **Language Core:** Variables, control structures, code blocks, and macros.
*   **Paradigms:** Procedural vs. Functional vs. Object-Oriented Programming (OOP) in Harbour.
*   **Data Handling:** Working with DBF, RDDs, SQL connections, and JSON parsing.

### 2. Code Examples (`/examples`)
A curated collection of source code, categorized by complexity:
*   **🟢 Snippets:** Single-function examples (e.g., string manipulation, date calculations).
*   **🟡 Step-by-Step:** Annotated programs explaining logic flow and specific APIs.
*   **🔴 Mini-Apps:** Complete, compilable projects with simple architectures (e.g., an inventory system, a text processor).

### 3. Tools & Configuration (`/resources`)
*   Sample `.hbc` and `.hbp` project files.
*   Scripts for automated compilation using `hbmk2`.
*   Editor configurations (VS Code, Vim, etc.) for Harbour syntax highlighting.

---

## 🚀 Quick Start

### Prerequisites
To run the examples in this repository, you need:
1.  **Harbour Compiler:** Download from the [official Harbour repository](https://github.com/harbour/core).
2.  **Build Tool:** We recommend using `hbmk2` (Harbour Make) for compiling projects.
3.  **Text Editor:** Any text editor, preferably one with xBase syntax support.

### Compiling an Example
Most examples come with a build script. Here is a generic workflow:

```bash
# Navigate to an example folder
cd examples/basic/hello_world

# Compile using hbmk2
hbmk2 hello_world.hbp

# Run the executable
./hello_world
```

# Español
# Manual Técnico y Ejemplos de Harbour

[![Licencia: MIT](https://img.shields.io/badge/Licencia-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lenguaje](https://img.shields.io/badge/Lenguaje-Harbour-xBase-blue)](https://harbour.github.io/)
[![Estado](https://img.shields.io/badge/Estado-Activo-success)](.)

## 📘 Sobre Este Repositorio

Bienvenido a **Manual Técnico y Ejemplos de Harbour**, un recurso educativo integral dedicado al lenguaje de programación **Harbour**. 

Harbour es un compilador xBase moderno y de código abierto que mantiene la compatibilidad con Clipper, ofreciendo al mismo tiempo características avanzadas como programación orientada a objetos, soporte multiplataforma (Windows, Linux, macOS, etc.) e integración con tecnologías modernas.

Este proyecto tiende un puente entre el conocimiento legacy y las prácticas de desarrollo modernas. Está diseñado para ayudar a los desarrolladores, especialmente a aquellos que migran desde **Clipper/xBase**, a entender cómo aprovechar Harbour en escenarios del mundo real. Ya sea que escribas scripts procedimentales, lógica funcional o aplicaciones orientadas a objetos, este repositorio proporciona notas curadas, mini-manuales y ejemplos de código funcionales.

> **🌍 Contenido Bilingüe:** Este repositorio contiene documentación y ejemplos tanto en **Español** como en **Inglés** para apoyar a una comunidad más amplia de desarrolladores.

---

## 🎯 Objetivos

1.  **Fundación Educativa:** Proporcionar manuales claros y paso a paso para principiantes y guías de referencia para expertos.
2.  **Aplicación Práctica:** Ir más allá de la teoría con fragmentos de código ejecutables, desde funciones simples hasta pequeñas aplicaciones completas.
3.  **Integración Moderna:** Demostrar cómo interactúa Harbour con JSON, APIs REST, bases de datos SQL y toolkits GUI modernos.
4.  **Impulsado por la Comunidad:** Mantener un "manual vivo" que evoluciona a través de contribuciones, sugerencias y correcciones de la comunidad.

---

## 📚 ¿Qué hay dentro?

El repositorio está organizado en secciones lógicas para facilitar el aprendizaje. Esto es lo que encontrarás:

### 1. Manuales Técnicos (`/docs`)
Documentación detallada que cubre conceptos centrales.
*   **Primeros Pasos:** Instalación, configuración del entorno y compilación.
*   **Núcleo del Lenguaje:** Variables, estructuras de control, bloques de código y macros.
*   **Paradigmas:** Programación Procedural vs. Funcional vs. Orientada a Objetos (OOP) en Harbour.
*   **Manejo de Datos:** Trabajo con DBF, RDDs, conexiones SQL y parseo de JSON.

### 2. Ejemplos de Código (`/examples`)
Una colección curada de código fuente, categorizada por complejidad:
*   **🟢 Fragmentos (Snippets):** Ejemplos de una sola función (ej. manipulación de strings, cálculos de fechas).
*   **🟡 Paso a Paso:** Programas anotados que explican el flujo lógico y APIs específicas.
*   **🔴 Mini-Aplicaciones:** Proyectos completos y compilables con arquitecturas sencillas (ej. un sistema de inventario, un procesador de texto).

### 3. Herramientas y Configuración (`/resources`)
*   Archivos de proyecto de ejemplo `.hbc` y `.hbp`.
*   Scripts para compilación automatizada usando `hbmk2`.
*   Configuraciones de editores (VS Code, Vim, etc.) para resaltado de sintaxis Harbour.

---

## 🚀 Inicio Rápido

### Prerrequisitos
Para ejecutar los ejemplos de este repositorio, necesitas:
1.  **Compilador Harbour:** Descárgalo desde el [repositorio oficial de Harbour](https://github.com/harbour/core).
2.  **Herramienta de Build:** Recomendamos usar `hbmk2` (Harbour Make) para compilar proyectos.
3.  **Editor de Texto:** Cualquier editor de texto, preferiblemente uno con soporte de sintaxis xBase.

### Compilar un Ejemplo
La mayoría de los ejemplos vienen con un script de construcción. Aquí hay un flujo de trabajo genérico:

```bash
# Navegar a la carpeta de un ejemplo
cd examples/basic/hello_world

# Compilar usando hbmk2
hbmk2 hello_world.hbp

# Ejecutar el binario
./hello_world

