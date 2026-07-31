/**
 * Diapositivas de la parte de Joseph (apertura y cierre) para la exposicion presencial.
 *
 * Paleta tomada de la propia app (app_flutter/lib/core/theme/app_colors.dart) para que
 * las slides se vean como el producto.
 *
 * Uso:  node docs/presentacion/build_slides_joseph.js
 */

const path = require('path');
const PptxGenJS = require('pptxgenjs');

// --- Imagenes (extraidas con extract_pdf_images.py). Cambiar aqui para sustituirlas.
const IMG = path.join(__dirname, 'img');
const IMAGES = {
  escudo: path.join(IMG, 'escudo_una.png'),
  home: path.join(IMG, 'home_oscuro.png'),
  zonas: path.join(IMG, 'zonas_kmeans.png'),
  chuno: path.join(IMG, 'chuno.png'),
  apk: path.join(IMG, 'apk_play_protect.png'),
  actions: path.join(IMG, 'actions_detalle.png'),
};

// Rejilla comun: todo el contenido de las slides claras arranca en LEFT.
const LEFT = 1.25;
const RIGHT_EDGE = 12.1; // margen derecho util
const CONTENT_W = RIGHT_EDGE - LEFT;

// --- Paleta del producto
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
pptx.title = 'FrostPuno - Apertura y cierre';

const W = 13.333;
const H = 7.5;
const STRIPE_W = 0.62; // franja lateral: motivo visual repetido

/** Franja lateral con el numero de seccion (todas las slides de contenido). */
function stripe(slide, label) {
  slide.addShape(pptx.ShapeType.rect, {
    x: 0, y: 0, w: STRIPE_W, h: H, fill: { color: NAVY },
  });
  slide.addText(label, {
    x: -0.72, y: H / 2 - 0.35, w: 2.1, h: 0.7,
    rotate: 270,
    align: 'center', valign: 'middle',
    fontFace: BODY_FONT, fontSize: 12, bold: true, color: ICE, charSpacing: 2,
  });
}

/* ------------------------------------------------------------------ 1. PORTADA */
{
  const s = pptx.addSlide();
  s.background = { color: NAVY };

  // Banda de acento a la derecha (color de marca, visible pero sin competir).
  s.addShape(pptx.ShapeType.rect, {
    x: W - 0.42, y: 0, w: 0.42, h: H, fill: { color: AMBER },
  });

  s.addImage({ path: IMAGES.escudo, x: 1.0, y: 1.35, w: 2.1, h: 2.27 });
  s.addText('Universidad Nacional\ndel Altiplano — Puno', {
    x: 0.75, y: 3.75, w: 2.6, h: 0.75,
    align: 'center', fontFace: BODY_FONT, fontSize: 12, color: 'A9BCC6', lineSpacing: 18,
  });

  s.addText('FrostPuno', {
    x: 3.85, y: 1.2, w: 8.0, h: 1.3,
    fontFace: TITLE_FONT, fontSize: 60, bold: true, color: 'FFFFFF',
  });
  s.addText('Prediccion de heladas y apoyo a la produccion de chuño\nen el altiplano de Puno', {
    x: 3.9, y: 2.5, w: 7.9, h: 0.95,
    fontFace: BODY_FONT, fontSize: 18, color: ICE, lineSpacing: 28,
  });

  s.addShape(pptx.ShapeType.rect, {
    x: 3.9, y: 3.6, w: 1.5, h: 0.05, fill: { color: AMBER },
  });

  s.addText(
    'Mamani Mendoza, Joseph Elvis   ·   Lipe Machaca, Juan Artemio\n' +
    'Ticona Erquinigo, Jhoel Yovani   ·   Tapara Ccahuana, Paul Renmis',
    {
      x: 3.9, y: 3.95, w: 7.9, h: 0.95,
      fontFace: BODY_FONT, fontSize: 15, color: 'FFFFFF', lineSpacing: 28,
    },
  );

  s.addShape(pptx.ShapeType.roundRect, {
    x: 3.9, y: 5.15, w: 7.0, h: 0.7, rectRadius: 0.08, fill: { color: NAVY_SOFT },
  });
  s.addText('Aprendizaje de Maquina  ·  Segunda Unidad  ·  UNA-Puno  ·  2026', {
    x: 4.2, y: 5.15, w: 6.5, h: 0.7,
    valign: 'middle', fontFace: BODY_FONT, fontSize: 14, color: ICE,
  });
}

