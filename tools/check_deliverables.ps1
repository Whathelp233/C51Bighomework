param(
    [switch]$Final
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

function New-UnicodeName {
    param([int[]]$Codes)
    return (-join ($Codes | ForEach-Object { [char]$_ }))
}

$docDesignDraft = Join-Path 'docs' (New-UnicodeName @(0x8BFE,0x7A0B,0x8BBE,0x8BA1,0x8BF4,0x660E,0x4E66,0x005F,0x8BFE,0x9898,0x0033,0x005F,0x521D,0x7A3F,0x002E,0x006D,0x0064))
$docProjectDesign = Join-Path 'docs' (New-UnicodeName @(0x8BFE,0x9898,0x0033,0x9879,0x76EE,0x8BBE,0x8BA1,0x6587,0x6863,0x002E,0x006D,0x0064))
$docRequirementMatrix = Join-Path 'docs' (New-UnicodeName @(0x9700,0x6C42,0x5B9E,0x73B0,0x77E9,0x9635,0x002E,0x006D,0x0064))
$docAssemblyNotes = Join-Path 'docs' (New-UnicodeName @(0x6C47,0x7F16,0x7A0B,0x5E8F,0x6E05,0x5355,0x4E0E,0x6A21,0x5757,0x8BF4,0x660E,0x002E,0x006D,0x0064))
$docSubmission = Join-Path 'docs' (New-UnicodeName @(0x63D0,0x4EA4,0x6750,0x6599,0x4E0E,0x7B54,0x8FA9,0x811A,0x672C,0x002E,0x006D,0x0064))
$docSimulationRecord = Join-Path 'docs' (New-UnicodeName @(0x4EFF,0x771F,0x6D4B,0x8BD5,0x8BB0,0x5F55,0x002E,0x006D,0x0064))
$docDatasheetIndex = Join-Path 'docs' (New-UnicodeName @(0x5668,0x4EF6,0x624B,0x518C,0x7D22,0x5F15,0x002E,0x006D,0x0064))
$docProteusInvestigation = Join-Path 'docs' ('proteus' + (New-UnicodeName @(0x81EA,0x52A8,0x751F,0x6210,0x53EF,0x884C,0x6027,0x8C03,0x67E5,0x002E,0x006D,0x0064)))

$checks = @(
    @{ Name = 'Design document draft'; Path = $docDesignDraft; Required = $true },
    @{ Name = 'Project design document'; Path = $docProjectDesign; Required = $true },
    @{ Name = 'Requirement matrix'; Path = $docRequirementMatrix; Required = $true },
    @{ Name = 'Assembly module notes'; Path = $docAssemblyNotes; Required = $true },
    @{ Name = 'Submission and defense script'; Path = $docSubmission; Required = $true },
    @{ Name = 'Simulation record template'; Path = $docSimulationRecord; Required = $true },
    @{ Name = 'Datasheet index'; Path = $docDatasheetIndex; Required = $true },
    @{ Name = 'Assembly source'; Path = 'firmware\asm\topic3_car.a51'; Required = $true },
    @{ Name = 'Build script'; Path = 'firmware\build.ps1'; Required = $true },
    @{ Name = 'Generated HEX'; Path = 'build\topic3_car.hex'; Required = $true },
    @{ Name = 'Proteus guide'; Path = 'proteus\README.md'; Required = $true },
    @{ Name = 'Proteus final checklist'; Path = 'proteus\FINAL_CIRCUIT_CHECKLIST.md'; Required = $true },
    @{ Name = 'Proteus BOM'; Path = 'proteus\topic3_bom.csv'; Required = $true },
    @{ Name = 'Proteus GUI build steps'; Path = 'proteus\topic3_gui_build_steps.md'; Required = $true },
    @{ Name = 'Proteus wiring table'; Path = 'proteus\topic3_car_wiring.csv'; Required = $true },
    @{ Name = 'Proteus Echo test inputs'; Path = 'proteus\topic3_echo_test_inputs.csv'; Required = $true },
    @{ Name = 'Proteus reference samples'; Path = 'proteus\reference_samples.md'; Required = $true },
    @{ Name = 'Proteus auto-generation investigation'; Path = $docProteusInvestigation; Required = $true },
    @{ Name = 'Proteus plan check script'; Path = 'tools\check_topic3_proteus_plan.ps1'; Required = $true },
    @{ Name = 'Final Proteus session launcher'; Path = 'tools\start_final_proteus_session.ps1'; Required = $true },
    @{ Name = 'Final submission check script'; Path = 'tools\check_final_submission.ps1'; Required = $true },
    @{ Name = 'Demo video storyboard'; Path = 'output\video\demo_storyboard.md'; Required = $true },
    @{ Name = 'Final Proteus project'; Path = 'proteus\topic3_car.pdsprj'; Required = [bool]$Final },
    @{ Name = '20-second demo video'; Path = 'output\video\demo.mp4'; Required = [bool]$Final }
)

$missingRequired = 0
$missingOptional = 0

foreach ($check in $checks) {
    $fullPath = Join-Path $repoRoot $check.Path
    $exists = Test-Path -LiteralPath $fullPath
    if ($exists) {
        Write-Host ("OK      {0}: {1}" -f $check.Name, $check.Path)
    } elseif ($check.Required) {
        Write-Host ("MISSING {0}: {1}" -f $check.Name, $check.Path)
        $missingRequired++
    } else {
        Write-Host ("PENDING {0}: {1}" -f $check.Name, $check.Path)
        $missingOptional++
    }
}

if ($missingRequired -gt 0) {
    throw "$missingRequired required deliverable(s) missing for this check mode."
}

if ($missingOptional -gt 0) {
    Write-Host ("Draft/checkpoint package present. Pending final evidence: {0}" -f $missingOptional)
    Write-Host "Run with -Final to fail when final Proteus project or demo video is missing."
} else {
    Write-Host "All deliverables required for this check mode are present."
}
