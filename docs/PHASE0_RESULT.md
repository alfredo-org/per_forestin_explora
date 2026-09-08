# Forestín Aventura — resultado fase 0

Fecha: 2026-09-08. Estado: infraestructura implementada y validada headless; aprobación visual y arranque Windows en PC pendientes.

Base auditada: `95328c523e625331b2c987d25b51f3d39b48622a`, repositorio `alfredo-org/per_forestin_explora`. La revisión fuente corresponde a la iteración que incorpora este documento; identificar su commit en el historial. El prototipo web conserva código y assets, incluida la ilustración Torres.

## Qué cambió

- Proyecto nativo `game/project.godot`, escena mínima con cámara, iluminación, suelo/collider y geometría de diagnóstico.
- Acciones lógicas de teclado/gamepad; adaptador táctil y locomoción pendientes de fase 1.
- Perfiles LOW/MEDIUM/HIGH/ULTRA/MOBILE con parámetros realmente aplicados: resolución, MSAA, sombras y distancia.
- Export Windows con recursos embebidos; herramientas con versiones/hashes fijados y logs de error.
- Exportación Blender de colección explícita con protección del original y validación de formato.
- CI nativa para importación, smoke, build Windows y prueba Blender → Godot; Pages automático limitado a cambios web.
- Inventario de reutilización, arquitectura, backlog y guías PC/Mac/iOS.

## Pruebas ejecutadas en este entorno Linux

| Comprobación | Resultado |
|---|---|
| `npm test` con dependencias instaladas | 11/11 pruebas web pasan |
| `npm run build` | TypeScript y Vite completados |
| `python3 -m unittest discover -s tests -v` | 5/5 pruebas de manejo de errores, timeout y argumentos pasan |
| Godot 4.5.1 importación headless | Sin errores de parseo/importación |
| Smoke nativo | `FORESTIN_SMOKE_RESULT failures=0` |
| Escena principal configurada | Arranca y emite `FORESTIN_BOOT_OK` |
| Export Windows | Correcto; executable PE x86_64 con paquete embebido |
| Blender 4.5.13 → GLB → Godot | `FORESTIN_GLB_RESULT failures=0`; cubo 2 m, escala y material conservados |
| Protección de fuente Blender | SHA-256 antes/después idéntico |

Se detectaron archivos incompletos al extraer Blender en este entorno; se repararon desde el archivo oficial verificado antes de ejecutar la prueba. La instalación final identificó Blender 4.5.13 LTS. No se usó ese arranque fallido como resultado satisfactorio.

## Build y métricas disponibles

- Versión nativa: `0.0.1-phase0`.
- Godot: `4.5.1.stable.official.f62fdbde1`.
- Windows EXE: `96740088` bytes (92.26 MiB).
- SHA-256 EXE: `a71a90b70eadec78a3d929a5b1735795ac4fd258b43cbc3bf99b4943bc4f41b0`.
- GLB de fixture: `1952` bytes; una malla de prueba, no el modelo final de Forestín.
- FPS, 1% low, frame time gráfico, VRAM, RAM en PC/iPhone, draw calls y tiempo de carga en dispositivo: **no medidos**.
- El build es una escena de diagnóstico sin firma de distribución, no un vertical slice jugable ni una publicación comercial.

## Pendientes y siguiente iteración

1. Abrir `ForestinAventura.exe` en Windows y registrar GPU, resolución, captura y errores si los hubiera. La exportación en Linux no prueba el arranque gráfico en Windows.
2. Implementar fase 1: movimiento y cámara tercera persona, terreno con colisión, Forestín/guanaco provisionales, objetivo y checkpoint.
3. Recrear modelos/rig en Blender usando las referencias; reutilizar reglas de la web y evaluar importación del fondo Torres.
4. Conectar el Mac mediante el repositorio y preparar Xcode/firma cuando se trabaje iOS. Sin instalación ni prueba física de iPhone en esta iteración.

Principal brecha actual: todavía no hay gameplay nativo ni assets finales. La infraestructura ya permite construirlos y verificarlos de forma repetible.

La ejecución local de las pruebas anteriores está verificada. Consultar GitHub Actions para el estado remoto del commit; este documento no anticipa su resultado.
