# Forestín Explora — web prototype 0.8

A playable third-person expedition inspired by Torres del Paine, Chile. Artistic landscape, procedural 3D character, four discoveries, camera framing and visibility checks, three unique litter pickups, a field passport, day/night lighting, local progress and touch/keyboard controls. Not an official park product or navigation map.

## Run

Node 24+. `npm ci`, `npm run dev`. Production: `npm test` then `npm run build`.

## Architecture

- `src/rules.ts`: renderer-independent mission rules, terrain math, save validation and pickup logic.
- `src/world.ts`: Babylon.js rendering, procedural geometry, lights, shadows and animation.
- `src/main.ts`: input, camera, game loop and accessible HTML interfaces.
- `src/style.css`: responsive desktop and iPhone interfaces.
- `.github/workflows/pages.yml`: tested Vite static build and GitHub Pages deployment.

WASD/arrows or left joystick to move. Drag scenery to orbit. C opens the camera; Space interacts/takes a photo. The guided-walk control follows the trail and stops at each encounter. Escape pauses. Photos and progress stay on the device. There is no analytics, backend or account.

## iOS path

The static `dist` build uses relative paths and can be embedded in a Capacitor iOS shell with `webDir: 'dist'`. Add the native shell only on a Mac with a supported Xcode/Capacitor toolchain. Real-device performance, signing, icons, privacy declarations and App Store release remain separate work; this repository is the playable web iteration.

## Validation

Node tests check save sanitization, unique/proximity-based pickups, traversable route and photo feedback gates. The scene includes a software polygon fallback for browsers without WebGL; hardware rendering remains the default. Browser QA covers rendered controls and progression. This prototype uses an original procedural interpretation of Forestín and the park rather than the detail level of the earlier concept illustration.

## Iteration 0.4 — Patagonian light

Smoother granite profiles, locally generated surface and normal textures, physically based materials on hardware rendering, animated glacial water, ACES color mapping, soft PCF shadows and restrained optional bloom. The quality control switches between balanced and cinematic rendering; mobile defaults to balanced. Software rendering retains simpler materials and omits GPU postprocessing.

Photography now accepts either visible guanaco and matches the actual on-screen viewfinder. Touch controls retain at least 44-pixel targets in landscape. Existing progress is retained.

This remains Babylon.js running locally in the browser, not an Unreal Engine build or an equivalent to Unreal's rendering features. Real-iPhone performance remains to be measured on the device.

## Iteration 0.5 — Characters and wildlife

Forestín has a separate articulated head, cheek lobes, whiskers, eyelids, a rounded backpack, uniform details and distance-driven gait with knee articulation. Guanacos have articulated necks and legs, different animation phases, grazing, alert and bounded retreat/return behavior. The supplied Forestín reference informs the green named helmet, khaki uniform, pale gloves, brown trousers, dark boots and broader face. The browser model is a simplified interpretation, not a reconstruction of the reference fur.

Photography uses each animal's transformed torso anchor, including scale, and rechecks visibility at shutter time. Wildlife stays within four game units of its home and checks terrain/obstacles. Player movement cannot pass through animals. Wildlife state rules have automated tests.


## Iteration 0.6 — Character and landscape detail

Visual-only iteration: directional fur color/normal maps, opaque short fur tufts, broader cheeks and nose, dark glossy eyes, pocket flaps, boot soles and laces. Guanacos have a separate ivory undercoat, narrower head and muzzle, ear interiors and coat tufts. Lenga crowns combine smaller inner volumes with individually oriented opaque leaves. Granite has deeper erosion channels, slope-dependent snow and a distinct surface pattern; the uniform and bark now have their own patterns.

Hardware rendering adds a small locally generated sky reflection cube, restrained environment lighting and water color based on the existing analytical shoreline. These are procedural approximations, not scanned assets, HDR photography or Unreal rendering. Mobile retains its balanced preset and no external assets are fetched.

The CPU fallback now uses per-pixel reciprocal-depth testing, near-plane clipping and interpolated shading, eliminating lake/ground ordering artifacts. It caps resolution at 720 pixels wide and 480,000 total pixels. All visual distribution uses separate deterministic seeds, keeping existing obstacles and route logic intact. Saved progress and gameplay rules are unchanged.

