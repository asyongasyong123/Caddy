FROM caddy:2-alpine

# Kinahanglan ang netcat para sa port check!
RUN apk add --no-cache netcat-openbsd

COPY --from=teddysun/xray:latest /usr/bin/xray /usr/local/bin/
COPY config.json /etc/xray.json
COPY Caddyfile /etc/caddy/Caddyfile
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /usr/local/bin/xray /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
