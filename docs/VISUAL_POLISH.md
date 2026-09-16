# Visual polish — September 2026

Procedural geometry and shaders; no generated bitmap assets.

- Continuous terrain normals and a 192-sector, 22-band distant ridge replace large visible triangular slopes.
- Rocks use smoother noisy surfaces and stone/moss variation. Trees have curved branches and cupped leaves with color, veins and wind.
- Instanced grass uses height gradients and wind: 420 tufts on LOW/MOBILE, 3600 on MEDIUM, 6000 on HIGH/ULTRA. Tree foliage remains 405/810 instances by profile; individual leaves have more geometry.
- Daylight, atmospheric color and water shading have been revised together.
- Forestin has a fitted helmet with shallow ribs, continuous boot uppers and curved garment pockets. Existing animation joints remain compatible.

Validation: local Godot 4.5.1 import and native validation passed, including adventure, save, collision and motion checks. The commit triggers actual software OpenGL captures and browser export checks in CI. Those captures must be reviewed separately; headless tests do not establish visual quality or hardware performance.

Limits: this remains a procedural stylized character. Clothing deformation, foot planting and production character topology still need further art and animation work. Higher foliage geometry needs real-device performance testing.
