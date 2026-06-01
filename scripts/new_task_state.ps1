param(
    [Parameter(Mandatory = $true)]
    [string]$Objective,

    [ValidateSet('LITE','STANDARD','AGENT')]
    [string]$Mode = 'AGENT',

    [Parameter(Mandatory = $true)]
    [string]$CurrentStep,

    [string]$Owner = 'Codex',

    [ValidateSet('planned','in_progress','waiting','blocked','complete')]
    [string]$Status = 'in_progress',

    [string[]]$RoleSplit = @(),

    [string]$ChatGPTCheckpoint = 'none',

    [string]$LastChatGPTUserInstruction = 'none',

    [ValidateSet('Codex','ChatGPT','Mobile','Unknown')]
    [string]$InstructionSource = 'Unknown',

    [ValidateSet('none','new','accepted','merged','blocked','superseded')]
    [string]$InstructionStatus = 'none',

    [string[]]$Artifacts = @(),

    [string[]]$Verification = @(),

    [string[]]$SafetyPolicy = @(
        'file_deletion: ask',
        'overwrite_existing_files: ask',
        'cleanup_generated_files: ask',
        'install_or_uninstall_scripts: ask',
        'send_email: ask',
        'public_posting: ask',
        'payment_actions: block',
        'browser_account_changes: ask',
        'expose_secrets: block'
    ),

    [string[]]$Blockers = @(),

    [Parameter(Mandatory = $true)]
    [string]$NextAction,

    [string[]]$StopConditions = @(),

    [ValidateSet('enough','low','unknown')]
    [string]$TokenBudget = 'unknown'
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

Write-Output 'TASK_STATE:'
Write-Output "OBJECTIVE: $Objective"
Write-Output "MODE: $Mode"
Write-Output "CURRENT_STEP: $CurrentStep"
Write-Output "OWNER: $Owner"
Write-Output "STATUS: $Status"
Write-Output 'ROLE_SPLIT:'
Write-List -Items $RoleSplit
Write-Output "CHATGPT_CHECKPOINT: $ChatGPTCheckpoint"
Write-Output "LAST_CHATGPT_USER_INSTRUCTION: $LastChatGPTUserInstruction"
Write-Output "INSTRUCTION_SOURCE: $InstructionSource"
Write-Output "INSTRUCTION_STATUS: $InstructionStatus"
Write-Output 'ARTIFACTS:'
Write-List -Items $Artifacts
Write-Output 'VERIFICATION:'
Write-List -Items $Verification
Write-Output 'SAFETY_POLICY:'
Write-List -Items $SafetyPolicy
Write-Output 'BLOCKERS:'
Write-List -Items $Blockers
Write-Output "NEXT_ACTION: $NextAction"
Write-Output 'STOP_CONDITIONS:'
Write-List -Items $StopConditions
Write-Output "TOKEN_BUDGET: $TokenBudget"
Write-Output 'END_TASK_STATE'
