FROM teddysun/xray:latest AS xray-builder
FROM caddy:2-alpine

# Copy Xray binary ug geodata
COPY --from=xray-builder /usr/bin/xray /usr/bin/xray
COPY --from=xray-builder /usr/share/xray /usr/share/xray

# Install kinahanglanon nga tools
RUN apk add --no-cache ca-certificates jq bash curl

WORKDIR /etc/caddy

# Copy runtime configs & script
COPY Caddyfile /etc/caddy/Caddyfile
COPY xray.json /etc/xray/config.json
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 80 443 8080

ENTRYPOINT ["/entrypoint.sh"]
