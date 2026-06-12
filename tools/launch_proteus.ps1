param(
    [ValidateSet('final', 'lcd', 'motor')]
    [string]$Project = 'final'
)

$ErrorActionPreference = 'Stop'

$pds = 'C:\Program Files (x86)\Labcenter Electronics\Proteus 8 Professional\BIN\PDS.EXE'
if (-not (Test-Path -LiteralPath $pds)) {
    throw "Proteus PDS.EXE not found: $pds"
}

$repoRoot = Split-Path -Parent $PSScriptRoot

switch ($Project) {
    'final' { $projectPath = Join-Path $repoRoot 'proteus\topic3_car.pdsprj' }
    'lcd' { $projectPath = Join-Path $repoRoot 'proteus\topic3_lcd1602_starter.pdsprj' }
    'motor' { $projectPath = Join-Path $repoRoot 'proteus\topic3_dc_motor_starter.pdsprj' }
}

if (-not (Test-Path -LiteralPath $projectPath)) {
    throw "Project file does not exist: $projectPath"
}

Start-Process -FilePath $pds -ArgumentList "`"$projectPath`""
Write-Host "Opened Proteus project: $projectPath"
