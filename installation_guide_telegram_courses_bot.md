# Installation Guide - Telegram Courses Bot (RPA)

## 1. System Requirements
- Windows 10/11
- Google Chrome installed (recommended)
- Java JRE/JDK **64-bit** (version 8+). Important: 32-bit Java causes crashes with SikuliX; the current workflow does NOT use SikuliX.
- Python 3.x installed and accessible from the PATH (`python`)

## 2. TagUI v6.114 Installation
1. Download TagUI v6.114 (the version used in this project).
2. Unzip into `C:\tagui\` (recommended path). Verify that `C:\tagui\src\tagui.cmd` exists.
3. Add `C:\tagui\src` to the Windows PATH (optional) to run `tagui` from any directory.

## 3. Obtaining the Project
1. Unzip the project ZIP file into `C:\RPA\Proyecto Integrador\Bot Cursos-Telegram\`
2. Verify the structure: `src/bot_telegram.tag`, `src/procesar_consulta.py`, `data/cursos.csv`

## 4. Initial Configuration
1. Open Telegram Web A (`https://web.telegram.org/a/`) in Chrome and keep the session logged in.
2. Verify that Python reads/writes correctly: the `procesar_consulta.py` script calculates absolute paths from its location.

## 5. Execution
From the root of the project (`C:\RPA\Proyecto Integrador\Bot Cursos-Telegram\`):
```cmd
tagui src/bot_telegram.tag
```

## 6. Verification
- Upon receiving messages with a notification badge, the bot should reply to the **chat with the oldest message** (reverse FIFO according to the DOM order in the sidebar).
- The responses include a menu, course search (exact + fuzzy matching), and farewell detection.