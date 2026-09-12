FROM alpine:3.20 AS builder

RUN apk add --no-cache curl unzip ca-certificates

RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip && \
    unzip -q xray.zip xray geosite.dat geoip.dat && \
    chmod +x xray

FROM caddy:2.7-alpine

COPY --from=builder /xray /usr/local/bin/xray
COPY --from=builder /geosite.dat /usr/local/share/xray/
COPY --from=builder /geoip.dat /usr/local/share/xray/

COPY config.json /etc/xray.json
COPY Caddyfile /etc/Caddyfile
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /usr/local/bin/xray /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
