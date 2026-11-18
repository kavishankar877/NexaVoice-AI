
#!/bin/bash

echo "Starting NexaVoice AI..."

cleanup() {
    echo "Stopping NexaVoice AI..."

    trap - SIGTERM SIGINT

    kill "$AGENT_PID" "$SERVER_PID" 2>/dev/null || true

    wait "$AGENT_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
}

trap cleanup SIGTERM SIGINT

run_agent() {
    while true; do
        echo "Starting LiveKit Gemini voice agent..."

        python agent.py start

        STATUS=$?

        echo "LiveKit agent exited with status $STATUS"
        echo "Restarting agent in 5 seconds..."

        sleep 5
    done
}

run_agent &
AGENT_PID=$!

echo "Starting FastAPI server..."

uvicorn server:app --host 0.0.0.0 --port "${PORT:-10000}" &
SERVER_PID=$!

wait -n "$AGENT_PID" "$SERVER_PID"
STATUS=$?

cleanup

exit "$STATUS"
