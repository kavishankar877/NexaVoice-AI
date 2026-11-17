
#!/bin/sh

python agent.py start &
AGENT_PID=$!

uvicorn server:app --host 0.0.0.0 --port "${PORT:-10000}" &
SERVER_PID=$!

wait -n "$AGENT_PID" "$SERVER_PID"

exit 1
