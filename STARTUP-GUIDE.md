# AIHOT 启动管理系统使用说明

## 概述

本项目为 AIHOT 开发了一套完整的 Windows 一键启动和管理系统，采用 BAT + PowerShell 混合架构，提供简单、可靠的开发环境管理。

## 文件结构

```
AIHOT-main/
├── start.bat              # 一键启动所有服务
├── stop.bat               # 停止所有服务
├── restart.bat            # 重启所有服务
├── status.bat             # 查看服务状态
├── logs.bat               # 查看日志
├── collect.bat            # 手动执行采集
├── db-status.bat          # 查看数据库状态
├── smoke.bat              # 执行冒烟测试
├── aihot.bat              # 统一 CLI 工具
│
├── scripts/
│   ├── aihot-config.ps1       # 统一配置
│   ├── aihot-utils.ps1        # 工具函数
│   ├── aihot-check-env.ps1    # 环境检查
│   ├── aihot-start.ps1        # 启动逻辑
│   ├── aihot-stop.ps1         # 停止逻辑
│   ├── aihot-status.ps1       # 状态查询
│   ├── aihot-logs.ps1         # 日志查看
│   ├── aihot-collect.ps1      # 手动采集
│   ├── aihot-db-status.ps1    # 数据库状态
│   ├── aihot-smoke.ps1        # 冒烟测试
│   │
│   ├── aihot-check-pg.cjs     # PostgreSQL 连接检查
│   ├── aihot-check-db.cjs     # 数据库检查
│   ├── aihot-db-stats.cjs     # 数据库统计
│   └── aihot-db-tables.cjs    # 数据库表列表
│
└── .data/
    ├── pids/                  # PID 文件
    │   ├── api.pid
    │   ├── web.pid
    │   └── worker.pid
    ├── api.log                # API 日志
    ├── web.log                # Web 日志
    ├── worker.log             # Worker 日志
    └── *-error.log            # 错误日志
```

## 快速开始

### 1. 启动所有服务

双击 `start.bat` 或在命令行运行：

```bash
start.bat
```

系统将自动：
1. 检查运行环境（Node.js、npm、PostgreSQL、.env）
2. 检查端口可用性（3000、3001）
3. 启动 API 服务（端口 3001）
4. 等待 API 健康检查通过
5. 启动 Web 服务（端口 3000）
6. 启动 Worker 服务（后台任务）
7. 显示服务状态和访问地址
8. 自动打开浏览器

### 2. 停止所有服务

```bash
stop.bat
```

### 3. 重启服务

```bash
restart.bat
```

### 4. 查看状态

```bash
status.bat
```

显示：
- 各服务运行状态
- PID 信息
- 访问 URL
- 数据库统计

### 5. 查看日志

```bash
logs.bat
```

可选择查看：
- API 日志
- Web 日志
- Worker 日志
- 所有日志

### 6. 手动采集

```bash
collect.bat
```

立即执行一次内容采集和 AI 筛选。

### 7. 数据库状态

```bash
db-status.bat
```

显示数据库统计信息和表列表。

### 8. 冒烟测试

```bash
smoke.bat
```

执行系统健康检查，验证所有端点正常工作。

## 统一 CLI 工具

除了独立的 BAT 文件，还可以使用 `aihot.bat` 统一管理：

```bash
aihot.bat start       # 启动
aihot.bat stop        # 停止
aihot.bat restart     # 重启
aihot.bat status      # 状态
aihot.bat logs        # 日志
aihot.bat collect     # 采集
aihot.bat db-status   # 数据库状态
aihot.bat smoke       # 冒烟测试
aihot.bat check       # 环境检查
aihot.bat help        # 帮助
```

## 核心功能

### 环境检查

启动前自动检查：
- ✅ Node.js 版本（>= 22）
- ✅ npm 安装
- ✅ node_modules 存在
- ✅ .env 配置完整
- ✅ PostgreSQL 连接
- ✅ 数据库和表存在
- ✅ 端口可用性

### 进程管理

- **精准控制**：通过 PID 文件管理进程，不会误杀其他 Node.js 进程
- **独立运行**：三个服务独立启动，一个崩溃不影响其他
- **健康检查**：真正等待服务就绪，不是简单的 sleep
- **自动重启**：检测到服务已运行时会询问是否重启

### 日志管理

- 每个服务独立日志文件
- 支持实时追踪（类似 tail -f）
- 错误日志单独记录
- 可选择查看单个或所有日志

### 数据库集成

- 自动检查 PostgreSQL 连接
- 显示数据库统计信息
- 验证表结构完整性

## 故障排查

### 服务无法启动

1. 检查 PostgreSQL 是否运行：
   ```bash
   services.msc  # 查找 PostgreSQL 服务
   ```

2. 检查端口是否被占用：
   ```bash
   netstat -ano | findstr :3000
   netstat -ano | findstr :3001
   ```

3. 查看错误日志：
   ```bash
   type .data\api-error.log
   type .data\web-error.log
   type .data\worker-error.log
   ```

### 数据库连接失败

1. 确认 PostgreSQL 服务运行中
2. 检查 `.env` 中的 `DATABASE_URL` 配置
3. 测试连接：
   ```bash
   node scripts/aihot-check-pg.cjs
   ```

### Worker 不采集内容

1. 检查 `.env` 配置：
   - `COLLECT_ENABLED=true`
   - `MODEL_CALLS_ENABLED=true`
   - `LLM_API_KEY` 有效

2. 查看 Worker 日志：
   ```bash
   type .data\worker.log
   ```

3. 手动触发采集：
   ```bash
   collect.bat
   ```

## 技术细节

### 架构设计

- **BAT 入口**：用户友好的双击启动
- **PowerShell 逻辑**：强大的进程管理和系统检查
- **Node.js 辅助**：数据库操作和验证
- **PID 文件**：精准的进程控制

### 安全性

- 不会误杀其他进程的 Node.js 实例
- 通过 PID 精准控制
- 停止前检查进程是否真实存在
- 环境变量隔离

### 兼容性

- Windows 10/11
- PowerShell 5.1+
- Node.js 22+
- 无需额外依赖

## 访问地址

启动后：

- **Web 前端**: http://127.0.0.1:3000
- **API 服务**: http://127.0.0.1:3001
- **管理后台**: http://127.0.0.1:3000/admin
- **API 健康检查**: http://127.0.0.1:3001/api/health

## 配置说明

所有配置集中在 `scripts/aihot-config.ps1`：

```powershell
$script:API_PORT = 3001
$script:WEB_PORT = 3000
$script:AUTO_OPEN_BROWSER = $true
$script:HEALTH_CHECK_TIMEOUT = 30
$script:HEALTH_CHECK_INTERVAL = 2
```

## 注意事项

1. **首次启动**：Worker 可能需要 5-10 分钟才开始采集内容
2. **端口冲突**：如果端口被占用，系统会提示并询问是否终止占用进程
3. **日志位置**：所有日志在 `.data/` 目录下
4. **PID 文件**：在 `.data/pids/` 目录下，不要手动删除
5. **环境变量**：从 `.env` 文件读取，不要硬编码在脚本中

## 开发建议

- 使用 `status.bat` 快速检查服务状态
- 使用 `logs.bat` 实时查看日志排查问题
- 使用 `smoke.bat` 验证系统完整性
- 使用 `collect.bat` 立即触发采集测试

---

**AIHOT 启动管理系统 v1.0**
