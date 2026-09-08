# Rendimiento

Estado inicial: FPS, 1% low, frame time, RAM, VRAM, draw calls, triángulos y carga nativos **no medidos** en este documento. Las cifras históricas del README corresponden a la web y no son benchmarks de Godot. Consultar resultados de ejecución de la iteración en PIPELINE/QA cuando se registren.

Objetivo PC: 60 FPS (presupuesto de referencia 16,67 ms por cuadro), condicionado a hardware/resolución. No existe todavía un PC mínimo validado. Móvil: establecer objetivo sostenido por dispositivo físico; no inferirlo del emulador o de un test headless.

| Perfil objetivo | Ajustes propuestos, aún por calibrar |
|---|---|
| LOW | Menor distancia/densidad, sombras económicas, reflejos simples. |
| MEDIUM | Balance de resolución, vegetación, sombras y efectos. |
| HIGH | Referencia PC de composición y detalle. |
| ULTRA | Mayor coste de sombras/reflejos/distancia según GPU. |
| MOBILE | Presupuesto independiente de memoria, resolución, vegetación y postprocesado. |

Todos conservan colisiones, interacción y reglas de misión. Medir antes de elegir LOD, culling, instancing o reducir texturas. Evitar aumentar pelaje/partículas sin registrar coste GPU y estabilidad del cuadro.

## Protocolo

Usar mismo commit, cámara/recorrido, semilla, escena y hora del día. Registrar versión del motor, SO, CPU/GPU, RAM, renderer, resolución interna/salida y perfil. Calentar shaders antes del recorrido medido y registrar por separado arranque frío. Repetir trayecto de 60 segundos al menos tres veces; documentar metodología del 1% low y distribución de frame times.

En iPhone registrar modelo, versión iOS, alimentación, brillo, duración y estado térmico disponible. Evaluar sesión prolongada y suspensión/reanudación. No comparar muestras con configuraciones distintas como mejoras concluyentes.

Plantilla por ejecución: fecha; commit/build; plataforma/hardware; motor/renderer; resolución/perfil; FPS medio; 1% low; frame time p95; RAM/VRAM; draw calls/triángulos; carga; duración; limitaciones. Si una métrica no está disponible, escribir “no medido”.
