# Forestín Aventura 0.1.1 — primera mejora del paisaje

Base: b5caac9638505c0d44ddee364d7fc4353b4458dc. Iteración de realismo estilizado para PC; no es una versión comercial ni una equivalencia visual con GTA VI.

## Cambios

- Suelo con mezcla de tierra, vegetación y grano a distintas escalas; el sendero usa distancia geométrica y mantiene las posiciones de objetivos y checkpoints.
- Terreno extendido y relieve lejano 3D alrededor del área jugable. El fondo Torres conserva el asset original y desvanece sus bordes mediante descarte tramado.
- Rocas deformadas por ruido determinista en siete variantes, conservando las colisiones de las rocas grandes.
- Árboles con tronco, ramas y 810 hojas de cuatro triángulos por árbol, agrupadas en MultiMesh. LOW/MOBILE muestran 405 hojas por árbol. Movimiento suave por shader.
- Hierba curva con ocho briznas por macolla; 1400 instancias, 420 visibles en LOW/MOBILE. El generador evita la franja caminable.
- Fibras opacas cortas en Forestín y guanacos, detalles de uniforme/mochila/botas, interiores de orejas y nariz. Son modelos procedurales provisionales; todavía no son personajes terminados en Blender.

## Verificación y trazabilidad

El driver valida importación, escena, misión, movimiento, salto, colisiones de cámara y persistencia. Las nuevas comprobaciones verifican que el perfil bajo reduzca hojas y el alto las restaure. La captura en CI ahora también rechaza errores de shaders y guarda cinco encuadres reales (título, sendero día, Forestín, noche y guanaco).

El reporte `render-metrics.json` registra primitivas, draw calls y nodos de un encuadre en el runner. Son métricas de OpenGL por software, no rendimiento en una GPU de juego. `native-result.json` y los logs determinan si una ejecución concreta aprobó; este documento no convierte una ejecución pendiente en éxito.

## Pendiente para una versión comercial

Revisión artística de los personajes, rigs y animaciones definitivos; integración del fondo a todas las distancias; paisaje con composición dirigida; audio espacial trabajado; sesiones completas de juego con usuarios; rendimiento y estabilidad en PC Windows real; alcance y duración del contenido comercial; revisión de los derechos de todos los assets y de la identidad del personaje. iOS requiere controles y pruebas físicas propias.

La ejecución paralela solicitada no estuvo disponible por límite de uso de agentes. El trabajo se realizó directamente, sin simular revisiones de agentes que no se ejecutaron.

## Hallazgos y correcciones de la primera captura

El primer render mostró relieve lejano demasiado claro y 2.221 llamadas de dibujo en su encuadre final. Se agruparon troncos y ramas en una superficie por árbol para reducir objetos y llamadas, se oscureció el relieve con material propio y se corrigió la cámara de fauna. La captura detectó además un recurso de audio retenido al cerrar con el driver Dummy: la captura visual ahora usa una opción explícita de audio silencioso; el juego normal conserva su audio. La nueva captura registra métricas por encuadre, por lo que no se deben comparar automáticamente valores de cámaras distintas.
