# Forestín Explora — web prototype 0.3

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

Node tests check save sanitization, unique/proximity-based pickups, traversable route and photo feedback gates. Browser QA checks the actual rendered game and complete expedition. This prototype uses an original procedural interpretation of Forestín and the park rather than the detail level of the earlier concept illustration.
