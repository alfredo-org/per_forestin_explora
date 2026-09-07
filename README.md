# Forestín Explora — web prototype 0.6

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
