const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..', '..');
const capturesDir = path.join(rootDir, 'docs', 'capturas');
const dataDir = path.join(rootDir, 'docs', 'capturas_data');
const appUrl = process.env.FLUTTER_WEB_URL || process.argv[2] || 'http://127.0.0.1:5174';

fs.mkdirSync(capturesDir, { recursive: true });
fs.mkdirSync(dataDir, { recursive: true });

const manualNotes = [];

async function waitForFlutter(page) {
  await page.waitForLoadState('domcontentloaded', { timeout: 15000 }).catch(() => {});
  await page.waitForLoadState('networkidle', { timeout: 15000 }).catch(() => {});
  await page.waitForTimeout(1800);
}

async function goHome(page) {
  await page.goto(appUrl, { waitUntil: 'domcontentloaded', timeout: 30000 });
  await waitForFlutter(page);
}

async function clickVisibleText(page, labels, timeout = 8000) {
  const candidates = Array.isArray(labels) ? labels : [labels];
  for (const label of candidates) {
    const locator = page.getByText(label, { exact: false }).first();
    try {
      await locator.waitFor({ state: 'visible', timeout });
      await locator.click({ timeout });
      await waitForFlutter(page);
      return true;
    } catch (_) {
      // Try next label.
    }
  }
  return false;
}

async function clickTextOrPoint(page, labels, point, timeout = 5000) {
  const clickedByText = await clickVisibleText(page, labels, timeout);
  if (clickedByText) return true;
  await page.mouse.click(point.x, point.y);
  await waitForFlutter(page);
  return true;
}

async function scrollDown(page, amount = 900) {
  await page.mouse.wheel(0, amount);
  await page.waitForTimeout(500);
}

async function screenshot(page, fileName) {
  await page.screenshot({
    path: path.join(capturesDir, fileName),
    fullPage: true,
  });
  console.log(`OK ${fileName}`);
}

async function safeStep(name, fn) {
  try {
    await fn();
  } catch (error) {
    const message = `${name}: ${error.message}`;
    manualNotes.push(message);
    console.warn(`MANUAL ${message}`);
  }
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 390, height: 844 },
    deviceScaleFactor: 1,
    isMobile: true,
    hasTouch: true,
  });
  const page = await context.newPage();

  await safeStep('Home', async () => {
    await goHome(page);
    await screenshot(page, '10_flutter_home.png');
  });

  await safeStep('PredictionForm', async () => {
    await goHome(page);
    const clicked = await clickTextOrPoint(
      page,
      ['Consultar riesgo'],
      { x: 195, y: 548 },
    );
    if (!clicked) throw new Error('No se encontro el boton Consultar riesgo.');
    await screenshot(page, '11_flutter_formulario.png');
  });

  await safeStep('Result', async () => {
    await scrollDown(page, 2400);
    const clicked = await clickTextOrPoint(
      page,
      ['Predecir riesgo', 'Prediciendo'],
      { x: 195, y: 792 },
    );
    if (!clicked) throw new Error('No se encontro el boton Predecir riesgo.');
    await page.getByText('Resultado', { exact: false }).first().waitFor({ timeout: 15000 }).catch(() => {});
    await waitForFlutter(page);
    await screenshot(page, '12_flutter_resultado.png');
  });

  await safeStep('History', async () => {
    await goHome(page);
    const clicked = await clickTextOrPoint(
      page,
      ['Historial', 'Ver historial'],
      { x: 195, y: 806 },
    );
    if (!clicked) throw new Error('No se encontro acceso a Historial.');
    await screenshot(page, '13_flutter_historial.png');
  });

  await safeStep('DataSources', async () => {
    await goHome(page);
    const clicked = await clickTextOrPoint(
      page,
      ['Fuentes de datos', 'Fuentes'],
      { x: 320, y: 806 },
    );
    if (!clicked) throw new Error('No se encontro acceso a Fuentes de datos.');
    await screenshot(page, '14_flutter_fuentes_datos.png');
  });

  await safeStep('ModelInfo', async () => {
    await goHome(page);
    await scrollDown(page, 520);
    const clicked = await clickTextOrPoint(
      page,
      ['Informacion del modelo', 'Información del modelo'],
      { x: 195, y: 742 },
    );
    if (!clicked) throw new Error('No se encontro acceso a Informacion del modelo.');
    await screenshot(page, '15_flutter_model_info.png');
  });

  await browser.close();

  if (manualNotes.length > 0) {
    fs.writeFileSync(
      path.join(dataDir, 'manual_flutter_screenshots.md'),
      ['# Capturas Flutter pendientes', '', ...manualNotes.map((note) => `- ${note}`), ''].join('\n'),
      'utf8',
    );
    process.exitCode = 1;
  }
})();
