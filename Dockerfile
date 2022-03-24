ARG ALPINE_VER
ARG GOLANG_VER=1.16

FROM ghcr.io/linuxserver/baseimage-alpine:${ALPINE_VER} AS base
FROM golang:${GOLANG_VER}-alpine${ALPINE_VER} AS go-builder

# 
# BUILD
# 
FROM go-builder AS builder
COPY caddy.go /tmp/caddy/

ENV GOBIN=/bar/usr/local/bin \
    GO111MODULE=on

RUN \
    echo "**** building caddyserver ****" && \
    cd /tmp/caddy && \
    go mod init caddy && \
    go mod tidy && \
    go get github.com/caddyserver/caddy@v1 && \
    echo "**** installing caddyserver ****" && \
    go install

RUN \
    echo "**** install green-tunnel ****" && \
    apk add npm && \
    npm i -g --prefix /bar/usr green-tunnel

# add local files
COPY root/ /bar/

# 
# RELEASE
# 
FROM base
LABEL maintainer="wiserain"
LABEL org.opencontainers.image.source https://github.com/wiserain/docker-ctunnel

# default environment settings
ENV \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    TZ=Asia/Seoul \
    GT_ENABLED=true \
    PROXY_ENABLED=true

COPY --from=builder /bar/ /

# install packages
RUN \
    echo "**** install nodejs ****" && \
    apk add --no-cache nodejs-current && \
    echo "**** install others ****" && \
    apk add --no-cache ca-certificates bash curl && \
    echo "**** permissions ****" && \
    chmod a+x /usr/local/bin/* && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* \
        /root/.cache

EXPOSE 8008 21000
VOLUME /config
WORKDIR /config

HEALTHCHECK --interval=10m --timeout=30s --start-period=10s --retries=3 \
    CMD /usr/local/bin/healthcheck

ENTRYPOINT ["/init"]