/* ------------------------------------------------------- 2. EL PROBLEMA */
{
  const s = pptx.addSlide();
  s.background = { color: LIGHT_BG };
  stripe(s, 'EL PROBLEMA');

  s.addText('Una helada, dos caras', {
    x: LEFT, y: 0.5, w: 8.4, h: 0.8,
    fontFace: TITLE_FONT, fontSize: 38, bold: true, color: NAVY,
  });

  const cardW = 3.85;
  const cardH = 1.95;
  const cardY = 1.55;

  // Tarjeta izquierda: destruye
  s.addShape(pptx.ShapeType.roundRect, {
    x: LEFT, y: cardY, w: cardW, h: cardH, rectRadius: 0.08,
    fill: { color: CARD }, line: { color: AMBER, width: 2.5 },
  });
  s.addText('DESTRUYE', {
    x: LEFT + 0.3, y: cardY + 0.2, w: cardW - 0.6, h: 0.32,
    fontFace: BODY_FONT, fontSize: 13, bold: true, color: AMBER, charSpacing: 1.5,
  });
  s.addText('Daña los cultivos de la campaña\nMata crias de alpaca y ovino', {
    x: LEFT + 0.3, y: cardY + 0.65, w: cardW - 0.6, h: 1.1,
    fontFace: BODY_FONT, fontSize: 15, color: TEXT, lineSpacing: 28,
  });

  // Tarjeta derecha: produce
  const card2X = LEFT + cardW + 0.4;
  s.addShape(pptx.ShapeType.roundRect, {
    x: card2X, y: cardY, w: cardW, h: cardH, rectRadius: 0.08,
    fill: { color: CARD }, line: { color: DEEP_TEAL, width: 2.5 },
  });
  s.addText('PRODUCE', {
    x: card2X + 0.3, y: cardY + 0.2, w: cardW - 0.6, h: 0.32,
    fontFace: BODY_FONT, fontSize: 13, bold: true, color: DEEP_TEAL, charSpacing: 1.5,
  });
  s.addText('Es el insumo del chuño\nPapa que se conserva por años', {
    x: card2X + 0.3, y: cardY + 0.65, w: cardW - 0.6, h: 1.1,
    fontFace: BODY_FONT, fontSize: 15, color: TEXT, lineSpacing: 28,
  });

  // Stat callout
  const statW = cardW * 2 + 0.4;
  s.addShape(pptx.ShapeType.roundRect, {
    x: LEFT, y: 3.85, w: statW, h: 2.6, rectRadius: 0.08,
    fill: { color: NAVY },
  });
  s.addText('> 3 800 m', {
    x: LEFT + 0.35, y: 4.2, w: statW - 0.7, h: 0.95,
    fontFace: TITLE_FONT, fontSize: 44, bold: true, color: ICE,
  });
  s.addText(
    'Altitud donde hoy se decide por experiencia, y sin datos,\n' +
    'si se protege el cultivo o si se tiende la papa.',
    {
      x: LEFT + 0.35, y: 5.25, w: statW - 0.7, h: 0.95,
      fontFace: BODY_FONT, fontSize: 15, color: 'FFFFFF', lineSpacing: 26,
    },
  );

  // La captura mantiene su proporcion original (721x1600) para no deformarse.
  s.addShape(pptx.ShapeType.roundRect, {
    x: 9.62, y: 1.5, w: 2.5, h: 5.0, rectRadius: 0.08, fill: { color: NAVY_SOFT },
  });
  s.addImage({ path: IMAGES.chuno, x: 9.795, y: 1.62, w: 2.145, h: 4.76 });
}

