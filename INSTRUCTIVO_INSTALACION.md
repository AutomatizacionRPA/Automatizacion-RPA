# Instructivo de Instalación - Bot Cursos Telegram (RPA)

## 1. Requisitos del sistema
- Windows 10/11
- Google Chrome instalado (recomendado)
- Java JRE/JDK **64-bit** (versión 8+). Importante: Java 32-bit provoca fallos con SikuliX; el flujo actual NO utiliza SikuliX.
- Python 3.x instalado y accesible desde PATH (`python`)

## 2. Instalación de TagUI v6.114
1. Descargar TagUI v6.114 (versión utilizada en el proyecto).
2. Descomprimir en `C:\tagui\` (ruta recomendada). Verificar `C:\tagui\src\tagui.cmd` exista.
3. Agregar `C:\tagui\src` al PATH de Windows (opcional) para ejecutar `tagui` desde cualquier directorio.

## 3. Obtención del proyecto
1. Descomprimir el ZIP del proyecto en `C:\RPA\Proyecto Integrador\Bot Cursos-Telegram\`
2. Verificar estructura: `src/bot_telegram.tag`, `src/procesar_consulta.py`, `data/cursos.csv`

## 4. Configuración inicial
1. Abrir Telegram Web A (`https://web.telegram.org/a/`) en Chrome y mantener sesión iniciada.
2. Verificar que Python lee/escribe correctamente: el script `procesar_consulta.py` calcula rutas absolutas desde su ubicación.

## 5. Ejecución
Desde la raíz del proyecto (`C:\RPA\Proyecto Integrador\Bot Cursos-Telegram\`):
```cmd
tagui src/bot_telegram.tag
```

## 6. Verificación
- Al recibir mensajes con badge, el bot debe responder al **chat con mensaje más antiguo** (FIFO inverso según orden DOM de la barra lateral).
- Las respuestas incluyen menú, búsqueda de cursos (coincidencia directa + fuzzy) y detección de despedidas.

