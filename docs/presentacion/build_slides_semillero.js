/**
 * Diapositivas del semillero. Expone Joseph solo, en modalidad virtual.
 *
 * Uso:  node docs/presentacion/build_slides_semillero.js
 */

const path = require('path');
const PptxGenJS = require('pptxgenjs');

const IMG = path.join(__dirname, 'img');
const IMAGES = {
  escudo: path.join(IMG, 'escudo_una.png'),
  zonas: path.join(IMG, 'zonas_kmeans.png'),
  home: path.join(IMG, 'home_oscuro.png'),
  chuno: path.join(IMG, 'chuno.png'),
  actions: path.join(IMG, 'actions_detalle.png'),
  swagger: path.join(IMG, 'swagger_api.png'),
  apk: path.join(IMG, 'apk_play_protect.png'),
};

const NAVY = '0D1B2A';
const NAVY_SOFT = '16232E';
const ICE = 'E0FBFC';
const TEAL = '3D5A80';
const DEEP_TEAL = '1F6F78';
const AMBER = 'EE6C4D';
const LIGHT_BG = 'F9F9F9';
const CARD = 'FFFFFF';
const TEXT = '1A1C1C';
const TEXT_SOFT = '44474C';

const TITLE_FONT = 'Georgia';
const BODY_FONT = 'Calibri';

const pptx = new PptxGenJS();
pptx.defineLayout({ name: 'FROST16x9', width: 13.333, height: 7.5 });
pptx.layout = 'FROST16x9';
pptx.author = 'Joseph Elvis Mamani Mendoza';
pptx.title = 'FrostPuno - Semillero de investigacion';

const W = 13.333;
const H = 7.5;
const LEFT = 1.25;
const RIGHT_EDGE = 12.1;
const CONTENT_W = RIGHT_EDGE - LEFT;
const STRIPE_W = 0.62;

function stripe(slide, label) {
  slide.addShape(pptx.ShapeType.rect, { x: 0, y: 0, w: STRIPE_W, h: H, fill: { color: NAVY } });
  slide.addText(label, {
    x: -0.72, y: H / 2 - 0.35, w: 2.1, h: 0.7, rotate: 270,
    align: 'center', valign: 'middle',
    fontFace: BODY_FONT, fontSize: 12, bold: true, color: ICE, charSpacing: 2,
  });
}

function titulo(slide, texto, subtitulo) {
  slide.addText(texto, {
    x: LEFT, y: 0.5, w: CONTENT_W, h: 0.8, margin: 0,
    fontFace: TITLE_FONT, fontSize: 34, bold: true, color: NAVY,
  });
  if (subtitulo) {
    slide.addText(subtitulo, {
      x: LEFT, y: 1.28, w: CONTENT_W, h: 0.45, margin: 0,
      fontFace: BODY_FONT, fontSize: 15, color: TEAL,
    });
  }
}

/* ------------------------------------------------------------- 1. PORTADA */
{
  const s = pptx.addSlide();
  s.background = { color: NAVY };
  s.addShape(pptx.ShapeType.rect, { x: W - 0.42, y: 0, w: 0.42, h: H, fill: { color: AMBER } });

  s.addImage({ path: IMAGES.escudo, x: 1.0, y: 1.5, w: 2.1, h: 2.27 });
  s.addText('Universidad Nacional\ndel Altiplano - Puno', {
    x: 0.75, y: 3.9, w: 2.6, h: 0.75,
    align: 'center', fontFace: BODY_FONT, fontSize: 12, color: 'A9BCC6', lineSpacing: 18,
  });

  s.addText('FrostPuno', {
    x: 3.85, y: 1.1, w: 8.0, h: 1.1, margin: 0,
    fontFace: TITLE_FONT, fontSize: 52, bold: true, color: 'FFFFFF',
  });
  s.addText(
    'Arquitectura distribuida y computo paralelo para la prediccion\n' +
    'de heladas mediante aprendizaje no supervisado',
    {
      x: 3.88, y: 2.25, w: 7.9, h: 1.0, margin: 0,
      fontFace: BODY_FONT, fontSize: 17, color: ICE, lineSpacing: 26,
    },
  );

  s.addShape(pptx.ShapeType.rect, { x: 3.88, y: 3.4, w: 1.5, h: 0.05, fill: { color: AMBER } });

  s.addText(
    'Mamani Mendoza, Joseph Elvis   ·   Pari Pari, Yimmy Ronaldo   ·   Quispe Galindo, Jahan Kevin\n' +
    'Flores Curasi, Hector Luis   ·   Apaza Llanos, Yoel',
    {
      x: 3.88, y: 3.75, w: 7.9, h: 0.9, margin: 0,
      fontFace: BODY_FONT, fontSize: 13, color: 'FFFFFF', lineSpacing: 24,
    },
  );

  s.addShape(pptx.ShapeType.roundRect, {
    x: 3.88, y: 4.95, w: 7.0, h: 0.7, rectRadius: 0.08, fill: { color: NAVY_SOFT },
  });
  s.addText('Semillero de investigacion  ·  Ingenieria de Sistemas  ·  2026', {
    x: 4.18, y: 4.95, w: 6.5, h: 0.7, margin: 0,
    valign: 'middle', fontFace: BODY_FONT, fontSize: 13, color: ICE,
  });
}

