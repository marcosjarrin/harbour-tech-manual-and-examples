# Manual de Programación en Harbour MiniGUI Extended: Programación Funcional vs. Orientada a Objetos

## Guía Definitiva para Elegir el Paradigma Adecuado Según el Tipo de Solución

---

# Introducción

Harbour es un lenguaje **multi-paradigma** por excelencia. Soporta programación imperativa, funcional (basada en funciones y procedimientos), orientada a objetos (con clases y herencia) y reflexiva. Esta flexibilidad es una gran fortaleza, pero también una responsabilidad: **elegir el paradigma incorrecto puede condenar un proyecto al fracaso** por deuda técnica, lentitud o código inmantenible.

Este manual tiene como objetivos:
1. **Definir la verdadera programación funcional en Harbour** (basada en `FUNCTION`/`PROCEDURE`) y sus ventajas para programas pequeños y rápidos.
2. **Explicar por qué la Programación Orientada a Objetos (OOP)** es superior para programas grandes, destacando su ventaja en mantenimiento y escalabilidad.
3. **Proporcionar una guía de decisión** para saber qué paradigma (o mezcla de ambos) usar en cada tipo de solución con Harbour MiniGUI Extended.

---

# Capítulo 1: La Verdadera Programación Funcional en Harbour

## 1.1 ¿Qué es la Programación Funcional en Harbour?

En el ecosistema xBase/Harbour, la programación funcional no se reduce a escribir `{|| ... }`. Se trata de un **estilo de programación donde las `FUNCTION` y `PROCEDURE` son las unidades fundamentales de construcción**. Este estilo se caracteriza por:

- **Funciones puras (o con efectos controlados)**: Dado un mismo input, siempre devuelven el mismo output, sin modificar variables externas.
- **Composición**: Construir programas complejos encadenando funciones simples.
- **Inmutabilidad relativa**: Evitar modificar estructuras de datos globales; en su lugar, crear nuevas.
- **Uso de orden superior**: Pasar funciones (mediante `codeblocks` o referencias) a otras funciones para filtrar, mapear o reducir datos.

```harbour
// ----------------------------------------------------------
// EJEMPLO CORRECTO DE ESTILO FUNCIONAL
// ----------------------------------------------------------

// Función pura: No toca nada externo, solo opera con sus parámetros
FUNCTION CalcularIVA(nPrecio, nPorcentaje)
   RETURN nPrecio * (nPorcentaje / 100)

// Función pura que transforma un array
FUNCTION FiltrarActivos(aClientes)
   LOCAL aResult := {}
   LOCAL i
   FOR i := 1 TO Len(aClientes)
      IF aClientes[i]:lActivo  // Asumiendo que es un array de objetos o hash
         AAdd(aResult, aClientes[i])
      ENDIF
   NEXT
RETURN aResult

// Uso de orden superior con codeblocks (el codeblock es el "pasajero", la FUNCTION es la "estructura")
PROCEDURE Main()
   LOCAL aNumeros := {10, 20, 30, 40, 50}
   LOCAL aDobles
   
   // AEval es una función de Harbour que recibe un codeblock (comportamiento)
   AEval(aNumeros, {|x| QOut("Número: " + Str(x))})
   
   // AScan busca usando un codeblock
   nPos := AScan(aNumeros, {|x| x > 25})
   
   ? "Primer número mayor que 25 está en la posición:", nPos
RETURN
```

## 1.2 Ventajas de la Programación Funcional en Programas Pequeños

### 🔹 Velocidad de Desarrollo (Rapidez)
Para utilidades, scripts o módulos aislados, el enfoque funcional es **directo y conciso**. No necesitas definir clases, constructores ni pensar en jerarquías de herencia. El código fluye de arriba a abajo.

### 🔹 Bajo Overhead y Rendimiento
Las funciones y procedimientos en Harbour tienen **menos sobrecarga de memoria y CPU** que los objetos. No hay tablas virtuales (vtables) ni gestión de referencias a objetos. Para tareas de procesamiento de datos masivos, esto marca la diferencia.

### 🔹 Facilidad de Depuración
En un programa pequeño, tener el flujo lineal a través de funciones hace que seguir la pila de llamadas sea trivial. No hay que navegar por herencias profundas o métodos sobrescritos.

