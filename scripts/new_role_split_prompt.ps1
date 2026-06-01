param(
    [Parameter(Mandatory = $true)]
    [string]$Objective,

    [string]$Context = 'none',

    [string[]]$AvailableTools = @(),

    [string[]]$SafetyPolicy = @(),

    [string[]]$Verification = @(),

    [string[]]$StopConditions = @()
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

Write-Output 'Please divide this task before execution.'
Write-Output ''
Write-Output "OBJECTIVE: $Objective"
Write-Output "CONTEXT: $Context"
Write-Output 'AVAILABLE_TOOLS:'
Write-List -Items $AvailableTools
Write-Output 'SAFETY_POLICY:'
Write-List -Items $SafetyPolicy
Write-Output 'REQUESTED_VERIFICATION:'
Write-List -Items $Verification
Write-Output 'KNOWN_STOP_CONDITIONS:'
Write-List -Items $StopConditions
Write-Output ''
Write-Output 'Return exactly this structure:'
Write-Output 'ROLE_SPLIT:'
Write-Output 'CHATGPT_ROLE:'
Write-Output '- reasoning, generation, review, or none'
Write-Output 'CODEX_ROLE:'
Write-Output '- local execution, files, code, Git, validation, or none'
Write-Output 'USER_ROLE:'
Write-Output '- approvals, preferences, missing input, or none'
Write-Output 'TOOLS:'
Write-Output '- tool and purpose, or none'
Write-Output 'VERIFICATION:'
Write-Output '- check or acceptance criterion'
Write-Output 'STOP_CONDITIONS:'
Write-Output '- condition requiring pause or approval'
Write-Output 'END_ROLE_SPLIT'
