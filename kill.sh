#!/bin/bash
# Kill all processes on ports used by radix-ios and radix-api

PORTS=(8080 8081 3000)

for PORT in "${PORTS[@]}"; do
  PID=$(lsof -ti :$PORT 2>/dev/null)
  if [ -n "$PID" ]; then
    echo "Killing process on port $PORT (PID: $PID)"
    kill -9 $PID 2>/dev/null
  else
    echo "No process on port $PORT"
  fi
done

echo "All ports cleared."