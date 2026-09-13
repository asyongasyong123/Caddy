#!/bin/sh
set -e

# Sugdi Xray sa background
xray run -c /etc/xray.json &
XRAY_PID=$!

# ⏳ HULAT HANGTOD ANDAM ANG PORT 10001 & 10002
echo "⏳ Waiting for Xray..."
for i in 1 2 3 4 5 6 7 8 9 10 15 20 25 30; do
  PORT1=0
  PORT2=0
  nc -z 127.0.0.1 10001 && PORT1=1
  nc -z 127.0.0.1 10002 && PORT2=1
  
  if [ $PORT1 -eq 1 ] && [ $PORT2 -eq 1 ]; then
    echo "✅ Xray READY — Starting Caddy..."
    break
  fi
  echo "  Port 10001: $PORT1 | Port 10002: $PORT2 | Attempt $i/30"
  sleep 1
done

# 🚀 Sugdi Caddy — KINI ANG MAIN PROCESS
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
