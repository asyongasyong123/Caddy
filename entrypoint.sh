#!/bin/bash
set -e

# Default values gikan sa imong gihatag
export UUID="${UUID:-a1b2c3d4-5678-40ef-98ab-cdef01234567}"
export TROJAN_PASS="${TROJAN_PASS:-gcp-xray}"
export VLESS_PATH="${VLESS_PATH:-/vless-ws}"
export TROJAN_PATH="${TROJAN_PATH:-/trojan-ws}"

echo "==> Configuring Xray for VLESS & Trojan WebSocket..."

# Inject values sa xray.json
jq --arg uuid "$UUID" \
   --arg pass "$TROJAN_PASS" \
   --arg vpath "$VLESS_PATH" \
   --arg tpath "$TROJAN_PATH" \
   '.inbounds[0].settings.clients[0].id = $uuid |
    .inbounds[0].streamSettings.wsSettings.path = $vpath |
    .inbounds[1].settings.clients[0].password = $pass |
    .inbounds[1].streamSettings.wsSettings.path = $tpath' \
   /etc/xray/config.json > /tmp/xray.json && mv /tmp/xray.json /etc/xray/config.json

# Launch Xray sa background
xray run -config /etc/xray/config.json &

# Launch Caddy sa foreground
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
