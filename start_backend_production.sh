#!/bin/bash
# Start FastAPI backend with Gunicorn and Uvicorn workers for production
exec /home/vivek-singh/classattendence/backend/attendance_env/bin/gunicorn backend.main:app \
    --workers 4 \
    --worker-class uvicorn.workers.UvicornWorker \
    --bind 0.0.0.0:8001 \
    --timeout 60 \
    --log-level info
