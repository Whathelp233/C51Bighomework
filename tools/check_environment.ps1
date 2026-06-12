$ErrorActionPreference = 'Stop'

$checks = @(
    @{
        Name = 'Keil A51'
        Path = 'C:\Keil_v5\C51\BIN\A51.EXE'
        Required = $true
    },
    @{
        Name = 'Keil BL51'
        Path = 'C:\Keil_v5\C51\BIN\BL51.EXE'
        Required = $true
    },
    @{
        Name = 'Keil OH51'
        Path = 'C:\Keil_v5\C51\BIN\OH51.EXE'
        Required = $true
    },
    @{
        Name = 'Proteus PDS'
        Path = 'C:\Program Files (x86)\Labcenter Electronics\Proteus 8 Professional\BIN\PDS.EXE'
        Required = $true
    }
)

$failed = $false
foreach ($check in $checks) {
    if (Test-Path -LiteralPath $check.Path) {
        Write-Host ("OK   {0}: {1}" -f $check.Name, $check.Path)
    } else {
        Write-Host ("MISS {0}: {1}" -f $check.Name, $check.Path)
        if ($check.Required) {
            $failed = $true
        }
    }
}

$pdftotext = Get-Command pdftotext -ErrorAction SilentlyContinue
if ($pdftotext) {
    Write-Host ("OK   pdftotext: {0}" -f $pdftotext.Source)
} else {
    Write-Host "WARN pdftotext: not found; PDF extraction will be unavailable"
}

if ($failed) {
    throw "Required tools are missing"
}
