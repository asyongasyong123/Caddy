#!/bin/sh
set -e

# Start Xray core in background
/usr/local/bin/xray run -c /etc/xray.json &

# Give Xray time to initialize
sleep 2

# Start Caddy in foreground
exec caddy run --config /etc/Caddyfile --adapter caddyfile
