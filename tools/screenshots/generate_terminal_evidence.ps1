$ErrorActionPreference = "Continue"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Resolve-Path (Join-Path $ScriptDir "..\..")
$DataDir = Join-Path $Root "docs\capturas_data"

New-Item -ItemType Directory -Force $DataDir | Out-Null

function Invoke-EvidenceCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$OutputFile,
        [Parameter(Mandatory = $true)][scriptblock]$Command,
        [string]$WorkingDirectory = $Root
    )

    Write-Host "==> $Name"
    Push-Location $WorkingDirectory
    try {
        $startedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $output = & $Command 2>&1
        $exitCode = $LASTEXITCODE
        if ($null -eq $exitCode) { $exitCode = 0 }
        $finishedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        $content = @(
            "FrostPuno terminal evidence",
            "Command: $Name",
            "Started at: $startedAt",
            "Finished at: $finishedAt",
            "Exit code: $exitCode",
            "",
            "Output:",
            "-------",
            ($output | Out-String)
        ) -join [Environment]::NewLine

        Set-Content -Path $OutputFile -Value $content -Encoding UTF8
        Write-Host "Saved $OutputFile"
    }
    catch {
        $content = @(
            "FrostPuno terminal evidence",
            "Command: $Name",
            "Status: failed to execute",
            "",
            $_.Exception.Message
        ) -join [Environment]::NewLine
        Set-Content -Path $OutputFile -Value $content -Encoding UTF8
        Write-Warning $_.Exception.Message
    }
    finally {
        Pop-Location
    }
}

$env:PYTHONPATH = Join-Path $Root "backend_fastapi"
$env:ENABLE_SUPABASE = "false"

Invoke-EvidenceCommand `
    -Name "pytest backend_fastapi/tests -q" `
    -OutputFile (Join-Path $DataDir "backend_tests_output.txt") `
    -Command { pytest .\backend_fastapi\tests -q } `
    -WorkingDirectory $Root

Invoke-EvidenceCommand `
    -Name "python -m ml_pipeline.registry.check_model_quality --metadata ml_pipeline\registry\model_metadata.json --min-f1-macro 0.70" `
    -OutputFile (Join-Path $DataDir "quality_gate_output.txt") `
    -Command { python -m ml_pipeline.registry.check_model_quality --metadata ml_pipeline\registry\model_metadata.json --min-f1-macro 0.70 } `
    -WorkingDirectory $Root

$FlutterDir = Join-Path $Root "app_flutter"

Invoke-EvidenceCommand `
    -Name "flutter analyze" `
    -OutputFile (Join-Path $DataDir "flutter_analyze_output.txt") `
    -Command { flutter analyze } `
    -WorkingDirectory $FlutterDir

Invoke-EvidenceCommand `
    -Name "flutter test" `
    -OutputFile (Join-Path $DataDir "flutter_test_output.txt") `
    -Command { flutter test } `
    -WorkingDirectory $FlutterDir

Invoke-EvidenceCommand `
    -Name "flutter build web --dart-define=API_BASE_URL=http://127.0.0.1:8000" `
    -OutputFile (Join-Path $DataDir "flutter_build_output.txt") `
    -Command { flutter build web --dart-define=API_BASE_URL=http://127.0.0.1:8000 } `
    -WorkingDirectory $FlutterDir

$ScreenshotsDir = Join-Path $Root "tools\screenshots"
if (Test-Path (Join-Path $ScreenshotsDir "node_modules")) {
    Push-Location $ScreenshotsDir
    try {
        npm run capture:static
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Warning "Playwright dependencies are not installed. Run 'npm install' in tools\screenshots to generate PNG captures from terminal evidence."
}
