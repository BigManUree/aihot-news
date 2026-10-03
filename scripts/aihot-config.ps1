# AIHOT Configuration File
# Shared configuration for all scripts

# Project root directory (auto-detect: parent of scripts directory)
if ($PSScriptRoot) {
    $script:PROJECT_ROOT = Split-Path -Parent $PSScriptRoot
} else {
    $script:PROJECT_ROOT = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}

# Port configuration
$script:API_PORT = 3001
$script:WEB_PORT = 3000

# URL configuration
$script:API_URL = "http://127.0.0.1:$script:API_PORT"
$script:WEB_URL = "http://127.0.0.1:$script:WEB_PORT"
$script:API_HEALTH_URL = "$script:API_URL/api/health"

# Directory configuration
$script:DATA_DIR = Join-Path $script:PROJECT_ROOT ".data"
$script:PID_DIR = Join-Path $script:DATA_DIR "pids"
$script:SCRIPTS_DIR = Join-Path $script:PROJECT_ROOT "scripts"

# Log files
$script:API_LOG = Join-Path $script:DATA_DIR "api.log"
$script:WEB_LOG = Join-Path $script:DATA_DIR "web.log"
$script:WORKER_LOG = Join-Path $script:DATA_DIR "worker.log"

# PID files
$script:API_PID_FILE = Join-Path $script:PID_DIR "api.pid"
$script:WEB_PID_FILE = Join-Path $script:PID_DIR "web.pid"
$script:WORKER_PID_FILE = Join-Path $script:PID_DIR "worker.pid"

# User configuration (can be overridden from .env)
$script:AUTO_OPEN_BROWSER = $true
$script:HEALTH_CHECK_TIMEOUT = 30  # seconds
$script:HEALTH_CHECK_INTERVAL = 2  # seconds

# Color configuration
$script:COLOR_SUCCESS = "Green"
$script:COLOR_ERROR = "Red"
$script:COLOR_WARNING = "Yellow"
$script:COLOR_INFO = "Cyan"
