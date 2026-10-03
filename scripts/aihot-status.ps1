# AIHOT Status Script

. (Join-Path $PSScriptRoot "aihot-utils.ps1")

function Show-AihotStatus {
    Write-Header "AIHOT STATUS"

    # PostgreSQL
    $dbUrl = Read-EnvValue "DATABASE_URL"
    $pgStatus = "X"
    $pgColor = "Red"
    if ($dbUrl -and (Test-PostgresConnection $dbUrl)) {
        $pgStatus = "OK"
        $pgColor = "Green"
    }

    # API
    $apiPid = Read-Pid $script:API_PID_FILE
    $apiStatus = "X"
    $apiColor = "Red"
    $apiInfo = ""
    if ($apiPid -and (Test-ProcessRunning $apiPid)) {
        if (Test-HttpHealth $script:API_HEALTH_URL 5 1) {
            $apiStatus = "OK"
            $apiColor = "Green"
            $apiInfo = ":$script:API_PORT"
        }
    }

    # Web
    $webPid = Read-Pid $script:WEB_PID_FILE
    $webStatus = "X"
    $webColor = "Red"
    $webInfo = ""
    if ($webPid -and (Test-ProcessRunning $webPid)) {
        if (Test-HttpHealth $script:WEB_URL 5 1) {
            $webStatus = "OK"
            $webColor = "Green"
            $webInfo = ":$script:WEB_PORT"
        }
    }

    # Worker
    $workerPid = Read-Pid $script:WORKER_PID_FILE
    $workerStatus = "X"
    $workerColor = "Red"
    if ($workerPid -and (Test-ProcessRunning $workerPid)) {
        $workerStatus = "OK"
        $workerColor = "Green"
    }

    # Display status
    Write-Host "PostgreSQL : " -NoNewline
    Write-Host $pgStatus -ForegroundColor $pgColor -NoNewline
    if ($pgColor -eq "Green") { Write-Host " RUNNING" -ForegroundColor Green } else { Write-Host " STOPPED" -ForegroundColor Red }

    Write-Host "API        : " -NoNewline
    Write-Host $apiStatus -ForegroundColor $apiColor -NoNewline
    if ($apiColor -eq "Green") {
        Write-Host " RUNNING" -ForegroundColor Green -NoNewline
        Write-Host $apiInfo -ForegroundColor Yellow
    } else {
        Write-Host " STOPPED" -ForegroundColor Red
    }

    Write-Host "Web        : " -NoNewline
    Write-Host $webStatus -ForegroundColor $webColor -NoNewline
    if ($webColor -eq "Green") {
        Write-Host " RUNNING" -ForegroundColor Green -NoNewline
        Write-Host $webInfo -ForegroundColor Yellow
    } else {
        Write-Host " STOPPED" -ForegroundColor Red
    }

    Write-Host "Worker     : " -NoNewline
    Write-Host $workerStatus -ForegroundColor $workerColor -NoNewline
    if ($workerColor -eq "Green") { Write-Host " RUNNING" -ForegroundColor Green } else { Write-Host " STOPPED" -ForegroundColor Red }

    # Display PIDs
    Write-Host ""
    Write-Host "PID:" -ForegroundColor Cyan
    if ($apiPid) {
        Write-Host "  API    : $apiPid"
    } else {
        Write-Host "  API    : -" -ForegroundColor Gray
    }
    if ($webPid) {
        Write-Host "  Web    : $webPid"
    } else {
        Write-Host "  Web    : -" -ForegroundColor Gray
    }
    if ($workerPid) {
        Write-Host "  Worker : $workerPid"
    } else {
        Write-Host "  Worker : -" -ForegroundColor Gray
    }

    # Display URLs
    Write-Host ""
    Write-Host "URL:" -ForegroundColor Cyan
    Write-Host "  Web    : http://127.0.0.1:$script:WEB_PORT"
    Write-Host "  API    : $script:API_HEALTH_URL"
    Write-Host "  Admin  : http://127.0.0.1:$script:WEB_PORT/admin"

    # Database stats
    if ($dbUrl -and (Test-PostgresConnection $dbUrl)) {
        $stats = Get-DatabaseStats $dbUrl
        if ($stats) {
            Write-Host ""
            Write-Host "Database:" -ForegroundColor Cyan
            Write-Host "  Items    : $($stats.items)"
            Write-Host "  Selected : $($stats.selected)"
            Write-Host "  Sources  : $($stats.sources)"
            Write-Host "  Latest   : $($stats.latest)"
        }
    }
}

# If run directly
if ($MyInvocation.InvocationName -ne '.') {
    Show-AihotStatus
    Write-Host ""
    Wait-KeyPress "Press any key to exit..."
}
