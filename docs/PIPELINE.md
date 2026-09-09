# Fase 0 — herramientas y ejecución

## Versiones fijadas

- Godot **4.5.1 stable**, edición estándar/GDScript. Pin inicial reproducible, no una afirmación de ser la última versión.
- Blender **4.5.13 LTS** para validar el flujo de assets; el exportador acepta 4.5.x.
- Python 3.10+ para herramientas nativas; Node 24 para el prototipo web.

Fuentes oficiales: [Godot 4.5.1](https://godotengine.org/article/maintenance-release-godot-4-5-1/), [assets y hashes del release](https://api.github.com/repos/godotengine/godot/releases/tags/4.5.1-stable), [Blender 4.5 LTS](https://www.blender.org/releases/4-5/), [checksums Blender 4.5.13](https://download.blender.org/release/Blender4.5/blender-4.5.13.sha256), [exportar iOS en Godot 4.5](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_ios.html).

## PC Windows

Clonar este repositorio en el PC y abrir `game/project.godot` con Godot 4.5.1. El editor permite F6 para la escena actual y F5 para el proyecto. Esta fase presenta una escena de infraestructura, todavía sin movimiento de personaje.

Desde la raíz del repositorio, PowerShell:

```powershell
py -3 tools/setup_godot.py --windows-templates
py -3 tools/native.py doctor
py -3 tools/native.py validate
py -3 tools/native.py export-windows
```

El instalador descarga archivos oficiales, verifica SHA-256 y conserva las herramientas en `.tools/`. El archivo de plantillas completo pesa aproximadamente 1,36 GB; solo se instalan las plantillas Windows x86_64. No modifica PATH ni instala servicios. Requiere curl y acceso a GitHub. Si Godot ya está instalado, indicar `--godot "C:\ruta\Godot_v4.5.1-stable_win64_console.exe"` o definir `GODOT_BIN`.

El ejecutable resultante está en `builds/windows/ForestinAventura.exe`. Incluye el paquete del juego embebido y no necesita el editor. Está sin firma de distribución. Su exportación no acredita aún una prueba gráfica real en Windows.

Para probar perfiles desde consola: `ForestinAventura.exe -- --quality=LOW` (también MEDIUM, HIGH, ULTRA, MOBILE). En fase 0 cambian escala de render, MSAA, sombras y distancia lejana; LOD, vegetación y reflejos se implementarán junto con los assets. El renderer Compatibility es una base conservadora de infraestructura; evaluar Forward+ PC/Mobile cuando exista una escena representativa.

## Blender y Mac

Instalar Blender 4.5.13 para el sistema y arquitectura correspondientes. Abrir/crear fuentes en las carpetas `blender/`; seguir [exportación GLB](../blender/PIPELINE.md). El proyecto Godot consume GLB, no necesita lanzar Blender al jugar.

En Mac se comparte el mismo repositorio. Ejecutar `python3 tools/setup_godot.py` y `python3 tools/native.py validate`. Para iOS se necesita Godot, plantillas iOS de la misma versión, Xcode compatible con el macOS instalado y firma configurada en el equipo; ver [IOS.md](IOS.md). El bootstrap `--windows-templates` no instala plantillas iOS. Esta fase no configura certificados ni publica en TestFlight/App Store.

La conexión de trabajo es mediante archivos del repositorio y comandos locales reproducibles. No existe en esta fase un agente remoto conectado al PC o al Mac del usuario. Los runners propios son opcionales posteriores; las validaciones nativas de CI usan un runner Linux alojado por GitHub y no dependen de VM3 ni Forge.

## CI y reportes

`native.yml` ejecuta tests de herramientas, descarga Godot/plantillas con hashes fijados, importa el proyecto, ejecuta smoke, verifica el arranque configurado y exporta Windows. Adjunta logs y build como artefactos del workflow, sin publicar una release. El job Windows tiene límite de 25 minutos. Un segundo job instala Blender 4.5.13 con checksum oficial y verifica fuente → GLB → Godot (límite de 15 minutos).

`pages.yml` solo se activa automáticamente con cambios del prototipo web. Una iteración exclusiva de `game/`, `tools/`, `blender/` o documentación no vuelve a publicar Pages. El disparo manual web sigue disponible.

Comandos nativos producen `builds/reports/doctor.json`, logs y `native-result.json`. Un error del motor en el log, salida no-cero o falta del marcador de smoke causa fallo. Las validaciones requieren el motor fijado; no convierten ausencia de herramientas en éxito.

## Prueba Blender → Godot

Ejecutar `python tools/validate_blender.py --blender "ruta/al/blender" --godot "ruta/al/godot"`. El script crea una fuente temporal bajo `builds/`, exporta mediante `blender/scripts/export_glb.py`, comprueba SHA-256 de la fuente antes/después y carga el GLB con `game/tests/glb_test.gd`. Usar `--python-exit-code 1` para propagar fallos de Python. El cubo de prueba valida escala y transporte, no anatomía, rig ni animaciones del futuro Forestín.

Ver [PHASE0_RESULT.md](PHASE0_RESULT.md) para evidencia y pendientes de esta ejecución.

## Capturas 0.1.0

En un entorno con pantalla, ejecutar Godot con `--path game --script res://tests/capture_adventure.gd -- --no-save`. CI usa Xvfb y guarda PNG en `builds/reports`. No confundir el render por software del runner con rendimiento de PC.
