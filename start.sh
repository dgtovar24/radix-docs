#!/bin/bash
# Start all radix services

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Starting Radix API (backend)..."
cd "$SCRIPT_DIR/radix-api" && ./mvnw spring-boot:run > /tmp/radix-api.log 2>&1 &
API_PID=$!
echo "API started (PID: $API_PID) — logs: /tmp/radix-api.log"


echo ""
echo "Waiting for services to be ready..."
sleep 10

# Check API
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/v2/actuator/health 2>/dev/null | grep -q "200\|UP"; then
  echo "✓ API ready at http://localhost:8080/v2"
else
  echo "○ API starting at http://localhost:8080/v2 (check /tmp/radix-api.log if issues)"
fi


echo ""
echo "PIDs saved:"
echo "  API:   $API_PID"
