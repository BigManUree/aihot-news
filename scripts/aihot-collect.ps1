# AIHOT 手动采集脚本

. (Join-Path $PSScriptRoot "aihot-utils.ps1")

function Invoke-ManualCollect {
    Write-Header "手动采集"

    # 检查环境
    $dbUrl = Read-EnvValue "DATABASE_URL"
    if (-not $dbUrl) {
        Write-Error "DATABASE_URL 未配置"
        return $false
    }

    if (-not (Test-PostgresConnection $dbUrl)) {
        Write-Error "PostgreSQL 连接失败"
        return $false
    }

    Write-Success "环境检查通过"
    Write-Host ""

    # 执行采集
    Write-Info "正在执行采集..."
    Write-Host ""

    $collectScript = Join-Path $script:PROJECT_ROOT "scripts" "collect.ts"
    if (-not (Test-Path $collectScript)) {
        Write-Error "采集脚本不存在：$collectScript"
        return $false
    }

    try {
        # 运行采集脚本
        & node --env-file-if-exists=.env $collectScript

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Success "采集完成"

            # 显示数据库统计
            $stats = Get-DatabaseStats $dbUrl
            if ($stats) {
                Write-Host ""
                Write-Host "当前数据库状态：" -ForegroundColor Cyan
                Write-Host "  Items   : $($stats.items)"
                Write-Host "  Selected: $($stats.selected)"
                Write-Host "  Sources : $($stats.sources)"
            }

            return $true
        } else {
            Write-Error "采集失败（退出码：$LASTEXITCODE）"
            return $false
        }
    } catch {
        Write-Error "采集过程出错：$($_.Exception.Message)"
        return $false
    }
}

# 如果直接运行此脚本
if ($MyInvocation.InvocationName -ne '.') {
    $result = Invoke-ManualCollect
    Write-Host ""
    if ($result) {
        Wait-KeyPress "按任意键退出..."
    } else {
        Wait-KeyPress "按任意键退出..."
        exit 1
    }
}
