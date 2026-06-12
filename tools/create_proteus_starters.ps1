$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$hex = Join-Path $root 'build\topic3_car.hex'
if (-not (Test-Path -LiteralPath $hex)) {
    throw "Build the firmware first: .\firmware\build.ps1"
}

$outDir = Join-Path $root 'proteus'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$samples = @(
    @{
        Name = 'topic3_lcd1602_starter.pdsprj'
        Source = 'C:\ProgramData\Labcenter Electronics\Proteus 8 Professional\SAMPLES\VSM for 8051\8051 with LCD1602 LCD controller\LCD1602.pdsprj'
        Description = 'Starter copied from Proteus 8051 LCD1602 sample; firmware replaced by topic3_car.hex.'
    },
    @{
        Name = 'topic3_dc_motor_starter.pdsprj'
        Source = 'C:\ProgramData\Labcenter Electronics\Proteus 8 Professional\SAMPLES\VSM for 8051\8051 DC Motor Controller\8051 DC Motor Controller.pdsprj'
        Description = 'Starter copied from Proteus 8051 DC motor sample; firmware replaced by topic3_car.hex.'
    }
)

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Replace-AsciiBytes {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$From,
        [Parameter(Mandatory=$true)][string]$To
    )
    if ($From.Length -ne $To.Length) {
        throw "Binary replacement strings must have equal length: '$From' -> '$To'"
    }
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $fromBytes = [System.Text.Encoding]::ASCII.GetBytes($From)
    $toBytes = [System.Text.Encoding]::ASCII.GetBytes($To)
    for ($i = 0; $i -le $bytes.Length - $fromBytes.Length; $i++) {
        $match = $true
        for ($j = 0; $j -lt $fromBytes.Length; $j++) {
            if ($bytes[$i + $j] -ne $fromBytes[$j]) {
                $match = $false
                break
            }
        }
        if ($match) {
            for ($j = 0; $j -lt $toBytes.Length; $j++) {
                $bytes[$i + $j] = $toBytes[$j]
            }
        }
    }
    [System.IO.File]::WriteAllBytes($Path, $bytes)
}

foreach ($sample in $samples) {
    if (-not (Test-Path -LiteralPath $sample.Source)) {
        throw "Proteus sample not found: $($sample.Source)"
    }

    $work = Join-Path $root ("tmp\proteus_starter_" + [System.IO.Path]::GetFileNameWithoutExtension($sample.Name))
    $zip = Join-Path $root ("tmp\" + [System.IO.Path]::GetFileNameWithoutExtension($sample.Name) + '.zip')
    $out = Join-Path $outDir $sample.Name

    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force -Path $work | Out-Null

    Copy-Item -LiteralPath $sample.Source -Destination $zip -Force
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $work)

    $firmwareXml = Join-Path $work 'FIRMWARE\AT89C51.XML'
    (Get-Content -LiteralPath $firmwareXml -Encoding UTF8 -Raw).Replace('Debug.ubf', 'Debug.hex') |
        Set-Content -LiteralPath $firmwareXml -Encoding UTF8

    foreach ($binary in @('ROOT.DSN', 'ROOT.CDB')) {
        Replace-AsciiBytes -Path (Join-Path $work $binary) -From 'Debug.ubf' -To 'Debug.hex'
    }

    $oldFirmware = Join-Path $work 'FIRMWARE\AT89C51\Debug\Debug.ubf'
    Remove-Item -LiteralPath $oldFirmware -Force -ErrorAction SilentlyContinue
    Copy-Item -LiteralPath $hex -Destination (Join-Path $work 'FIRMWARE\AT89C51\Debug\Debug.hex') -Force

    $projectXml = Join-Path $work 'PROJECT.XML'
    $project = Get-Content -LiteralPath $projectXml -Encoding UTF8 -Raw
    $project = $project -replace '<TEXT>.*?</TEXT>', ('<TEXT>' + $sample.Description + '</TEXT>')
    Set-Content -LiteralPath $projectXml -Encoding UTF8 -Value $project

    Remove-Item -LiteralPath $out -Force -ErrorAction SilentlyContinue
    $tempZip = $out + '.zip'
    Remove-Item -LiteralPath $tempZip -Force -ErrorAction SilentlyContinue
    [System.IO.Compression.ZipFile]::CreateFromDirectory($work, $tempZip)
    Move-Item -LiteralPath $tempZip -Destination $out -Force

    Write-Host "Created $out"
}