/* --------------------------------------------------- 3. QUE CONSTRUIMOS */
{
  const s = pptx.addSlide();
  s.background = { color: LIGHT_BG };
  stripe(s, 'EL PRODUCTO');

  s.addText('En produccion, no una maqueta', {
    x: LEFT, y: 0.5, w: 8.6, h: 0.8,
    fontFace: TITLE_FONT, fontSize: 36, bold: true, color: NAVY,
  });

  const cards = [
    ['App web', 'Flutter desplegada en Vercel', 'frost-puno.vercel.app'],
    ['App Android', 'APK release instalable, 47 MB', 'app-release.apk'],
    ['API', 'FastAPI desplegada en Render', 'frost-puno.onrender.com'],
  ];
  const cardW = 6.9;
  cards.forEach(([title, desc, url], i) => {
    const y = 1.6 + i * 1.65;
    s.addShape(pptx.ShapeType.roundRect, {
      x: LEFT, y, w: cardW, h: 1.4, rectRadius: 0.06,
      fill: { color: CARD }, line: { color: 'E1E5E8', width: 1 },
    });
    s.addShape(pptx.ShapeType.ellipse, {
      x: LEFT + 0.3, y: y + 0.4, w: 0.6, h: 0.6, fill: { color: NAVY },
    });
    s.addText(String(i + 1), {
      x: LEFT + 0.3, y: y + 0.4, w: 0.6, h: 0.6,
      align: 'center', valign: 'middle',
      fontFace: BODY_FONT, fontSize: 16, bold: true, color: ICE,
    });
    s.addText(title, {
      x: LEFT + 1.1, y: y + 0.25, w: 3.2, h: 0.42,
      fontFace: BODY_FONT, fontSize: 18, bold: true, color: NAVY,
    });
    s.addText(desc, {
      x: LEFT + 1.1, y: y + 0.72, w: 4.3, h: 0.4,
      fontFace: BODY_FONT, fontSize: 13, color: TEXT_SOFT,
    });
    s.addText(url, {
      x: LEFT + 4.05, y: y + 0.45, w: 2.55, h: 0.5,
      align: 'right', valign: 'middle',
      fontFace: 'Consolas', fontSize: 11, color: DEEP_TEAL,
    });
  });

  // Proporcion original de la captura (721x1422) para no deformarla.
  s.addShape(pptx.ShapeType.roundRect, {
    x: 8.75, y: 1.6, w: 3.35, h: 4.7, rectRadius: 0.08, fill: { color: NAVY_SOFT },
  });
  s.addImage({ path: IMAGES.home, x: 9.375, y: 1.83, w: 2.1, h: 4.14 });
  s.addText('Inicio: riesgo del dia y navegacion', {
    x: 8.75, y: 5.9, w: 3.35, h: 0.35,
    align: 'center', fontFace: BODY_FONT, fontSize: 11, italic: true, color: ICE,
  });
}

