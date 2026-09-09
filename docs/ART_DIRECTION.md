# Dirección artística

Objetivo: realismo estilizado cinematográfico de Patagonia. PC es la referencia visual; preservar Forestín, silueta de Torres y lectura del sendero en móvil. La fase 0 no entrega personajes finales ni aprobación visual.

Forestín debe leerse como coipo. El código web usa pelaje marrón cálido, hocico claro, casco verde, uniforme caqui, pantalón marrón, botas oscuras y guantes claros; conservarlo como referencia provisional hasta revisar la imagen original del personaje. Evitar anatomía humana genérica. Prioridad: proporciones y rostro, rig/locomoción, materiales y detalle; no esconder una silueta débil con más pelo.

Guanacos: cuello y orejas característicos, torso ligero, hocico diferenciado y vientre claro. Animaciones de pastoreo, reposo, alerta y huida con apoyos de patas creíbles y variación individual controlada.

Torres: primer plano 3D, relieve medio optimizado y fondo distante híbrido. La PNG existente es reutilizable; comprobar alfa contra cielo claro/oscuro, bruma, escala aparente, reflejo y cambios de cámara. No convertirla en billboard que gire con el jugador.

Luz: estados día/atardecer/noche antes de ciclo completo. Contraste legible, aire frío, viento visible en vegetación y composición monumental. Audio de viento, agua, fauna y pasos apoya distancia y movimiento.

## Entrega de asset

Fuente `.blend`, GLB, identificador/versionado, unidades declaradas, pivote, transforms aplicadas, materiales/texturas y animaciones nombradas. Comprobar escala con referencia de 1 metro; usar conversión de ejes del exportador y evitar rotaciones manuales repetidas. Cada asset registra procedencia y dependencias. Detallar LOD y colisión separada cuando existan.

QA manual: rostro en primer plano, silueta lateral/trasera, manos/pies en interacción, deslizamiento de pies, clipping, lectura a distancia y comparación diurna/nocturna. Capturas deben indicar resolución, perfil y commit.

## Estado 0.1.0

Personaje y fauna procedurales provisionales, fondo Torres reutilizado del prototipo y geometría de primer plano. Pendientes modelos Blender y validación perceptual de calidad final.
