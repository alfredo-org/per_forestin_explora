# Arquitectura — Forestín Aventura

Decisión de fase 0: conservar el prototipo web en su ubicación actual e incorporar el juego nativo en `game/` dentro del mismo repositorio dedicado. No mezclar con Forge ni crear un segundo gameplay para iOS. El estado base auditado está en [INVENTORY.md](INVENTORY.md).

| Área | Responsabilidad |
|---|---|
| `src/`, `public/`, configuración Vite | Prototipo web existente y referencia de comportamiento. |
| `game/` | Proyecto Godot, escenas, scripts, recursos y assets importados nativos. |
| `blender/` | Fuentes editables y automatización de assets; añadir `.blend` reales al producirlos. |
| `tools/` | Comprobación de herramientas, importación, validación y builds reproducibles. |
| `docs/` | Decisiones, backlog, QA y métricas con evidencia. |
| `.github/workflows/` | CI nativa diferenciada de publicación web. |
| `builds/` | Salida local de exportación; binarios generados excluidos de Git. |

Godot 4.5.1 es la versión inicial fijada; Blender 4.5.13 LTS es la versión de validación del pipeline. Las versiones disponibles y sus verificaciones pertenecen a [PIPELINE.md](PIPELINE.md). No hay actualización automática de motor: cambiar versiones exige importar, probar y exportar nuevamente.

## Contratos objetivo de fases 1–2

Estas interfaces son diseño objetivo, no una afirmación de que el scaffold de fase 0 ya las implemente.

- Player: `CharacterBody3D` con velocidad física, collider independiente de apariencia y rig bajo nodo visual. Cámara con pivot, `SpringArm3D` y `Camera3D`.
- Input: acciones lógicas move, look, jump, sprint, interact y pause; adaptadores teclado/mouse, gamepad y tacto. La física consume intención, no botones específicos.
- Missions: definición de objetivo en Resource; progreso separado de la presentación. Interacciones emiten eventos de descubrimiento, recogida o llegada.
- Save: JSON versionado en `user://`, IDs estables, validación al cargar y escritura mediante archivo temporal. No depender del guardado web ni sobrescribirlo.
- Wildlife: estados locales por animal, percepción y navegación separados del rig; semilla explícita para variación reproducible.
- Quality: un perfil compartido selecciona presupuestos visuales sin alterar colisiones, objetivos ni guardado. El renderer de arranque no se promete intercambiable durante la partida.
- Art: `.blend` como fuente; `.glb` como entrega importada. No requerir Blender instalado para abrir el build final.

Las mallas de fondo no deben participar en colisiones ni objetivos. El sendero y los obstáculos deben conservarse al cambiar calidad. Documentar unidades/transformaciones y validar un asset de prueba antes de producir modelos en serie.

## Criterio de migración

Portar primero un recorrido pequeño con controles, cámara, un guanaco y un checkpoint. Luego comparar comportamiento con la web; trasladar reglas verificables antes de sustituir presentación. No retirar la versión web como parte de fase 0. El perfil visual inicial puede ser conservador mientras se valida la toolchain; la elección PC final y móvil se resuelve con mediciones GPU.

## Aventura nativa 0.1.0

`game/adventure/main.gd` integra UI y misión; `player.gd` resuelve locomoción/cámara; `wildlife.gd` percepción y movimiento; `landscape.gd` escenario; `shapes.gd` modelos provisionales; `progress.gd` validación y persistencia. Los tests nativos ejecutan la escena real.
