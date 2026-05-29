$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Resolve-Path (Join-Path $ScriptDir "..\..")
$DataDir = Join-Path $Root "docs\capturas_data"
New-Item -ItemType Directory -Force $DataDir | Out-Null

$ExcludeNames = @(
    ".git",
    ".dart_tool",
    "build",
    "node_modules",
    "__pycache__",
    ".pytest_cache",
    ".venv",
    "venv",
    "_render_informe_frost_puno"
)

function Write-Tree {
    param(
        [string]$Path,
        [string]$Prefix = "",
        [int]$Depth = 0,
        [int]$MaxDepth = 4
    )

    if ($Depth -gt $MaxDepth) { return @() }

    $items = Get-ChildItem -LiteralPath $Path -Force |
        Where-Object { $ExcludeNames -notcontains $_.Name } |
        Sort-Object @{ Expression = { -not $_.PSIsContainer } }, Name

    $lines = @()
    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $isLast = $i -eq ($items.Count - 1)
        $branch = if ($isLast) { "\-- " } else { "|-- " }
        $lines += "$Prefix$branch$($item.Name)"

        if ($item.PSIsContainer) {
            $childPrefix = if ($isLast) { "$Prefix    " } else { "$Prefix|   " }
            $lines += Write-Tree -Path $item.FullName -Prefix $childPrefix -Depth ($Depth + 1) -MaxDepth $MaxDepth
        }
    }
    return $lines
}

$OutputFile = Join-Path $DataDir "project_tree.txt"
$header = @(
    "FrostPuno - estructura del proyecto",
    "Generado localmente para evidencias del informe.",
    "Raiz: frost-puno",
    ""
)
$treeLines = Write-Tree -Path $Root -MaxDepth 4
Set-Content -Path $OutputFile -Value ($header + $treeLines) -Encoding UTF8
Write-Host "Saved $OutputFile"

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
    Write-Warning "Playwright dependencies are not installed. Run 'npm install' in tools\screenshots to generate docs\capturas\01_estructura_proyecto.png."
}
