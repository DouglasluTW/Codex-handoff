param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('TASK','CLAIM','STATUS','REQUEST','RESULT','DONE','BLOCKED')]
    [string]$Type,

    [Parameter(Mandatory = $true)]
    [string]$Task,

    [string]$Machine = $env:COMPUTERNAME,

    [Parameter(Mandatory = $true)]
    [string]$Body,

    [string[]]$Artifacts = @(),

    [string]$Next = 'none'
)

if ([string]::IsNullOrWhiteSpace($Machine)) {
    $Machine = 'PC-A'
}

$timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:sszzz")

Write-Output 'HANDOFF:'
Write-Output "TYPE: $Type"
Write-Output "TASK: $Task"
Write-Output "MACHINE: $Machine"
Write-Output "TIME: $timestamp"
Write-Output 'BODY:'
Write-Output $Body
Write-Output 'ARTIFACTS:'
if ($Artifacts.Count -eq 0) {
    Write-Output '- none'
} else {
    foreach ($artifact in $Artifacts) {
        Write-Output "- $artifact"
    }
}
Write-Output 'NEXT:'
Write-Output $Next
Write-Output 'END_HANDOFF'
