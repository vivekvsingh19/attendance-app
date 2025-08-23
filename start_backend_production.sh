#!/bin/bash
exec /home/vivek-singh/upasthit/backend/attendance_env/bin/gunicorn backend.main:app \
    --workers 4 \
    --worker-class uvicorn.workers.UvicornWorker \
    --bind 0.0.0.0:8000 \
    --timeout 60 \
    --log-level info