Validation: six gameplay tests and TypeScript/production build; full-scene headless CPU rendering checked for valid geometry and wildlife anchors; isolated renderer tests checked draw-order independence, crossing triangles and near-plane clipping. Hardware rendering and real-iPhone frame rate still require device validation.


## Iteration 0.7 — Mobile rendering and living landscape

Touch devices now build a dedicated geometry profile: reduced terrain/rock/crown tessellation, grass and fur counts; 512-pixel shadows with fewer casters; no HDR postprocess, MSAA or persistent drawing buffer. The default mobile target is 30 render frames per second, not a guaranteed device measurement. The mobile quality control switches between fluency and detail; its preference is independent of desktop. Rendering uses inverse pixel density correctly, with an adaptive resolution controller and pixel budgets, including rotation.

Headless geometry construction measured 214,855 triangles on the mobile profile versus 622,367 on the desktop profile (65.5% fewer), and 46 versus 140 shadow casters. Both profiles keep the same 43 blocking obstacles. These numbers describe scene complexity, not measured FPS. Desktop has smoother character surfaces, additional fur, 1536-pixel shadows and retained cinematic processing. Both hardware profiles add shader-driven wind in grass, drifting clouds and nose surface relief.

HUD and photography feedback update about eight times per second; the shutter still validates the exact current frame. Mobile camera obstruction checks update at ten Hz. Static world matrices are frozen. Hidden pages stop rendering, dialogs pause it, WebGL context loss preserves progress, and touch pointers retain their own ownership. Mobile controls use safe areas and avoid costly backdrop blur.

Validation: eight tests (including pixel budgets and adaptive resolution), production TypeScript/Vite build, CPU scene rendering, finite wildlife anchors and mobile/desktop obstacle comparison. GPU shaders, WebGL photo export, context restoration, actual touch interaction and thermal performance require testing on a real iPhone; they were not measured by the headless checks.


## Iteration 0.8 — Desktop visual finish

Desktop-only additions: curved combed fur ribbons on Forestin and guanacos, uniform topstitching, restrained fabric sheen and helmet clearcoat; clustered tussocks with narrow seed heads, low cushion plants and glacial gravel. These add 40,237 triangles in eleven opaque batches, for 662,604 desktop triangles total. They are decorative, use independent seeds and follow existing character rigs. The mobile profile remains at 214,855 triangles and contains none of these additional batches. Both retain the same 43 obstacles and transformed animal photo anchors.

Desktop surface maps use 512-pixel detail and a 128-pixel sky cube. Supported desktop hardware adds half-resolution SSAO2 contact occlusion, conservative sharpen and a scenery-only planar lake reflection (768 square pixels). SSAO attaches before final color/AA processing and uses a geometry buffer to coexist with custom grass/water shaders. The reflected camera matrix is copied at RTT rendering; mobile water does not compile a reflection sampler. Balanced quality removes both contact occlusion and the reflection render target.

Desktop quality cycles Balanced / Cinematic / Ultra. New desktop preferences default to Ultra; existing choices are honored. Ultra allows up to 6.2 million output pixels, MSAA up to four samples according to support, 16 AO samples and reflection each frame; Cinematic uses 8 AO samples and reflection every second frame. Adaptive pixel density remains available, including DPR1 monitors. This is a quality preset, not a promise of fixed FPS on all PCs.

Validation: eleven Node tests and TypeScript/Vite build. Headless geometry construction checked all positions, eleven desktop-only batches, identical collision placement/animal anchors, and unchanged mobile triangle count. No browser GPU was available in this run; visual correctness and speed of SSAO, planar reflection and hardware antialiasing still need a real-PC review. Software fallback cannot validate these effects. The assets remain a procedural stylized interpretation of the supplied character reference.

Desktop feel is also refined: a closer shoulder camera with frame-rate independent orbit easing, progressive manual acceleration/braking and a narrower field of view. Guided-route logic is preserved. Two additional tests check angle wrapping and matching motion at 30/60 FPS.
