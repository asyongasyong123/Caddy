#!/bin/sh
set -e

echo "🚀 Starting Xray core in background..."
xray run -c /etc/xray.json &
XRAY_PID=$!

echo "🚀 Starting Caddy server on port 8080..."
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
CADDY_PID=$!

# Wait for both background processes
wait -n $CADDY_PID $XRAY_PID
