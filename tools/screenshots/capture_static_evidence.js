const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..', '..');
const capturesDir = path.join(rootDir, 'docs', 'capturas');
const dataDir = path.join(rootDir, 'docs', 'capturas_data');
const htmlDir = path.join(dataDir, 'html');

fs.mkdirSync(capturesDir, { recursive: true });
fs.mkdirSync(dataDir, { recursive: true });
fs.mkdirSync(htmlDir, { recursive: true });

function escapeHtml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

function readText(relativePath) {
  const file = path.join(rootDir, relativePath);
  if (!fs.existsSync(file)) return null;
  return fs.readFileSync(file, 'utf8');
}

function readMany(relativePaths) {
  return relativePaths
    .map((relativePath) => {
      const content = readText(relativePath);
      if (content === null) return null;
      return `# ${relativePath}\n\n${content}`;
    })
    .filter(Boolean)
    .join('\n\n');
}

function htmlPage(title, subtitle, body) {
  return `<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${escapeHtml(title)}</title>
  <style>
    body { margin: 0; padding: 30px; background: #0d1b2a; color: #f8fbff; font-family: Arial, sans-serif; }
    h1 { margin: 0 0 8px; color: #e0fbfc; font-size: 28px; }
    p { margin: 0 0 20px; color: #b9d8df; font-size: 15px; }
    pre { white-space: pre-wrap; overflow-wrap: anywhere; background: #10263a; border: 1px solid #3d5a80; border-radius: 12px; padding: 18px; font: 13px/1.45 Consolas, 'Courier New', monospace; }
    .badge { display: inline-block; margin-bottom: 14px; padding: 6px 10px; border-radius: 999px; background: #ee6c4d; color: #111827; font-weight: 700; font-size: 12px; }
  </style>
</head>
<body>
  <span class="badge">FrostPuno - evidencia local</span>
  <h1>${escapeHtml(title)}</h1>
  <p>${escapeHtml(subtitle)}</p>
  <pre>${escapeHtml(body || 'Archivo no disponible al momento de generar la captura.')}</pre>
</body>
</html>`;
}

async function render(page, outputFile, title, subtitle, body) {
  const htmlPath = path.join(htmlDir, `${path.basename(outputFile, '.png')}.html`);
  fs.writeFileSync(htmlPath, htmlPage(title, subtitle, body), 'utf8');
  await page.goto(`file://${htmlPath.replaceAll(path.sep, '/')}`);
  await page.screenshot({ path: path.join(capturesDir, outputFile), fullPage: true });
  console.log(`OK ${outputFile}`);
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1366, height: 900 } });

  await render(
    page,
    '01_estructura_proyecto.png',
    'Estructura del proyecto',
    'Arbol generado localmente con carpetas principales y archivos relevantes.',
    readText('docs/capturas_data/project_tree.txt'),
  );

  const dataset = readText('data/processed/frost_training_dataset.csv');
  await render(
    page,
    '02_dataset_generado.png',
    'Dataset generado',
    'Primeras filas del dataset procesado para entrenamiento supervisado.',
    dataset ? dataset.split(/\r?\n/).slice(0, 24).join('\n') : null,
  );

  const metadata = readText('ml_pipeline/registry/model_metadata.json');
  await render(
    page,
    '03_model_metadata.png',
    'Model metadata',
    'Registro del modelo productivo v0.1.0 usado actualmente por FastAPI.',
    metadata ? JSON.stringify(JSON.parse(metadata), null, 2) : null,
  );

  const datasetV2 = readText('data/processed/frost_training_dataset_v2.csv');
  await render(
    page,
    '20_dataset_v2_sin_leakage.png',
    'Dataset v2 sin data leakage',
    'Primeras filas del dataset experimental sin temperatura_minima_diaria ni horas_bajo_cero como features.',
    datasetV2 ? datasetV2.split(/\r?\n/).slice(0, 24).join('\n') : null,
  );

  const metadataV2 = readText('ml_pipeline/registry/model_metadata_v0_2_0.json');
  await render(
    page,
    '21_model_metadata_v0_2_0.png',
    'Model metadata v0.2.0',
    'Registro experimental con split por distrito, metricas realistas y matriz de confusion.',
    metadataV2 ? JSON.stringify(JSON.parse(metadataV2), null, 2) : null,
  );

  await render(
    page,
    '22_comparacion_modelos.png',
    'Comparacion v0.1.0 vs v0.2.0',
    'Documento academico que explica data leakage, falsos positivos/falsos negativos y evaluacion realista.',
    readText('docs/model_comparison_v1_vs_v2.md'),
  );

  await render(
    page,
    '23_despliegue_render_vercel_supabase.png',
    'Despliegue Render + Vercel + Supabase',
    'Guia de despliegue gratuito con backend FastAPI, Flutter Web, Supabase y GitHub Actions.',
    readText('docs/deployment.md'),
  );

  await render(
    page,
    '24_android_apk_mobile.png',
    'Android APK y prueba movil',
    'Guia para correr FrostPuno en Android, configurar SDK local, probar GPS y generar APK.',
    readText('docs/mobile_build.md'),
  );

  await render(
    page,
    '18_github_workflows.png',
    'GitHub Actions workflows',
    'Workflows implementados para backend, datos, entrenamiento y quality gate.',
    readMany([
      '.github/workflows/backend-tests.yml',
      '.github/workflows/data-validation.yml',
      '.github/workflows/ml-training.yml',
      '.github/workflows/model-quality-gate.yml',
    ]),
  );

  await render(
    page,
    '19_supabase_sql.png',
    'Supabase SQL',
    'Migraciones, politicas RLS y datos semilla preparados para el MVP.',
    readMany([
      'supabase/migrations/001_create_core_tables.sql',
      'supabase/migrations/002_add_feedback_and_observations.sql',
      'supabase/policies/rls_policies.sql',
      'supabase/seed/seed_locations.sql',
    ]),
  );

  const terminalCaptures = [
    ['04_quality_gate.png', 'Quality gate', 'Validacion del f1-score macro minimo.', 'docs/capturas_data/quality_gate_output.txt'],
    ['09_tests_backend.png', 'Backend tests', 'Ejecucion de pytest sobre backend_fastapi/tests.', 'docs/capturas_data/backend_tests_output.txt'],
    ['16_flutter_analyze_test.png', 'Flutter analyze y test', 'Validacion estatica y pruebas del frontend Flutter.', null],
    ['17_flutter_build_web.png', 'Flutter build web', 'Compilacion web local del frontend Flutter.', 'docs/capturas_data/flutter_build_output.txt'],
  ];

  const analyze = readText('docs/capturas_data/flutter_analyze_output.txt');
  const test = readText('docs/capturas_data/flutter_test_output.txt');

  for (const [file, title, subtitle, relativePath] of terminalCaptures) {
    let body = relativePath ? readText(relativePath) : null;
    if (file === '16_flutter_analyze_test.png') {
      body = `# flutter analyze\n\n${analyze || 'Pendiente'}\n\n# flutter test\n\n${test || 'Pendiente'}`;
    }
    if (body) {
      await render(page, file, title, subtitle, body);
    }
  }

  await browser.close();
})();