/* ------------------------------------------------------ 4. ARQUITECTURA */
{
  const s = pptx.addSlide();
  s.background = { color: LIGHT_BG };
  stripe(s, 'ARQUITECTURA');

  s.addText('Cuatro piezas conectadas', {
    x: LEFT, y: 0.5, w: 8.6, h: 0.8,
    fontFace: TITLE_FONT, fontSize: 36, bold: true, color: NAVY,
  });

  const boxes = [
    ['Pipeline ML', 'Ingesta y\nentrenamiento', TEAL],
    ['Registry', 'Modelo + metadata\nversionados', DEEP_TEAL],
    ['API FastAPI', 'Carga el modelo\ny predice', TEAL],
    ['Cliente Flutter', 'Web y\nAndroid', AMBER],
  ];
  const gap = 0.45;
  const bw = (CONTENT_W - gap * (boxes.length - 1)) / boxes.length;

  boxes.forEach(([title, desc, color], i) => {
    const x = LEFT + i * (bw + gap);
    s.addShape(pptx.ShapeType.roundRect, {
      x, y: 1.75, w: bw, h: 2.0, rectRadius: 0.06,
      fill: { color: CARD }, line: { color, width: 2.5 },
    });
    s.addText(title, {
      x: x + 0.12, y: 2.0, w: bw - 0.24, h: 0.45,
      align: 'center', fontFace: BODY_FONT, fontSize: 16, bold: true, color,
    });
    s.addText(desc, {
      x: x + 0.12, y: 2.55, w: bw - 0.24, h: 0.95,
      align: 'center', fontFace: BODY_FONT, fontSize: 13, color: TEXT_SOFT, lineSpacing: 20,
    });

    if (i < boxes.length - 1) {
      s.addText('→', {
        x: x + bw, y: 2.55, w: gap, h: 0.45,
        align: 'center', valign: 'middle',
        fontFace: BODY_FONT, fontSize: 22, bold: true, color: TEAL,
      });
    }
  });

  s.addShape(pptx.ShapeType.roundRect, {
    x: LEFT, y: 4.25, w: CONTENT_W, h: 1.6, rectRadius: 0.06,
    fill: { color: 'EDF3F5' },
  });
  s.addText(
    [
      { text: 'La clave del diseño:  ', options: { bold: true, color: NAVY } },
      {
        text: 'la lista de caracteristicas del modelo es el contrato entre el pipeline y el backend. ' +
              'Reentrenar no obliga a tocar el codigo del servidor.',
        options: { color: TEXT },
      },
    ],
    {
      x: LEFT + 0.4, y: 4.45, w: CONTENT_W - 0.8, h: 1.2,
      fontFace: BODY_FONT, fontSize: 16, valign: 'middle', lineSpacing: 26,
    },
  );

  s.addText('Render  ·  Vercel  ·  Supabase  ·  Open-Meteo', {
    x: LEFT, y: 6.15, w: CONTENT_W, h: 0.4,
    fontFace: BODY_FONT, fontSize: 13, color: TEXT_SOFT,
  });
}

/* ------------------------------------------------ 5. EL MODELO EN 1 LINEA */
{
  const s = pptx.addSlide();
  s.background = { color: LIGHT_BG };
  stripe(s, 'EL MODELO');

  const COL = 4.35; // columna derecha, comun a titulo, cajas y cierre

  // Proporcion original (721x1600); el titulo arranca a la misma altura que el resto.
  s.addShape(pptx.ShapeType.roundRect, {
    x: LEFT, y: 0.95, w: 2.75, h: 5.5, rectRadius: 0.08, fill: { color: NAVY_SOFT },
  });
  s.addImage({ path: IMAGES.zonas, x: LEFT + 0.215, y: 1.1, w: 2.32, h: 5.15 });

  s.addText('Nadie escribio la regla', {
    x: COL, y: 0.5, w: RIGHT_EDGE - COL, h: 0.8,
    fontFace: TITLE_FONT, fontSize: 36, bold: true, color: NAVY,
  });
  s.addText(
    'K-Means agrupa los distritos por su regimen termico. El nivel de riesgo\n' +
    'sale de los grupos que el algoritmo descubre, sin etiquetas.',
    {
      x: COL, y: 1.35, w: RIGHT_EDGE - COL, h: 0.9,
      fontFace: BODY_FONT, fontSize: 15, color: TEXT_SOFT, lineSpacing: 24,
    },
  );

  const stats = [
    ['K-Means', 'no supervisado'],
    ['0.419', 'silhouette'],
    ['3', 'clusters'],
  ];
  const statGap = 0.3;
  const statW = (RIGHT_EDGE - COL - statGap * 2) / 3;
  stats.forEach(([value, label], i) => {
    const x = COL + i * (statW + statGap);
    s.addShape(pptx.ShapeType.roundRect, {
      x, y: 2.65, w: statW, h: 1.65, rectRadius: 0.06,
      fill: { color: NAVY },
    });
    s.addText(value, {
      x: x + 0.08, y: 2.9, w: statW - 0.16, h: 0.8,
      align: 'center', valign: 'middle',
      fontFace: TITLE_FONT, fontSize: 26, bold: true, color: ICE,
    });
    s.addText(label, {
      x: x + 0.08, y: 3.72, w: statW - 0.16, h: 0.4,
      align: 'center', fontFace: BODY_FONT, fontSize: 12, color: 'A9BCC6',
    });
  });

  s.addShape(pptx.ShapeType.roundRect, {
    x: COL, y: 4.65, w: RIGHT_EDGE - COL, h: 1.8, rectRadius: 0.06,
    fill: { color: CARD }, line: { color: 'E1E5E8', width: 1 },
  });
  s.addText(
    [
      { text: 'Macusani', options: { bold: true, color: AMBER } },
      { text: ' (4 315 m) queda en riesgo alto,\n', options: { color: TEXT } },
      { text: 'Sandia', options: { bold: true, color: DEEP_TEAL } },
      { text: ' (2 170 m, en valle) en riesgo bajo.\n', options: { color: TEXT } },
      { text: 'Coincide con la geografia, y no lo programamos.', options: { color: TEXT } },
    ],
    {
      x: COL + 0.35, y: 4.85, w: RIGHT_EDGE - COL - 0.7, h: 1.4,
      fontFace: BODY_FONT, fontSize: 15, valign: 'middle', lineSpacing: 26,
    },
  );
}

