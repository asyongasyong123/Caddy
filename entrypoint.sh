#!/bin/sh
set -e

/usr/local/bin/xray run -c /etc/xray.json &

sleep 2

exec caddy run --config /etc/Caddyfile --adapter caddyfile
