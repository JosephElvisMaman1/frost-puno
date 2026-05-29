const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');
const childProcess = require('child_process');

const rootDir = path.resolve(__dirname, '..', '..');
const capturesDir = path.join(rootDir, 'docs', 'capturas');
const dataDir = path.join(rootDir, 'docs', 'capturas_data');
const htmlDir = path.join(dataDir, 'html');

fs.mkdirSync(capturesDir, { recursive: true });
fs.mkdirSync(dataDir, { recursive: true });
fs.mkdirSync(htmlDir, { recursive: true });

const repoUrl = 'https://github.com/JosephElvisMaman1/frost-puno';
const vercelUrl = process.env.VERCEL_URL || 'https://frost-puno.vercel.app';
const renderUrl = process.env.RENDER_URL || 'https://frost-puno.onrender.com';

function escapeHtml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

function run(command) {
  try {
    return childProcess.execSync(command, {
      cwd: rootDir,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'pipe'],
    }).trim();
  } catch (error) {
    return `${error.stdout || ''}${error.stderr || error.message}`.trim();
  }
}

function writeEvidenceHtml(fileBase, title, subtitle, body) {
  const html = `<!doctype html>
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
  <span class="badge">FrostPuno - evidencia de despliegue</span>
  <h1>${escapeHtml(title)}</h1>
  <p>${escapeHtml(subtitle)}</p>
  <pre>${escapeHtml(body || 'Sin datos disponibles.')}</pre>
</body>
</html>`;
  const htmlPath = path.join(htmlDir, `${fileBase}.html`);
  fs.writeFileSync(htmlPath, html, 'utf8');
  return htmlPath;
}

async function screenshotUrl(page, url, fileName) {
  await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 });
  await page.waitForLoadState('networkidle', { timeout: 20000 }).catch(() => {});
  await page.waitForTimeout(1500);
  await page.screenshot({ path: path.join(capturesDir, fileName), fullPage: true });
  console.log(`OK ${fileName}`);
}

async function screenshotHtml(page, htmlPath, fileName) {
  await page.goto(`file://${htmlPath.replaceAll(path.sep, '/')}`);
  await page.screenshot({ path: path.join(capturesDir, fileName), fullPage: true });
  console.log(`OK ${fileName}`);
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const desktop = await browser.newPage({ viewport: { width: 1366, height: 900 } });
  const mobile = await browser.newPage({
    viewport: { width: 390, height: 844 },
    deviceScaleFactor: 1,
    isMobile: true,
    hasTouch: true,
  });

  await screenshotUrl(desktop, repoUrl, '25_github_repo.png');
  await screenshotUrl(desktop, `${repoUrl}/tree/codex/model-v0-2-0`, '26_github_branch_v0_2_0.png');
  await screenshotUrl(desktop, `${repoUrl}/commits/codex/model-v0-2-0`, '27_github_commits_v0_2_0.png');
  await screenshotUrl(desktop, `${repoUrl}/actions`, '28_github_actions.png');

  await screenshotUrl(desktop, `${renderUrl}/health`, '29_render_health.png');
  await screenshotUrl(desktop, `${renderUrl}/ml/model-info`, '30_render_model_info.png');
  await screenshotUrl(desktop, `${renderUrl}/docs`, '31_render_swagger.png');

  await screenshotUrl(mobile, vercelUrl, '32_vercel_flutter_mobile.png');
  await screenshotUrl(desktop, vercelUrl, '33_vercel_flutter_desktop.png');

  const renderHeaders = run(`curl.exe -i -L --max-time 80 ${renderUrl}/health`);
  const vercelHeaders = run(`curl.exe -I -L --max-time 40 ${vercelUrl}`);
  const branches = run('git ls-remote --heads origin');
  const commits = run('git log --oneline --decorate -6');
  const status = run('git status --short --branch');
  const modelV1 = fs.readFileSync(path.join(rootDir, 'ml_pipeline/registry/model_metadata.json'), 'utf8');
  const modelV2 = fs.readFileSync(path.join(rootDir, 'ml_pipeline/registry/model_metadata_v0_2_0.json'), 'utf8');

  await screenshotHtml(
    desktop,
    writeEvidenceHtml(
      '34_despliegue_headers',
      'Headers de despliegue Render y Vercel',
      'Evidencia tecnica: Render responde con uvicorn y Vercel sirve Flutter Web con cache HIT.',
      `# Render /health\n${renderHeaders}\n\n# Vercel frontend\n${vercelHeaders}`,
    ),
    '34_despliegue_headers.png',
  );

  await screenshotHtml(
    desktop,
    writeEvidenceHtml(
      '35_ramas_y_versiones',
      'Ramas, commits y versiones del despliegue',
      'Mapa de trazabilidad entre main, codex/model-v0-2-0, v0.1.0 productivo y v0.2.0 experimental.',
      `# git status\n${status}\n\n# ramas remotas\n${branches}\n\n# commits recientes\n${commits}\n\n# modelo productivo v0.1.0\n${JSON.stringify(JSON.parse(modelV1), null, 2)}\n\n# modelo experimental v0.2.0\n${JSON.stringify(JSON.parse(modelV2), null, 2)}`,
    ),
    '35_ramas_y_versiones.png',
  );

  await screenshotHtml(
    desktop,
    writeEvidenceHtml(
      '36_supabase_estado',
      'Supabase: esquema preparado y pendiente de reautenticacion',
      'Las credenciales del conector Supabase expiraron; se documenta el esquema SQL versionado y el paso necesario para capturar el dashboard real.',
      `# Estado del conector\nEl conector Supabase devolvio token_expired durante la verificacion automatica.\n\n# SQL versionado\n${fs.readFileSync(path.join(rootDir, 'supabase/migrations/001_create_core_tables.sql'), 'utf8')}\n\n# RLS\n${fs.readFileSync(path.join(rootDir, 'supabase/policies/rls_policies.sql'), 'utf8')}\n\n# Seed\n${fs.readFileSync(path.join(rootDir, 'supabase/seed/seed_locations.sql'), 'utf8')}`,
    ),
    '36_supabase_estado.png',
  );

  await screenshotHtml(
    desktop,
    writeEvidenceHtml(
      '37_vercel_estado',
      'Vercel: frontend desplegado y dashboard pendiente de reautenticacion',
      'Vercel sirve la app en frost-puno.vercel.app. El conector Vercel devolvio token_expired para dashboard/deployments privados.',
      `# URL publica\n${vercelUrl}\n\n# Headers\n${vercelHeaders}\n\n# Configuracion versionada\n${fs.readFileSync(path.join(rootDir, 'app_flutter/vercel.json'), 'utf8')}`,
    ),
    '37_vercel_estado.png',
  );

  await browser.close();
})();
