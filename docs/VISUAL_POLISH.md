# Visual polish — September 2026

Procedural geometry and shaders; no generated bitmap assets.

- Continuous terrain normals and a 192-sector, 22-band distant ridge replace large visible triangular slopes.
- Rocks use smoother noisy surfaces and stone/moss variation. Trees have curved branches and cupped leaves with color, veins and wind.
- Instanced grass uses height gradients and wind: 420 tufts on LOW/MOBILE, 3600 on MEDIUM, 6000 on HIGH/ULTRA. Tree foliage remains 405/810 instances by profile; individual leaves have more geometry.
- Daylight, atmospheric color and water shading have been revised together.
- Forestin has a fitted helmet with shallow ribs, continuous boot uppers and curved garment pockets. Existing animation joints remain compatible.

Validation: local Godot 4.5.1 import and native validation passed, including adventure, save, collision and motion checks. The commit triggers actual software OpenGL captures and browser export checks in CI. Those captures must be reviewed separately; headless tests do not establish visual quality or hardware performance.

Limits: this remains a procedural stylized character. Clothing deformation, foot planting and production character topology still need further art and animation work. Higher foliage geometry needs real-device performance testing.

## Continuous sleeves — September 22

Each sleeve is now one skinned mesh with a torso anchor and blended upper-arm/forearm influences, driven by the existing animation joints. The wrist follows the same elbow transform as the hand. Shoulder pivots sit closer to the torso, and cuffs use a shallow continuous contour. Clothing uses a matte shader with fine weave faded by screen-space derivatives to avoid distant shimmer.

Regression checks cover normalized packed skin weights (16-bit quantization tolerance), inverse bind transforms, left/right elbow poses under a transformed character, and existing walk/run/pause/checkpoint behavior. Real rendering and web export are checked by CI; target-device FPS remains unmeasured. The torso and sleeves remain separate meshes at the garment seam; this is not a full-body production rig or cloth simulation.
