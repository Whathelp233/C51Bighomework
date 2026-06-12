param(
    [switch]$OpenReferences
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$pds = 'C:\Program Files (x86)\Labcenter Electronics\Proteus 8 Professional\BIN\PDS.EXE'
$finalProject = Join-Path $repoRoot 'proteus\topic3_car.pdsprj'
$videoDir = Join-Path $repoRoot 'output\video'

function Open-WorkspaceFile {
    param([Parameter(Mandatory=$true)][string]$RelativePath)

    $path = Join-Path $repoRoot $RelativePath
    if (Test-Path -LiteralPath $path) {
        Start-Process -FilePath $path
        Write-Host "Opened reference: $RelativePath"
    } else {
        Write-Host "Missing reference: $RelativePath"
    }
}

if (-not (Test-Path -LiteralPath $pds)) {
    throw "Proteus PDS.EXE not found: $pds"
}

New-Item -ItemType Directory -Force -Path $videoDir | Out-Null

Write-Host "Building firmware..."
& (Join-Path $repoRoot 'firmware\build.ps1')

Write-Host "Checking Proteus preparation files..."
& (Join-Path $repoRoot 'tools\check_topic3_proteus_plan.ps1')

if ($OpenReferences) {
    Open-WorkspaceFile -RelativePath 'proteus\topic3_gui_build_steps.md'
    Open-WorkspaceFile -RelativePath 'proteus\topic3_bom.csv'
    Open-WorkspaceFile -RelativePath 'proteus\topic3_car_wiring.csv'
    Open-WorkspaceFile -RelativePath 'proteus\topic3_echo_test_inputs.csv'
    Open-WorkspaceFile -RelativePath 'output\video\demo_storyboard.md'
}

if (Test-Path -LiteralPath $finalProject) {
    Start-Process -FilePath $pds -ArgumentList "`"$finalProject`""
    Write-Host "Opened final Proteus project: $finalProject"
} else {
    Start-Process -FilePath $pds
    Write-Host "Final project does not exist yet: $finalProject"
    Write-Host "Create a new Proteus project and save it exactly as proteus\topic3_car.pdsprj."
    Write-Host "Use proteus\topic3_gui_build_steps.md and proteus\topic3_car_wiring.csv for the wiring."
}

Write-Host "After saving the final project and recording output\video\demo.mp4, run:"
Write-Host ".\tools\check_final_submission.ps1"
