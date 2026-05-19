#!/bin/bash
set -euo pipefail

echo "1. 开始执行数据库迁移 (Alembic)..."
alembic upgrade head

echo "2. 数据库迁移成功，开始启动 FastAPI 服务..."
fastapi run app/main.py --reload
