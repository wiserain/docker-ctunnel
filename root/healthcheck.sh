#!/bin/bash

TEST_URL="https://www.google.com"

# check connectivity of caddy forwardproxy at front
if [[ ! -z "${PROXY_USER}" ]] && [[ ! -z "${PROXY_PASS}" ]]; then
    PROXY_URL="http://${PROXY_USER}:${PROXY_PASS}@127.0.0.1:${PROXY_PORT:-8008}"
else
    PROXY_URL="http://127.0.0.1:${PROXY_PORT:-8008}"
fi

/usr/bin/curl --silent --fail --proxy ${PROXY_URL} "${TEST_URL}" || exit 1

# check connectivity of GT
if [[ "${GT_USE:-true}" == "true" ]]; then
    /usr/bin/curl --silent --fail --proxy http://127.0.0.1:${GT_PORT:-21000} "${TEST_URL}" || exit 1
fi

exit 0
