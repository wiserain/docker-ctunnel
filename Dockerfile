FROM lsiobase/alpine:3.12
LABEL maintainer "wiserain"

# default environment settings
ENV TZ=Asia/Seoul
ENV GT_USE=true

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

RUN chmod a+x /healthcheck.sh

EXPOSE 8008 21000
VOLUME /config
WORKDIR /config

HEALTHCHECK --interval=10m --timeout=30s --start-period=10s --retries=3 CMD [ "/healthcheck.sh" ]  

ENTRYPOINT ["/init"]
