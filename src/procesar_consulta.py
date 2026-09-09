import sys
import csv
import os
import difflib
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LOG_FILE = os.path.join(BASE_DIR, "..", "bot.log")
CSV_PATH = os.path.join(BASE_DIR, "..", "data", "cursos.csv")

def registrar_log(tipo, detalle):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, mode="a", encoding="utf-8") as f:
        f.write(f"[{timestamp}] [{tipo}] {detalle}\n")

def formatear_curso(data):
    return (
        f"Curso: {data['curso']}\n"
        f"• Docente: {data['docente']}\n"
        f"• Días: {data['dias']}\n"
        f"• Horario: {data['horario']} hs\n"
        f"• Arancel: {data['precio']}\n"
        f"• Detalle: {data['descripcion']}"
    )

def procesar_mensaje(mensaje_usuario):
    consulta = mensaje_usuario.strip().lower()

    if not consulta:
        registrar_log("WARN", "Mensaje recibido vacío.")
        return "No detecté texto. Escribí el nombre de un curso o 'menu' para consultar."

    if consulta in ["hola", "inicio", "/start", "ayuda", "menu"]:
        registrar_log("INFO", f"Comando de ayuda ejecutado: '{consulta}'")
        return (
            "¡Hola! Escribí una opción para ver aranceles y horarios:\n"
            "• Peluquería\n• Python\n• Maquillaje\n• Barbería"
        )

    if not os.path.exists(CSV_PATH):
        registrar_log("ERROR_CRITICO", f"No existe el archivo {CSV_PATH}")
        return "Error interno: Base de datos no disponible temporalmente."

    cursos = {}
    try:
        with open(CSV_PATH, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                cursos[row["keyword"].lower()] = row
    except Exception as e:
        registrar_log("ERROR_CSV", f"Fallo al abrir CSV: {str(e)}")
        return "Error interno al leer los registros de cursos."

    # 1. Coincidencia exacta o contenida
    for kw, datos in cursos.items():
        if kw in consulta:
            registrar_log("EXITO_EXACTO", f"Coincidencia directa con '{kw}'")
            return formatear_curso(datos)

    # 2. Tolerancia a errores de tipeo (Fuzzy Matching)
    palabras = consulta.split()
    claves = list(cursos.keys())
    mejor_match = None
    mejor_ratio = 0.0

    for token in palabras:
        coincidencias = difflib.get_close_matches(token, claves, n=1, cutoff=0.6)
        if coincidencias:
            palabra_candidata = coincidencias[0]
            ratio = difflib.SequenceMatcher(None, token, palabra_candidata).ratio()
            if ratio > mejor_ratio:
                mejor_ratio = ratio
                mejor_match = palabra_candidata

    if mejor_match:
        if mejor_ratio >= 0.75:
            registrar_log("CORRECCION_AUTO", f"Aceptado '{mejor_match}' (Ratio: {mejor_ratio:.2f}) para '{consulta}'")
            return f"*(Inferí que consultaste por '{mejor_match.capitalize()}')*\n\n" + formatear_curso(cursos[mejor_match])
        else:
            registrar_log("SUGERENCIA", f"Duda con '{mejor_match}' (Ratio: {mejor_ratio:.2f}) para '{consulta}'")
            return f"¿Quisiste consultar por '{mejor_match.capitalize()}'? Escribilo para confirmar."

    # 3. Término no reconocido
    registrar_log("NO_RECONOCIDO", f"Consulta sin coincidencias: '{consulta}'")
    return "No identifiqué el curso solicitado. Escribí 'menu' para consultar opciones disponibles."

if __name__ == "__main__":
    entrada = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else ""
    print(procesar_mensaje(entrada))