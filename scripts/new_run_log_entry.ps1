param(
    [Parameter(Mandatory = $true)]
    [string]$Task,

    [Parameter(Mandatory = $true)]
    [string]$Step,

    [Parameter(Mandatory = $true)]
    [string]$Action,

    [Parameter(Mandatory = $true)]
    [string]$Result,

    [string[]]$Artifacts = @(),

    [string[]]$Verification = @(),

    [Parameter(Mandatory = $true)]
    [string]$NextAction
)

function Write-List {
    param(
        [string[]]$Items
    )

    $written = $false

    if ($Items.Count -eq 0) {
        Write-Output '- none'
        return
    }

    foreach ($item in $Items) {
        if ([string]::IsNullOrWhiteSpace($item)) {
            continue
        }
        Write-Output "- $item"
        $written = $true
    }

    if (-not $written) {
        Write-Output '- none'
    }
}

$timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:sszzz")

Write-Output 'RUN_LOG_ENTRY:'
Write-Output "TIME: $timestamp"
Write-Output "TASK: $Task"
Write-Output "STEP: $Step"
Write-Output "ACTION: $Action"
Write-Output "RESULT: $Result"
Write-Output 'ARTIFACTS:'
Write-List -Items $Artifacts
Write-Output 'VERIFICATION:'
Write-List -Items $Verification
Write-Output "NEXT_ACTION: $NextAction"
Write-Output 'END_RUN_LOG_ENTRY'
