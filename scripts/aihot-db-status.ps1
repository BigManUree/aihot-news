# AIHOT 数据库状态脚本

. (Join-Path $PSScriptRoot "aihot-utils.ps1")

function Show-DatabaseStatus {
    Write-Header "AIHOT DATABASE"

    $dbUrl = Read-EnvValue "DATABASE_URL"
    if (-not $dbUrl) {
        Write-Error "DATABASE_URL 未配置"
        return
    }

    # 提取数据库名
    if ($dbUrl -match '/([^/]+)\?') {
        $dbName = $matches[1]
    } elseif ($dbUrl -match '/([^/]+)$') {
        $dbName = $matches[1]
    } else {
        $dbName = "Unknown"
    }

    Write-Host "Database:" -ForegroundColor Cyan
    Write-Host "  $dbName"
    Write-Host ""

    # 检查连接
    if (-not (Test-PostgresConnection $dbUrl)) {
        Write-Error "PostgreSQL 连接失败"
        Write-Host "  请检查数据库服务是否启动"
        return
    }

    Write-Success "PostgreSQL 连接正常"
    Write-Host ""

    # 获取统计信息
    $stats = Get-DatabaseStats $dbUrl
    if ($stats) {
        Write-Host "Statistics:" -ForegroundColor Cyan
        Write-Host "  Items    : $($stats.items)"
        Write-Host "  Selected : $($stats.selected)"
        Write-Host "  Sources  : $($stats.sources)"
        Write-Host "  Latest   : $($stats.latest)"
    } else {
        Write-Warning "无法获取数据库统计信息"
    }

    # 显示表结构信息
    Write-Host ""
    Write-Host "Tables:" -ForegroundColor Cyan
    try {
        $env:DATABASE_URL = $dbUrl
        $scriptPath = Join-Path $PSScriptRoot "aihot-db-tables.cjs"
        $result = & node $scriptPath 2>&1
        $result | ForEach-Object { Write-Host $_ }
    } catch {
        Write-Warning "无法获取表列表"
    }
}

# 如果直接运行此脚本
if ($MyInvocation.InvocationName -ne '.') {
    Show-DatabaseStatus
    Write-Host ""
    Wait-KeyPress "按任意键退出..."
}
