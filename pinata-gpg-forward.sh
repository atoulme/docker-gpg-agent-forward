#!/bin/sh
set -eo pipefail

GNUPG_EXTRA_SOCKET=$HOME/.gnupg/S.gpg-agent.extra
IMAGE_NAME=tmio/gpg-agent-forward:latest
CONTAINER_NAME=pinata-gpg-agent
VOLUME_NAME=gpg-agent
HOST_PORT=2255
AUTHORIZED_KEYS=$(ssh-add -L | base64 | tr -d '\n')
KNOWN_HOSTS_FILE=$(mktemp -t dsaf.XXX)

trap 'rm ${KNOWN_HOSTS_FILE}' EXIT

docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

docker volume create --name "${VOLUME_NAME}"

docker run \
  --name "${CONTAINER_NAME}" \
  --restart always \
  -e AUTHORIZED_KEYS="${AUTHORIZED_KEYS}" \
  -v ${VOLUME_NAME}:/gpg-agent \
  -d \
  -p "${HOST_PORT}:22" \
  "${IMAGE_NAME}" >/dev/null

if [ "${DOCKER_HOST}" ]; then
  HOST_IP=$(echo "$DOCKER_HOST" | awk -F '//' '{print $2}' | awk -F ':' '{print $1}')
else
  HOST_IP=127.0.0.1
fi

# FIXME Find a way to get rid of this additional 1s wait
sleep 1
while [ 1 ] && ! nc -z -w5 ${HOST_IP} ${HOST_PORT}; do sleep 0.1; done

ssh-keyscan -p "${HOST_PORT}" "${HOST_IP}" >"${KNOWN_HOSTS_FILE}" 2>/dev/null

# forward gnupg extra socket
ssh \
  -fNT \
  -R /gpg-agent/S.gpg-agent:$GNUPG_EXTRA_SOCKET \
  -o "UserKnownHostsFile=${KNOWN_HOSTS_FILE}" \
  -o "ExitOnForwardFailure=yes" \
  -p "${HOST_PORT}" \
  -S none \
  "root@${HOST_IP}"

# import public keys
gpg --with-colons -K| \
    awk -F: '/^sec/{print $5}' | \
    xargs -n 1 gpg --export -a | \
    ssh -o "UserKnownHostsFile=${KNOWN_HOSTS_FILE}" \
       -S none -p "${HOST_PORT}" "root@${HOST_IP}" \
       gpg --homedir /gpg-agent --import

echo 'GPG Agent forwarding successfully started.'
echo 'Run your containers with "-v /gnupg/:$HOME/.gnupg"'
