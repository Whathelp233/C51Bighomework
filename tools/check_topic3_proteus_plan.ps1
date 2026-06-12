$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot

function New-UnicodeName {
    param([int[]]$Codes)
    return (-join ($Codes | ForEach-Object { [char]$_ }))
}

function Assert-PathExists {
    param([Parameter(Mandatory=$true)][string]$RelativePath)

    $fullPath = Join-Path $root $RelativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        throw "Missing required file: $RelativePath"
    }
    Write-Host "OK   file: $RelativePath"
}

function Assert-Columns {
    param(
        [Parameter(Mandatory=$true)]$Row,
        [Parameter(Mandatory=$true)][string[]]$Columns,
        [Parameter(Mandatory=$true)][string]$Path
    )

    $actual = @($Row.PSObject.Properties.Name)
    foreach ($column in $Columns) {
        if ($actual -notcontains $column) {
            throw "Missing column '$column' in $Path"
        }
    }
}

function Assert-TextContains {
    param(
        [Parameter(Mandatory=$true)][string]$RelativePath,
        [Parameter(Mandatory=$true)][string[]]$Needles
    )

    $fullPath = Join-Path $root $RelativePath
    $text = Get-Content -LiteralPath $fullPath -Encoding UTF8 -Raw
    foreach ($needle in $Needles) {
        if ($text -notmatch [regex]::Escape($needle)) {
            throw "$RelativePath does not mention '$needle'"
        }
    }
    Write-Host "OK   text refs: $RelativePath"
}

$docProteusInvestigation = Join-Path 'docs' ('proteus' + (New-UnicodeName @(0x81EA,0x52A8,0x751F,0x6210,0x53EF,0x884C,0x6027,0x8C03,0x67E5,0x002E,0x006D,0x0064)))

$requiredFiles = @(
    'proteus\README.md',
    'proteus\FINAL_CIRCUIT_CHECKLIST.md',
    'proteus\topic3_bom.csv',
    'proteus\topic3_gui_build_steps.md',
    'proteus\topic3_car_wiring.csv',
    'proteus\topic3_echo_test_inputs.csv',
    'proteus\reference_samples.md',
    'output\video\demo_storyboard.md',
    'tools\start_final_proteus_session.ps1',
    'tools\check_final_submission.ps1',
    $docProteusInvestigation
)

foreach ($file in $requiredFiles) {
    Assert-PathExists -RelativePath $file
}

$wiringPath = Join-Path $root 'proteus\topic3_car_wiring.csv'
$wiring = Import-Csv -LiteralPath $wiringPath
if ($wiring.Count -lt 80) {
    throw "Wiring table is unexpectedly small: $($wiring.Count) rows"
}
Assert-Columns -Row $wiring[0] -Columns @('block','ref','part','proteus_part','pin','net','connects_to','setting','required') -Path 'proteus\topic3_car_wiring.csv'

$requiredNets = @(
    'LED0_DRV','LED1_DRV','LED2_DRV','LED3_DRV','LED4_DRV','LED5_DRV','LED6_DRV','LED7_DRV',
    'KEY_UP_N','KEY_DOWN_N','KEY_START_N','KEY_MODE_N',
    'US_TRIG','US_ECHO',
    'LCD_RS','LCD_EN','LCD_D4','LCD_D5','LCD_D6','LCD_D7',
    'L_IN1','L_IN2','R_IN1','R_IN2','L_EN','R_EN',
    'L_MOTOR_A','L_MOTOR_B','R_MOTOR_A','R_MOTOR_B',
    'VCC_5V','MOTOR_VCC','GND','XTAL1','XTAL2','RESET'
)

foreach ($net in $requiredNets) {
    if (-not ($wiring | Where-Object { $_.net -eq $net })) {
        throw "Wiring table lacks required net: $net"
    }
}
Write-Host ("OK   wiring nets: {0}" -f $requiredNets.Count)

$requiredRefs = @(
    'U1','U2','U3','U4','D1','D2','D3','D4','D5','D6','D7','D8',
    'SW1','SW2','SW3','SW4','M1','M2','Y1','R1','R8','R9','R12'
)

