const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..', '..');
const capturesDir = path.join(rootDir, 'docs', 'capturas');
const checklistPath = path.join(rootDir, 'docs', 'capturas_checklist.md');

const items = [
  ['01', 'Estructura del proyecto', '01_estructura_proyecto.png', 'Automatica', 'tools/screenshots/generate_project_tree.ps1'],
  ['02', 'Dataset generado', '02_dataset_generado.png', 'Automatica', 'npm run capture:static'],
  ['03', 'Model metadata', '03_model_metadata.png', 'Automatica', 'npm run capture:static'],
  ['04', 'Quality gate aprobado', '04_quality_gate.png', 'Automatica', 'tools/screenshots/generate_terminal_evidence.ps1'],
  ['05', 'FastAPI Swagger', '05_fastapi_swagger.png', 'Automatica con backend activo', 'npm run capture:api'],
  ['06', 'Endpoint health', '06_endpoint_health.png', 'Automatica con backend activo', 'npm run capture:api'],
  ['07', 'Endpoint model-info', '07_endpoint_model_info.png', 'Automatica con backend activo', 'npm run capture:api'],
  ['08', 'Endpoint predict', '08_endpoint_predict.png', 'Automatica con backend activo', 'npm run capture:api'],
  ['09', 'Tests backend', '09_tests_backend.png', 'Automatica', 'tools/screenshots/generate_terminal_evidence.ps1'],
  ['10', 'Flutter Home', '10_flutter_home.png', 'Automatica con Flutter Web activo', 'npm run capture:flutter'],
  ['11', 'Formulario Flutter', '11_flutter_formulario.png', 'Automatica con Flutter Web activo', 'npm run capture:flutter'],
  ['12', 'Resultado de prediccion', '12_flutter_resultado.png', 'Automatica con Flutter Web y backend activos', 'npm run capture:flutter'],
  ['13', 'Historial', '13_flutter_historial.png', 'Automatica con Flutter Web activo', 'npm run capture:flutter'],
  ['14', 'Fuentes de datos', '14_flutter_fuentes_datos.png', 'Automatica con Flutter Web activo', 'npm run capture:flutter'],
  ['15', 'Flutter ModelInfo', '15_flutter_model_info.png', 'Automatica con Flutter Web activo', 'npm run capture:flutter'],
  ['16', 'Flutter analyze y test', '16_flutter_analyze_test.png', 'Automatica', 'tools/screenshots/generate_terminal_evidence.ps1'],
  ['17', 'Flutter build web', '17_flutter_build_web.png', 'Automatica', 'tools/screenshots/generate_terminal_evidence.ps1'],
  ['18', 'GitHub workflows', '18_github_workflows.png', 'Automatica', 'npm run capture:static'],
  ['19', 'Supabase SQL', '19_supabase_sql.png', 'Automatica', 'npm run capture:static'],
  ['20', 'Dataset v2 sin leakage', '20_dataset_v2_sin_leakage.png', 'Automatica', 'npm run capture:static'],
  ['21', 'Model metadata v0.2.0', '21_model_metadata_v0_2_0.png', 'Automatica', 'npm run capture:static'],
  ['22', 'Comparacion v0.1.0 vs v0.2.0', '22_comparacion_modelos.png', 'Automatica', 'npm run capture:static'],
  ['23', 'Despliegue Render/Vercel/Supabase', '23_despliegue_render_vercel_supabase.png', 'Automatica', 'npm run capture:static'],
  ['24', 'Android APK y prueba movil', '24_android_apk_mobile.png', 'Automatica', 'npm run capture:static'],
  ['25', 'GitHub repositorio', '25_github_repo.png', 'Automatica web publica', 'npm run capture:deploy'],
  ['26', 'GitHub rama v0.2.0', '26_github_branch_v0_2_0.png', 'Automatica web publica', 'npm run capture:deploy'],
  ['27', 'GitHub commits v0.2.0', '27_github_commits_v0_2_0.png', 'Automatica web publica', 'npm run capture:deploy'],
  ['28', 'GitHub Actions', '28_github_actions.png', 'Automatica web publica', 'npm run capture:deploy'],
  ['29', 'Render health remoto', '29_render_health.png', 'Automatica web publica', 'npm run capture:deploy'],
  ['30', 'Render model-info remoto', '30_render_model_info.png', 'Automatica web publica', 'npm run capture:deploy'],
  ['31', 'Render Swagger remoto', '31_render_swagger.png', 'Automatica web publica', 'npm run capture:deploy'],
  ['32', 'Vercel Flutter movil', '32_vercel_flutter_mobile.png', 'Automatica web publica', 'npm run capture:deploy'],
  ['33', 'Vercel Flutter desktop', '33_vercel_flutter_desktop.png', 'Automatica web publica', 'npm run capture:deploy'],
  ['34', 'Headers Render/Vercel', '34_despliegue_headers.png', 'Automatica', 'npm run capture:deploy'],
  ['35', 'Ramas y versiones', '35_ramas_y_versiones.png', 'Automatica', 'npm run capture:deploy'],
  ['36', 'Supabase estado/esquema', '36_supabase_estado.png', 'Automatica con SQL versionado', 'npm run capture:deploy'],
  ['37', 'Vercel estado/configuracion', '37_vercel_estado.png', 'Automatica', 'npm run capture:deploy'],
];

function exists(fileName) {
  return fs.existsSync(path.join(capturesDir, fileName));
}

const lines = [
  '# Checklist de capturas - FrostPuno',
  '',
  'Este documento se actualiza con `node tools/screenshots/update_checklist.js` o desde `tools/screenshots/run_all_screenshots.ps1`.',
  '',
  '## Estado de capturas',
  '',
  '| Nro. | Captura | Archivo | Modo | Estado |',
  '|---|---|---|---|---|',
  ...items.map(([nro, title, file, mode]) => {
    const status = exists(file) ? 'Generada' : 'Pendiente';
    return `| ${nro} | ${title} | \`docs/capturas/${file}\` | ${mode} | ${status} |`;
  }),
  '',
  '## Comandos principales',
  '',
  '```powershell',
  'Set-Location tools\\screenshots',
  'npm install',
  'npx playwright install chromium',
  'Set-Location ..\\..',
  '.\\tools\\screenshots\\run_all_screenshots.ps1',
  '```',
  '',
  '## Requisitos de servidores locales',
  '',
  '- Backend FastAPI: `http://127.0.0.1:8000`.',
  '- Flutter Web: usar `FLUTTER_WEB_URL`, recomendado `http://127.0.0.1:5174`.',
  '- No se usan credenciales reales ni servicios desplegados.',
  '',
  '## Capturas manuales posibles',
  '',
  '- Si Flutter Web usa CanvasKit sin semantica accesible y Playwright no puede hacer clic por texto, capturar manualmente las pantallas indicadas.',
  '- Si Swagger o endpoints no estan disponibles, levantar FastAPI y repetir `npm run capture:api`.',
  '- Si un comando de terminal falla por dependencias locales, revisar el archivo `.txt` correspondiente en `docs/capturas_data/`.',
  '',
];

fs.writeFileSync(checklistPath, `${lines.join('\n')}\n`, 'utf8');
console.log(`Checklist actualizado: ${path.relative(rootDir, checklistPath)}`);
