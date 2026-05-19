#!/bin/bash
set -euo pipefail

echo "===== 开发环境启动 ====="

# ---------- 1. 同步配置 ----------
echo ""
echo "[1/4] 同步配置..."
cp .env.dev .env

# ---------- 2. 启动数据库 ----------
echo ""
echo "[2/4] 启动数据库..."
docker compose up -d

# ---------- 3. 执行数据库迁移 ----------
echo ""
echo "[3/4] 执行数据库迁移..."
alembic upgrade head

# ---------- 4. 启动服务 ----------
echo ""
echo "[4/4] 启动服务..."
fastapi run app/main.py --reload
