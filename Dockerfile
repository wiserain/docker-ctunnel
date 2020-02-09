FROM lsiobase/alpine:3.11
LABEL maintainer "wiserain"

# default environment settings
ENV TZ=Asia/Seoul
ENV USE_GT=true

# install packages
RUN \
 echo "**** install greentunnel ****" && \
 apk add --no-cache npm glib gsettings-desktop-schemas && \
 npm i -g green-tunnel && \
 echo "**** install caddyserver ****" && \
 apk add --no-cache ca-certificates bash curl && \
 curl --fail https://getcaddy.com | bash -s personal http.forwardproxy && \
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
