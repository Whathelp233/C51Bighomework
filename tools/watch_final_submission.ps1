param(
    [int]$TimeoutMinutes = 120,
    [int]$PollSeconds = 10
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$projectPath = Join-Path $repoRoot 'proteus\topic3_car.pdsprj'
$videoPath = Join-Path $repoRoot 'output\video\demo.mp4'
$deadline = (Get-Date).AddMinutes($TimeoutMinutes)

Write-Host "Waiting for final deliverables:"
Write-Host "  $projectPath"
Write-Host "  $videoPath"
Write-Host "Timeout: $TimeoutMinutes minute(s); polling every $PollSeconds second(s)."

while ((Get-Date) -lt $deadline) {
    $hasProject = Test-Path -LiteralPath $projectPath
    $hasVideo = Test-Path -LiteralPath $videoPath

    if ($hasProject -and $hasVideo) {
        Write-Host "Final deliverables detected. Running final submission check..."
        & (Join-Path $repoRoot 'tools\check_final_submission.ps1')
        exit $LASTEXITCODE
    }

    $missing = @()
    if (-not $hasProject) { $missing += 'proteus\topic3_car.pdsprj' }
    if (-not $hasVideo) { $missing += 'output\video\demo.mp4' }
    Write-Host ("Still waiting for: {0}" -f ($missing -join ', '))
    Start-Sleep -Seconds $PollSeconds
}

throw "Timed out waiting for final deliverables."
