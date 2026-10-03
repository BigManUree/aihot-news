@echo off
chcp 65001 >nul
cd /d "%~dp0"

if "%1"=="" goto :help
if "%1"=="start" goto :start
if "%1"=="stop" goto :stop
if "%1"=="restart" goto :restart
if "%1"=="status" goto :status
if "%1"=="logs" goto :logs
if "%1"=="collect" goto :collect
if "%1"=="db-status" goto :dbstatus
if "%1"=="smoke" goto :smoke
if "%1"=="check" goto :check
if "%1"=="help" goto :help

echo [错误] 未知命令: %1
echo.
goto :help

:start
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\aihot-start.ps1"
goto :end

:stop
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\aihot-stop.ps1"
goto :end

:restart
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\aihot-stop.ps1"
timeout /t 2 /nobreak >nul
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\aihot-start.ps1"
goto :end

:status
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\aihot-status.ps1"
goto :end

:logs
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\aihot-logs.ps1"
goto :end

:collect
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\aihot-collect.ps1"
goto :end

:dbstatus
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\aihot-db-status.ps1"
goto :end

:smoke
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\aihot-smoke.ps1"
goto :end

:check
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\aihot-check-env.ps1"
goto :end

:help
echo.
echo ========================================
echo        AIHOT 管理工具
echo ========================================
echo.
echo 用法: aihot.bat ^<命令^>
echo.
echo 命令:
echo   start      启动所有服务
echo   stop       停止所有服务
echo   restart    重启所有服务
echo   status     查看服务状态
echo   logs       查看日志
echo   collect    手动执行一次采集
echo   db-status  查看数据库状态
echo   smoke      执行冒烟测试
echo   check      检查运行环境
echo   help       显示此帮助
echo.
goto :end

:end
