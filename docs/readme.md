# Harbour & MiniGUI Extended Technical Documentation

## English | [Español](#español)

---

# English

## 📚 Overview

Welcome to the **Harbour & MiniGUI Extended Technical Documentation** repository. This folder contains a comprehensive collection of technical manuals, guides, and reference materials covering everything from fundamental concepts to advanced internals of the Harbour programming language and the MiniGUI Extended graphical interface framework.

Whether you are a beginner taking your first steps or an experienced developer seeking deep technical knowledge, this repository has something for you.

---

## 🎯 Target Audience

- **Beginner developers** learning Harbour and MiniGUI Extended
- **Intermediate programmers** looking to deepen their understanding
- **Advanced developers** and **system architects** needing technical depth
- **Educators** and **technical writers** preparing course materials
- **Open-source contributors** to Harbour and MiniGUI projects

---

## 📖 What You Will Find Here

### 1. Programming Paradigms

- **Functional Programming in Harbour** — Learn how to write clean, efficient code using `FUNCTION` and `PROCEDURE` as the fundamental building blocks. Understand pure functions, composition, and higher-order programming with codeblocks.
- **Object-Oriented Programming (OOP) in Harbour** — Comprehensive guides on using `CLASS ... ENDCLASS` syntax, encapsulation, inheritance, polymorphism, and design patterns. Harbour implements a robust OOP model inspired by the Class(y) library used in Clipper.
- **Comparative Analysis** — Detailed comparisons between functional and OOP approaches, with decision guidelines for choosing the right paradigm for your project size and complexity.

### 2. Database Fundamentals

- **DBF File Structure** — Technical deep-dive into the internal layout of `.dbf` files, including record headers, field descriptors, and data storage mechanisms.
- **CDX Index Files** — Complete technical documentation on `.cdx` index files, including:
  - **B+ Tree Structure**: Understand how CDX pages (512 bytes each) are organized in a B-tree structure with leaf, branch, and root pages.
  - **Page Types and Formats**: Detailed breakdown of CDX page headers and data layouts.
  - **Index Page Size**: How to configure custom page sizes (power of 2 values from 512 up to 8192 bytes).
  - **Tag Management**: Creating and managing multiple index tags within a single CDX file.
- **Hash Tables** — Technical explanation of hash-based data structures and their implementation in Harbour.

### 3. MiniGUI Extended Framework

- **Architecture Overview** — Understanding the MiniGUI Extended environment for developing Windows desktop applications.
- **Pseudo-OOP Syntax** — Documentation on the traditional property-based syntax used in MiniGUI.
- **Win32 API Integration** — Technical deep-dive into how HMG Extended integrates with the Windows API.
- **Controls and Components** — Detailed guides on buttons, grids, text boxes, and other GUI elements.

### 4. Practical Examples and Code Snippets

- Real-world code examples demonstrating key concepts
- Best practices for database handling and indexing
- GUI application patterns and architecture templates
- Performance optimization techniques

---

## 🤝 Contributing

Contributions are welcome! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) guide for details on how to submit improvements, corrections, or new content.

---

## 📚 Additional Resources