/* -------------------------------------------------------- 2. EL PROBLEMA */
{
  const s = pptx.addSlide();
  s.background = { color: LIGHT_BG };
  stripe(s, 'EL PROBLEMA');
  titulo(s, 'Una helada, dos caras');

  const cardW = 3.85;
  const cardY = 1.75;

  s.addShape(pptx.ShapeType.roundRect, {
    x: LEFT, y: cardY, w: cardW, h: 2.0, rectRadius: 0.08,
    fill: { color: CARD }, line: { color: AMBER, width: 2.5 },
  });
  s.addText('DESTRUYE', {
    x: LEFT + 0.3, y: cardY + 0.22, w: cardW - 0.6, h: 0.32, margin: 0,
    fontFace: BODY_FONT, fontSize: 13, bold: true, color: AMBER, charSpacing: 1.5,
  });
  s.addText('Cultivos de la campaña\nCrias de alpaca y ovino', {
    x: LEFT + 0.3, y: cardY + 0.7, w: cardW - 0.6, h: 1.1, margin: 0,
    fontFace: BODY_FONT, fontSize: 15, color: TEXT, lineSpacing: 28,
  });

  const c2 = LEFT + cardW + 0.4;
  s.addShape(pptx.ShapeType.roundRect, {
    x: c2, y: cardY, w: cardW, h: 2.0, rectRadius: 0.08,
    fill: { color: CARD }, line: { color: DEEP_TEAL, width: 2.5 },
  });
  s.addText('PRODUCE', {
    x: c2 + 0.3, y: cardY + 0.22, w: cardW - 0.6, h: 0.32, margin: 0,
    fontFace: BODY_FONT, fontSize: 13, bold: true, color: DEEP_TEAL, charSpacing: 1.5,
  });
  s.addText('Es el insumo del chuño\nSeguridad alimentaria', {
    x: c2 + 0.3, y: cardY + 0.7, w: cardW - 0.6, h: 1.1, margin: 0,
    fontFace: BODY_FONT, fontSize: 15, color: TEXT, lineSpacing: 28,
  });

  s.addShape(pptx.ShapeType.roundRect, {
    x: LEFT, y: 4.1, w: cardW * 2 + 0.4, h: 2.3, rectRadius: 0.08, fill: { color: NAVY },
  });
  s.addText('> 3 800 m', {
    x: LEFT + 0.35, y: 4.4, w: 7.4, h: 0.9, margin: 0,
    fontFace: TITLE_FONT, fontSize: 42, bold: true, color: ICE,
  });
  s.addText(
    'La decision de proteger el cultivo, resguardar el ganado o\n' +
    'tender la papa se toma por experiencia, sin datos integrados.',
    {
      x: LEFT + 0.35, y: 5.4, w: 7.4, h: 0.9, margin: 0,
      fontFace: BODY_FONT, fontSize: 14, color: 'FFFFFF', lineSpacing: 24,
    },
  );

  s.addShape(pptx.ShapeType.roundRect, {
    x: 9.62, y: 1.75, w: 2.5, h: 4.65, rectRadius: 0.08, fill: { color: NAVY_SOFT },
  });
  s.addImage({ path: IMAGES.chuno, x: 9.81, y: 1.88, w: 2.11, h: 4.39 });
}

