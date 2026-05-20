#!/bin/sh
set -e

mkdir -p /home/node/.n8n
chown -R node:node /home/node/.n8n

if [ "$#" -eq 0 ]; then
  set -- start
fi

if [ "$1" = "n8n" ]; then
  shift
fi

if command -v su-exec >/dev/null 2>&1; then
  exec su-exec node n8n "$@"
fi

if command -v gosu >/dev/null 2>&1; then
  exec gosu node n8n "$@"
fi

if command -v runuser >/dev/null 2>&1; then
  exec runuser -u node -- n8n "$@"
fi

exec su node -s /bin/sh -c "exec n8n $*"