### 🔹 Ideal para Procesamiento de Datos (Batch)
Harbour destaca en el manejo de bases de datos. Las funciones permiten encapsular consultas SQL o lógica de filtrado de manera rápida y reutilizable sin la parafernalia de una clase.

## 1.3 Ejemplo Práctico: Utilidad de Limpieza de Base de Datos

```harbour
// ----------------------------------------------------------
// PROGRAMA FUNCIONAL PEQUEÑO (Utilidad de consola)
// ----------------------------------------------------------

PROCEDURE Main()
   LOCAL cFechaLimite := Date() - 365
   LOCAL aRegistros, nEliminados
   
   ? "=== LIMPIEZA DE REGISTROS ANTIGUOS ==="
   
   // Cargar datos
   aRegistros := CargarLogs()
   
   // Filtrar funcionalmente (usamos funciones, no clases)
   aRegistros := FiltrarPorFecha(aRegistros, cFechaLimite)
   
   // Contar y eliminar
   nEliminados := EliminarRegistros(aRegistros)
   
   ? "Registros eliminados:", nEliminados
   ? "Proceso finalizado."
RETURN

// ----------------------------------------------------------
// FUNCIONES PURAS O CON EFECTOS CONTROLADOS
// ----------------------------------------------------------

FUNCTION CargarLogs()
   LOCAL aLogs := {}
   USE logs ALIAS Log NEW
   DO WHILE !Log->(Eof())
      AAdd(aLogs, {;
         id := Log->id,;
         fecha := Log->fecha,;
         texto := Log->texto;
      })
      Log->(DbSkip())
   ENDDO
   USE
RETURN aLogs

FUNCTION FiltrarPorFecha(aArray, dLimite)
   LOCAL aFiltrado := {}
   LOCAL i
   FOR i := 1 TO Len(aArray)
      IF aArray[i]['fecha'] < dLimite
         AAdd(aFiltrado, aArray[i])
      ENDIF
   NEXT
RETURN aFiltrado

FUNCTION EliminarRegistros(aArray)
   LOCAL nCont := 0
   LOCAL i
   USE logs ALIAS Log NEW
   FOR i := 1 TO Len(aArray)
      IF Log->(DbSeek(aArray[i]['id']))
         Log->(DbDelete())
         nCont++
      ENDIF
   NEXT
   USE
RETURN nCont
```

---

# Capítulo 2: Programación Orientada a Objetos en Harbour

## 2.1 ¿Qué es la OOP en Harbour?

La OOP en Harbour está soportada nativamente mediante la sintaxis `CLASS ... ENDCLASS`. Permite **encapsular** datos (propiedades) y comportamientos (métodos) en una misma entidad. Harbour soporta herencia simple, polimorfismo y clases abstractas.

## 2.2 Ventajas de la OOP en Programas Grandes

### 🔹 Mantenibilidad Superior
En un programa con más de 10,000 líneas, el mayor costo no es escribirlo, sino **mantenerlo**.
- **Aislamiento de cambios**: Modificar la lógica de clientes (`TCliente`) no afecta a la lógica de facturas (`TFactura`), siempre que se respete la interfaz pública.
- **Legibilidad semántica**: `oCliente:CalcularDescuento()` es mucho más legible y autodocumentado que una función suelta `CalcularDescuento(oCliente)`.

### 🔹 Escalabilidad (Crecimiento Orgánico)
La OOP permite que una aplicación crezca en funcionalidades sin volverse caótica:
- **Herencia**: Crea clases base (`TEntidad`) y extiende comportamientos en clases hijas (`TCliente`, `TProveedor`).
- **Polimorfismo**: Puedes tener un array de `TEntidad` y llamar al método `Guardar()` sin saber si es un cliente o un proveedor; cada uno ejecutará su propia lógica.
- **Composición**: Un objeto `TFactura` contiene un array de objetos `TLineaFactura`, delegando responsabilidades.

### 🔹 Organización para Trabajo en Equipo
Cuando trabajan varios desarrolladores:
- **Contratos definidos**: El equipo de frontend solo necesita conocer la interfaz de los objetos del backend.
- **Menos conflictos de fusión (merge)**: Cada desarrollador trabaja en clases diferentes.
- **Código autodocumentado**: Los nombres de clases y métodos expresan la intención del negocio.

