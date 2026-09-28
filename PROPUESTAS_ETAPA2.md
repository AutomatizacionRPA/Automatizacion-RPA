# Propuestas de mejora - Etapa 2 (Proyecto recibido: Bot Cursos Telegram - RPA)

## Mejora 1 - FIFO por timestamp real (Sustancial, alta prioridad)
**Problema**: El criterio actual usa índice DOM (último con badge) para inferir antigüedad. Aunque funciona para el orden visual típico de Telegram Web A, puede fallar ante reordenamientos/scroll.

**Propuesta**: Extraer timestamp del último mensaje no propio en cada chat con badge (`data-timestamp`, atributo `title` con hora o elemento `.time`/`.chat-time`). Seleccionar el chat con **menor timestamp** (más antiguo) entre candidatos.

**Justificación teórica**: Refuerza el **control de calidad del proceso** (ordenamiento determinista) y reduce **perturbaciones exógenas** (cambios de layout).

**Esfuerzo estimado**: 1h | Realizable: Sí

## Mejora 2 - Normalización de texto (Robustez, bajo costo)
**Problema**: Variantes con tildes/diacríticos (`Menú` vs `menu`, `adiós` vs `adios`) ya funcionan con fuzzy, pero se puede mejorar.

**Propuesta**: Aplicar `unicodedata.normalize('NFKD', texto).encode('ascii','ignore').decode('ascii')` antes de comparar (tanto saludos/despedidas como tokens). Ajustar umbrales si necesario.

**Justificación teórica**: Reduce sensibilidad a **perturbaciones endógenas** (errores/variantes tipográficas).

**Esfuerzo estimado**: 15–30 min | Realizable: Sí

## Mejora 3 - Reintentos de inserción (Estabilidad)
**Problema**: En cargas lentas, `execCommand('insertText')` puede fallar puntualmente.

**Propuesta**: Reintentar hasta 2 veces (espera 0.5s entre intentos) si no retorna `INSERT:true`, con fallback a `el.innerText = t` + `InputEvent('input')`.

**Justificación teórica**: Mejora robustez ante **perturbaciones exógenas** (render/latencia).

**Esfuerzo estimado**: 30 min | Realizable: Sí

## Mejora 4 - Tests unitarios Python (Mantenibilidad)
**Propuesta**: Crear `tests/test_procesar_consulta.py` con casos: vacío, menú variantes, despedidas, fuzzy cursos, sugerencia, no reconocido. Ejecutar con `python -m pytest`.

**Justificación teórica**: **Control de calidad** (validación repetible) y facilita comprensión/documentación para otro grupo.

**Esfuerzo estimado**: 30–60 min | Realizable: Sí

## Mejora 5 - Logging estructurado (Debugging)
**Propuesta**: Añadir logs con `ratio`/`entrada_normalizada` y opcional JSON línea por línea para análisis.

**Esfuerzo estimado**: 15 min | Realizable: Sí

**Recomendación para Etapa 2**: Implementar **Mejora 1 (FIFO por timestamp real)** como mejora sustancial. Es clara, medible, vinculable a conceptos teóricos y realizable en tiempo estimado (<2h).