- [Official Harbour Website](https://harbour.github.io)
- [MiniGUI Extended Official Site](https://www.hmgextended.com)
- [HMG Forum](https://groups.google.com/g/minigui-forum)
- [Harbour OOP Manual](https://github.com/marcosjarrin/Harbour_oop_manual)

---

## 📄 License

This documentation is provided under the [MIT License](LICENSE).

---

# Español

## 📚 Descripción General

Bienvenido al repositorio de **Documentación Técnica de Harbour & MiniGUI Extended**. Esta carpeta contiene una colección completa de manuales técnicos, guías y materiales de referencia que cubren desde conceptos fundamentales hasta los internos más avanzados del lenguaje de programación Harbour y el framework de interfaz gráfica MiniGUI Extended.

Ya seas un principiante dando tus primeros pasos o un desarrollador experimentado en busca de conocimiento técnico profundo, este repositorio tiene algo para ti.

---

## 🎯 Audiencia Objetivo

- **Desarrolladores principiantes** que aprenden Harbour y MiniGUI Extended
- **Programadores intermedios** que desean profundizar su comprensión
- **Desarrolladores avanzados** y **arquitectos de sistemas** que necesitan profundidad técnica
- **Educadores** y **escritores técnicos** que preparan materiales de curso
- **Colaboradores de código abierto** en proyectos Harbour y MiniGUI

---

## 📖 Qué Encontrarás Aquí

### 1. Paradigmas de Programación

- **Programación Funcional en Harbour** — Aprende a escribir código limpio y eficiente usando `FUNCTION` y `PROCEDURE` como bloques fundamentales. Comprende funciones puras, composición y programación de orden superior con codeblocks.
- **Programación Orientada a Objetos (OOP) en Harbour** — Guías completas sobre el uso de la sintaxis `CLASS ... ENDCLASS`, encapsulamiento, herencia, polimorfismo y patrones de diseño. Harbour implementa un modelo OOP robusto inspirado en la biblioteca Class(y) usada en Clipper.
- **Análisis Comparativo** — Comparaciones detalladas entre enfoques funcionales y OOP, con guías de decisión para elegir el paradigma adecuado según el tamaño y complejidad de tu proyecto.

### 2. Fundamentos de Bases de Datos

- **Estructura de Archivos DBF** — Inmersión técnica profunda en el diseño interno de los archivos `.dbf`, incluyendo cabeceras de registros, descriptores de campos y mecanismos de almacenamiento de datos.
- **Archivos de Índice CDX** — Documentación técnica completa sobre archivos de índice `.cdx`, incluyendo:
  - **Estructura de Árbol B+**: Comprende cómo las páginas CDX (512 bytes cada una) se organizan en una estructura de árbol B+ con páginas hoja, rama y raíz.
  - **Tipos de Página y Formatos**: Desglose detallado de cabeceras y diseños de datos de páginas CDX.
  - **Tamaño de Página de Índice**: Cómo configurar tamaños de página personalizados (potencias de 2 desde 512 hasta 8192 bytes).
  - **Gestión de Etiquetas**: Creación y gestión de múltiples etiquetas de índice dentro de un único archivo CDX.
- **Tablas Hash** — Explicación técnica de estructuras de datos basadas en hash y su implementación en Harbour.

### 3. Framework MiniGUI Extended

- **Visión General de la Arquitectura** — Comprender el entorno MiniGUI Extended para desarrollar aplicaciones de escritorio en Windows.
- **Sintaxis Pseudo-OOP** — Documentación sobre la sintaxis tradicional basada en propiedades usada en MiniGUI.
- **Integración con la API Win32** — Inmersión técnica profunda en cómo HMG Extended se integra con la API de Windows.
- **Controles y Componentes** — Guías detalladas sobre botones, grids, cuadros de texto y otros elementos GUI.

### 4. Ejemplos Prácticos y Fragmentos de Código

- Ejemplos de código del mundo real que demuestran conceptos clave
- Mejores prácticas para manejo de bases de datos e indexación
- Patrones de aplicaciones GUI y plantillas de arquitectura
- Técnicas de optimización de rendimiento

---

## 🤝 Cómo Contribuir

¡Las contribuciones son bienvenidas! Por favor, lee nuestra guía contributing.md para detalles sobre cómo enviar mejoras, correcciones o nuevo contenido.

---

## 📚 Recursos Adicionales

- [Sitio Oficial de Harbour](https://harbour.github.io)
- [Sitio Oficial de MiniGUI Extended](https://www.hmgextended.com)
- [Foro HMG](https://groups.google.com/g/minigui-forum)
- [Manual de OOP en Harbour](https://github.com/marcosjarrin/Harbour_oop_manual)

---

## 📄 Licencia

Esta documentación se proporciona bajo la [Licencia MIT](LICENSE).