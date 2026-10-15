#!/usr/bin/env bash
set -euo pipefail

environment="${1:?Usage: deploy.sh qa|prod IMAGE}"
image="${2:?Usage: deploy.sh qa|prod IMAGE}"

case "$environment" in
  qa)
    container="practical-qa"
    port=8081
    ;;
  prod)
    container="practical-prod"
    port=8082
    ;;
  *)
    echo "Error: environment must be qa or prod" >&2
    exit 2
    ;;
esac

printf 'Deploying %s to %s on local port %s\n' "$image" "$environment" "$port"
docker pull "$image"
docker rm -f "$container" >/dev/null 2>&1 || true
docker run -d \
  --name "$container" \
  --restart unless-stopped \
  --memory 128m \
  --pids-limit 64 \
  -p "127.0.0.1:${port}:80" \
  "$image"

curl --fail --silent --show-error \
  --retry 8 --retry-delay 2 --retry-connrefused \
  "http://127.0.0.1:${port}/" >/dev/null

echo "Success: $environment is healthy at http://127.0.0.1:$port/"
docker ps --filter "name=^/${container}$" --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'
