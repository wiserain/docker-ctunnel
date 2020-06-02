FROM lsiobase/alpine:3.12
LABEL maintainer "wiserain"

# default environment settings
ENV TZ=Asia/Seoul
ENV GT_USE=true

# install packages
RUN \
    echo "**** install green-tunnel ****" && \
    apk add --no-cache npm glib gsettings-desktop-schemas && \
    npm i -g green-tunnel && \
    echo "**** install others ****" && \
    apk add --no-cache ca-certificates bash curl && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* \
        /root/.cache

# add local files
COPY root/ /

EXPOSE 8008 21000
VOLUME /config
WORKDIR /config

ENTRYPOINT ["/init"]