/* ------------------------------------------------- 3. LAS 3 CONTRIBUCIONES */
{
  const s = pptx.addSlide();
  s.background = { color: LIGHT_BG };
  stripe(s, 'APORTE');
  titulo(s, 'Tres contribuciones', 'Lo que sostiene el paper, en computo paralelo y distribuido.');

  const items = [
    ['1', 'Ingesta paralela', 'Pool de hilos con aislamiento de fallos por distrito'],
    ['2', 'Arquitectura distribuida', 'Cuatro servicios autonomos en proveedores distintos'],
    ['3', 'Mantenimiento automatizado', 'Trabajos concurrentes con barrera de calidad'],
  ];
  items.forEach(([n, tit, desc], i) => {
    const y = 2.15 + i * 1.5;
    s.addShape(pptx.ShapeType.roundRect, {
      x: LEFT, y, w: CONTENT_W, h: 1.25, rectRadius: 0.06,
      fill: { color: CARD }, line: { color: 'E1E5E8', width: 1 },
    });
    s.addShape(pptx.ShapeType.ellipse, {
      x: LEFT + 0.32, y: y + 0.32, w: 0.62, h: 0.62, fill: { color: NAVY },
    });
    s.addText(n, {
      x: LEFT + 0.32, y: y + 0.32, w: 0.62, h: 0.62,
      align: 'center', valign: 'middle',
      fontFace: BODY_FONT, fontSize: 16, bold: true, color: ICE,
    });
    s.addText(tit, {
      x: LEFT + 1.2, y: y + 0.25, w: 4.2, h: 0.42, margin: 0,
      fontFace: BODY_FONT, fontSize: 19, bold: true, color: NAVY,
    });
    s.addText(desc, {
      x: LEFT + 1.2, y: y + 0.72, w: 9.2, h: 0.4, margin: 0,
      fontFace: BODY_FONT, fontSize: 14, color: TEXT_SOFT,
    });
  });
}

/* ---------------------------------------------------- 4. ARQUITECTURA */
{
  const s = pptx.addSlide();
  s.background = { color: LIGHT_BG };
  stripe(s, 'ARQUITECTURA');
  titulo(s, 'Cuatro servicios, cuatro proveedores',
    'Distribucion efectiva, no separacion logica dentro de un proceso.');

  const boxes = [
    ['Cliente Flutter', 'Vercel + APK', AMBER],
    ['API FastAPI', 'Render', TEAL],
    ['Base de datos', 'Supabase', DEEP_TEAL],
    ['Clima', 'Open-Meteo', TEAL],
  ];
  const gap = 0.45;
  const bw = (CONTENT_W - gap * 3) / 4;
  boxes.forEach(([tit, plat, color], i) => {
    const x = LEFT + i * (bw + gap);
    s.addShape(pptx.ShapeType.roundRect, {
      x, y: 2.05, w: bw, h: 1.5, rectRadius: 0.06,
      fill: { color: CARD }, line: { color, width: 2.5 },
    });
    s.addText(tit, {
      x: x + 0.12, y: 2.32, w: bw - 0.24, h: 0.5,
      align: 'center', fontFace: BODY_FONT, fontSize: 16, bold: true, color,
    });
    s.addText(plat, {
      x: x + 0.12, y: 2.9, w: bw - 0.24, h: 0.5,
      align: 'center', fontFace: BODY_FONT, fontSize: 13, color: TEXT_SOFT,
    });
    if (i < 3) {
      s.addText('↔', {
        x: x + bw, y: 2.75, w: gap, h: 0.45,
        align: 'center', valign: 'middle',
        fontFace: BODY_FONT, fontSize: 14, bold: true, color: TEAL,
      });
    }
  });

  s.addShape(pptx.ShapeType.roundRect, {
    x: LEFT, y: 4.35, w: CONTENT_W, h: 1.75, rectRadius: 0.06, fill: { color: 'EDF3F5' },
  });
  s.addText(
    [
      { text: 'El contrato que los desacopla:  ', options: { bold: true, color: NAVY } },
      {
        text: 'la lista de caracteristicas declarada en el metadata del modelo. ' +
              'El backend arma el vector en ese orden, asi que reentrenar no obliga a tocar el servidor.',
        options: { color: TEXT },
      },
    ],
    {
      x: LEFT + 0.4, y: 4.6, w: CONTENT_W - 0.8, h: 1.3, margin: 0,
      fontFace: BODY_FONT, fontSize: 16, valign: 'middle', lineSpacing: 26,
    },
  );
}

