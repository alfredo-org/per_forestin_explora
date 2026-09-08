"""Blender 4.5.x: validate one named collection and export GLB without saving source."""

import argparse
import math
from pathlib import Path
import re
import sys
import tempfile


def arguments(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, help="Destination .glb")
    parser.add_argument("--collection", required=True, help="Exact export collection name")
    parser.add_argument("--overwrite", action="store_true", help="Replace an existing GLB")
    args = parser.parse_args(argv)
    if args.output.suffix.lower() != ".glb":
        parser.error("output must have .glb extension")
    return args


def validate_name(name):
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*", name):
        raise ValueError(f"Use stable ASCII names (letters, digits, underscore): {name!r}")


def export(args):
    import bpy

    if bpy.app.version[:2] != (4, 5):
        raise RuntimeError(f"Expected Blender 4.5.x; found {bpy.app.version_string}")
    source = Path(bpy.data.filepath).resolve() if bpy.data.filepath else None
    if source is None or not source.is_file():
        raise ValueError("Open a saved .blend source with --background source.blend")
    output = args.output.resolve()
    if output == source:
        raise ValueError("The output must not replace the source")
    if output.exists() and not args.overwrite:
        raise FileExistsError(f"{output} exists; pass --overwrite to replace the GLB")
    collection = bpy.data.collections.get(args.collection)
    if collection is None:
        raise ValueError(f"Collection not found: {args.collection}")
    validate_name(collection.name)
    objects = list(collection.all_objects)
    if not objects or not any(obj.type == "MESH" for obj in objects):
        raise ValueError("Export collection must contain at least one mesh")
    if not math.isclose(bpy.context.scene.unit_settings.scale_length, 1.0):
        raise ValueError("Set scene unit scale to 1.0 (one Blender unit = one meter)")
    for obj in objects:
        validate_name(obj.name)
        if obj.type not in {"MESH", "ARMATURE", "EMPTY"}:
            raise ValueError(f"Unsupported export object: {obj.name} ({obj.type})")
        if obj.instance_type != "NONE":
            raise ValueError(f"Realize instances before export: {obj.name}")
        if obj.name not in bpy.context.view_layer.objects:
            raise ValueError(f"Object excluded from active view layer: {obj.name}")
        if obj.hide_get() or obj.hide_viewport or obj.hide_select:
            raise ValueError(f"Make export object visible and selectable: {obj.name}")
        if obj.parent is not None and obj.parent not in objects:
            raise ValueError(f"Include parent {obj.parent.name} in the export collection")
        if not all(math.isfinite(v) for row in obj.matrix_world for v in row):
            raise ValueError(f"Non-finite transform: {obj.name}")
        if not all(math.isclose(s, 1.0, abs_tol=1e-5) for s in obj.scale):
            raise ValueError(f"Apply object scale before export: {obj.name}")
        if obj.type == "ARMATURE":
            for bone in obj.data.bones:
                validate_name(bone.name)
        if obj.type == "MESH":
            if not obj.data.vertices or not obj.data.polygons:
                raise ValueError(f"Empty mesh: {obj.name}")
            if not all(math.isfinite(v) for vertex in obj.data.vertices for v in vertex.co):
                raise ValueError(f"Non-finite mesh coordinates: {obj.name}")
            for material in obj.data.materials:
                if material is None:
                    raise ValueError(f"Empty material slot: {obj.name}")
                validate_name(material.name)
            for modifier in obj.modifiers:
                if modifier.type == "ARMATURE" and modifier.object not in objects:
                    raise ValueError(f"Missing armature in collection: {obj.name}")

    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    for obj in bpy.context.view_layer.objects:
        obj.select_set(False)
    for obj in objects:
        obj.select_set(True)
        if not obj.select_get():
            raise ValueError(f"Could not select object: {obj.name}")
    bpy.context.view_layer.objects.active = next(obj for obj in objects if obj.type == "MESH")
    output.parent.mkdir(parents=True, exist_ok=True)
    # Stage beside the destination so an exporter failure preserves any previous GLB.
    with tempfile.TemporaryDirectory(prefix=".glb-export-", dir=output.parent) as staging:
        temporary = Path(staging) / output.name
        result = bpy.ops.export_scene.gltf(
            filepath=str(temporary),
            export_format="GLB",
            use_selection=True,
            export_cameras=False,
            export_lights=False,
            export_animations=True,
            export_yup=True,
        )
        if result != {"FINISHED"} or not temporary.is_file():
            raise RuntimeError(f"GLB export failed: {result}")
        with temporary.open("rb") as stream:
            header = stream.read(12)
        if len(header) != 12 or header[:4] != b"glTF" or int.from_bytes(header[4:8], "little") != 2:
            raise RuntimeError("Exporter did not produce a glTF 2.0 binary")
        if int.from_bytes(header[8:12], "little") != temporary.stat().st_size:
            raise RuntimeError("GLB length does not match its header")
        temporary.replace(output)
    print(f"EXPORTED {output} ({output.stat().st_size} bytes; {len(objects)} objects)")


if __name__ == "__main__":
    try:
        if "--" not in sys.argv:
            raise ValueError("Pass script arguments after --: output.glb --collection AssetName")
        export(arguments(sys.argv[sys.argv.index("--") + 1:]))
    except Exception as exc:
        print(f"EXPORT ERROR: {exc}", file=sys.stderr)
        # --python-exit-code 1 makes Blender propagate this exception to CI.
        raise
