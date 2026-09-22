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

## Legs and ground contact — September 22

- Continuous skinned trouser legs blend thigh and shin across the knee; existing boots and animation paths remain intact.
- Stance travel now matches measured character displacement. Shorter stride cycles fit the character's leg length; arm response follows the faster cadence.
- Two downward physics probes adjust foot height and sole orientation on walkable surfaces. Player collision and jump physics are unchanged. Checkpoint reset clears ankle corrections.
- Deterministic flat-ground walk regression: mean stance drift 0.000452 m/frame, maximum sole height error 0.000143 m over 95 samples at 60 Hz and 3.2 m/s. This is a synthetic straight-line test, not a claim about every terrain or turn. Slope-normal and existing motion/pause/collision checks also pass.
- CI now captures running as well as walking and jumping. Remaining limits: no persistent world-space foot lock through sharp turns, no toe articulation, and steep terrain can exceed leg reach. Hardware FPS has not been measured.

## Torres del Paine skyline — September 22

Replaced the active flat photo backdrop with three volumetric procedural granite towers and a shared scree apron. The original texture remains in source history/assets but is no longer displayed. Each tower has an independently authored height/width, asymmetric contour, longitudinal ribs and coherent surface noise. A granite shader adds vertical weathering, tonal variation and snow limited by height and surface slope. Native day/night lighting now affects the entire landmark.

The four added meshes total approximately 61,000 triangles and four material submissions before engine passes. No transparent skyline edges or billboard orientation are used. Added front and side renderer captures for silhouette and depth review. This is a stylized artistic interpretation, not surveyed terrain or a geographically accurate digital twin. These distant meshes are scenery outside the playable route, not climbable terrain. Hardware performance remains unmeasured.
