"""Create a saved, reproducible 2-meter Blender source for the GLB pipeline gate.

Run with Blender --factory-startup --background --python-exit-code 1
--python tests/blender_fixture.py -- /absolute/path/source.blend.
"""

from pathlib import Path
import sys

import bpy


def main():
    if "--" not in sys.argv:
        raise ValueError("Pass destination source.blend after --")
    arguments = sys.argv[sys.argv.index("--") + 1:]
    if len(arguments) != 1:
        raise ValueError("Expected exactly one destination source.blend")
    destination = Path(arguments[0]).resolve()
    if destination.suffix.lower() != ".blend":
        raise ValueError("Destination must end in .blend")
    if destination.exists():
        raise FileExistsError(f"Refusing to replace an existing source: {destination}")
    if bpy.app.version[:2] != (4, 5):
        raise RuntimeError(f"Expected Blender 4.5.x; found {bpy.app.version_string}")

    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    for collection in list(bpy.data.collections):
        bpy.data.collections.remove(collection)
    for material in list(bpy.data.materials):
        bpy.data.materials.remove(material)
    collection = bpy.data.collections.new("ExportFixture")
    bpy.context.scene.collection.children.link(collection)
    bpy.context.scene.unit_settings.system = "METRIC"
    bpy.context.scene.unit_settings.scale_length = 1.0

    bpy.ops.mesh.primitive_cube_add(size=2.0, location=(0.0, 0.0, 0.0))
    cube = bpy.context.object
    cube.name = "FixtureCube"
    cube.data.name = "FixtureCubeMesh"
    for owner in list(cube.users_collection):
        owner.objects.unlink(cube)
    collection.objects.link(cube)
    material = bpy.data.materials.new("FixtureMaterial")
    material.use_nodes = True
    material.node_tree.nodes.get("Principled BSDF").inputs["Base Color"].default_value = (
        0.15, 0.5, 0.2, 1.0
    )
    cube.data.materials.append(material)
    destination.parent.mkdir(parents=True, exist_ok=True)
    result = bpy.ops.wm.save_as_mainfile(filepath=str(destination))
    if result != {"FINISHED"} or not destination.is_file():
        raise RuntimeError(f"Could not save fixture: {result}")
    print(f"FORESTIN_BLENDER_FIXTURE source={destination}")


if __name__ == "__main__":
    main()