### 🔹 Facilitación de Pruebas Unitarias
Con OOP, puedes sustituir dependencias reales por **mocks** o **stubs**.
```harbour
// En tus pruebas, en lugar de conectar a una DB real...
oRepo := TMockClienteRepository():New()  // Simula respuestas
oController := TClienteController():New(oRepo, oView)
// Pruebas aisladas y rápidas.
```

## 2.3 Ejemplo Práctico: Sistema de Facturación con OOP (Grande)

Aquí se muestra cómo se estructura un módulo completo usando clases.

```harbour
// ==============================================================
// 1. CAPA DE ENTIDADES (Modelo de Dominio)
// ==============================================================

CLASS TEntity
   DATA nId
   DATA lDeleted
   METHOD New()
   METHOD Validate() VIRTUAL
   METHOD ToHash()
ENDCLASS

CLASS TCustomer FROM TEntity
   DATA cName
   DATA cPhone
   DATA cEmail
   DATA nCreditLimit
   METHOD New(cName, cPhone, cEmail)
   METHOD Validate() OVERRIDE
   METHOD GetDiscount(nTotal)
ENDCLASS

METHOD Validate() CLASS TCustomer
   IF Empty(::cName)
      RETURN .F.
   ENDIF
   IF !Empty(::cEmail) .AND. !("@" $ ::cEmail)
      RETURN .F.
   ENDIF
RETURN .T.

// ==============================================================
// 2. CAPA DE ACCESO A DATOS (Repositories)
// ==============================================================

CLASS TCustomerRepository
   DATA oDBConnection
   METHOD New(oDB)
   METHOD FindById(nId)
   METHOD FindByCriteria(cFilter)
   METHOD Save(oCustomer)
   METHOD Delete(nId)
ENDCLASS

METHOD Save(oCustomer) CLASS TCustomerRepository
   IF !oCustomer:Validate()
      RETURN .F.
   ENDIF
   IF oCustomer:nId == 0
      ::oDBConnection:Execute("INSERT INTO customers (name, phone, email, credit) VALUES (?, ?, ?, ?)",;
         oCustomer:cName, oCustomer:cPhone, oCustomer:cEmail, oCustomer:nCreditLimit)
      oCustomer:nId := ::oDBConnection:LastInsertId()
   ELSE
      ::oDBConnection:Execute("UPDATE customers SET name=?, phone=?, email=?, credit=? WHERE id=?",;
         oCustomer:cName, oCustomer:cPhone, oCustomer:cEmail, oCustomer:nCreditLimit, oCustomer:nId)
   ENDIF
RETURN .T.

// ==============================================================
// 3. CAPA DE LÓGICA DE NEGOCIO (Services / Controllers)
// ==============================================================

CLASS TInvoiceService
   DATA oCustomerRepo
   DATA oInvoiceRepo
   DATA oProductRepo
   METHOD New(oCustomerRepo, oInvoiceRepo, oProductRepo)
   METHOD CreateInvoice(nCustomerId, aItems)
   METHOD CalculateTotal(aItems)
ENDCLASS

METHOD CreateInvoice(nCustomerId, aItems) CLASS TInvoiceService
   LOCAL oCustomer := ::oCustomerRepo:FindById(nCustomerId)
   IF oCustomer == NIL
      RETURN NIL
   ENDIF
   
   // Lógica de negocio: validar límite de crédito
   LOCAL nTotal := ::CalculateTotal(aItems)
   IF nTotal > oCustomer:nCreditLimit
      RETURN NIL
   ENDIF
   
   // Crear la factura
   LOCAL oInvoice := TInvoice():New(oCustomer, aItems, nTotal)
   ::oInvoiceRepo:Save(oInvoice)
   
   // Descontar stock
   FOR EACH oItem IN aItems
      ::oProductRepo:DecreaseStock(oItem:ProductId, oItem:Quantity)
   NEXT
   
RETURN oInvoice

// ==============================================================
// 4. CAPA DE PRESENTACIÓN (MiniGUI)
// ==============================================================

CLASS TInvoiceView
   DATA oWindow
   DATA oController
   DATA oGrid
   METHOD New(oController)
   METHOD CreateWindow()
   METHOD RefreshGrid(aData)
   METHOD GetSelectedCustomer()
ENDCLASS

METHOD CreateWindow() CLASS TInvoiceView
   ::oWindow := TWindow():New( "InvoiceForm", "Nueva Factura", 0, 0, 800, 600 )
   ::oWindow:SetMain()
   
   // ... Creación de controles usando OOHG ... 
   // (Botones llaman a ::oController:OnSave(), etc.)
   
   ::oWindow:Center()
   ::oWindow:Activate()
RETURN
```

