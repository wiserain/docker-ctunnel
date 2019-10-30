# docker-ctunnel

[[**c**]addy-forwardproxy](https://github.com/caddyserver/forwardproxy) + [green-[**tunnel**]](https://github.com/SadeghHayeri/GreenTunnel)

## Usage

```yaml
version: '3'

services:
  ctunnel:
    container_name: ctunnel
    image: wiserain/ctunnel:latest
    restart: always
    network_mode: bridge
    ports:
      - "${PORT_TO_EXPOSE}:${PROXY_PORT}"
    environment:
      - PUID=${PUID:-911}
      - PGID=${PGID:-911}
      - PROXY_USER=${PROXY_USER}
      - PROXY_PASS=${PROXY_PASS}
      - PROXY_PORT=${PROXY_PORT:-8008}
```

You can access to your password-authenticated proxy server via

```http://${PROXY_USER}:${PROXY_PASS}@0.0.0.0:${PROXY_PORT:-8008}``` 

This service is run by caddy forward-proxy and will relay all your requests to the internally running green-tunnel below

```bash
gt --ip 127.0.0.1 --port 21000 \
    --dnsType ${GT_DNSTYPE:-https} \
    --dnsServer ${GT_DNSSERVER:-https://cloudflare-dns.com/dns-query}
```

If you are familar with ```Caddyfile```, you may want your container-volume ```/config``` maped and make your own ```Caddyfile``` to customize behaviour of caddy-server. Default is

```bash
0.0.0.0:${PROXY_PORT:-8008}
forwardproxy {
    basicauth ${PROXY_USER} ${PROXY_PASS}
    upstream http://localhost:21000
}
```
