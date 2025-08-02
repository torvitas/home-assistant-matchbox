#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

bashio::log.info "Preparing TLS certificates..."

CA_CRT=$(bashio::config "ca.crt")
CLIENT_CRT=$(bashio::config "client.crt")
CLIENT_KEY=$(bashio::config "client.key")
SERVER_CRT=$(bashio::config "server.crt")
SERVER_KEY=$(bashio::config "server.key")
FQDN=$(bashio::config "fqdn")

cd /etc/matchbox
if [[ "$CA_CRT" != "null" && "$CLIENT_CRT" != "null" && "$CLIENT_KEY" != "null" && "$SERVER_CRT" != "null" && "$SERVER_KEY" != "null" ]]; then
    echo "${CA_CRT}" > ca.crt
    echo "${CLIENT_CRT}" > client.crt
    echo "${CLIENT_KEY}" > client.key
    echo "${SERVER_CRT}" > server.crt
    echo "${SERVER_KEY}" > server.key
    chmod 644 /etc/matchbox/*.crt
    chmod 600 /etc/matchbox/*.key
elif [[ ! -f "ca.crt" || ! -f "client.crt" || ! -f "client.key" || ! -f "server.crt" || ! -f "server.key" ]] && [[ -n "$FQDN" ]]; then
    if [[ -n "$FQDN" ]]; then
        cd /scripts/tls
        export SAN="DNS.1:${FQDN}"
        ./cert-gen
        cp ca.crt client.crt server.crt server.key /etc/matchbox/
        bashio::log.green "ca.crt: \n $(<ca.crt)"
        bashio::log.green "client.crt: \n $(<client.crt)"
        bashio::log.green "client.key: \n $(<client.key)"
        cd /etc/matchbox
    else
        bashio::log.fatal "Configuration invalid, either specify fqdn or a full set of certificates..."
    fi
fi
cd ~

bashio::log.info "Starting matchbox..."

exec /matchbox