---

# Capítulo 3: Comparativa Técnica y Guía de Decisión

## 3.1 Tabla Comparativa

| Aspecto | Programación Funcional (FUNCTION/PROCEDURE) | Programación Orientada a Objetos (CLASS) |
|---------|---------------------------------------------|------------------------------------------|
| **Unidad de construcción** | Función / Procedimiento | Objeto / Clase |
| **Complejidad inicial** | Muy Baja | Media (curva de aprendizaje) |
| **Velocidad de escritura (<2K líneas)** | **Excelente** | Buena |
| **Velocidad de escritura (>10K líneas)** | Mala (se vuelve spaghetti) | **Excelente** (organizado) |
| **Mantenibilidad a 5 años** | Muy Baja | **Excelente** |
| **Escalabilidad (agregar módulos)** | Difícil (acoplamiento global) | **Fácil** (nuevas clases) |
| **Reutilización entre proyectos** | Baja (copiar/pegar funciones) | **Alta** (librerías de clases) |
| **Pruebas Unitarias** | Difícil (mocks complejos) | **Fácil** (inyección de dependencias) |
| **Trabajo en equipo** | Caótico (conflictos) | **Organizado** (por módulos) |
| **Rendimiento (CPU/Memoria)** | **Excelente** (menos overhead) | Bueno (ligero overhead) |

## 3.2 ¿Cuándo Usar Programación Funcional Pura?

| Escenario | Ejemplo en MiniGUI Extended |
|-----------|----------------------------|
| **Scripts de mantenimiento** | Limpieza de índices, respaldo automático |
| **Herramientas de migración** | Pasar datos de DBF a PostgreSQL |
| **Prototipos desechables** | Prueba de concepto de un algoritmo |
| **Módulo de reportes simple** | Generar un PDF con datos agregados |
| **Plugins o extensiones aisladas** | Un botón que ejecuta una rutina específica |

**Regla de oro**: Si el programa **no va a crecer** y **no requiere mantenimiento a largo plazo**, usa funcional.

## 3.3 ¿Cuándo Usar Programación Orientada a Objetos?

| Escenario | Ejemplo en MiniGUI Extended |
|-----------|----------------------------|
| **ERP / CRM / Facturación** | Sistema completo con clientes, productos, pedidos |
| **Aplicación con múltiples ventanas** | Dashboard, formularios maestros-detalle |
| **Proyectos con ciclo de vida > 2 años** | Software que se actualizará constantemente |
| **Equipos de 2+ desarrolladores** | Frontend y backend separados en clases |
| **Necesidad de pruebas automatizadas** | CI/CD con pruebas unitarias y de integración |

**Regla de oro**: Si el proyecto **va a crecer** o **lo mantendrán varias personas**, invierte en OOP desde el día 1.

## 3.4 El Enfoque Híbrido (Recomendado para MiniGUI Extended)

La práctica más exitosa en Harbour MiniGUI Extended es **usar OOP para la arquitectura y Funcional para las operaciones internas**:

1. **Arquitectura OOP**: Ventanas, Controladores, Repositorios y Servicios.
2. **Lógica interna funcional**: Dentro de los métodos, usa funciones puras para cálculos, transformación de datos y filtrado.

```harbour
// EJEMPLO HÍBRIDO PERFECTO
CLASS TReportService
   METHOD GenerateSalesReport(dFrom, dTo)
ENDCLASS

METHOD GenerateSalesReport(dFrom, dTo) CLASS TReportService
   LOCAL aRawData := ::oRepo:GetSales(dFrom, dTo)
   LOCAL aGrouped, nTotal
   
   // 1. Funcional: Agrupar y sumar con funciones auxiliares
   aGrouped := GroupByProduct(aRawData)   // <-- Función pura
   nTotal := SumArray(aGrouped, "amount") // <-- Función pura
   
   // 2. OOP: Crear el objeto reporte y guardarlo
   oReport := TSalesReport():New(aGrouped, nTotal, dFrom, dTo)
   ::oRepo:SaveReport(oReport)
   
   // 3. OOP: Mostrar en la vista
   ::oView:DisplayReport(oReport)
RETURN
```

