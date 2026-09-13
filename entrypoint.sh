#!/bin/sh
set -e

# ✅ SUGDI ANG CADDY UNA — PARA MO-ANDAM ANG PORT 8080 DIHA-DAYON!
echo "🚀 Starting Caddy..."
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
CADDY_PID=$!

# ⏳ HULAT ANG CADDY ANDAM NA
for i in 1 2 3 4 5 6 7 8 9 10; do
  if nc -z 127.0.0.1 8080; then
    echo "✅ Caddy READY on port 8080!"
    break
  fi
  sleep 1
done

# ✅ SUGDI ANG XRAY SA IKADUHA — dili na maghulat ang Cloud Run
echo "🚀 Starting Xray..."
xray run -c /etc/xray.json &
XRAY_PID=$!

# ⏳ HULAT ANG XRAY ANDAM NA
for i in 1 2 3 4 5 6 7 8 9 10 15 20; do
  P1=0; P2=0
  nc -z 127.0.0.1 10001 && P1=1
  nc -z 127.0.0.1 10002 && P2=1
  if [ $P1 -eq 1 ] && [ $P2 -eq 1 ]; then
    echo "✅ XRAY READY — Ports 10001 & 10002 listening!"
    break
  fi
  sleep 1
done

# ⏳ HUWAT SA TANANG PROSESO
wait $CADDY_PID $XRAY_PID
