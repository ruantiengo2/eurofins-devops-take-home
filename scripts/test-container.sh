#!/usr/bin/env bash
set -euo pipefail

image="${1:?Usage: bash scripts/test-container.sh IMAGE}"
container=""
cleanup() {
  if [[ -n "$container" ]]; then
    docker logs "$container" || true
    docker rm --force "$container" >/dev/null || true
  fi
}
trap cleanup EXIT

container=$(docker run --detach --publish 127.0.0.1::8080 "$image")
port=$(docker port "$container" 8080/tcp | awk -F: '{print $NF}')
base="http://127.0.0.1:$port"
ready=false
for attempt in {1..30}; do
  if curl --fail --silent --max-time 2 "$base/health" >/dev/null; then
    ready=true
    break
  fi
  sleep 1
done
[[ "$ready" == true ]] || { echo "Container did not become healthy"; exit 1; }

check() {
  local path="$1" expected="$2" response
  response=$(curl --silent --show-error --max-time 10 --write-out '\n%{http_code}' "$base$path")
  [[ "$response" == "$expected"$'\n200' ]] || {
    printf 'Unexpected response for %s: %s\n' "$path" "$response"
    exit 1
  }
  printf 'PASS %s -> HTTP 200; %s\n' "$path" "$expected"
}
check / 'Hello World!'
check /health 'Healthy'
[[ "$(docker inspect --format '{{.State.Running}}' "$container")" == true ]]
