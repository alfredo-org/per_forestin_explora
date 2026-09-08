# Blender → Godot

Base del pipeline: **Blender 4.5 LTS**, serie 4.5.x. Una unidad representa un metro.
El script rechaza otras series; fijar también el parche y checksum al instalarlo en CI.

Las fuentes editables `.blend` se organizan en `forestin/`, `wildlife/`,
`environment/` y `props/`. Sus README definen criterios de producción; todavía no
contienen modelos. Los GLB derivados van a `game/assets/` y Godot los importa.
Evitar importar `.blend` directamente: obligaría a tener Blender en cada equipo.

Desde la raíz del repositorio, con una fuente real creada y guardada:

```bash
blender --background blender/forestin/forestin.blend --python-exit-code 1 --python blender/scripts/export_glb.py -- game/assets/forestin/forestin.glb --collection Forestin
```

Para reemplazar un GLB existente añadir `--overwrite`. No se guarda ni modifica
el `.blend` fuente en disco. La salida se prepara temporalmente y se reemplaza
solo después de comprobar el encabezado GLB. Mantener `--python-exit-code 1`:
Blender necesita esta opción para devolver error al shell si falla Python.

La colección explícita incluye sus subcolecciones. Debe contener meshes y sus
armatures/padres, visibles y seleccionables en la capa activa. Realizar instancias
antes de exportar. Excluir cámaras y luces de esa colección. Aplicar escala en la
fuente de forma deliberada, antes de rigging; el exportador no altera geometría.
Usar nombres ASCII estables que comiencen por letra, con dígitos o guion bajo;
sin sufijos automáticos `.001`. Esto se valida en objetos, colección principal,
materiales y huesos. Se rechazan meshes vacíos, coordenadas no finitas y escala
de objeto distinta de uno.

El exportador incluye animaciones según la configuración glTF de Blender. No
comprueba aún pesos, UV, texturas externas, LOD ni calidad de clips: verificar
materiales, orientación, tamaño, esqueleto y todas las animaciones en Godot antes
de integrar cada asset. Registrar origen y licencia de texturas y referencias.

Validación pendiente: ejecutar con Blender 4.5.x y una fuente real; confirmar
importación GLB en Godot y conservación del SHA-256 de la fuente. La revisión
estática del script no demuestra una exportación ni una animación funcional.
