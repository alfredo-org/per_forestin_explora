# Backlog y responsables

La fase 0 comienza en esta iteración. Cada fase se cierra con evidencia; preparar archivos no satisface las pruebas de ejecución. Los roles son responsabilidades de producción y no implican trece procesos trabajando permanentemente.

| Fase | Entrega acotada | Responsables | Criterio de salida |
|---|---|---|---|
| 0 — Infraestructura | Inventario, coexistencia web/nativo, escena mínima, herramientas, CI y guía local | Technical Director, Build/DevOps, QA; Game Director integra | Importación y prueba headless sin error, export Windows reproducible y arranque del ejecutable; registrar bloqueos reales. |
| 1 — Prototipo | Terreno, Forestín y guanaco provisionales, movimiento/cámara, colisiones, misión/checkpoint | Gameplay Engineer, Wildlife Engineer, Technical Director | Recorrido completo, pausa/reinicio/guardado consistentes; sin atravesar terreno ni cámara. |
| 2 — Vertical slice | Zona de 5–10 minutos con Forestín reconocible, Torres, guanacos, entorno y audio | Character Artist, Environment Artist, Technical Artist, Cinematic/Lighting Artist, Audio Designer | Comparativa visual aprobada en PC, animaciones fluidas y misión completa sin placeholders prioritarios. |
| 3 — Pulido PC | Sensación de control, materiales, UX, audio y perfiles | Gameplay Engineer, Performance Engineer, QA Engineer | Medición repetible por hardware/perfil; resolver regresiones visuales y funcionales. |
| 4 — iOS | Tacto, safe areas, perfil móvil, export Xcode y dispositivo | iOS/Mobile Engineer, Performance Engineer, Build/DevOps, QA | Build firmado probado en iPhone real, memoria/temperatura y suspensión evaluadas. |
| 5 — Expansión | Nuevas zonas, misiones y fauna | Game Director con equipo según contenido | Solo después de aprobación del vertical slice. |

## Siguiente secuencia verificable

1. Ejecutar las herramientas de fase 0 disponibles y registrar resultado con versión/commit.
2. Importar y exportar la escena mínima con Godot fijado y plantillas coincidentes.
3. Abrir build Windows en PC y registrar hardware/captura; el acceso al PC no está establecido por estos archivos.
4. Validar pipeline Blender → GLB → Godot con un asset sencillo y escala conocida.
5. Implementar movimiento/cámara/colisiones del prototipo antes de invertir en mundo extenso.
6. Producir Forestín y guanaco con rig; comparar silueta y locomoción antes del detalle de pelaje.

Technical Director revisa cambios estructurales; Game Director controla alcance y aprueba la transición de fase. QA y Performance revisan al integrar. Agrupar la iteración en un commit/push cuando esté autorizado y tras evaluar el workflow que publica Pages.
