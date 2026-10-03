# AIHOT 冒烟测试脚本

. (Join-Path $PSScriptRoot "aihot-utils.ps1")

function Invoke-SmokeTest {
    Write-Header "AIHOT SMOKE TEST"

    # 检查服务是否运行
    $apiRunning = $false
    $webRunning = $false

    $apiPid = Read-Pid $script:API_PID_FILE
    $webPid = Read-Pid $script:WEB_PID_FILE

    if ($apiPid -and (Test-ProcessRunning $apiPid)) {
        $apiRunning = $true
    }
    if ($webPid -and (Test-ProcessRunning $webPid)) {
        $webRunning = $true
    }

    if (-not $apiRunning -or -not $webRunning) {
        Write-Error "服务未完全运行"
        if (-not $apiRunning) { Write-Host "  API 未运行" -ForegroundColor Red }
        if (-not $webRunning) { Write-Host "  Web 未运行" -ForegroundColor Red }
        Write-Host ""
        Write-Info "请先运行 start.bat 启动服务"
        return $false
    }

    Write-Success "服务运行正常"
    Write-Host ""

    # 运行冒烟测试
    Write-Info "正在执行冒烟测试..."
    Write-Host ""

    $smokeScript = Join-Path $script:PROJECT_ROOT "scripts" "smoke.ts"
    if (-not (Test-Path $smokeScript)) {
        Write-Error "冒烟测试脚本不存在：$smokeScript"
        return $false
    }

    try {
        # 运行冒烟测试脚本
        & node --env-file-if-exists=.env $smokeScript --base "http://localhost:$script:WEB_PORT"

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Success "冒烟测试通过"
            return $true
        } else {
            Write-Error "冒烟测试失败（退出码：$LASTEXITCODE）"
            return $false
        }
    } catch {
        Write-Error "冒烟测试出错：$($_.Exception.Message)"
        return $false
    }
}

# 如果直接运行此脚本
if ($MyInvocation.InvocationName -ne '.') {
    $result = Invoke-SmokeTest
    Write-Host ""
    if ($result) {
        Wait-KeyPress "按任意键退出..."
    } else {
        Wait-KeyPress "按任意键退出..."
        exit 1
    }
}
