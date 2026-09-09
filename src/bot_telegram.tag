// =============================================================================
// BOT RPA TELEGRAM - ETAPA 1
// =============================================================================

https://web.telegram.org/a/
wait 8

echo Asegurese de tener el chat de prueba visible en pantalla
ultimo_mensaje_atendido = ""

for ciclo from 1 to infinity
    echo --- Monitoreo en curso ---

    // Selectores del resumen lateral y la hora
    selector_resumen = "(//span[contains(@class, 'last-message-summary')])[1]"
    selector_hora = "(//span[contains(@class, 'time') or contains(@class, 'message-time') or contains(@class, 'date')])[1]"

    if present(selector_resumen)
        // Lectura nativa sin el signo '+'
        read selector_resumen to mensaje_recibido
        js mensaje_recibido = mensaje_recibido.trim()

        firma_actual = mensaje_recibido

        if present(selector_hora)
            read selector_hora to hora_recibida
            js hora_recibida = hora_recibida.trim()
            firma_actual = mensaje_recibido + "_" + hora_recibida

        // Si hay texto nuevo y no es el último ya respondido
        if mensaje_recibido != "" and firma_actual != ultimo_mensaje_atendido
            echo Nuevo mensaje detectado: `mensaje_recibido`
            ultimo_mensaje_atendido = firma_actual

            // Llamada al script de Python con el mensaje como argumento
            run python src/procesar_consulta.py `mensaje_recibido` to salida_bot

            // Selector del campo de texto de Telegram Web A
            selector_input = "//div[@contenteditable='true']"

            if present(selector_input)
                click selector_input
                type selector_input as `salida_bot`[enter]
                echo Respuesta enviada al usuario con exito.
            else
                echo No se encontro la caja de texto para escribir.

            wait 2
        else
            echo En espera: Sin mensajes nuevos o mensaje ya respondido.
    else
        echo En espera: No se visualiza el elemento en pantalla.

    wait 3