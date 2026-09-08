# Inventario de partida — fase 0

Fecha: 2026-09-08. Repositorio: `per_forestin_explora`. Commit inspeccionado: `95328c523e625331b2c987d25b51f3d39b48622a`.

La base existente es un prototipo web de tercera persona. `package.json` declara versión 0.9.0, Babylon.js 9.25.0, TypeScript ~5.9.3 y Vite 8.2.2. El encabezado del README aún decía 0.8. Esta auditoría describe archivos leídos; no certifica su ejecución ni su calidad visual.

| Material existente | Evidencia | Decisión de reutilización |
|---|---|---|
| Mundo y personaje procedurales | `src/world.ts`, `src/art.ts`, `src/character-finish.ts` | Referencia de proporciones, paleta y composición; reconstruir escenas/materiales y rig nativos. No son modelos Blender exportables ya disponibles. |
| Torres ilustradas | `public/assets/torres-paine-v1.png`, `src/mountain-backdrop.ts` | Conservar original y reutilizar como candidato a fondo distante 2.5D. Verificar alfa, bruma y composición en Godot antes de aprobarlo. |
| Sendero y objetivos | `src/rules.ts` | Portar datos y reglas a recursos/componentes nativos; cuatro descubrimientos y tres residuos como referencia de alcance. |
| Guardado local | `src/rules.ts`, `src/main.ts` | Reutilizar criterios de saneamiento y unicidad. El `localStorage` del navegador no pasa automáticamente a `user://` de Godot. |
| Movimiento y cámara | `src/motion.ts`, `src/main.ts` | Portar interpolación independiente del frame rate; reconstruir física y cámara con colisión en Godot. |
| Guanacos | `src/wildlife.ts`, `src/world.ts` | Conservar estados, histéresis de distancias y reacción al jugador como especificación inicial. Añadir navegación y grupo en fases posteriores. |
| Paisaje y acabado PC | `src/foliage.ts`, `src/ground-detail.ts`, `src/cinematic.ts`, `src/desktop-light.ts` | Reutilizar intención artística y semillas controladas; shaders/API Babylon deben reimplementarse. |
| Perfiles de rendimiento | `src/performance.ts` | Reutilizar separación móvil/PC y control de resolución como criterios; los costes GPU no se trasladan entre motores. |
| Pruebas de lógica | `src/rules.test.ts`, `src/motion.test.ts`, `src/wildlife.test.ts`, `src/performance.test.ts` | Mantener las pruebas web y traducir casos relevantes; no cuentan como pruebas nativas. |
| Interfaz HTML y fallback CPU | `src/main.ts`, `src/style.css`, `src/software.ts` | Mantener en web. Rehacer UI con `Control` e inputs Godot; no portar el renderizador software. |
| CI web | `.github/workflows/pages.yml` | Conservar. Actualmente publica GitHub Pages en push a main; cualquier push puede desplegar la web. |

En el árbol base no se encontraron `project.godot`, `.blend`, `.glb` ni `.gltf`. Tampoco se identificaron archivos de audio ni proyecto Xcode. Las fuentes procedurales y la imagen de Torres sí están disponibles. La referencia externa original de Forestín mencionada por el README no está incluida como imagen de personaje en el árbol inspeccionado.

Mayor brecha: falta un pipeline nativo comprobado y assets de personaje/fauna con rig y animaciones. La fase 0 incorpora infraestructura coexistente en `game/`; no equivale a migrar el juego completo ni a disponer de un producto vendible.
