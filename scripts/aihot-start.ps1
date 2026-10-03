# AIHOT Start Script

. (Join-Path $PSScriptRoot "aihot-utils.ps1")

function Start-AihotServices {
    # Environment check
    . (Join-Path $PSScriptRoot "aihot-check-env.ps1")
    $envOk = Invoke-EnvironmentCheck
    if (-not $envOk) {
        return $false
    }

    Write-Host ""

    # Check if services are already running
    $apiRunning = $false
    $webRunning = $false
    $workerRunning = $false

    $apiPid = Read-Pid $script:API_PID_FILE
    $webPid = Read-Pid $script:WEB_PID_FILE
    $workerPid = Read-Pid $script:WORKER_PID_FILE

    if ($apiPid -and (Test-ProcessRunning $apiPid)) { $apiRunning = $true }
    if ($webPid -and (Test-ProcessRunning $webPid)) { $webRunning = $true }
    if ($workerPid -and (Test-ProcessRunning $workerPid)) { $workerRunning = $true }

    if ($apiRunning -or $webRunning -or $workerRunning) {
        Write-Warning "AIHOT services are already running:"
        if ($apiRunning) { Write-Host "  API    : PID $apiPid" }
        if ($webRunning) { Write-Host "  Web    : PID $webPid" }
        if ($workerRunning) { Write-Host "  Worker : PID $workerPid" }
        Write-Host ""
        $confirm = Read-Host "Restart? (Y/N)"
        if ($confirm -ne 'Y' -and $confirm -ne 'y') {
            Write-Info "Start cancelled"
            return $false
        }

        # Stop existing services
        Write-Host ""
        Write-Info "Stopping existing services..."
        if ($apiRunning) { Stop-ServiceByPid "API" $script:API_PID_FILE | Out-Null }
        if ($webRunning) { Stop-ServiceByPid "Web" $script:WEB_PID_FILE | Out-Null }
        if ($workerRunning) { Stop-ServiceByPid "Worker" $script:WORKER_PID_FILE | Out-Null }
        Start-Sleep -Seconds 2
    }

    # Ensure log directory exists
    if (-not (Test-Path $script:DATA_DIR)) {
        New-Item -ItemType Directory -Path $script:DATA_DIR -Force | Out-Null
    }

    Write-Host ""
    Write-Header "Starting AIHOT Services"

    # Start API
    Write-Info "Starting API service (port $script:API_PORT)..."
    $apiProcess = Start-Process -FilePath "cmd.exe" `
        -ArgumentList "/c", "npm", "run", "dev:api" `
        -WorkingDirectory $script:PROJECT_ROOT `
        -RedirectStandardOutput $script:API_LOG `
        -RedirectStandardError (Join-Path $script:DATA_DIR "api-error.log") `
        -PassThru -WindowStyle Hidden

    Save-Pid $script:API_PID_FILE $apiProcess.Id
    Write-Success "API started (PID: $($apiProcess.Id))"

    # Wait for API health check
    Write-Info "Waiting for API to be ready..."
    if (Test-HttpHealth $script:API_HEALTH_URL $script:HEALTH_CHECK_TIMEOUT $script:HEALTH_CHECK_INTERVAL) {
        Write-Success "API health check passed"
    } else {
        Write-Error "API failed to start or health check timed out"
        Write-Host "    Check log: $script:API_LOG"
        Stop-ServiceByPid "API" $script:API_PID_FILE | Out-Null
        return $false
    }

    # Start Web
    Write-Info "Starting Web service (port $script:WEB_PORT)..."
    $webProcess = Start-Process -FilePath "cmd.exe" `
        -ArgumentList "/c", "npm", "run", "dev:web" `
        -WorkingDirectory $script:PROJECT_ROOT `
        -RedirectStandardOutput $script:WEB_LOG `
        -RedirectStandardError (Join-Path $script:DATA_DIR "web-error.log") `
        -PassThru -WindowStyle Hidden

    Save-Pid $script:WEB_PID_FILE $webProcess.Id
    Write-Success "Web started (PID: $($webProcess.Id))"

    # Wait for Web to be ready
    Write-Info "Waiting for Web to be ready..."
    if (Test-HttpHealth $script:WEB_URL $script:HEALTH_CHECK_TIMEOUT $script:HEALTH_CHECK_INTERVAL) {
        Write-Success "Web health check passed"
    } else {
        Write-Warning "Web health check timed out, but service may still be starting"
        Write-Host "    Check log: $script:WEB_LOG"
    }

    # Start Worker
    Write-Info "Starting Worker service..."
    $workerProcess = Start-Process -FilePath "cmd.exe" `
        -ArgumentList "/c", "npm", "run", "dev:worker" `
        -WorkingDirectory $script:PROJECT_ROOT `
        -RedirectStandardOutput $script:WORKER_LOG `
        -RedirectStandardError (Join-Path $script:DATA_DIR "worker-error.log") `
        -PassThru -WindowStyle Hidden

    Save-Pid $script:WORKER_PID_FILE $workerProcess.Id
    Write-Success "Worker started (PID: $($workerProcess.Id))"

    # Wait for Worker to start
    Start-Sleep -Seconds 3

    if (Test-ProcessRunning $workerProcess.Id) {
        Write-Success "Worker is running"
    } else {
        Write-Warning "Worker may have failed to start, check logs"
    }

    # Show final status
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "          AIHOT Started Successfully" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  PostgreSQL  " -NoNewline -ForegroundColor Cyan
    Write-Host "OK RUNNING" -ForegroundColor Green
    Write-Host "  API         " -NoNewline -ForegroundColor Cyan
    Write-Host "OK RUNNING " -NoNewline -ForegroundColor Green
    Write-Host ":$script:API_PORT" -ForegroundColor Yellow
    Write-Host "  Web         " -NoNewline -ForegroundColor Cyan
    Write-Host "OK RUNNING " -NoNewline -ForegroundColor Green
    Write-Host ":$script:WEB_PORT" -ForegroundColor Yellow
    Write-Host "  Worker      " -NoNewline -ForegroundColor Cyan
    Write-Host "OK RUNNING" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan

    # Show database stats
    $dbUrl = Read-EnvValue "DATABASE_URL"
    if ($dbUrl) {
        $stats = Get-DatabaseStats $dbUrl
        if ($stats) {
            Write-Host "  DB Items: $($stats.items)" -ForegroundColor White
            Write-Host "  Selected: $($stats.selected)" -ForegroundColor White
        }
    }

    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  Web   : http://127.0.0.1:$script:WEB_PORT" -ForegroundColor Yellow
    Write-Host "  API   : $script:API_HEALTH_URL" -ForegroundColor Yellow
    Write-Host "  Admin : http://127.0.0.1:$script:WEB_PORT/admin" -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan

    Write-Host ""
    Write-Info "Worker background tasks:"
    Write-Host "  - RSS/API content collection"
    Write-Host "  - AI content filtering"
    Write-Host "  - Hot topic scoring"
    Write-Host "  - Daily report generation"
    Write-Host ""
    Write-Info "First startup may take 5-10 minutes to produce new content"

    # Auto-open browser
    if ($script:AUTO_OPEN_BROWSER) {
        Write-Host ""
        Write-Info "Opening browser..."
        Start-Process $script:WEB_URL
    }

    return $true
}

# If run directly
if ($MyInvocation.InvocationName -ne '.') {
    $result = Start-AihotServices
    if ($result) {
        Wait-KeyPress "Press any key to exit this window (services will continue running)..."
    } else {
        Wait-KeyPress "Press any key to exit..."
        exit 1
    }
}
