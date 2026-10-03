# AIHOT Utility Functions

. (Join-Path $PSScriptRoot "aihot-config.ps1")

function Write-Header {
    param([string]$Title)
    $width = 50
    $line = "=" * $width
    Write-Host ""
    Write-Host $line -ForegroundColor Cyan
    $padding = [math]::Max(0, ($width - $Title.Length) / 2)
    Write-Host (" " * $padding + $Title) -ForegroundColor Cyan
    Write-Host $line -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERR] " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] " -ForegroundColor Cyan -NoNewline
    Write-Host $Message
}

function Test-PortAvailable {
    param([int]$Port)
    $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return -not $connections
}

function Get-PortProcess {
    param([int]$Port)
    $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($connections) {
        $processId = $connections[0].OwningProcess
        try {
            return Get-Process -Id $processId -ErrorAction SilentlyContinue
        } catch {
            return $null
        }
    }
    return $null
}

function Test-ProcessRunning {
    param([int]$ProcessId)
    try {
        $proc = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
        return $null -ne $proc
    } catch {
        return $false
    }
}

function Save-Pid {
    param(
        [string]$PidFile,
        [int]$ProcessId
    )
    $pidDir = Split-Path -Parent $PidFile
    if (-not (Test-Path $pidDir)) {
        New-Item -ItemType Directory -Path $pidDir -Force | Out-Null
    }
    # Write UTF8 without BOM
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($PidFile, $ProcessId.ToString(), $utf8NoBom)
}

function Read-Pid {
    param([string]$PidFile)
    if (Test-Path $PidFile) {
        $content = Get-Content $PidFile -Raw
        if ($content -match '^\d+$') {
            return [int]$content.Trim()
        }
    }
    return $null
}

function Remove-PidFile {
    param([string]$PidFile)
    if (Test-Path $PidFile) {
        Remove-Item $PidFile -Force
    }
}

function Stop-ServiceByPid {
    param(
        [string]$ServiceName,
        [string]$PidFile
    )
    $processId = Read-Pid $PidFile
    if (-not $processId) {
        Write-Warning "$ServiceName not running (PID file missing)"
        return $false
    }

    if (Test-ProcessRunning $processId) {
        try {
            $proc = Get-Process -Id $processId
            $proc.Kill()
            $proc.WaitForExit(5000)

            if (Test-ProcessRunning $processId) {
                Stop-Process -Id $processId -Force
                Start-Sleep -Seconds 1
            }

            Remove-PidFile $PidFile
            Write-Success "$ServiceName stopped (PID: $processId)"
            return $true
        } catch {
            Write-Error "Failed to stop ${ServiceName}: $($_.Exception.Message)"
            return $false
        }
    } else {
        Write-Warning "$ServiceName process (PID: $processId) no longer exists, cleaning PID file"
        Remove-PidFile $PidFile
        return $false
    }
}

function Test-HttpHealth {
    param(
        [string]$Url,
        [int]$TimeoutSeconds = 30,
        [int]$IntervalSeconds = 2
    )
    $startTime = Get-Date
    while (((Get-Date) - $startTime).TotalSeconds -lt $TimeoutSeconds) {
        try {
            $response = Invoke-WebRequest -Uri $Url -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                return $true
            }
        } catch {
            # Continue retry
        }
        Start-Sleep -Seconds $IntervalSeconds
    }
    return $false
}

function Test-PostgresConnection {
    param([string]$ConnectionString)
    try {
        $env:DATABASE_URL = $ConnectionString
        $scriptPath = Join-Path $PSScriptRoot "aihot-check-pg.cjs"
        $result = & node $scriptPath 2>&1
        return $result -match 'OK'
    } catch {
        return $false
    }
}

function Get-DatabaseStats {
    param([string]$ConnectionString)
    try {
        $env:DATABASE_URL = $ConnectionString
        $scriptPath = Join-Path $PSScriptRoot "aihot-db-stats.cjs"
        $result = & node $scriptPath 2>&1 | Select-String -Pattern '^\{' | ForEach-Object { $_.Line }
        return $result | ConvertFrom-Json
    } catch {
        return $null
    }
}

function Read-EnvValue {
    param([string]$Key)
    $envFile = Join-Path $script:PROJECT_ROOT ".env"
    if (Test-Path $envFile) {
        $content = Get-Content $envFile -Encoding UTF8
        foreach ($line in $content) {
            if ($line -match "^\s*$Key\s*=\s*(.+)$") {
                return $matches[1].Trim()
            }
        }
    }
    return $null
}

function Wait-KeyPress {
    param([string]$Message = "Press any key to continue...")
    Write-Host ""
    Write-Host $Message -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