/* ------------------------------------------------------- 5. PARALELISMO */
{
  const s = pptx.addSlide();
  s.background = { color: LIGHT_BG };
  stripe(s, 'PARALELISMO');
  titulo(s, 'Ingesta paralela de 13 distritos',
    'Tareas independientes dominadas por latencia de red: caso ideal para hilos.');

  s.addShape(pptx.ShapeType.roundRect, {
    x: LEFT, y: 1.95, w: 6.55, h: 2.85, rectRadius: 0.06, fill: { color: NAVY },
  });
  s.addText(
    'with ThreadPoolExecutor(max_workers) as executor:\n' +
    '    futures = {executor.submit(fetch, d): d\n' +
    '               for d in distritos}\n' +
    '    for future in as_completed(futures):\n' +
    '        try:\n' +
    '            frames.append(future.result())\n' +
    '        except Exception as exc:\n' +
    '            failures.append(...)   # aisla el fallo',
    {
      x: LEFT + 0.25, y: 2.15, w: 6.05, h: 2.45, margin: 0,
      fontFace: 'Consolas', fontSize: 12, color: ICE, lineSpacing: 19,
    },
  );

  const props = [
    ['Fan-out / fan-in', 'Se lanzan 13 tareas y se recolectan al terminar, sin orden'],
    ['Aislamiento de fallos', 'Si un distrito cae, los demas continuan'],
    ['Paralelismo configurable', 'Numero de hilos ajustable, 4 por defecto'],
    ['Amdahl', 'Tiempo total tiende al de UNA peticion, no a 13'],
  ];
  props.forEach(([tit, desc], i) => {
    const y = 1.95 + i * 1.12;
    s.addShape(pptx.ShapeType.roundRect, {
      x: 8.15, y, w: 3.95, h: 0.95, rectRadius: 0.06,
      fill: { color: CARD }, line: { color: 'E1E5E8', width: 1 },
    });
    s.addText(tit, {
      x: 8.4, y: y + 0.12, w: 3.5, h: 0.35, margin: 0,
      fontFace: BODY_FONT, fontSize: 14, bold: true, color: DEEP_TEAL,
    });
    s.addText(desc, {
      x: 8.4, y: y + 0.46, w: 3.5, h: 0.42, margin: 0,
      fontFace: BODY_FONT, fontSize: 11, color: TEXT_SOFT,
    });
  });

  s.addText('El manejo de excepciones esta DENTRO del bucle: por eso el fallo se aisla por distrito.', {
    x: LEFT, y: 5.05, w: 6.55, h: 0.9, margin: 0,
    fontFace: BODY_FONT, fontSize: 14, bold: true, color: NAVY, lineSpacing: 22,
  });
}

