# Gameplay

Alcance objetivo: expedición de 5–10 minutos, moverse agradablemente, observar guanacos, interactuar y llegar a un checkpoint. La escena mínima de fase 0 solo comprueba infraestructura; estas mecánicas se implementan en fase 1.

## Referencia funcional web inspeccionada

`src/rules.ts` define un sendero de ocho puntos, cuatro descubrimientos (mirador, guanaco, lago y residuos), tres residuos únicos y posición inicial `(-10, 31)` en X/Z. La foto exige distancia entre 7 y 19 unidades inclusive, encuadre y visibilidad. La recogida acepta proximidad máxima de 2,6 unidades. Son valores del prototipo, no distancias oficiales del parque ni parámetros nativos ya migrados.

`src/wildlife.ts` contiene grazing/watching/retreating/returning, umbrales con histéresis y desplazamiento limitado alrededor del origen. La versión nativa añadirá navegación y reposo/reagrupamiento cuando la primera interacción sea estable.

## Primer incremento nativo

Jugador camina, corre, salta, cae y aterriza; el collider gobierna movimiento en pendientes. Cámara orbital suave evita paredes y oclusión. Mantener acción lógica de interacción separada de salto: en web Space también interactúa/fotografía, por lo que no trasladar teclas literalmente.

Objetivo inicial: seguir sendero, observar un guanaco y alcanzar mirador/checkpoint. Recogidas y pasaporte pueden migrarse después del flujo mínimo. Objetivos tienen IDs estables y finalización idempotente. Recargar recupera checkpoint válido; guardado corrupto vuelve a estado seguro.

Entradas objetivo: teclado/mouse y gamepad en PC; joystick y zona de cámara táctiles en iOS. UI sin emojis, con estado de pausa explícito y objetivos breves. No generar dos implementaciones del gameplay.

Criterios: velocidad estable entre tasas de cuadros, diagonal normalizada, salto sin atravesar terreno, cámara sin clipping, animal sin cruzar obstáculos, objetivos sin duplicación y restauración coherente al reiniciar.

## Prototipo 0.1.0

Implementados los cuatro objetivos del sendero, guardado y locomoción descritos en [fase 1](PHASE1_RESULT.md). Las acciones existentes alimentan el controlador nativo; los adaptadores táctiles siguen pendientes.
