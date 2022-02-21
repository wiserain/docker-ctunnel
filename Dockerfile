ARG ALPINE_VER=3.15
FROM golang:1.16-alpine${ALPINE_VER} AS builder

COPY caddy.go /tmp/caddy/

ENV GOBIN=/bar/usr/local/bin

RUN \
    echo "**** building caddyserver ****" && \
    cd /tmp/caddy && \
    export GO111MODULE=on && \
    go mod init caddy && \
    go mod tidy && \
    go get github.com/caddyserver/caddy@v1 && \
    echo "**** installing caddyserver ****" && \
    go install

# add local files
COPY root/ /bar/


FROM ghcr.io/linuxserver/baseimage-alpine:${ALPINE_VER}
LABEL maintainer="wiserain"
LABEL org.opencontainers.image.source https://github.com/wiserain/docker-ctunnel

# default environment settings
ENV \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    TZ=Asia/Seoul \
    GT_ENABLED=true \
    GT_UPDATE=false \
    PROXY_ENABLED=true

COPY --from=builder /bar/ /

# install packages
RUN \
    echo "**** install green-tunnel ****" && \
    apk add --no-cache npm && \
    npm i -g green-tunnel && \
    echo "**** install others ****" && \
    apk add --no-cache ca-certificates bash curl && \
    echo "**** permissions ****" && \
    chmod a+x /healthcheck.sh && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* \
        /root/.cache

EXPOSE 8008 21000
VOLUME /config
WORKDIR /config

HEALTHCHECK --interval=10m --timeout=30s --start-period=10s --retries=3 \
    CMD /healthcheck.sh

ENTRYPOINT ["/init"]