/* ------------------------------------------- 6. COMPUTO ML DISTRIBUIDO */
{
  const s = pptx.addSlide();
  s.background = { color: LIGHT_BG };
  stripe(s, 'COMPUTO ML');
  titulo(s, 'Entrenamiento por lotes, inferencia en linea',
    'Dos computos con exigencias opuestas, unidos por un registro de modelos.');

  const cols = [
    ['OFFLINE', 'Entrenamiento', 'Grid de 24 combinaciones\nSerializa al registry\nSemanal, sin intervencion', TEAL],
    ['REGISTRY', 'Contrato', 'Modelo .joblib\n+ metadata con features\nFrontera del sistema', NAVY],
    ['ONLINE', 'Inferencia', 'Carga 1 vez por proceso\nAsigna al centroide: O(k)\nRespuesta inmediata', AMBER],
  ];
  const gap = 0.5;
  const bw = (CONTENT_W - gap * 2) / 3;
  cols.forEach(([etiqueta, tit, desc, color], i) => {
    const x = LEFT + i * (bw + gap);
    s.addShape(pptx.ShapeType.roundRect, {
      x, y: 2.05, w: bw, h: 2.9, rectRadius: 0.06,
      fill: { color: CARD }, line: { color, width: 2.5 },
    });
    s.addText(etiqueta, {
      x: x + 0.2, y: 2.28, w: bw - 0.4, h: 0.32, margin: 0,
      fontFace: BODY_FONT, fontSize: 12, bold: true, color, charSpacing: 1.5,
    });
    s.addText(tit, {
      x: x + 0.2, y: 2.68, w: bw - 0.4, h: 0.45, margin: 0,
      fontFace: BODY_FONT, fontSize: 19, bold: true, color: NAVY,
    });
    s.addText(desc, {
      x: x + 0.2, y: 3.25, w: bw - 0.4, h: 1.5, margin: 0,
      fontFace: BODY_FONT, fontSize: 13, color: TEXT_SOFT, lineSpacing: 22,
    });
    if (i < 2) {
      s.addText('→', {
        x: x + bw, y: 3.3, w: gap, h: 0.45,
        align: 'center', valign: 'middle',
        fontFace: BODY_FONT, fontSize: 22, bold: true, color: TEAL,
      });
    }
  });

  s.addText('Patron estandar en sistemas distribuidos de aprendizaje automatico.', {
    x: LEFT, y: 5.25, w: CONTENT_W, h: 0.4, margin: 0,
    fontFace: BODY_FONT, fontSize: 14, color: TEXT_SOFT,
  });
}

/* ------------------------------------------------------------ 7. MODELO */
{
  const s = pptx.addSlide();
  s.background = { color: LIGHT_BG };
  stripe(s, 'EL MODELO');

  s.addShape(pptx.ShapeType.roundRect, {
    x: LEFT, y: 0.95, w: 2.75, h: 5.5, rectRadius: 0.08, fill: { color: NAVY_SOFT },
  });
  s.addImage({ path: IMAGES.zonas, x: LEFT + 0.215, y: 1.1, w: 2.32, h: 5.15 });

  const COL = 4.35;
  s.addText('Nadie escribio la regla', {
    x: COL, y: 0.5, w: RIGHT_EDGE - COL, h: 0.8, margin: 0,
    fontFace: TITLE_FONT, fontSize: 34, bold: true, color: NAVY,
  });
  s.addText(
    'K-Means agrupa los distritos por su regimen termico, sin etiquetas.\n' +
    'Mejoramos el modelo QUITANDO variables: silhouette 0.286 -> 0.419.',
    {
      x: COL, y: 1.3, w: RIGHT_EDGE - COL, h: 0.9, margin: 0,
      fontFace: BODY_FONT, fontSize: 15, color: TEXT_SOFT, lineSpacing: 24,
    },
  );

  const stats = [['0.419', 'silhouette'], ['0.813', 'Davies-Bouldin'], ['24', 'combinaciones']];
  const gap = 0.3;
  const sw = (RIGHT_EDGE - COL - gap * 2) / 3;
  stats.forEach(([v, l], i) => {
    const x = COL + i * (sw + gap);
    s.addShape(pptx.ShapeType.roundRect, {
      x, y: 2.6, w: sw, h: 1.6, rectRadius: 0.06, fill: { color: NAVY },
    });
    s.addText(v, {
      x: x + 0.08, y: 2.85, w: sw - 0.16, h: 0.75,
      align: 'center', valign: 'middle',
      fontFace: TITLE_FONT, fontSize: 26, bold: true, color: ICE,
    });
    s.addText(l, {
      x: x + 0.08, y: 3.65, w: sw - 0.16, h: 0.4,
      align: 'center', fontFace: BODY_FONT, fontSize: 12, color: 'A9BCC6',
    });
  });

  s.addShape(pptx.ShapeType.roundRect, {
    x: COL, y: 4.55, w: RIGHT_EDGE - COL, h: 1.9, rectRadius: 0.06,
    fill: { color: CARD }, line: { color: 'E1E5E8', width: 1 },
  });
  s.addText(
    [
      { text: 'Macusani', options: { bold: true, color: AMBER } },
      { text: ' (4 315 m) queda en riesgo alto,\n', options: { color: TEXT } },
      { text: 'Sandia', options: { bold: true, color: DEEP_TEAL } },
      { text: ' (2 170 m, en valle) en riesgo bajo.\n\n', options: { color: TEXT } },
      { text: 'Coincide con la geografia. No lo programamos.', options: { bold: true, color: NAVY } },
    ],
    {
      x: COL + 0.35, y: 4.75, w: RIGHT_EDGE - COL - 0.7, h: 1.5, margin: 0,
      fontFace: BODY_FONT, fontSize: 15, valign: 'middle', lineSpacing: 24,
    },
  );
}