---

# Capítulo 4: Recomendaciones Específicas para MiniGUI Extended

## 4.1 Clasificación de Proyectos por Tamaño

| Tamaño | Líneas aprox. | Paradigma Recomendado | Estilo MiniGUI |
|--------|---------------|----------------------|----------------|
| **Micro** | < 500 | Funcional puro | Sintaxis clásica (DEFINE WINDOW) |
| **Pequeño** | 500 - 3,000 | Funcional + pseudo-OOP | MiniGUI estándar con eventos |
| **Mediano** | 3,000 - 10,000 | **Híbrido (OOP + Funcional)** | Minigui para ventanas, Funcional para datos |
| **Grande** | > 10,000 | **OOP pura** (MVC) | OOP con Controladores y Servicios |

## 4.2 Patrones OOP Indispensables para Proyectos Grandes

1. **Repository Pattern**: Aísla la lógica de base de datos. Cambiar de DBF a SQL solo requiere cambiar el repositorio.
2. **Service Layer**: Centraliza la lógica de negocio. Los controladores de la GUI solo llaman a servicios.
3. **Dependency Injection (DI)**: Pasa las dependencias (repositorios) por constructor, facilitando las pruebas.
4. **Observer (Eventos)**: Para desacoplar la GUI de la lógica (usando `EventManager`).

## 4.3 Checklist de Decisión para tu Próximo Proyecto

Marca estas casillas antes de escribir la primera línea:

- [ ] ¿El proyecto superará las **5,000 líneas**? → Si es **SÍ**, **OBLIGATORIO** usar OOP.
- [ ] ¿Participarán **más de 2 desarrolladores**? → Si es **SÍ**, **OBLIGATORIO** usar OOP.
- [ ] ¿Se espera que el software **viva más de 2 años**? → Si es **SÍ**, **OBLIGATORIO** usar OOP.
- [ ] ¿Es un **script de una sola ejecución** o utilidad menor? → Si es **SÍ**, usa FUNCIONAL.
- [ ] ¿La interfaz de usuario tiene **múltiples ventanas interactivas**? → Si es **SÍ**, usa OOP.
- [ ] ¿Necesitas **reutilizar** este código en otro proyecto futuro? → Si es **SÍ**, usa OOP.

Si tienes una mezcla de "SÍ" y "NO", prioriza la OOP, porque **migrar de funcional a OOP cuando el proyecto ya es grande es extremadamente costoso**. En cambio, empezar con OOP y usar funciones internas es siempre más barato y seguro.

---

# Conclusión Final

> **La programación funcional (basada en `FUNCTION`/`PROCEDURE`) es la reina de la velocidad y la simplicidad para programas pequeños, utilitarios y de corta vida.**
>
> **La programación orientada a objetos (basada en `CLASS`) es la arquitectura reina para programas grandes, mantenibles, escalables y desarrollados en equipo.**

En Harbour MiniGUI Extended, no eres prisionero de un solo paradigma. La sabiduría está en **usar OOP para dar estructura al castillo (la arquitectura general) y usar funciones para construir los ladrillos (la lógica interna de cada módulo)**.

Recuerda: El código se escribe una vez, pero se lee y se modifica durante años. Invierte el tiempo inicial en diseñar una buena arquitectura OOP para tu aplicación principal, y deja el estilo funcional para las tareas auxiliares y los cálculos internos. Tu yo del futuro (y tu equipo) te lo agradecerán.

---

# Anexo: Recursos Adicionales

- **Patrones en Harbour**: Repositorio de referencia en GitHub: [angelvisionwin/design-patterns-harbour](https://github.com/angelvisionwin/design-patterns-harbour).
- **Foro oficial**: [https://groups.google.com/g/minigui-forum](https://groups.google.com/g/minigui-forum) - Comunidad activa para resolver dudas sobre arquitectura.
- **Documentación de Harbour**: https://github.com/marcosjarrin/Harbour_oop_manual