/* ------------------------------------------------------ 6. LIMITACIONES */
{
  const s = pptx.addSlide();
  s.background = { color: LIGHT_BG };
  stripe(s, 'LIMITACIONES');

  s.addText('Lo que el sistema todavia no hace', {
    x: LEFT, y: 0.5, w: CONTENT_W, h: 0.8,
    fontFace: TITLE_FONT, fontSize: 36, bold: true, color: NAVY,
  });
  s.addText('Un informe honesto vale mas que uno perfecto.', {
    x: LEFT, y: 1.28, w: CONTENT_W, h: 0.45,
    fontFace: BODY_FONT, fontSize: 16, italic: true, color: TEAL,
  });

  const limits = [
    ['1', 'Riesgo derivado del perfil termico',
      'No existe un registro oficial de heladas observadas por distrito con el que validar.'],
    ['2', 'SENAMHI sin API publica estable',
      'Es la fuente oficial prioritaria, pero Open-Meteo es la fuente operativa real.'],
    ['3', 'Umbrales de chuño y ganado del MVP',
      'Documentados con fuentes, pero no son cifras oficiales.'],
  ];
  limits.forEach(([n, title, desc], i) => {
    const y = 2.1 + i * 1.42;
    s.addShape(pptx.ShapeType.roundRect, {
      x: LEFT, y, w: CONTENT_W, h: 1.2, rectRadius: 0.06,
      fill: { color: CARD }, line: { color: 'E1E5E8', width: 1 },
    });
    s.addShape(pptx.ShapeType.ellipse, {
      x: LEFT + 0.3, y: y + 0.29, w: 0.62, h: 0.62, fill: { color: AMBER },
    });
    s.addText(n, {
      x: LEFT + 0.3, y: y + 0.29, w: 0.62, h: 0.62,
      align: 'center', valign: 'middle',
      fontFace: BODY_FONT, fontSize: 16, bold: true, color: 'FFFFFF',
    });
    s.addText(title, {
      x: LEFT + 1.15, y: y + 0.22, w: CONTENT_W - 1.5, h: 0.42,
      fontFace: BODY_FONT, fontSize: 18, bold: true, color: NAVY,
    });
    s.addText(desc, {
      x: LEFT + 1.15, y: y + 0.68, w: CONTENT_W - 1.5, h: 0.4,
      fontFace: BODY_FONT, fontSize: 14, color: TEXT_SOFT,
    });
  });

  s.addText('Ninguna invalida la arquitectura ni el ciclo de vida que mostramos.', {
    x: LEFT, y: 6.45, w: CONTENT_W, h: 0.4,
    fontFace: BODY_FONT, fontSize: 14, bold: true, color: DEEP_TEAL,
  });
}

