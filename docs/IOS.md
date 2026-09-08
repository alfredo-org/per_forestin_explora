# PC de desarrollo y ruta iOS

Estos pasos describen configuración pendiente; crear archivos en el repositorio no establece conexión con el PC, Mac ni iPhone del usuario. Versiones y comandos reproducibles de la iteración se centralizan en [PIPELINE.md](PIPELINE.md).

## Windows

Instalar Git, Godot 4.5.1 y sus plantillas de exportación coincidentes; Blender 4.5 LTS es la base propuesta para producción de assets. Usar un checkout del repositorio, por ejemplo `C:\dev\per_forestin_explora`, y abrir `game/project.godot`. Mantener herramientas en rutas explícitas y comprobar sus versiones antes de importar.

El flujo inicial es Git + comandos locales: importar proyecto, ejecutar escena, exportar a `builds/windows/` y abrir el ejecutable sin editor. Una ejecución headless en Linux no sustituye esta prueba. Si posteriormente se registra un runner propio, limitarlo al repositorio y cargas confiables; aún no se da por conectado ni configurado.

## Mac e iPhone

Usar el mismo repositorio y `game/`, Godot fijado, plantillas de exportación, Xcode con SDK compatible con el iPhone y herramientas de línea de comandos seleccionadas. Confirmar compatibilidad real de macOS, Xcode, arquitectura del Mac y versión iOS antes de fijar ese runner. No se presupone que el Mac ya tenga la versión necesaria.

Secuencia de trabajo: importar en Godot sobre Mac, exportar proyecto iOS a `builds/ios/`, abrirlo en Xcode, configurar identificador de app y equipo de firma, compilar y ejecutar en dispositivo. Emparejar/desbloquear iPhone y completar los requisitos de desarrollo que solicite Xcode. Guardar certificados y credenciales fuera de Git.

Exportar el proyecto Xcode, compilarlo, firmarlo, probarlo y publicarlo son pasos distintos. Distribución mediante TestFlight/App Store requiere configurar la cuenta y la distribución correspondiente; ninguna publicación está incluida en fase 0.

## Diseño móvil

Mismo gameplay y guardado lógico, con adaptación de input/UI y perfil visual. Validar safe areas, orientación, tamaño de controles, multitouch, pausa al perder foco y suspensión/reanudación. Priorizar Forestín y composición del paisaje al ajustar densidad, sombras, resolución y reflejos.

Gate iOS: build firmado en iPhone físico, misión completada, guardado recuperado, controles comprobados y rendimiento sostenido con memoria/temperatura documentados. Actualmente ese gate no está acreditado por la documentación de arranque.
