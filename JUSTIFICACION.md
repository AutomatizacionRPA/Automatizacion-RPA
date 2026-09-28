# Justificación del Trabajo Práctico - Etapa 1 (RPA)

## 1. Herramienta RPA seleccionada
Se seleccionó **TagUI v6.114**.

### Características principales
- Código abierto, basado en lenguaje natural + JavaScript/DOM (pasos simples: `dom`, `js`, `py`, `dump`, `load`).
- Integración con navegador Chrome vía CDP (DevTools Protocol) para automatización web fiable.
- Soporta motor Python persistente (`py`) para procesamiento de datos y lógica de negocio.
- Ligero, portable y ejecutable desde línea de comandos.

### Fundamentación de la elección
TagUI permite automatizar la interfaz web de Telegram Web A (SPA) sin depender exclusivamente de APIs (evitando restricciones). Su sintaxis híbrida (DOM + JS + Python) facilita separar extracción/UI (TagUI) de lógica de procesamiento (Python). Además, al detectar limitaciones en Windows (PhantomJS + `run` y SikuliX con Java 32-bit), fue posible corregir el flujo utilizando únicamente mecanismos nativos (CDP + subprocess), demostrando adaptación técnica al entorno real.

## 2. Proceso a automatizar
**Asistente automático de cursos en Telegram Web A.**

### Alcance
Monitorear chats con mensajes no leídos, extraer consulta del usuario, buscar curso en `data/cursos.csv` (coincidencia directa + fuzzy), generar respuesta adecuada (menú, info de curso, sugerencia o despedida) y enviarla automáticamente.

### Objetivo
Responder consultas sobre oferta de cursos de forma automática, reduciendo tiempo de respuesta y asegurando disponibilidad.

### Restricciones
- Depende de sesión activa en Telegram Web A (Chrome).
- UI de Telegram Web A puede cambiar selectores (mitigado con múltiples fallbacks).
- Entorno Windows + TagUI v6.114.

### Controles para verificar funcionamiento
- Parseo correcto (`tagui_parse.php` sin errores).
- Inserción/envío verificado (estado `INSERT:true`).
- Logs en `bot.log` (tipo de respuesta, ratio fuzzy, casos vacíos/no reconocidos).
- Validación de casos: menú/despedidas con variantes, búsqueda de cursos, no reconocido.

## 3. Implementación
Ver `src/bot_telegram.tag` y `src/procesar_consulta.py`. Cambios clave:
- Reemplazo de `run` por `py` + `subprocess.run` (Windows compatible).
- Envío sin Sikuli: base64 + `execCommand('insertText')` + `Input.dispatchKeyEvent(Enter)` vía CDP.
- Detección FIFO inversa: atiende chat con badge más antiguo (mayor índice DOM en lista lateral).
- Detecciones de menú/despedidas con fuzzy matching (`difflib`), cutoff 0.7.

## 4. Conceptos teóricos aplicados (3)

### 4.1 Retroalimentación (Feedback)
El sistema recibe entrada (mensaje del usuario), la procesa, genera salida (respuesta) y continúa monitoreando cíclicamente. Los logs (`bot.log`) constituyen retroalimentación operativa para verificar comportamiento y detectar desviaciones.

### 4.2 Perturbaciones (Endógenas/Exógenas)
- **Exógenas**: cambios en UI de Telegram Web A, tiempo de carga, red, sesión expirada.
- **Endógenas**: errores de codificación, contenido con emojis/acentos/comillas, variaciones tipográficas del usuario. Se mitigan con base64, selectores con fallbacks y fuzzy matching.

### 4.3 Control de calidad del proceso
Se implementan validaciones (mensaje vacío, CSV inexistente, lectura/escritura UTF-8), logging de eventos (INFO/WARN/ERROR), verificación de inserción (`INSERT:true`) y criterio de ordenamiento (FIFO) para garantizar consistencia y trazabilidad.

## 5. Instructivo de instalación
Ver `INSTRUCTIVO_INSTALACION.md`.

## 6. Complicaciones y soluciones
- **`run` roto en Windows (PhantomJS)** → `py` + `subprocess.run` + `flow_path`.
- **Cuelgue por SikuliX + Java 32-bit** → envío vía CDP (Chrome), eliminación de `clipboard`/`keyboard`/Escape dependientes de Sikuli.
- **Rutas inconsistentes dump/load vs Python** → rutas absolutas derivadas de ubicación del script Python; `dump`/`load` relativos según directorio del tag.
- **Contenido con comillas/saltos/emojis** → transmisión en base64 entre TagUI/Python y navegador.

## 7. Posible mejora para Etapa 2
**Mejora sustancial propuesta**: Implementar FIFO por timestamp real del último mensaje no propio (extraer `data-timestamp`/`.time` de cada chat con badge y seleccionar el de menor timestamp). Esto hace el orden independiente del scroll/DOM y garantiza estricto orden cronológico de llegada. Factible (<2h), mejora robustez sin cambiar lógica de negocio. Ver `PROPUESTAS_ETAPA2.md`.
