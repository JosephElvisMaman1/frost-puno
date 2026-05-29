$ErrorActionPreference = "Continue"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Resolve-Path (Join-Path $ScriptDir "..\..")
$ScreenshotsDir = Join-Path $Root "tools\screenshots"
$CapturesDir = Join-Path $Root "docs\capturas"
$DataDir = Join-Path $Root "docs\capturas_data"

New-Item -ItemType Directory -Force $CapturesDir, $DataDir | Out-Null

Write-Host "FrostPuno screenshot automation"
$BackendUrl = if ($env:BACKEND_URL) { $env:BACKEND_URL } else { "http://127.0.0.1:8000" }
$FlutterUrl = if ($env:FLUTTER_WEB_URL) { $env:FLUTTER_WEB_URL } else { "http://127.0.0.1:5174" }
Write-Host "Backend URL: $BackendUrl"
Write-Host "Flutter URL: $FlutterUrl"
Write-Host ""

Push-Location $ScreenshotsDir
try {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw "npm is required. Install Node.js/npm before running this script."
    }

    if (-not (Test-Path "node_modules")) {
        Write-Host "Installing screenshot dependencies..."
        npm install
    }

    Write-Host "Ensuring Chromium browser is installed for Playwright..."
    npx playwright install chromium
}
catch {
    Write-Warning $_.Exception.Message
}
finally {
    Pop-Location
}

& (Join-Path $ScreenshotsDir "generate_project_tree.ps1")
& (Join-Path $ScreenshotsDir "generate_terminal_evidence.ps1")

Push-Location $ScreenshotsDir
try {
    Write-Host "Capturing static file evidence..."
    npm run capture:static

    Write-Host "Capturing FastAPI evidence..."
    npm run capture:api
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "FastAPI screenshots failed. Verify backend is running at BACKEND_URL."
    }

    Write-Host "Capturing Flutter Web evidence..."
    npm run capture:flutter
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Flutter screenshots failed. Verify Flutter Web is running at FLUTTER_WEB_URL."
    }

    Write-Host "Updating checklist..."
    npm run checklist
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "Done. Review docs\capturas and docs\capturas_data."
