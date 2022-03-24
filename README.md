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
      - PUID=${PUID}
      - PGID=${PGID}
      - PROXY_USER=${PROXY_USER}
      - PROXY_PASS=${PROXY_PASS}
```

You can access to your password-authenticated proxy server via

```http://${PROXY_USER}:${PROXY_PASS}@${DOCKER_HOST}:${PROXY_PORT:-8008}```

This service is run by caddy forward-proxy and will relay all your requests to the internally running green-tunnel below

```bash
gt --ip 0.0.0.0 --port ${GT_PORT:-21000} --system-proxy false \
    --dns-type ${GT_DNSTYPE:-https} \
    --dns-server ${GT_DNSSERVER:-https://1.1.1.1/dns-query}
```

If you are familar with ```Caddyfile```, you may want your container-volume ```/config``` maped and make your own ```Caddyfile``` to customize behaviour of caddy-server. Default is

```bash
0.0.0.0:${PROXY_PORT:-8008}
forwardproxy {
    basicauth ${PROXY_USER} ${PROXY_PASS}
    upstream http://localhost:${GT_PORT:-21000}
    hide_ip
    hide_via
}
```

## Direct connection to green-tunnel

As green-tunnel is running with ```0.0.0.0:21000```, you can directly access it independently to caddy forward-proxy running at front by publishing your container port ```21000```. It is highly recommended exposing the port for internal use only.

## Environment variables

| ENV  | Description  | Default  |
|---|---|---|
| ```PUID``` / ```PGID```  | uid and gid for running an app  | ```911``` / ```911```  |
| ```TZ```  | timezone  | ```Asia/Seoul```  |
| ```PROXY_ENABLED```  | set ```false``` to disable caddy | ```true``` |
| ```PROXY_USER``` / ```PROXY_PASS```  | required both to activate proxy authentication   |  |
| ```PROXY_PORT```  | to run caddy forward-proxy in a different port  | ```8008``` |
| ```PROXY_VERBOSE```  | append ```-log stdout``` to caddy server cmd  |  |
| ```GT_ENABLED```  | set ```false``` to disable green-tunnel  | ```true``` |
| ```GT_PORT```  | to run green-tunnel in different port  | ```21000```  |
| ```GT_VERBOSE```  | set ```true``` to run green-tunnel in verbose mode for the purpose of debugging  |  |
| ```GT_DNSTYPE```  | agrument ```--dns-type``` for [green-tunnel CLI](https://github.com/SadeghHayeri/GreenTunnel#command-line-interface-cli)  | ```https```  |
| ```GT_DNSSERVER```  | agrument ```--dns-server``` for [green-tunnel CLI](https://github.com/SadeghHayeri/GreenTunnel#command-line-interface-cli)  | ```https://1.1.1.1/dns-query```  |

## TODO

- [ ] Suppress log for certificate maintenance
- [ ] Apply http/2 for better performance?
