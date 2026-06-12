$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$src = Join-Path $PSScriptRoot 'asm\topic3_car.a51'
$build = Join-Path $root 'build'
$obj = Join-Path $build 'topic3_car.obj'
$lst = Join-Path $build 'topic3_car.lst'
$abs = Join-Path $build 'topic3_car.abs'
$m51 = Join-Path $build 'topic3_car.m51'
$hex = Join-Path $build 'topic3_car.hex'

$a51 = 'C:\Keil_v5\C51\BIN\A51.EXE'
$bl51 = 'C:\Keil_v5\C51\BIN\BL51.EXE'
$oh51 = 'C:\Keil_v5\C51\BIN\OH51.EXE'

foreach ($tool in @($a51, $bl51, $oh51)) {
    if (-not (Test-Path -LiteralPath $tool)) {
        throw "Required Keil tool not found: $tool"
    }
}

New-Item -ItemType Directory -Force -Path $build | Out-Null

& $a51 $src "OBJECT($obj)" "PRINT($lst)"
if ($LASTEXITCODE -ne 0) {
    throw "A51 failed with exit code $LASTEXITCODE"
}

& $bl51 $obj "TO" $abs "PRINT($m51)"
if ($LASTEXITCODE -ne 0) {
    throw "BL51 failed with exit code $LASTEXITCODE"
}

& $oh51 $abs "HEXFILE($hex)"
if ($LASTEXITCODE -ne 0) {
    throw "OH51 failed with exit code $LASTEXITCODE"
}

Write-Host "Generated $hex"