foreach ($ref in $requiredRefs) {
    if (-not ($wiring | Where-Object { $_.ref -eq $ref })) {
        throw "Wiring table lacks required reference: $ref"
    }
}
Write-Host ("OK   wiring refs: {0}" -f $requiredRefs.Count)

$echoPath = Join-Path $root 'proteus\topic3_echo_test_inputs.csv'
$echo = Import-Csv -LiteralPath $echoPath
Assert-Columns -Row $echo[0] -Columns @('scenario','source_mode','initial_delay_us','high_time_us','period_us','estimated_distance_cm','expected_lcd','expected_motor','notes') -Path 'proteus\topic3_echo_test_inputs.csv'

foreach ($scenario in @('no_echo','danger_500us','threshold_870us','safe_2000us')) {
    if (-not ($echo | Where-Object { $_.scenario -eq $scenario })) {
        throw "Echo test table lacks scenario: $scenario"
    }
}

$danger = $echo | Where-Object { $_.scenario -eq 'danger_500us' } | Select-Object -First 1
$threshold = $echo | Where-Object { $_.scenario -eq 'threshold_870us' } | Select-Object -First 1
$safe = $echo | Where-Object { $_.scenario -eq 'safe_2000us' } | Select-Object -First 1
if ([int]$danger.high_time_us -ge 870) {
    throw "Danger Echo width must be shorter than 870 us"
}
if ([int]$threshold.high_time_us -ne 870) {
    throw "Threshold Echo width must be 870 us"
}
if ([int]$safe.high_time_us -le 870) {
    throw "Safe Echo width must be wider than 870 us"
}
Write-Host "OK   echo scenarios: no_echo danger threshold safe"

$bomPath = Join-Path $root 'proteus\topic3_bom.csv'
$bom = Import-Csv -LiteralPath $bomPath
Assert-Columns -Row $bom[0] -Columns @('ref','qty','proteus_search','description','value_or_setting','required','notes') -Path 'proteus\topic3_bom.csv'
foreach ($ref in @('U1','U2','U3','U4','V1','D1-D8','SW1','SW2','SW3','SW4','M1','M2','Y1','VS1','VS2','GND')) {
    if (-not ($bom | Where-Object { $_.ref -eq $ref })) {
        throw "BOM lacks required item: $ref"
    }
}
Write-Host "OK   BOM core items"

Assert-TextContains -RelativePath 'proteus\README.md' -Needles @(
    'proteus/topic3_bom.csv',
    'proteus/topic3_gui_build_steps.md',
    'proteus/topic3_car_wiring.csv',
    'proteus/topic3_echo_test_inputs.csv',
    'proteus/reference_samples.md'
)
Assert-TextContains -RelativePath 'proteus\FINAL_CIRCUIT_CHECKLIST.md' -Needles @(
    'proteus/topic3_bom.csv',
    'proteus/topic3_gui_build_steps.md',
    'proteus/topic3_car_wiring.csv',
    'proteus/topic3_echo_test_inputs.csv'
)
Assert-TextContains -RelativePath 'output\video\demo_storyboard.md' -Needles @(
    '0-3 s',
    '3-6 s',
    '9-13 s',
    '13-17 s',
    'tools\start_final_proteus_session.ps1',
    'tools\check_final_submission.ps1',
    'output/video/demo.mp4'
)
Assert-TextContains -RelativePath 'tools\start_final_proteus_session.ps1' -Needles @(
    'firmware\build.ps1',
    'check_topic3_proteus_plan.ps1',
    'topic3_car.pdsprj',
    'PDS.EXE'
)
Assert-TextContains -RelativePath 'tools\check_final_submission.ps1' -Needles @(
    'check_deliverables.ps1',
    'topic3_car.pdsprj',
    'demo.mp4',
    'ffprobe'
)
Assert-TextContains -RelativePath $docProteusInvestigation -Needles @(
    'ROOT.DSN',
    'topic3_car.pdsprj',
    'tools/check_topic3_proteus_plan.ps1'
)

Write-Host "Topic 3 Proteus plan files are internally consistent."
