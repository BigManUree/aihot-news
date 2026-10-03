# AIHOT 日志查看脚本

. (Join-Path $PSScriptRoot "aihot-utils.ps1")

function Show-AihotLogs {
    Write-Host ""
    Write-Host "请选择要查看的日志：" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] API    - $script:API_LOG"
    Write-Host "  [2] Web    - $script:WEB_LOG"
    Write-Host "  [3] Worker - $script:WORKER_LOG"
    Write-Host "  [4] 全部（同时显示三个日志）"
    Write-Host "  [0] 退出"
    Write-Host ""

    $choice = Read-Host "请输入选项 (0-4)"

    switch ($choice) {
        "1" {
            Watch-LogFile $script:API_LOG "API"
        }
        "2" {
            Watch-LogFile $script:WEB_LOG "Web"
        }
        "3" {
            Watch-LogFile $script:WORKER_LOG "Worker"
        }
        "4" {
            Watch-AllLogs
        }
        "0" {
            Write-Info "退出"
            return
        }
        default {
            Write-Error "无效选项"
            return
        }
    }
}

function Watch-LogFile {
    param(
        [string]$LogPath,
        [string]$ServiceName
    )

    if (-not (Test-Path $LogPath)) {
        Write-Error "日志文件不存在：$LogPath"
        return
    }

    Write-Host ""
    Write-Header "查看 $ServiceName 日志"
    Write-Info "文件：$LogPath"
    Write-Info "按 Ctrl+C 退出"
    Write-Host ""

    # 先显示最后 50 行
    Get-Content $LogPath -Tail 50

    # 然后实时追踪
    Write-Host ""
    Write-Host "--- 以下为实时日志 ---" -ForegroundColor Yellow
    Write-Host ""
    Get-Content $LogPath -Wait -Tail 0
}

function Watch-AllLogs {
    Write-Host ""
    Write-Header "查看所有日志"
    Write-Info "按 Ctrl+C 退出"
    Write-Host ""

    $logs = @(
        @{ Name = "API"; Path = $script:API_LOG },
        @{ Name = "Web"; Path = $script:WEB_LOG },
        @{ Name = "Worker"; Path = $script:WORKER_LOG }
    )

    # 先显示每个日志的最后 20 行
    foreach ($log in $logs) {
        if (Test-Path $log.Path) {
            Write-Host "=== $($log.Name) ===" -ForegroundColor Cyan
            Get-Content $log.Path -Tail 20
            Write-Host ""
        }
    }

    Write-Host "--- 以下为实时日志 ---" -ForegroundColor Yellow
    Write-Host ""

    # 实时追踪所有日志
    $jobs = @()
    foreach ($log in $logs) {
        if (Test-Path $log.Path) {
            $job = Start-Job -ScriptBlock {
                param($path, $name)
                Get-Content $path -Wait -Tail 0 | ForEach-Object {
                    "[$name] $_"
                }
            } -ArgumentList $log.Path, $log.Name
            $jobs += $job
        }
    }

    try {
        while ($true) {
            foreach ($job in $jobs) {
                $output = Receive-Job $job -ErrorAction SilentlyContinue
                if ($output) {
                    $output | ForEach-Object { Write-Host $_ }
                }
            }
            Start-Sleep -Milliseconds 100
        }
    } finally {
        $jobs | Stop-Job -ErrorAction SilentlyContinue
        $jobs | Remove-Job -ErrorAction SilentlyContinue
    }
}

# 如果直接运行此脚本
if ($MyInvocation.InvocationName -ne '.') {
    Show-AihotLogs
}