/* -------------------------------------------------------- 7. CONCLUSION */
{
  const s = pptx.addSlide();
  s.background = { color: NAVY };

  const DL = 1.0; // columna izquierda de la slide oscura

  s.addText('Lo que entregamos', {
    x: DL, y: 0.6, w: 7.4, h: 0.8, margin: 0,
    fontFace: TITLE_FONT, fontSize: 38, bold: true, color: 'FFFFFF',
  });

  const points = [
    ['Aprendizaje no supervisado', 'K-Means con hiperparametros optimizados'],
    ['Desplegado en produccion', 'Web, Android y API en la nube'],
    ['Mantenimiento automatizado', 'Se reentrena solo y el quality gate lo protege'],
  ];
  points.forEach(([title, desc], i) => {
    const y = 1.75 + i * 1.35;
    s.addShape(pptx.ShapeType.roundRect, {
      x: DL, y, w: 0.62, h: 0.62, rectRadius: 0.12, fill: { color: DEEP_TEAL },
    });
    s.addText('✓', {
      x: DL, y, w: 0.62, h: 0.62,
      align: 'center', valign: 'middle',
      fontFace: BODY_FONT, fontSize: 18, bold: true, color: 'FFFFFF',
    });
    s.addText(title, {
      x: DL + 0.9, y: y - 0.05, w: 5.4, h: 0.42,
      fontFace: BODY_FONT, fontSize: 19, bold: true, color: ICE,
    });
    s.addText(desc, {
      x: DL + 0.9, y: y + 0.42, w: 5.6, h: 0.4,
      fontFace: BODY_FONT, fontSize: 14, color: 'A9BCC6',
    });
  });

  // Detalle de 3 corridas, ampliado: proyectado si se lee.
  s.addShape(pptx.ShapeType.roundRect, {
    x: 7.35, y: 1.75, w: 5.05, h: 2.15, rectRadius: 0.06, fill: { color: 'FFFFFF' },
  });
  s.addImage({ path: IMAGES.actions, x: 7.5, y: 1.9, w: 4.75, h: 1.85 });
  s.addText('5 workflows de integracion continua, en verde', {
    x: 7.35, y: 4.0, w: 5.05, h: 0.35,
    align: 'center', fontFace: BODY_FONT, fontSize: 12, italic: true, color: 'A9BCC6',
  });

  // Cifras de respaldo, para que la mitad derecha no quede hueca.
  const proof = [['12 + 6', 'pruebas'], ['0.419', 'silhouette'], ['5', 'workflows']];
  proof.forEach(([value, label], i) => {
    const x = 7.35 + i * 1.72;
    s.addShape(pptx.ShapeType.roundRect, {
      x, y: 4.55, w: 1.6, h: 1.05, rectRadius: 0.06, fill: { color: NAVY_SOFT },
    });
    s.addText(value, {
      x: x + 0.06, y: 4.68, w: 1.48, h: 0.45,
      align: 'center', fontFace: TITLE_FONT, fontSize: 18, bold: true, color: ICE,
    });
    s.addText(label, {
      x: x + 0.06, y: 5.13, w: 1.48, h: 0.35,
      align: 'center', fontFace: BODY_FONT, fontSize: 11, color: 'A9BCC6',
    });
  });

  s.addShape(pptx.ShapeType.rect, {
    x: DL, y: 5.85, w: 1.5, h: 0.05, fill: { color: AMBER },
  });
  s.addText('Gracias', {
    x: DL, y: 6.05, w: 4.0, h: 0.65, margin: 0,
    fontFace: TITLE_FONT, fontSize: 28, bold: true, color: 'FFFFFF',
  });
  s.addText('frost-puno.vercel.app   ·   github.com/JosephElvisMaman1/frost-puno', {
    x: 5.0, y: 6.15, w: 7.35, h: 0.45,
    align: 'right', valign: 'middle',
    fontFace: 'Consolas', fontSize: 12, color: 'A9BCC6',
  });
}

const out = path.join(__dirname, 'FrostPuno_Joseph.pptx');
pptx.writeFile({ fileName: out }).then(() => console.log('OK ->', out));
