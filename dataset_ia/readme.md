# Harbour MiniGUI Extended Code Dataset

## Dataset Summary

This dataset contains **3,185 complete code examples** written in **Harbour**, specifically focused on the **MiniGUI Extended (HMG Extended)** framework.

Harbour is a modern, open-source implementation of the Clipper/xBase language, widely used for business and desktop applications. MiniGUI Extended is one of its most powerful and popular GUI libraries. Due to the niche nature of xBase dialects, high-quality code corpora are scarce. This dataset aims to bridge that gap, providing a rich resource for training, fine-tuning, and evaluating Large Language Models (LLMs) on legacy system maintenance, desktop application development, and xBase syntax.

### Key Features

- **Size:** 3,185 distinct source code files/examples.
- **Language:** Harbour (xBase family).
- **Framework:** MiniGUI Extended (HMG Extended).
- **Context-Rich:** Preserves original folder structures and filenames, allowing models to understand project architecture and module relationships.
- **Cleaned Data:** Standardized includes (e.g., ensuring `minigui.ch` / `hmg.ch` consistency) to prevent model confusion with other frameworks like FiveWin.

---

## Dataset Structure

### Data Instances

Each row in the dataset represents a single source code file (mostly `.prg` files).

```json
{
  "file_name": "example.prg",
  "extension": "prg",
  "folder_path": "SAMPLES/easy_report/example",
  "text": "#INCLUDE \"minigui.ch\"\n\nFUNCTION Start()\n   // Harbour code here...\nRETURN NIL"
}
```

### Data Fields

| Column | Type | Description |
|--------|------|-------------|
| `file_name` | `string` | The original name of the source file (e.g., `main.prg`). |
| `extension` | `string` | The file extension (mostly `.prg`). |
| `folder_path` | `string` | The directory path indicating the module or project structure. |
| `text` | `string` | The complete, raw source code content. |

---

## Licensing Information

This dataset is distributed under the terms of the **MIT License**.

Permission is hereby granted, free of charge, to any person obtaining a copy of this dataset and associated documentation files, to deal in the dataset without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the dataset, and to permit persons to whom the dataset is furnished to do so, subject to the following condition:

**The above copyright notice and this permission notice shall be included in all copies or substantial portions of the dataset.**

THE DATASET IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATASET OR THE USE OR OTHER DEALINGS IN THE DATASET.

---

## Files and Formats

The dataset is available in two formats: JSONL and Parquet. Since it is very large, the first one is compressed in RAR format, while the other is in Parquet format.

**File:** dataset-harbour-minigui-extended.rar  
**Internal format:** dataset-harbour-minigui-extended.jsonl  
**Size:** 23.6 MB (24,840,277 bytes)

**dataset-harbour-minigui-extended.parquet**  
**Format:** Parquet  
**Size:** 6.49 MB (6,812,313 bytes)

---

# Dataset de Código Harbour MiniGUI Extended

## Resumen del Dataset

Este dataset contiene **3.185 ejemplos de código completos** escritos en **Harbour**, enfocados específicamente en el framework **MiniGUI Extended (HMG Extended)**.

Harbour es una implementación moderna y de código abierto del lenguaje Clipper/xBase, ampliamente utilizado para aplicaciones de escritorio y sistemas empresariales. MiniGUI Extended es una de sus librerías gráficas (GUI) más potentes y populares. Debido a la naturaleza de nicho de los dialectos xBase, los corpus de código de alta calidad son muy escasos. Este dataset tiene como objetivo cubrir ese vacío, proporcionando un recurso valioso para entrenar, ajustar (fine-tuning) y evaluar Modelos de Lenguaje Grande (LLMs) en el mantenimiento de sistemas legacy, desarrollo de aplicaciones de escritorio y sintaxis xBase.

### Características Principales

- **Tamaño:** 3.185 archivos/ejemplos de código fuente distintos.
- **Lenguaje:** Harbour (familia xBase).
- **Framework:** MiniGUI Extended (HMG Extended).
- **Rico en Contexto:** Preserva las rutas de carpetas y nombres de archivos originales, lo que permite a los modelos comprender la arquitectura del proyecto y las relaciones entre módulos.
- **Datos Limpios:** Includes estandarizados (por ejemplo, asegurando la consistencia entre `minigui.ch` y `hmg.ch`) para evitar que el modelo se confunda con otros frameworks como FiveWin.

---

## Estructura del Dataset

### Instancias de Datos

Cada fila en el dataset representa un único archivo de código fuente (mayormente archivos `.prg`).

```json
{
  "file_name": "example.prg",
  "extension": "prg",
  "folder_path": "SAMPLES/easy_report/example",
  "text": "#INCLUDE \"minigui.ch\"\n\nFUNCTION Start()\n   // Código Harbour aquí...\nRETURN NIL"
}
```

### Campos de Datos

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `file_name` | `string` | El nombre original del archivo fuente (ej. `main.prg`). |
| `extension` | `string` | La extensión del archivo (mayormente `.prg`). |
| `folder_path` | `string` | La ruta del directorio que indica el módulo o estructura del proyecto. |
| `text` | `string` | El contenido completo y crudo del código fuente. |

---

## Información de Licencia

Este dataset se distribuye bajo los términos de la **Licencia MIT**.

Por la presente se concede permiso, de forma gratuita, a cualquier persona que obtenga una copia de este dataset y de los archivos de documentación asociados, para utilizar el dataset sin restricción alguna, incluyendo, sin limitación, los derechos de usar, copiar, modificar, fusionar, publicar, distribuir, sublicenciar y/o vender copias del dataset, y para permitir que las personas a las que se les proporcione el dataset hagan lo mismo, sujeto a la siguiente condición:

**El aviso de copyright anterior y este aviso de permiso deberán incluirse en todas las copias o partes sustanciales del dataset.**

EL DATASET SE PROPORCIONA "TAL CUAL", SIN GARANTÍA DE NINGÚN TIPO, EXPRESA O IMPLÍCITA, INCLUYENDO PERO NO LIMITADO A GARANTÍAS DE COMERCIABILIDAD, IDONEIDAD PARA UN PROPÓSITO PARTICULAR Y NO INFRACCIÓN. EN NINGÚN CASO LOS AUTORES O TITULARES DEL COPYRIGHT SERÁN RESPONSABLES POR NINGUNA RECLAMACIÓN, DAÑO U OTRA RESPONSABILIDAD, YA SEA EN UNA ACCIÓN CONTRACTUAL, EXTRACONTRACTUAL O DE OTRO TIPO, QUE SURJA DE, O EN RELACIÓN CON EL DATASET O EL USO U OTRO TIPO DE ACCIONES EN EL DATASET.

---

## Archivos y Formatos

El dataset está disponible en dos formatos: JSONL y Parquet. Como es muy grande, el primero está comprimido en RAR, mientras que el otro está en formato Parquet.

**Archivo:** dataset-harbour-minigui-extended.rar  
**Formato interno:** dataset-harbour-minigui-extended.jsonl  
**Tamaño:** 23,6 MB (24.840.277 bytes)

**dataset-harbour-minigui-extended.parquet**  
**Formato:** Parquet  
**Tamaño:** 6,49 MB (6.812.313 bytes)

---
