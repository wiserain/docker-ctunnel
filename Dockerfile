ARG ALPINE_VER=3.12
ARG GOLANG_VER=1.15
FROM golang:${GOLANG_VER}-alpine${ALPINE_VER} AS builder

COPY caddy.go /tmp/caddy/

RUN \
    echo "**** building caddyserver ****" && \
    cd /tmp/caddy && \
    export GO111MODULE=on && \
    go mod init caddy && \
    go get github.com/caddyserver/caddy@v1 && \
    echo "**** installing caddyserver ****" && \
    go install


FROM lsiobase/alpine:${ALPINE_VER}
LABEL maintainer "wiserain"

# default environment settings
ENV TZ=Asia/Seoul
ENV GT_ENABLED=true
ENV GT_UPDATE=false
ENV PROXY_ENABLED=true

# install packages
RUN \
    echo "**** install green-tunnel ****" && \
    apk add --no-cache npm && \
    npm i -g green-tunnel && \
    echo "**** install others ****" && \
    apk add --no-cache ca-certificates bash curl && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* \
        /root/.cache

# add local files
COPY root/ /

# install caddy binary
COPY --from=builder /go/bin/caddy /usr/bin/

RUN chmod a+x /healthcheck.sh /usr/bin/caddy

EXPOSE 8008 21000
VOLUME /config
WORKDIR /config

HEALTHCHECK --interval=10m --timeout=30s --start-period=10s --retries=3 \
    CMD /healthcheck.sh

ENTRYPOINT ["/init"]
