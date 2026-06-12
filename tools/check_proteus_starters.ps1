$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$projects = @(
    'proteus\topic3_lcd1602_starter.pdsprj',
    'proteus\topic3_dc_motor_starter.pdsprj'
)

$tmpRoot = Join-Path $root 'tmp\proteus_starter_check'
Remove-Item -LiteralPath $tmpRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null

foreach ($project in $projects) {
    $path = Join-Path $root $project
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing starter project: $project"
    }

    $name = [System.IO.Path]::GetFileNameWithoutExtension($project)
    $zip = Join-Path $tmpRoot "$name.zip"
    $extract = Join-Path $tmpRoot $name
    Copy-Item -LiteralPath $path -Destination $zip -Force
    Expand-Archive -LiteralPath $zip -DestinationPath $extract -Force

    $hex = Join-Path $extract 'FIRMWARE\AT89C51\Debug\Debug.hex'
    $ubf = Join-Path $extract 'FIRMWARE\AT89C51\Debug\Debug.ubf'
    if (-not (Test-Path -LiteralPath $hex)) {
        throw "Starter project lacks Debug.hex: $project"
    }
    if (Test-Path -LiteralPath $ubf) {
        throw "Starter project still contains Debug.ubf: $project"
    }

    $xml = Get-Content -LiteralPath (Join-Path $extract 'FIRMWARE\AT89C51.XML') -Encoding UTF8 -Raw
    if ($xml -notmatch 'Debug\.hex') {
        throw "Firmware XML does not reference Debug.hex: $project"
    }

    $hexHead = Get-Content -LiteralPath $hex -TotalCount 1
    if ($hexHead -notmatch '^:') {
        throw "Debug.hex is not Intel HEX: $project"
    }

    Write-Host "Verified $project"
}
