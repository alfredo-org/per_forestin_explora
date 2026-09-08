# QA — evidencia y criterios

Esta documentación inicial no afirma que se hayan ejecutado pruebas, builds o revisiones visuales. Registrar los resultados reales de la iteración en PIPELINE o en un reporte fechado con comando, versión, commit y salida. Los tests TypeScript existentes pertenecen al prototipo web.

| Gate | Comprobación | Evidencia exigida |
|---|---|---|
| Preservación web | Tests Node y build TypeScript/Vite | Comandos, resultado y errores; sin inferir QA visual. |
| Importación nativa | Godot importa/parsea proyecto y assets | Versión fijada, código de salida y log sin errores relevantes. |
| Smoke headless | Escena inicia y termina bajo control | Log y aserciones si están implementadas; no demuestra render GPU. |
| Export Windows | Export con plantillas coincidentes | Archivo producido, tamaño/hash y log. |
| Arranque Windows | Ejecutable abre sin editor | PC/GPU, captura y comprobación manual. |
| Blender → Godot | Asset conocido conserva escala/materiales | Versiones, fuente/export, resultado de import y revisión. |
| Gameplay fase 1 | Movimiento, cámara, colisiones y misión | Recorrido y casos de regresión. |
| iOS fase 4 | Firma, instalación y sesión física | Modelo, iOS/Xcode y resultados, separados de emulación. |

## Casos funcionales a implementar con cada sistema

- Movimiento normal/diagonal, pendientes, salto, caída y aterrizaje; pausa sin acumulación de movimiento.
- Cámara cerca de pared, detrás de vegetación y al cambiar foco/inputs.
- Fauna alerta/huida/retorno, sin atravesar obstáculos ni abandonar el área segura.
- Interacción fuera de alcance rechazada; objetivos y recogidas repetidos no duplican progreso.
- Guardado nuevo, válido, corrupto y versión desconocida; checkpoint recuperado después de reiniciar.
- Inputs de teclado/gamepad/tacto con pérdida de foco y cambios de orientación pertinentes.

## QA visual humano

Forestín reconocible, guanacos anatómicamente legibles, pies sin deslizamiento evidente, sombras/reflejos sin artefactos, fondo Torres integrado y HUD legible día/noche. Grabar recorrido comparable en PC y posteriormente en iPhone. Headless, compilación y conteo de triángulos no acreditan estas condiciones.

Cerrar cada iteración distinguiendo: implementado, ejecutado, comprobado visualmente y pendiente. Un gate bloqueado debe incluir requisito concreto (herramienta, plantilla, hardware o firma) y siguiente paso. No sustituir un fallo por una nota de éxito.
