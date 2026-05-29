const { chromium, request } = require('playwright');
const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..', '..');
const capturesDir = path.join(rootDir, 'docs', 'capturas');
const dataDir = path.join(rootDir, 'docs', 'capturas_data');
const htmlDir = path.join(dataDir, 'html');
const backendUrl = process.env.BACKEND_URL || process.argv[2] || 'http://127.0.0.1:8000';

fs.mkdirSync(capturesDir, { recursive: true });
fs.mkdirSync(dataDir, { recursive: true });
fs.mkdirSync(htmlDir, { recursive: true });

const predictionPayload = {
  district: 'Puno',
  province: 'Puno',
  populated_center: 'Centro poblado demo',
  latitude: -15.8402,
  longitude: -70.0219,
  altitude: 3827,
  rural_population: 1200,
  agricultural_activity: true,
  main_crop: 'papa',
  temperature_min: -2.5,
  temperature_max: 12.4,
  feels_like: -4.0,
  humidity: 68,
  wind_speed: 7,
  cloud_cover: 20,
  dew_point: -3.5,
  precipitation: 0,
  month: 6,
  hour: 3,
  hours_below_zero: 4,
};

function escapeHtml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

function evidenceHtml(title, subtitle, body) {
  return `<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${escapeHtml(title)}</title>
  <style>
    body { margin: 0; padding: 28px; font-family: Consolas, 'Courier New', monospace; background: #0d1b2a; color: #f8fbff; }
    h1 { margin: 0 0 6px; font-family: Arial, sans-serif; font-size: 24px; color: #e0fbfc; }
    p { margin: 0 0 18px; font-family: Arial, sans-serif; color: #b9d8df; }
    pre { white-space: pre-wrap; background: #10263a; border: 1px solid #3d5a80; border-radius: 10px; padding: 18px; line-height: 1.45; font-size: 13px; }
  </style>
</head>
<body>
  <h1>${escapeHtml(title)}</h1>
  <p>${escapeHtml(subtitle)}</p>
  <pre>${escapeHtml(body)}</pre>
</body>
</html>`;
}

async function screenshotPage(page, url, fileName) {
  await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 30000 });
  await page.waitForLoadState('networkidle', { timeout: 10000 }).catch(() => {});
  await page.waitForTimeout(800);
  await page.screenshot({ path: path.join(capturesDir, fileName), fullPage: true });
  console.log(`OK ${fileName}`);
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1366, height: 900 } });

  await screenshotPage(page, `${backendUrl}/docs`, '05_fastapi_swagger.png');
  await screenshotPage(page, `${backendUrl}/health`, '06_endpoint_health.png');
  await screenshotPage(page, `${backendUrl}/ml/model-info`, '07_endpoint_model_info.png');

  const api = await request.newContext({ baseURL: backendUrl });
  const response = await api.post('/predict/frost-risk', { data: predictionPayload });
  const json = await response.json();
  const pretty = JSON.stringify(json, null, 2);
  fs.writeFileSync(path.join(dataDir, 'predict_response.json'), pretty, 'utf8');

  const htmlPath = path.join(htmlDir, 'predict_response.html');
  fs.writeFileSync(
    htmlPath,
    evidenceHtml(
      'POST /predict/frost-risk',
      `Respuesta generada localmente desde FastAPI. Status HTTP: ${response.status()}.`,
      pretty,
    ),
    'utf8',
  );
  await page.goto(`file://${htmlPath.replaceAll(path.sep, '/')}`);
  await page.screenshot({ path: path.join(capturesDir, '08_endpoint_predict.png'), fullPage: true });
  console.log('OK 08_endpoint_predict.png');

  await api.dispose();
  await browser.close();
})();
