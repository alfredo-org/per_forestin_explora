# Fase 1 — Sendero del mirador, 0.1.0

Iteración 2026-09-09. Base recuperada: a112373cd8e8774088498a1758041adf6a097e46.

## Implementado

Godot 4.5.1, renderer Compatibility. Terreno triangulado con colisiones, sendero, lago con shader animado, rocas, árboles y vegetación MultiMesh. Reutilización del fondo Torres del prototipo existente, teñido para noche. Forestín y guanacos son modelos procedurales simplificados con animación de pivotes; no son assets finales de Blender.

Locomoción con aceleración, sprint, salto con tolerancia de borde y pulsación anticipada, gravedad y cámara SpringArm con sonda esférica. Acciones compartidas de teclado y gamepad. Fauna con pastoreo, alerta, retirada y retorno limitado al entorno de origen; detección frontal de obstáculos, sin navegación avanzada.

Una misión de cuatro objetivos: señal de entrada, observación respetuosa de fauna con encuadre y visibilidad, tres residuos únicos, mirador final. Checkpoints por objetivo, JSON validado y escritura temporal con reemplazo, reinicio de partida, pausa, cambio de luz y calidad. Audio original generado por herramientas reproducibles: viento, pasos y confirmación.

## Validación

`python tools/native.py validate` importa el proyecto, conserva el smoke de infraestructura, ejecuta la escena principal sin guardado y prueba el recorrido nativo. `game/tests/adventure_test.gd` comprueba terreno, movimiento, salto/aterrizaje, pausa, proximidad, observación, recogidas únicas, final, continuación, reinicio, huida, datos inválidos, archivo corrupto, escritura/lectura, luz, densidad de vegetación y retracción de cámara ante pared. El recorrido automatizado usa teletransporte entre objetivos: no sustituye una sesión humana continua.

Se corrigió una inversión de caras del terreno descubierta por las pruebas físicas. Las pruebas de herramientas Python pasan (5 casos). Las salidas exactas de cada ejecución quedan en `builds/reports`, también adjuntas por CI. La exportación Windows se ejecuta con las plantillas oficiales fijadas y se considera comprobada solamente cuando `native-result.json` registra `passed` y el tamaño del ejecutable.

Capturas reales preparadas en `capture_adventure.gd` para CI con Xvfb/OpenGL por software. No se pudo abrir Xvfb en el entorno local. No se ha hecho QA perceptual ni medido FPS, 1% low, VRAM o latencia en una GPU de Windows. iPhone, firma y Xcode siguen pendientes.

## Mayor brecha y siguiente iteración

La identidad visual todavía depende de geometría simplificada. Priorizar personaje y guanaco elaborados en Blender, rig y animaciones de calidad, integración del fondo con relieve medio 3D y una revisión visual del recorrido en PC. Validar a mano duración, legibilidad del sendero, cámara, audio y fauna antes de ampliar contenido. No es una versión comercial terminada.
