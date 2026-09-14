# Forestín Aventura 0.1.2 — movimiento articulado

Base integrada: 637617c58e8c34d6ba33d03a9a3096bc8a390c12 (0.1.1). Se conserva el paisaje y sus optimizaciones.

## Cambios

Forestín incorpora rodillas, tobillos y codos articulados. La pose usa dos segmentos por pierna, objetivos de apoyo y elevación de pie, compensación del tobillo y transiciones de reposo, caminata, carrera, ascenso, caída y aterrizaje. La cadencia depende del desplazamiento físico real: al quedar bloqueado contra una pared, la animación converge a reposo. Se agregan respiración y parpadeo discretos. Son animaciones procedurales, no un rig o animaciones finales elaborados en Blender; no hay adaptación de cada pie al terreno mediante rayos.

La pausa ahora congela física y articulaciones del jugador y los guanacos, incluso durante un salto. Reanudar conserva el impulso vertical. Volver al checkpoint limpia velocidad, pose y reacción de aterrizaje. La misión, el formato de guardado y los controles se mantienen.

## Verificación

Un agente de QA propuso los casos de regresión y escribió `game/tests/motion_test.gd`. La integración y ejecución se realizaron en el entorno principal. El driver exige que esta prueba pase además de importación, smoke, escena principal y aventura. Casos: sprint→caminar→reposo, pausa aérea, congelación de fauna/articulaciones, reanudación y aterrizaje, choque con pared y limpieza de pose al reaparecer.

La captura con renderer real añade encuadres de caminar, saltar y volver al suelo. Las imágenes acreditan poses y encuadres; no sustituyen una evaluación perceptual continua de la animación. Los reportes registran el renderer software del runner, no FPS de un PC objetivo. Estado de cada ejecución en `native-result.json` y logs.

## Pendientes

Modelos y rig final de Blender; adaptación de pies a pendientes; navegación de fauna alrededor de obstáculos; audio espacial y sincronización fina de pasos; revisión continua de movimiento por una persona; ejecución y rendimiento en Windows físico. El incremento no declara el juego listo para venta ni compatibilidad iOS física.
