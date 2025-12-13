#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

mkdir -p "${MATCHBOX_DATA_PATH}"
mkdir -p "${MATCHBOX_ASSETS_PATH}"

bashio::log.info "Preparing TLS certificates..."

CA_CRT=$(bashio::config "ca.crt")
SERVER_CRT=$(bashio::config "server.crt")
SERVER_KEY=$(bashio::config "server.key")
FQDN=$(bashio::config "fqdn")

mkdir -p $(dirname ${MATCHBOX_CA_FILE})
mkdir -p $(dirname ${MATCHBOX_CERT_FILE})
mkdir -p $(dirname ${MATCHBOX_KEY_FILE})
if [[ "$CA_CRT" != "null" && "$SERVER_CRT" != "null" && "$SERVER_KEY" != "null" ]]; then
  echo "${CA_CRT}" >${MATCHBOX_CA_FILE}
  chmod 644 ${MATCHBOX_CA_FILE}
  echo "${SERVER_CRT}" >${MATCHBOX_CERT_FILE}
  chmod 644 ${MATCHBOX_CERT_FILE}
  echo "${SERVER_KEY}" >${MATCHBOX_KEY_FILE}
  chmod 600 ${MATCHBOX_KEY_FILE}
elif [[ ! -s "${MATCHBOX_CA_FILE}" || ! -s "${MATCHBOX_CERT_FILE}" || ! -s "${MATCHBOX_KEY_FILE}" ]]; then
  if [[ "$FQDN" != "null" ]]; then
    cd /scripts/tls
    export SAN="DNS.1:${FQDN}"
    ./cert-gen
    cp ca.crt "${MATCHBOX_CA_FILE}"
    cp server.crt "${MATCHBOX_CERT_FILE}"
    cp server.key "${MATCHBOX_KEY_FILE}"
    mkdir -p $(dirname ${CLIENT_CERT_FILE})
    cp client.crt "${CLIENT_CERT_FILE}"
    mkdir -p $(dirname ${CLIENT_KEY_FILE})
    cp client.key "${CLIENT_KEY_FILE}"
    bashio::log.green "ca.crt: \n $(<ca.crt)"
    bashio::log.green "client.crt: \n $(<client.crt)"
    bashio::log.green "client.key: \n $(<client.key)"
  else
    bashio::log.fatal "Configuration invalid, either specify fqdn or a full set of certificates..."
    exit 1
  fi
fi
cd ~

bashio::log.info "Starting matchbox..."

exec /matchbox $(bashio::config "arguments")
