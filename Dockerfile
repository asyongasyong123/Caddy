# Step 1: Download Xray Core & Geodata
FROM alpine:3.20 AS builder

RUN apk add --no-cache curl unzip ca-certificates

# Download latest Xray-core
RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip && \
    unzip -q xray.zip xray geosite.dat geoip.dat && \
    chmod +x xray

# Step 2: Build Final Image using Caddy Alpine
FROM caddy:2.7-alpine

# Copy Xray binaries and data
COPY --from=builder /xray /usr/local/bin/xray
COPY --from=builder /geosite.dat /usr/local/share/xray/
COPY --from=builder /geoip.dat /usr/local/share/xray/

# Copy Configuration Files
COPY config.json /etc/xray.json
COPY Caddyfile /etc/Caddyfile
COPY entrypoint.sh /entrypoint.sh

# Permissions & Execution
RUN chmod +x /usr/local/bin/xray /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
