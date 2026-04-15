# **Technical Whitepaper: Structure of a DBF File**

>**Document Version**: 1.0  
**Language**: English  
**Author**: Engineer Marcos Jarrin  
**Date**: 2025-05-07  

---

### 📚 Table of Contents

- [Technical Whitepaper: Structure of a DBF File]( technical-whitepaper-structure-of-a-dbf-file)
    - [📚 Table of Contents](#-table-of-contents)
  - [1. Introduction 🚮 ➡️ 🗑️](#1-introduction--️-️)
    - [📚 Table of Contents](#-table-of-contents-1)
- [Technical Document: Structure of a DBF File](technical-document-structure-of-a-dbf-file)
  - [1. Overview of the DBF File Format](#1-overview-of-the-dbf-file-format)
  - [2. Header Area**](#2-header-area)
    - [2.1 Primary Header (File Information Block)](#21-primary-header-file-information-block)
    - [2.2 Field Descriptor Array (Field Definitions)](#22-field-descriptor-array-field-definitions)
      - [Field Type Mapping Table](#field-type-mapping-table)
    - [2.3 End of Field Descriptors](#23-end-of-field-descriptors)
  - [3. Data Area](#3-data-area)
    - [3.1 Record Structure](#31-record-structure)
    - [3.2 Data Storage by Field Type](#32-data-storage-by-field-type)
      - [Character (`C`)](#character-c)
      - [Numeric (`N`) and Float (`F`)](#numeric-n-and-float-f)
      - [Logical (`L`)](#logical-l)
      - [Date (`D`)](#date-d)
      - [Memo (`M`) and General (`G`)](#memo-m-and-general-g)
  - [4. Memo File (.FPT or .DBT)](#4-memo-file-fpt-or-dbt)
    - [4.1 .FPT File Structure](#41-fpt-file-structure)
      - [FPT Header (First 512 bytes)](#fpt-header-first-512-bytes)
      - [Data Blocks](#data-blocks)
        - [Memo Content Format](#memo-content-format)
  - [5. End of File Marker](#5-end-of-file-marker)
  - [6. Diagrams](#6-diagrams)
    - [6.1 Overall DBF File Layout](#61-overall-dbf-file-layout)
    - [6.2 Field Descriptor Layout (32 bytes)](#62-field-descriptor-layout-32-bytes)
    - [6.3 Record Layout Example](#63-record-layout-example)
  - [7. File Integrity and Recovery Considerations](#7-file-integrity-and-recovery-considerations)
    - [7.1 Common Corruption Scenarios](#71-common-corruption-scenarios)
    - [7.2 Preventive Measures](#72-preventive-measures)
  - [8. Summary of Key Technical Details](#8-summary-of-key-technical-details)
  - [9. Conclusion](#9-conclusion)
  - [Bibliography](#Bibliography)
  
---

## 1. Introduction 🚮 ➡️ 🗑️

The **Garbage Collector (GC)** in Harbour is a core runtime component responsible for **automating dynamic memory management**, reclaiming memory blocks that are no longer accessible by the program. It prevents memory leaks and simplifies development by eliminating the need for manual `free()` calls on complex structures.

Harbour inherits the dynamic semantics of xBase, allowing ephemeral allocations of strings, arrays, and codeblocks. Without a robust GC, such operations would cause massive memory leaks. The GC acts as a **proactive garbage collector**, identifying and freeing orphaned objects 🚮 ➡️ 🗑️.

---

# **Technical Document: Structure of a DBF File**

This document provides a detailed technical analysis of the structure of a `.DBF` (DataBase File) file, based on the specifications and descriptions found in Xbase-compatible database systems such as Harbour and Clipper. The architectural overview presented herein is derived from a synthesis of multiple expert sources covering the DBF format's specifications, including its file header, field definition array, data record storage mechanism, and memo file (.FPT) interoperability.

---

## 1. Overview of the DBF File Format

The DBF file format was originally introduced with dBase III+ and has since become a standard for many Xbase-family programming languages, including Harbour, Clipper, and others. It is a simple, flat-file database format designed for efficient data storage and retrieval.

A DBF file is composed of two main sections:

1. **Header Area** – Contains metadata about the table structure, including file type, record count, field definitions, and structural flags.
2. **Data Area** – Contains the actual data records stored sequentially.

At the very end of the file, a single **End-of-File (EOF) marker** byte (`1Ah`) is placed.

```
+---------------------+
|     Header Area     |  → File Info + Field Descriptions
+---------------------+
|     Data Area       |  → Records (with delete flag)
+---------------------+
|       EOF Mark      |  → 0x1A
+---------------------+
```

---

## **2. Header Area**

The header area is divided into two distinct parts:

### **2.1 Primary Header (File Information Block)**

This section is **32 bytes long** and contains general information about the database file.

| Byte Offset | Size (bytes) | Description |
|-------------|--------------|-------------|
| 0           | 1            | **File Type Identifier**<br>• `03h`: No memo fields<br>• `F5h` (Harbour): Contains memo fields (.FPT)<br>• `83h` (Clipper/NTX): Contains memo fields (.DBT) |
| 1–3         | 3            | **Last Modification Date**<br>Stored as YY MM DD in hexadecimal:<br>• Byte 1: Year (e.g., 94h = 1994, 00h = 2000)<br>• Byte 2: Month (01h = Jan, 0Ch = Dec)<br>• Byte 3: Day (01h to 1Fh) |
| 4–7         | 4            | **Number of Records**<br>Little-endian format (least significant byte first).<br>Represents total number of data records in the file. |
| 8–9         | 2            | **Offset to Start of Data Records**<br>Little-endian value indicating the byte position where the first record begins. Must be a multiple of 32. |
| 10–11       | 2            | **Length of Each Record**<br>Includes all field data + 1 byte delete flag. |
| 12–28       | 17           | Reserved / Unused (typically filled with 00h) |
| 29          | 1            | **Structural Index Flag**<br>• `00h`: No structural index (.CDX) present<br>• Non-zero: Structural index exists<br>If set and .CDX is missing, Harbour shows: `STRUCTURAL CDX FILE NOT FOUND` |
| 30          | 1            | **Code Page / Language Driver ID**<br>Indicates character encoding used (e.g., 03h = Windows Latin-1, 08h = Russian, etc.) |
| 31          | 1            | **Reserved / Fill byte** (usually 00h) |

> ✅ **Note**: The date format in the header uses only the last two digits of the year (e.g., 94h = 1994), which contributed to the "Year 2000" problem in legacy systems.

---

### **2.2 Field Descriptor Array (Field Definitions)**

Following the primary header is a variable-length array of **32-byte field descriptors**, one for each field in the table.

Each field descriptor has the following structure:

| Byte Offset | Size | Description |
|------------|------|-------------|
| 0–10      | 11   | **Field Name**<br>ASCII string, padded with null (`00h`) or space (`20h`) if shorter than 10 characters. Last character must be null-terminated. |
| 11         | 1    | **Field Type**<br>Single ASCII character indicating data type:<br>• `'C'` = Character<br>• `'N'` = Numeric<br>• `'F'` = Float<br>• `'L'` = Logical<br>• `'D'` = Date<br>• `'M'` = Memo<br>• `'G'` = General (OLE, images, etc.) |
| 12–15     | 4    | **Reserved / Not Used** (in most implementations) |
| 16         | 1    | **Field Length**<br>Number of bytes occupied by the field in the record.<br>For numeric: total digits including decimal point.<br>For character/memo: actual byte length. |
| 17         | 1    | **Decimal Count / Precision**<br>• For numeric fields: number of decimal places<br>• For non-numeric: typically 0 |
| 18–31     | 14   | **Reserved / Unused** (filled with 00h) |

#### **Field Type Mapping Table**

| Type       | ASCII Char | Hex | Decimal | Description |
|-----------|------------|-----|---------|-----------|
| Character | `'C'`      | 43h | 67      | Fixed-length text |
| Numeric   | `'N'`      | 4Eh | 78      | Number stored as ASCII digits |
| Float     | `'F'`      | 46h | 70      | Legacy floating-point (same as N) |
| Logical   | `'L'`      | 4Ch | 76      | Boolean: T/F or Y/N |
| Date      | `'D'`      | 44h | 68      | 8-byte YYYYMMDD (ASCII) |
| Memo      | `'M'`      | 4Dh | 77      | Pointer to block in .FPT/.DBT |
| General   | `'G'`      | 47h | 71      | OLE object (stored in .FPT) |

> 🔍 **Example**: A field named `NAME` of type `'C'`, length 20, starts at byte offset 0 → occupies bytes 1 through 20 in each record (after delete flag).

---

### **2.3 End of Field Descriptors**

After the last field descriptor, a single byte marks the **end of the header**:

- **Value**: `0Dh` (Carriage Return)
- This byte separates the header from the data area.
- It is critical for parsing: reading stops when `0Dh` is encountered after a 32-byte field block.

Thus, total **header size** = `32 + (n × 32) + 1` bytes, where `n` = number of fields.

```
[Primary Header (32 bytes)]
[Field 1 Descriptor (32 bytes)]
[Field 2 Descriptor (32 bytes)]
...
[Field n Descriptor (32 bytes)]
[0Dh Terminator (1 byte)]
```

➡️ The next byte is the **first data record**.

---

## **3. Data Area**

The data area contains all the records in sequential order. Each record has a fixed length defined in bytes 10–11 of the primary header.

### **3.1 Record Structure**

Each record starts with a **1-byte delete flag**, followed by concatenated field values.

| Offset | Size | Content |
|--------|------|--------|
| 0      | 1    | **Delete Flag**<br>• `20h` (space): Record is active<br>• `2Ah` (`*`): Record is marked for deletion |
| 1      | varies | **Field 1 Data** |
| ...    | ...  | **Field 2, 3, ... Data** |
| End    | 1    | **End of Record** (implicit) |

> ⚠️ There are **no delimiters** between fields. The database engine uses field positions and lengths from the header to parse data.

---

### **3.2 Data Storage by Field Type**

#### **Character (`C`)**
- Stored as ASCII text.
- Padded with spaces (`20h`) to full field length.
- Example: `"John"` in a 10-char field → `"John      "`.

#### **Numeric (`N`) and Float (`F`)**
- Stored as ASCII characters representing the number.
- Includes sign (`-`) and decimal point (`.` = `2Ch`).
- Right-aligned within field; unused left positions filled with spaces (`20h`).
- Unused right positions (after decimal) filled with zeros (`30h`).
- Example: `123.45` in a 8-digit field → `" 123.450"`.

#### **Logical (`L`)**
- Single byte:
  - `'T'` (`54h`) = True
  - `'F'` (`46h`) = False
  - `'?'` (`3Fh`) = Uninitialized
- Stored as uppercase ASCII.

#### **Date (`D`)**
- 8 bytes in format `YYYYMMDD`, stored as ASCII digits.
- Example: January 15, 1995 → `"19950115"` (`31 39 39 35 30 31 31 35` hex).
- No separators stored.

#### **Memo (`M`) and General (`G`)**
- Stored in a separate file:
  - Harbour → `.FPT`
  - Clipper → `.DBT`
- DBF record contains a **10-byte pointer** (ASCII) indicating the **block number** in the memo file where content begins.
- If empty, filled with spaces (`20h`).
- Example: `"      0001"` → points to block 1 in .FPT file.

> 📌 **Block Size**: Default is **64 bytes** per block. So block 1 starts at byte 512 (after 512-byte .FPT header), block 2 at 576, etc.

---

## **4. Memo File (.FPT or .DBT)**

When a DBF contains memo or general fields, a corresponding memo file is created.

### **4.1 .FPT File Structure**

```
+----------------------+
|     Header (512)     |
+----------------------+
|     Data Blocks      |
|   (64 bytes each)    |
+----------------------+
```

#### **FPT Header (First 512 bytes)**

Only the first 8 bytes are used:

| Bytes | Description |
|-------|-------------|
| 0–3   | **Number of Blocks Used**<br>Little-endian integer indicating how many 64-byte blocks are allocated. |
| 4–7   | **Block Size**<br>Usually `40h` (64 decimal). Can be customized. |

Remaining 504 bytes are unused (filled with 00h).

#### **Data Blocks**

Each block is 64 bytes. Memo content is stored across one or more blocks.

##### **Memo Content Format**
Each memo entry starts with a 8-byte header:

| Bytes | Content |
|-------|--------|
| 0–3   | Marker: `00 00 00 01` → Memo field<br>or `00 00 00 02` → General (OLE) field |
| 4–7   | **Length of memo content** in bytes (little-endian) |

Followed by actual data (text, binary, etc.).

> ✅ Example: A 100-byte memo requires 2 blocks (64 + 36). Unused space in second block is ignored.

---

## **5. End of File Marker**

At the very end of the DBF file, a single byte is written:

- **Value**: `1Ah` (ASCII SUB)
- **Purpose**: Marks end of file; used by some utilities to detect EOF.
- Not required by all systems but standard in Harbour and Clipper.

> ❗ This is **different** from the `0Dh` that ends the header.

---

## **6. Diagrams**

### **6.1 Overall DBF File Layout**

```
Offset 0x0000
+--------------------------------------------------+
| Primary Header (32 bytes)                        |
+--------------------------------------------------+
| Field Descriptor 1 (32 bytes)                    |
+--------------------------------------------------+
| Field Descriptor 2 (32 bytes)                    |
+--------------------------------------------------+
| ...                                              |
+--------------------------------------------------+
| Field Descriptor n (32 bytes)                    |
+--------------------------------------------------+
| 0Dh (Header Terminator)                          |
+--------------------------------------------------+
| Record 1: [Delete Flag][Field Data...]           |
+--------------------------------------------------+
| Record 2: [Delete Flag][Field Data...]           |
+--------------------------------------------------+
| ...                                              |
+--------------------------------------------------+
| Record N: [Delete Flag][Field Data...]           |
+--------------------------------------------------+
| 1Ah (EOF Marker)                                 |
+--------------------------------------------------+
```

---

### **6.2 Field Descriptor Layout (32 bytes)**

```
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
| 0| 1| 2| 3| 4| 5| 6| 7| 8| 9|10|11|   12-15   |16|17|     18-31     |
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|     Field Name (11)     |T|     Reserved     |L |D |    Reserved     |
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 0                          11                16 17
```

- T = Type (1 byte)
- L = Length (1 byte)
- D = Decimal Count (1 byte)

---

### **6.3 Record Layout Example**

Assume a table with:
- `NAME` (C, 10)
- `AGE` (N, 3)
- `HIRED` (D, 8)

Record Length = 1 (flag) + 10 + 3 + 8 = **22 bytes**

```
+----+----------+-----+----------+
|Flag|   NAME   | AGE |   HIRED  |
+----+----------+-----+----------+
|20h |"John Doe"| "25"| "199901"||
```

---

## **7. File Integrity and Recovery Considerations**

### **7.1 Common Corruption Scenarios**

| Scenario | Cause | Solution |
|--------|-------|---------|
| **DBF size = 0** | Power failure during write | Restore from backup or .BAK file |
| **FPT header corrupted** | Incomplete write | Recalculate block count: `(FileSize / BlockSize) + 1` |
| **Memo changes not saved** | FPT header not updated | Manually fix memo length in FPT block header |
| **Missing .CDX** | Deleted externally | Run `DELETE TAG ALL` to clear structural flag |

### **7.2 Preventive Measures**
- Use **UPS** (Uninterruptible Power Supply)
- Maintain **regular backups**
- Use `PACK` or `PACK MEMO` to clean deleted records and update FPT
- Avoid direct file manipulation without locking

---

## **8. Summary of Key Technical Details**

| Feature | Value |
|--------|-------|
| **Primary Header Size** | 32 bytes |
| **Field Descriptor Size** | 32 bytes per field |
| **Header Terminator** | `0Dh` |
| **EOF Marker** | `1Ah` |
| **Record Delimiter** | None (fixed-length records) |
| **Delete Flag** | `20h` = active, `2Ah` = deleted |
| **Memo Pointer Size** | 10 bytes (ASCII block number) |
| **Default Memo Block Size** | 64 bytes |
| **FPT Header Size** | 512 bytes (only first 8 used) |
| **Date Format in Data** | 8-byte ASCII `YYYYMMDD` |
| **Numeric Storage** | ASCII, with space padding |
| **Endianness** | Little-endian for multi-byte integers |

---

## **9. Conclusion**

The DBF file format, despite its age, remains a remarkably simple and efficient design for storing structured data. Its reliance on fixed-length records, positional field access, and minimal metadata overhead allows for fast random access and straightforward parsing.

Understanding the internal structure of a DBF file is essential for:
- Data recovery
- Low-level debugging
- Interoperability with non-native tools
- Building custom import/export utilities

While modern applications may use more advanced formats (e.g., SQL databases, JSON, Parquet), the DBF format continues to be relevant in legacy systems, embedded applications, and data exchange scenarios due to its simplicity and wide support.

---

## **Bibliography**

### XBase / dBASE File Structure
-   **Title:** La Cabecera de los .DBF
-   **Source:** FPress Revista
-   **URL:** [https://www.fpress.com/revista/Num9906/Jun99.htm](https://www.fpress.com/revista/Num9906/Jun99.htm)

-   **Title:** Arquitectura Xbase, ¿Cómo es por dentro un DBF?
-   **Source:** Alanit
-   **URL:** [https://alanit.com/2002/05/arquitectura-xbase-como-es-por-dentro-un-dbf/](https://alanit.com/2002/05/arquitectura-xbase-como-es-por-dentro-un-dbf/)

### Technical Specifications & Documentation
-   **Title:** dbfread Documentation Release 2.0.7
-   **Source:** dbfread (Read the Docs)
-   **URL:** [https://dbfread.readthedocs.io/_/downloads/en/stable/pdf/](https://dbfread.readthedocs.io/_/downloads/en/stable/pdf/)

-   **Title:** Data File Header Structure for the dBASE Version 7 Table File
-   **Source:** dBase LLC Knowledge Base
-   **URL:** [https://www.dbase.com/Knowledgebase/INT/db7_file_fmt.htm](https://www.dbase.com/Knowledgebase/INT/db7_file_fmt.htm)

### General Reference
-   **Title:** .dbf
-   **Source:** Wikipedia
-   **URL:** [https://en.m.wikipedia.org/wiki/.dbf](https://en.m.wikipedia.org/wiki/.dbf)

### Field-Specific Information
-   **Title:** AutoIncrement Fields
-   **Source:** dBase LLC Bulletin
-   **URL:** [https://www.dbase.com/Knowledgebase/dbulletin/bu02_c.htm](https://www.dbase.com/Knowledgebase/dbulletin/bu02_c.htm)
