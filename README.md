# FastAPI Template

FastAPI + SQLModel + PostgreSQL 项目模板，包含用户认证、CRUD、统一响应格式、容器化部署等开箱即用的功能。

## 特性

- **JWT 认证** — access token + refresh token，支持用户名/邮箱登录
- **CRUD 示例** — 用户管理 + Item CRUD（所有权校验）
- **统一响应格式** — `{code, msg, data}`
- **全局异常处理** — 业务异常、参数校验、HTTP 异常统一拦截
- **请求日志** — IP、路径、参数、耗时、错误堆栈
- **Sentry 集成** — 错误追踪 + 性能监控
- **飞书通知** — Webhook 告警
- **API 文档** — Swagger UI（开发环境自动开启，生产环境关闭）
- **Docker 部署** — Traefik 反代 + PostgreSQL + 自动备份 + 数据库迁移
- **GitHub Actions CI** — 单元测试 + Compose 部署验证

## 环境要求

- Python 3.12+
- Docker & Docker Compose（生产部署）
- uv（包管理）

## 开发

### 手动启动

```bash
cp .env.dev .env                     # 同步配置
uv sync --all-extras                 # 安装依赖
docker compose up -d                 # 启动数据库
uv run alembic upgrade head          # 迁移
uv run fastapi run app/main.py --reload  # 启动服务
```

### 验证

```bash
curl http://localhost:8000/health
# {"code":200,"msg":"ok","data":{"status":"ok"}}
```

### API 文档

开发环境访问 http://localhost:8000/docs

### 运行测试

```bash
uv run pytest tests/ -v --cov
```

### 代码质量

```bash
# Ruff — 代码检查 + 格式化
uv run ruff check .
uv run ruff format --check .

# Mypy — 类型检查
uv run mypy app/

# Pre-commit — 提交前自动检查（ruff + mypy + 通用检查）
uv run pre-commit install    # 安装 git hooks（只需一次）
uv run pre-commit run --all-files  # 手动触发全量检查
```

### 数据库迁移

```bash
uv run alembic revision --autogenerate -m "description"  # 生成迁移
uv run alembic upgrade head                               # 执行迁移
uv run alembic downgrade -1                               # 回滚
```

## CI

推送代码和 PR 时自动触发：

| Workflow | 触发条件 | 说明 |
|----------|----------|------|
| **Lint** | push/PR to main | Ruff 代码检查 + 格式化 + Mypy 类型检查 |
| **Test Backend** | push/PR to main | pytest 单元测试 + 覆盖率检查 |
| **Test Compose** | push/PR to main | 构建镜像 → 部署 → 健康检查，验证完整部署流程 |

## 部署

### 环境配置

提供三套环境配置：

| 文件 | 环境 | 说明 |
|------|------|------|
| `.env.dev` | 开发 | DB 在本地，SQL 日志开启 |
| `.env.staging` | 预发布 | DB 在 Docker，阿里云 ACR 镜像 |
| `.env.prod` | 生产 | DB 在 Docker，阿里云 ACR 镜像 |

### 部署命令

```bash
# 部署生产环境
bash deploy.sh prod

# 部署预发布环境
bash deploy.sh staging
```

`deploy.sh` 执行流程：
1. 同步配置（`.env.{env}` → `.env`）
2. 拉取最新镜像（阿里云 ACR）
3. 启动数据库
4. 备份数据库
5. 执行数据库迁移
6. 启动服务
7. 健康检查

### 架构

```
客户端 → Traefik(:80) → Backend(:8000) → PostgreSQL(:5432)
```

### 镜像构建与推送

```bash
docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG} .
docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
```

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `APP_ENV` | dev | 环境（dev / staging / prod） |
| `LOG_LEVEL` | INFO | 日志级别 |
| `DB_DEBUG` | True | 是否打印 SQL |
| `WORKERS` | 4 | Worker 进程数 |
| `POSTGRES_SERVER` | localhost | 数据库地址 |
| `POSTGRES_PORT` | 5432 | 数据库端口 |
| `POSTGRES_USER` | postgres | 数据库用户 |
| `POSTGRES_PASSWORD` | postgres | 数据库密码 |
| `POSTGRES_DB` | fastapi_template | 数据库名 |
| `SECRET_KEY` | | JWT 签名密钥 |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | 30 | Access token 过期时间 |
| `REFRESH_TOKEN_EXPIRE_DAYS` | 7 | Refresh token 过期时间 |
| `SENTRY_DSN` | | Sentry DSN |
| `SENTRY_SAMPLE_RATE` | 0.1 | Sentry 采样率 |
| `FEISHU_WEBHOOK_URL` | | 飞书 Webhook 地址 |
| `DOCKER_REGISTRY` | | 镜像仓库地址（生产） |
| `DOCKER_IMAGE` | | 镜像名（生产） |
| `DOCKER_TAG` | | 镜像标签（生产） |
