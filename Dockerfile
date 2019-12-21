FROM alpine:3.11
LABEL maintainer "wiserain" 

# s6 environment settings
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_KEEP_ENV=1

ENV USE_GT=true

# install packages
RUN \
 echo "**** install greentunnel ****" && \
 apk add --no-cache npm glib gsettings-desktop-schemas && \
 npm i -g green-tunnel && \
 echo "**** install caddyserver ****" && \
 apk add --no-cache ca-certificates bash curl && \
 curl --fail https://getcaddy.com | bash -s personal http.forwardproxy && \
 echo "**** add s6 overlay ****" && \
 OVERLAY_VERSION=$(curl -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl -o /tmp/s6-overlay.tar.gz -L "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-amd64.tar.gz" && \
 tar xfz  /tmp/s6-overlay.tar.gz -C / && \
 echo "**** system configurations - user and default folders ****" && \
 apk add --no-cache coreutils shadow tzdata && \
 sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd && \
 groupmod -g 1000 users && \
 useradd -u 911 -U -d /config -s /bin/false abc && \
 usermod -G users abc && \
 mkdir -p /config && \
 echo "**** cleanup ****" && \
 rm -rf \
 	/tmp/* \
	/root/.cache

# add local files
COPY root/ /

VOLUME /config
WORKDIR /config

ENTRYPOINT ["/init"]
