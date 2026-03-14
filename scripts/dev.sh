#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_SCRIPT="$ROOT_DIR/scripts/build-index.sh"
WATCH_DIRS=(
  "$ROOT_DIR/partials"
  "$ROOT_DIR/css"
  "$ROOT_DIR/js"
  "$ROOT_DIR/assets"
)
PORT="${PORT:-4000}"
HOST="${HOST:-127.0.0.1}"
POLL_INTERVAL="${POLL_INTERVAL:-1}"

build_site() {
  bash "$BUILD_SCRIPT"
  printf '[dev] rebuilt index.html at %s\n' "$(date '+%H:%M:%S')"
}

snapshot_tree() {
  find "${WATCH_DIRS[@]}" -type f -print0 2>/dev/null \
    | sort -z \
    | xargs -0 stat -f '%N %m'
}

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]]; then
    kill "$SERVER_PID" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

build_site

printf '[dev] serving http://%s:%s\n' "$HOST" "$PORT"
python3 -m http.server "$PORT" --bind "$HOST" --directory "$ROOT_DIR" >/dev/null 2>&1 &
SERVER_PID=$!

LAST_SNAPSHOT="$(snapshot_tree)"

while true; do
  sleep "$POLL_INTERVAL"
  CURRENT_SNAPSHOT="$(snapshot_tree)"

  if [[ "$CURRENT_SNAPSHOT" != "$LAST_SNAPSHOT" ]]; then
    build_site
    LAST_SNAPSHOT="$CURRENT_SNAPSHOT"
  fi
done
