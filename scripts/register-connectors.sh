#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
secrets_dir="$root_dir/.secrets"
env_file="$secrets_dir/secrets.env"
render_dir="$secrets_dir/connectors"

if [ ! -f "$env_file" ]; then
  echo "Missing $env_file. Run ./scripts/init.sh first." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$env_file"
set +a

mkdir -p "$render_dir"

render_template() {
  local input="$1"
  local output="$2"

  if command -v envsubst >/dev/null 2>&1; then
    envsubst < "$input" > "$output"
    return
  fi

  python3 - <<PY
import os
import re

with open("$input", "r", encoding="utf-8") as fh:
    data = fh.read()

def repl(match):
    key = match.group(1)
    return os.environ.get(key, "")

out = re.sub(r"\$\{([^}]+)\}", repl, data)
with open("$output", "w", encoding="utf-8") as fh:
    fh.write(out)
PY
}

render_template "$root_dir/connectors/mysql-source.template.json" "$render_dir/mysql-source.json"
render_template "$root_dir/connectors/postgres-sink.template.json" "$render_dir/postgres-sink.json"

extract_config() {
  local input="$1"
  local output="$2"

  python3 - <<PY
import json

with open("$input", "r", encoding="utf-8") as fh:
    data = json.load(fh)

with open("$output", "w", encoding="utf-8") as fh:
    json.dump(data.get("config", {}), fh)
PY
}

extract_config "$render_dir/mysql-source.json" "$render_dir/mysql-source.config.json"
extract_config "$render_dir/postgres-sink.json" "$render_dir/postgres-sink.config.json"

register_connector() {
  local name="$1"
  local payload="$2"
  local config_payload="$3"
  local status

  status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8083/connectors/$name")
  if [ "$status" = "200" ]; then
    curl -s -X PUT -H "Content-Type: application/json" \
      --data "@$config_payload" \
      "http://localhost:8083/connectors/$name/config" >/dev/null
    echo "Updated connector: $name"
    return
  fi

  curl -s -X POST -H "Content-Type: application/json" \
    --data "@$payload" \
    "http://localhost:8083/connectors" >/dev/null
  echo "Created connector: $name"
}

register_connector "mysql-source" "$render_dir/mysql-source.json" "$render_dir/mysql-source.config.json"
register_connector "postgres-sink" "$render_dir/postgres-sink.json" "$render_dir/postgres-sink.config.json"
