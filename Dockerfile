FROM teddysun/xray:latest AS xray-builder
FROM caddy:2-alpine

COPY --from=xray-builder /usr/bin/xray /usr/bin/xray
COPY --from=xray-builder /usr/share/xray /usr/share/xray

RUN apk add --no-cache ca-certificates netcat-openbsd

WORKDIR /etc/caddy

COPY Caddyfile /etc/caddy/Caddyfile

RUN mkdir -p /etc/xray && echo '{ \
  "log": { "loglevel": "warning" }, \
  "policy": { "levels": { "0": { "handshake": 15, "connIdle": 300, "uplinkOnly": 30, "downlinkOnly": 30, "bufferSize": 1024 } } }, \
  "inbounds": [ \
    { \
      "port": 10000, "listen": "127.0.0.1", "protocol": "vless", \
      "settings": { "clients": [{ "id": "a1b2c3d4-5678-40ef-98ab-cdef01234567", "level": 0 }], "decryption": "none" }, \
      "streamSettings": { "network": "ws", \
        "wsSettings": { "path": "/vless-ws", "maxEarlyData": 0, "heartbeatPeriod": 30 }, \
        "sockopt": { "tcpKeepAliveInterval": 15 } \
      } \
    }, \
    { \
      "port": 20000, "listen": "127.0.0.1", "protocol": "trojan", \
      "settings": { "clients": [{ "password": "gcp-xray", "level": 0 }] }, \
      "streamSettings": { "network": "ws", \
        "wsSettings": { "path": "/trojan-ws", "maxEarlyData": 0, "heartbeatPeriod": 30 }, \
        "sockopt": { "tcpKeepAliveInterval": 15 } \
      } \
    } \
  ], \
  "outbounds": [{ "protocol": "freedom", "settings": { "domainStrategy": "UseIP" } }] \
}' > /etc/xray/config.json

EXPOSE 8080

ENTRYPOINT ["/bin/sh", "-c", "\
xray run -config /etc/xray/config.json & \
until nc -z 127.0.0.1 10000; do sleep 1; done; \
until nc -z 127.0.0.1 20000; do sleep 1; done; \
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile \
"]
