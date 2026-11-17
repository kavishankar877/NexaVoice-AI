#!/bin/bash

echo "Starting LiveKit voice agent..."

python agent.py start &
AGENT_PID=$!

echo "Starting FastAPI server..."

uvicorn server:app --host 0.0.0.0 --port "${PORT:-10000}" &
SERVER_PID=$!

cleanup() {
    echo "Stopping services..."
    trap - SIGTERM SIGINT
    kill "$AGENT_PID" "$SERVER_PID" 2>/dev/null || true
    wait "$AGENT_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
}

trap cleanup SIGTERM SIGINT

wait -n "$AGENT_PID" "$SERVER_PID"
STATUS=$?

cleanup
exit "$STATUS"