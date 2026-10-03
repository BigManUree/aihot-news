# AIHOT Stop Script

. (Join-Path $PSScriptRoot "aihot-utils.ps1")

function Stop-AihotServices {
    Write-Header "Stopping AIHOT"

    $stoppedAny = $false

    # Stop Web
    Write-Info "Stopping Web..."
    if (Stop-ServiceByPid "Web" $script:WEB_PID_FILE) {
        $stoppedAny = $true
    }

    # Stop API
    Write-Info "Stopping API..."
    if (Stop-ServiceByPid "API" $script:API_PID_FILE) {
        $stoppedAny = $true
    }

    # Stop Worker
    Write-Info "Stopping Worker..."
    if (Stop-ServiceByPid "Worker" $script:WORKER_PID_FILE) {
        $stoppedAny = $true
    }

    Write-Host ""
    if ($stoppedAny) {
        Write-Success "All AIHOT services stopped"
    } else {
        Write-Info "No AIHOT services were running"
    }

    return $true
}

# If run directly
if ($MyInvocation.InvocationName -ne '.') {
    Stop-AihotServices
    Wait-KeyPress "Press any key to exit..."
}
