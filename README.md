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
      - "${PORT_TO_EXPOSE}:${PROXY_PORT:-8008}"
    environment:
      - PUID=${PUID:-911}
      - PGID=${PGID:-911}
      - PROXY_USER=${PROXY_USER}
      - PROXY_PASS=${PROXY_PASS}
```

You can access to your password-authenticated proxy server ```http://${PROXY_USER}:${PROXY_PASS}@0.0.0.0:${PROXY_PORT:-8008}``` which has an upstream to the internally running green-tunnel below

```bash
gt --ip 127.0.0.1 --port 21000 --dnsType ${GT_DNSTYPE:-https} --dnsServer ${GT_DNSSERVER:-https://cloudflare-dns.com/dns-query}
```

If you are familar with ```Caddyfile``` customizing behaviour of caddy-server, you may want your container-volume ```/config``` maped and make your own configuration.
