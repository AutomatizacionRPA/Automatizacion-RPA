// ===================================
// BOT RPA TELEGRAM - ETAPA 1 
// ===================================

https://web.telegram.org/a/
wait 8

echo Sesion lista. Monitoreando barra lateral...

for ciclo from 1 to infinity
    echo --- Buscando mensajes pendientes ---

    // 1. Detección y clic sobre el chat con badge numérico > 0 (ES5 estricto)
    dom var elementos = document.querySelectorAll('.chatlist-chat, a.ListItem, .ListItem-button'); for (var i = 0; i < elementos.length; i++) { var lineas = elementos[i].innerText.split('\n'); var ult = lineas[lineas.length - 1].trim(); if (/^\d+$/.test(ult) && parseInt(ult, 10) > 0) { elementos[i].dispatchEvent(new MouseEvent('mousedown', { bubbles: true })); elementos[i].dispatchEvent(new MouseEvent('mouseup', { bubbles: true })); elementos[i].click(); return "CHAT_ABIERTO"; } } return "SIN_MENSAJES";
    estado_chat = dom_result

    if estado_chat == "CHAT_ABIERTO"
        echo Chat detectado. Ingresando a la conversacion...
        wait 3

        // 2. Extraer el texto entrante omitiendo horas y mensajes propios
        dom var nodos = document.querySelectorAll('.message-content, .text-content'); var txt = ''; for (var i = nodos.length - 1; i >= 0; i--) { if (!nodos[i].closest('.own, .is-out')) { var clone = nodos[i].cloneNode(true); var tiempos = clone.querySelectorAll('.time, .message-time, .date'); for (var j = 0; j < tiempos.length; j++) { tiempos[j].remove(); } txt = clone.innerText.replace(/(\r\n|\n|\r)/gm, ' ').trim(); break; } } return txt;
        mensaje_cliente = dom_result

        echo Mensaje recibido: `mensaje_cliente`

        if mensaje_cliente != ""
            // 1. Guardar mensaje recibido en in.txt 
            dump `mensaje_cliente` to ../in.txt

            // 2. Ejecutar el script Python con el motor "py" de TagUI.
            js var fs = require('fs'); fs.write('tagui_base.txt', flow_path);
            py base2 = open('tagui_base.txt').read().strip()
            py import subprocess, os
            py os.path.exists(base2 + '/../out.txt') and os.remove(base2 + '/../out.txt')
            py subprocess.run(['python', base2 + '/procesar_consulta.py'], check=False)
            echo Respuesta generada por Python.

            // 3. Codificar out.txt en base64 para inyectarlo sin problemas de comillas/saltos
            py import base64
            py b64 = base64.b64encode(open(base2 + '/../out.txt', 'rb').read()).decode()
            py print(b64)


            js var expr = "(function(){var b=atob(" + JSON.stringify(py_result) + ");var u=new Uint8Array(b.length);for(var i=0;i<b.length;i++)u[i]=b.charCodeAt(i);var t=new TextDecoder('utf-8').decode(u);var el=document.querySelector('.ProseMirror, .input-message-input[contenteditable=\"true\"], div[contenteditable=\"true\"], textarea');if(!el)return 'NO_INPUT';el.focus();var ok=false;if(document.execCommand){ok=document.execCommand('insertText',false,t);}if(!ok||el.innerText.trim()===''){el.innerText=t;el.dispatchEvent(new InputEvent('input',{bubbles:true,inputType:'insertText',data:t}));}return 'INSERT:'+ok+':'+t.length;})()";
            js estado_insert = chrome_step('Runtime.evaluate',{expression: expr});
            echo Estado de la insercion: `estado_insert`

            // 4. Enviar con Enter confiable via CDP (evento real del navegador).
            js chrome_step('Input.dispatchKeyEvent', {type: 'keyDown', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13, nativeVirtualKeyCode: 13, text: '\r', unmodifiedText: '\r'});
            js chrome_step('Input.dispatchKeyEvent', {type: 'keyUp', key: 'Enter', code: 'Enter', windowsVirtualKeyCode: 13, nativeVirtualKeyCode: 13});
            wait 2

            if estado_insert contains "INSERT:true"
                echo Mensaje despachado al usuario correctamente.
            else
                echo ALERTA: No se pudo insertar la respuesta en la caja de texto.
        else
            echo Chat sin contenido valido para responder.

        // 5. Salir del chat: Clic en el fondo neutro para liberar foco y deseleccionar
        dom var fondo = document.querySelector('.messages-container, .bubbles, .chat-background') || document.body; fondo.dispatchEvent(new MouseEvent('click', { bubbles: true })); document.activeElement.blur();
        wait 1
        // Escape via CDP (reemplaza 'keyboard [esc]', que usa SikuliX y se cuelga con Java 32 bits)
        js chrome_step('Input.dispatchKeyEvent', {type: 'keyDown', key: 'Escape', code: 'Escape', windowsVirtualKeyCode: 27, nativeVirtualKeyCode: 27});
        js chrome_step('Input.dispatchKeyEvent', {type: 'keyUp', key: 'Escape', code: 'Escape', windowsVirtualKeyCode: 27, nativeVirtualKeyCode: 27});

        // Respaldo de navegación hacia atrás en caso de vista fija
        dom if (window.location.hash || document.querySelector('.middle-column-open')) { window.history.back(); }
        wait 2
    else
        echo En espera: Sin mensajes pendientes en la barra lateral.

    wait 4