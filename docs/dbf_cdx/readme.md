# DBF & CDX Explorer for Harbour

[English](#english) | [Español](#español)

---

<a name="english"></a>
## English

Welcome to the **DBF & CDX Explorer** repository – a comprehensive resource for understanding and working with the low‑level structure of **dBase III+ compatible DBF files** and **CDX index files** (B+‑tree implementation) using the **Harbour** language.

This project is ideal for developers who want to:
- Learn the **binary internals** of DBF and CDX formats.
- Manipulate DBF files **without relying on Harbour’s RDD** (Runtime Data Driver).
- Explore a clean **Object‑Oriented Programming (OOP)** example in Harbour.
- Use the provided technical whitepapers as reference documentation.

---

### 📁 Repository Structure

```
.
├── docs/
│   ├── Structure of a DBF File.md          # Detailed DBF format whitepaper
│   └── The CDX File Format as a B+ Tree Implementation.md  # CDX / B+tree internals
├── src/
│   ├── application.prg                     # Main entry point (TApp)
│   ├── dbf_crud.prg                        # TDBFFile class (low‑level I/O)
│   ├── error.prg                           # TErrorMgr class
│   ├── file_i_o.prg                        # Low‑level file helpers
│   ├── recordmodel.prg                     # TPersonRec model
│   ├── utility.prg                         # Endian conversion, padding, etc.
│   ├── user_manual_en.md                   # Complete user manual (English) 
│   └── user_manual_es.md                   # Complete user manual (Spanish) 
│   
│    
└── README.md                               # This file
```

> **Note**: The `src/` folder contains all Harbour source code. Compile with `hbmk2` or the Harbour compiler of your choice.

---

### 📖 Documentation

1. **[Structure of a DBF File](docs/Structure%20of%20a%20DBF%20File.md)**  
   A technical whitepaper that describes every byte of the DBF header, field descriptors, data area, memo file (`.FPT`), and integrity considerations.

2. **[The CDX File Format as a B+ Tree Implementation](docs/The%20CDX%20File%20Format%20as%20a%20B+%20Tree%20Implementation.md)**  
   An in‑depth analysis of CDX index files, including node layout, B+‑tree algorithms (search, insert, delete), prefix compression, and performance trade‑offs. Contains step‑by‑step animations and Harbour code examples.

3. **[User Manual (English)](docs/user_manual_en.md)**  
   Complete guide to the Harbour CRUD application: installation, compilation, menu options (create, open, add, list, update, delete, read one record, close), validation rules, and troubleshooting.

---

### 🧪 Harbour Example – Low‑Level DBF CRUD without RDD

The `src/` directory contains a **full object‑oriented Harbour application** that performs **Create, Read, Update, Delete** operations on a DBF file **without using any high‑level database commands** (`USE`, `APPEND`, `REPLACE`, etc.). Instead, it directly reads and writes bytes using `FOpen()`, `FRead()`, `FWrite()`, `FSeek()`.

#### Key features

- Pure low‑level file I/O – demonstrates complete understanding of the DBF binary layout.
- Clean OOP design with separate classes for file management, data modelling, error handling, and user interface.
- Full validation (name length, age range, date format, logical values).
- Logical deletion (marked with `*`) – deleted records are hidden from lists but can be recovered.
- Header metadata is correctly updated on close (record count, last modified date).

#### Compile & run

```bash
# Clone the repository
git clone https://github.com/yourusername/dbf-cdx-explorer.git
cd dbf-cdx-explorer/src

# Compile with Harbour (example using hbmk2)
hbmk2 application.prg dbf_crud.prg error.prg file_i_o.prg recordmodel.prg utility.prg -o dbfcrud

# Run the program (optional: specify a DBF file path)
./dbfcrud          # uses default "people.dbf"
./dbfcrud /path/to/myfile.dbf
```

Once running, follow the numbered menu. See the [User Manual](docs/user_manual_en.md) for detailed usage.

---

### 🤝 Contributing

Issues, suggestions, and pull requests are welcome. If you find a bug in the DBF/CDX documentation or the Harbour example, please open an issue.

---

### 📜 License

This project is provided under the **MIT License**. You are free to use, modify, and distribute the code and documentation.

---

<a name="español"></a>
## Español

Bienvenido al repositorio **DBF & CDX Explorer** – un recurso completo para entender y trabajar a bajo nivel con archivos **DBF compatibles con dBase III+** y archivos de índice **CDX** (implementación de árbol B+) utilizando el lenguaje **Harbour**.

Este proyecto es ideal para desarrolladores que deseen:
- Aprender la **estructura binaria** interna de los formatos DBF y CDX.
- Manipular archivos DBF **sin depender del RDD de Harbour**.
- Explorar un ejemplo limpio de **Programación Orientada a Objetos (POO)** en Harbour.
- Utilizar los documentos técnicos como referencia.

---

### 📁 Estructura del Repositorio

```
.
├── docs/
│   ├── Structure of a DBF File.md          # Documento técnico del formato DBF
│   └── The CDX File Format as a B+ Tree Implementation.md  # Internals de CDX / B+tree
├── src/
│   ├── application.prg                     # Punto de entrada (TApp)
│   ├── dbf_crud.prg                        # Clase TDBFFile (I/O de bajo nivel)
│   ├── error.prg                           # Clase TErrorMgr
│   ├── file_i_o.prg                        # Ayudantes de archivos
│   ├── recordmodel.prg                     # Modelo TPersonRec
│   ├── utility.prg                         # Conversión endian, relleno, etc.
│   ├── user_manual_en.md                   # Manual de usuario (inglés)
│   └── user_manual_es.md                   # Manual de usuario (español)
│        
└── README.md                               # Este archivo
```

> **Nota**: La carpeta `src/` contiene todo el código fuente Harbour. Compila con `hbmk2` o el compilador Harbour de tu preferencia.

---

### 📖 Documentación

1. **[Structure of a DBF File](docs/Structure%20of%20a%20DBF%20File.md)**  
   Documento técnico que describe cada byte de la cabecera DBF, los descriptores de campo, el área de datos, el archivo memo (`.FPT`) y consideraciones de integridad.

2. **[The CDX File Format as a B+ Tree Implementation](docs/The%20CDX%20File%20Format%20as%20a%20B+%20Tree%20Implementation.md)**  
   Análisis en profundidad de los índices CDX: diseño de nodos, algoritmos de árbol B+ (búsqueda, inserción, borrado), compresión de prefijos y características de rendimiento. Incluye animaciones paso a paso y ejemplos de código Harbour.

3. **[Manual de Usuario (inglés)](docs/user_manual_en.md)**  
   Guía completa de la aplicación CRUD en Harbour: instalación, compilación, opciones del menú (crear, abrir, agregar, listar, actualizar, borrar lógico, leer un registro, cerrar), reglas de validación y solución de problemas.

---

### 🧪 Ejemplo en Harbour – CRUD de DBF de Bajo Nivel sin RDD

El directorio `src/` contiene una **aplicación Harbour orientada a objetos** que realiza operaciones **Crear, Leer, Actualizar, Borrar** sobre un archivo DBF **sin utilizar comandos de alto nivel** (`USE`, `APPEND`, `REPLACE`, etc.). En su lugar, lee y escribe bytes directamente con `FOpen()`, `FRead()`, `FWrite()`, `FSeek()`.

#### Características principales

- I/O de archivos puramente de bajo nivel – demuestra un conocimiento completo del formato binario DBF.
- Diseño POO limpio con clases separadas para gestión de archivos, modelo de datos, manejo de errores e interfaz de usuario.
- Validación completa (longitud de nombre, rango de edad, formato de fecha, valores lógicos).
- Borrado lógico (marcado con `*`) – los registros borrados no se muestran en las listas, pero pueden recuperarse.
- Los metadatos de la cabecera (número de registros, fecha de última modificación) se actualizan correctamente al cerrar.

#### Compilar y ejecutar

```bash
# Clonar el repositorio
git clone https://github.com/tuusuario/dbf-cdx-explorer.git
cd dbf-cdx-explorer/src

# Compilar con Harbour (ejemplo con hbmk2)
hbmk2 application.prg dbf_crud.prg error.prg file_i_o.prg recordmodel.prg utility.prg -o dbfcrud

# Ejecutar el programa (opcional: especificar ruta de un DBF)
./dbfcrud          # usa "people.dbf" por defecto
./dbfcrud /ruta/a/miarchivo.dbf
```

Una vez en ejecución, sigue el menú numerado. Consulta el [Manual de Usuario](docs/user_manual_en.md) para un uso detallado.

---

### 🤝 Contribuciones

Las sugerencias, reportes de errores y pull requests son bienvenidos. Si encuentras algún error en la documentación de DBF/CDX o en el ejemplo Harbour, por favor abre un *issue*.

---

### 📜 Licencia

Este proyecto se distribuye bajo la **Licencia MIT**. Eres libre de usar, modificar y distribuir el código y la documentación.
