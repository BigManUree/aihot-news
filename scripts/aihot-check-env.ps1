# AIHOT Environment Check Script

. (Join-Path $PSScriptRoot "aihot-utils.ps1")

function Invoke-EnvironmentCheck {
    $allPassed = $true

    Write-Header "AIHOT Startup Check"

    # 1. Check project directory
    if (Test-Path (Join-Path $script:PROJECT_ROOT "package.json")) {
        Write-Success "Project directory correct: $script:PROJECT_ROOT"
    } else {
        Write-Error "Project directory incorrect, package.json not found"
        $allPassed = $false
    }

    # 2. Check Node.js
    try {
        $nodeVersion = & node --version 2>&1
        if ($nodeVersion -match '^v(\d+)\.') {
            $majorVersion = [int]$matches[1]
            if ($majorVersion -ge 22) {
                Write-Success "Node.js installed: $nodeVersion"
            } else {
                Write-Error "Node.js version too low: $nodeVersion (requires >= 22)"
                $allPassed = $false
            }
        } else {
            Write-Error "Node.js version detection failed: $nodeVersion"
            $allPassed = $false
        }
    } catch {
        Write-Error "Node.js not installed or not in PATH"
        $allPassed = $false
    }

    # 3. Check npm
    try {
        $npmVersion = & npm --version 2>&1
        Write-Success "npm installed: v$npmVersion"
    } catch {
        Write-Error "npm not installed or not in PATH"
        $allPassed = $false
    }

    # 4. Check node_modules
    if (Test-Path (Join-Path $script:PROJECT_ROOT "node_modules")) {
        Write-Success "node_modules exists"
    } else {
        Write-Warning "node_modules missing, run: npm install"
        $allPassed = $false
    }

    # 5. Check .env
    $envFile = Join-Path $script:PROJECT_ROOT ".env"
    if (Test-Path $envFile) {
        Write-Success ".env config file exists"

        # Check key configs
        $dbUrl = Read-EnvValue "DATABASE_URL"
        $llmKey = Read-EnvValue "LLM_API_KEY"
        $collectEnabled = Read-EnvValue "COLLECT_ENABLED"
        $modelCallsEnabled = Read-EnvValue "MODEL_CALLS_ENABLED"

        if ($dbUrl) {
            Write-Success "DATABASE_URL configured"
        } else {
            Write-Error "DATABASE_URL not configured"
            $allPassed = $false
        }

        if ($llmKey) {
            $maskedKey = $llmKey.Substring(0, [Math]::Min(8, $llmKey.Length)) + "..."
            Write-Success "LLM_API_KEY configured: $maskedKey"
        } else {
            Write-Error "LLM_API_KEY not configured"
            $allPassed = $false
        }

        if ($collectEnabled -eq "true") {
            Write-Success "COLLECT_ENABLED=true"
        } else {
            Write-Warning "COLLECT_ENABLED=$collectEnabled (collection disabled)"
        }

        if ($modelCallsEnabled -eq "true") {
            Write-Success "MODEL_CALLS_ENABLED=true"
        } else {
            Write-Warning "MODEL_CALLS_ENABLED=$modelCallsEnabled (model calls disabled)"
        }
    } else {
        Write-Error ".env config file missing"
        Write-Host "    Copy .env.example to .env and configure"
        $allPassed = $false
    }

    # 6. Check PostgreSQL
    $dbUrl = Read-EnvValue "DATABASE_URL"
    if ($dbUrl) {
        if (Test-PostgresConnection $dbUrl) {
            Write-Success "PostgreSQL connection OK"

            # Check database and tables
            try {
                $env:DATABASE_URL = $dbUrl
                $scriptPath = Join-Path $PSScriptRoot "aihot-check-db.cjs"
                $result = & node $scriptPath 2>&1 | Select-String -Pattern '^\{' | ForEach-Object { $_.Line }
                $dbInfo = $result | ConvertFrom-Json
                Write-Success "Database connected: $($dbInfo.database)"
                if ($dbInfo.hasTable) {
                    Write-Success "articles table exists"
                } else {
                    Write-Warning "articles table missing, run migrations first"
                }
            } catch {
                Write-Warning "Database check failed: $($_.Exception.Message)"
            }
        } else {
            Write-Error "PostgreSQL connection failed"
            Write-Host "    Please check:"
            Write-Host "    1. PostgreSQL service running"
            Write-Host "    2. 127.0.0.1:5432 accessible"
            Write-Host "    3. Database config correct"
            $allPassed = $false
        }
    }

    # 7. Check ports
    if (Test-PortAvailable $script:API_PORT) {
        Write-Success "API port $script:API_PORT available"
    } else {
        $proc = Get-PortProcess $script:API_PORT
        if ($proc) {
            Write-Error "API port $script:API_PORT occupied (PID: $($proc.Id), process: $($proc.ProcessName))"
        } else {
            Write-Error "API port $script:API_PORT occupied"
        }
        $allPassed = $false
    }

    if (Test-PortAvailable $script:WEB_PORT) {
        Write-Success "Web port $script:WEB_PORT available"
    } else {
        $proc = Get-PortProcess $script:WEB_PORT
        if ($proc) {
            Write-Error "Web port $script:WEB_PORT occupied (PID: $($proc.Id), process: $($proc.ProcessName))"
        } else {
            Write-Error "Web port $script:WEB_PORT occupied"
        }
        $allPassed = $false
    }

    Write-Host ""
    if ($allPassed) {
        Write-Success "Environment check passed, ready to start services..."
        return $true
    } else {
        Write-Error "Environment check failed, fix issues above and retry"
        return $false
    }
}

# If run directly
if ($MyInvocation.InvocationName -ne '.') {
    $result = Invoke-EnvironmentCheck
    if (-not $result) {
        Wait-KeyPress "Press any key to exit..."
        exit 1
    }
}
