$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

function Assert-File {
    param(
        [Parameter(Mandatory=$true)][string]$RelativePath,
        [int64]$MinBytes = 1
    )

    $path = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing required file: $RelativePath"
    }

    $item = Get-Item -LiteralPath $path
    if ($item.Length -lt $MinBytes) {
        throw "File is too small: $RelativePath ($($item.Length) bytes)"
    }

    Write-Host ("OK   {0}: {1} bytes" -f $RelativePath, $item.Length)
    return $item
}

& (Join-Path $repoRoot 'tools\check_environment.ps1')
& (Join-Path $repoRoot 'firmware\build.ps1')
& (Join-Path $repoRoot 'tools\check_topic3_proteus_plan.ps1')
& (Join-Path $repoRoot 'tools\check_deliverables.ps1') -Final

$project = Assert-File -RelativePath 'proteus\topic3_car.pdsprj' -MinBytes 1024
$video = Assert-File -RelativePath 'output\video\demo.mp4' -MinBytes 1024

$ffprobe = Get-Command ffprobe -ErrorAction SilentlyContinue
if ($ffprobe) {
    $durationRaw = & $ffprobe.Source -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $video.FullName
    $duration = [double]::Parse($durationRaw, [System.Globalization.CultureInfo]::InvariantCulture)
    if ($duration -gt 20.5) {
        throw ("Demo video is longer than 20 seconds: {0:N2}s" -f $duration)
    }
    Write-Host ("OK   demo video duration: {0:N2}s" -f $duration)
} else {
    Write-Host "WARN ffprobe not found; video duration was not checked automatically."
    Write-Host "Manual requirement: output\video\demo.mp4 must be 20 seconds or shorter."
}

Write-Host "Final submission checks passed."