/* ------------------------------------------------- 8. MANTENIMIENTO E IC */
{
  const s = pptx.addSlide();
  s.background = { color: LIGHT_BG };
  stripe(s, 'MANTENIMIENTO');
  titulo(s, 'Se mantiene solo, y lo probamos',
    'Cinco flujos concurrentes, reentrenamiento programado y una barrera de calidad.');

  s.addShape(pptx.ShapeType.roundRect, {
    x: LEFT, y: 1.95, w: 5.55, h: 2.5, rectRadius: 0.06, fill: { color: 'FFFFFF' },
  });
  s.addImage({ path: IMAGES.actions, x: LEFT + 0.15, y: 2.1, w: 5.25, h: 2.2 });
  s.addText('Los 5 flujos corren en paralelo: el tiempo total es el del mas lento.', {
    x: LEFT, y: 4.55, w: 5.55, h: 0.6, margin: 0,
    fontFace: BODY_FONT, fontSize: 13, color: TEXT_SOFT, lineSpacing: 20,
  });

  const puntos = [
    ['Reentrenamiento adaptativo', 'Si no llega al objetivo, amplia la ventana: 14 -> 29 -> 44 dias'],
    ['Barrera de calidad', 'silhouette < 0.35 detiene la integracion con codigo de error'],
    ['6 pruebas de mantenimiento', 'Una verifica que la barrera BLOQUEA un modelo degradado'],
  ];
  puntos.forEach(([tit, desc], i) => {
    const y = 1.95 + i * 1.35;
    s.addShape(pptx.ShapeType.roundRect, {
      x: 7.15, y, w: 4.95, h: 1.15, rectRadius: 0.06,
      fill: { color: CARD }, line: { color: 'E1E5E8', width: 1 },
    });
    s.addText(tit, {
      x: 7.4, y: y + 0.15, w: 4.5, h: 0.4, margin: 0,
      fontFace: BODY_FONT, fontSize: 15, bold: true, color: NAVY,
    });
    s.addText(desc, {
      x: 7.4, y: y + 0.55, w: 4.5, h: 0.5, margin: 0,
      fontFace: BODY_FONT, fontSize: 12, color: TEXT_SOFT, lineSpacing: 18,
    });
  });

  s.addText('Tenemos una prueba automatizada que verifica que nuestra propia barrera funciona.', {
    x: LEFT, y: 6.1, w: CONTENT_W, h: 0.5, margin: 0,
    fontFace: BODY_FONT, fontSize: 15, bold: true, color: DEEP_TEAL,
  });
}

/* ---------------------------------------------------------- 9. RESULTADOS */
{
  const s = pptx.addSlide();
  s.background = { color: LIGHT_BG };
  stripe(s, 'RESULTADOS');
  titulo(s, 'Verificado y en produccion');

  const filas = [
    ['Pruebas del servicio', '12 satisfactorias'],
    ['Pruebas de mantenimiento', '6 satisfactorias'],
    ['Barrera de calidad', 'Aprobada, 0.419'],
    ['Cliente web y Android', 'Compilando, 47.3 MB'],
    ['Modelo en produccion', 'K-Means v1.0.0'],
  ];
  filas.forEach(([k, v], i) => {
    const y = 1.85 + i * 0.82;
    s.addShape(pptx.ShapeType.roundRect, {
      x: LEFT, y, w: 6.5, h: 0.68, rectRadius: 0.05,
      fill: { color: i % 2 === 0 ? CARD : 'F1F4F6' }, line: { color: 'E1E5E8', width: 1 },
    });
    s.addText(k, {
      x: LEFT + 0.25, y, w: 3.8, h: 0.68, margin: 0,
      valign: 'middle', fontFace: BODY_FONT, fontSize: 14, color: TEXT,
    });
    s.addText(v, {
      x: LEFT + 4.0, y, w: 2.3, h: 0.68, margin: 0,
      valign: 'middle', align: 'right',
      fontFace: BODY_FONT, fontSize: 14, bold: true, color: DEEP_TEAL,
    });
  });

  s.addShape(pptx.ShapeType.roundRect, {
    x: 8.35, y: 1.85, w: 3.75, h: 4.05, rectRadius: 0.08, fill: { color: NAVY_SOFT },
  });
  s.addImage({ path: IMAGES.home, x: 9.42, y: 2.0, w: 1.75, h: 3.45 });
  s.addText('Cliente en operacion', {
    x: 8.35, y: 5.5, w: 3.75, h: 0.35, margin: 0,
    align: 'center', fontFace: BODY_FONT, fontSize: 12, color: ICE,
  });
}

/* --------------------------------------------------------- 10. CIERRE */
{
  const s = pptx.addSlide();
  s.background = { color: NAVY };
  const DL = 1.0;

  s.addText('Lo que aportamos', {
    x: DL, y: 0.7, w: 7.4, h: 0.8, margin: 0,
    fontFace: TITLE_FONT, fontSize: 36, bold: true, color: 'FFFFFF',
  });

  const puntos = [
    ['Ingesta paralela', 'Pool de hilos con aislamiento de fallos por distrito'],
    ['Arquitectura distribuida', 'Cuatro servicios acoplados solo por contratos'],
    ['Mantenimiento probado', 'Trabajos concurrentes y barrera verificada'],
  ];
  puntos.forEach(([tit, desc], i) => {
    const y = 1.9 + i * 1.3;
    s.addShape(pptx.ShapeType.roundRect, {
      x: DL, y, w: 0.62, h: 0.62, rectRadius: 0.12, fill: { color: DEEP_TEAL },
    });
    s.addText('✓', {
      x: DL, y, w: 0.62, h: 0.62,
      align: 'center', valign: 'middle',
      fontFace: BODY_FONT, fontSize: 18, bold: true, color: 'FFFFFF',
    });
    s.addText(tit, {
      x: DL + 0.9, y: y - 0.05, w: 5.6, h: 0.42, margin: 0,
      fontFace: BODY_FONT, fontSize: 19, bold: true, color: ICE,
    });
    s.addText(desc, {
      x: DL + 0.9, y: y + 0.42, w: 5.9, h: 0.4, margin: 0,
      fontFace: BODY_FONT, fontSize: 13, color: 'A9BCC6',
    });
  });

  s.addShape(pptx.ShapeType.roundRect, {
    x: 7.6, y: 1.9, w: 4.75, h: 2.6, rectRadius: 0.06, fill: { color: 'FFFFFF' },
  });
  s.addImage({ path: IMAGES.apk, x: 7.95, y: 2.15, w: 4.05, h: 2.1 });
  s.addText('APK verificado con Play Protect', {
    x: 7.6, y: 4.6, w: 4.75, h: 0.35,
    align: 'center', fontFace: BODY_FONT, fontSize: 12, color: 'A9BCC6',
  });

  s.addShape(pptx.ShapeType.rect, { x: DL, y: 5.85, w: 1.5, h: 0.05, fill: { color: AMBER } });
  s.addText('Gracias', {
    x: DL, y: 6.05, w: 4.0, h: 0.65, margin: 0,
    fontFace: TITLE_FONT, fontSize: 28, bold: true, color: 'FFFFFF',
  });
  s.addText('github.com/JosephElvisMaman1/frost-puno   ·   frost-puno.vercel.app', {
    x: 5.0, y: 6.15, w: 7.35, h: 0.45, margin: 0,
    align: 'right', valign: 'middle',
    fontFace: 'Consolas', fontSize: 12, color: 'A9BCC6',
  });
}

const out = path.join(__dirname, process.env.OUT_NAME || 'FrostPuno_Semillero.pptx');
pptx.writeFile({ fileName: out }).then(() => console.log('OK ->', out));
