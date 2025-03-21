#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
secrets_dir="$root_dir/.secrets"
env_file="$secrets_dir/secrets.env"

mkdir -p "$secrets_dir"

if [ ! -f "$env_file" ]; then
  cat <<'ENV' > "$env_file"
MYSQL_ROOT_PASSWORD=MySQL123$
MYSQL_USER=appuser
MYSQL_PASSWORD=MySQL123$
POSTGRES_USER=appuser
POSTGRES_PASSWORD=Postgres123$
ENV
fi

cd "$root_dir"

docker compose up -d --build

printf 'Waiting for Kafka Connect...'
for _ in {1..60}; do
  if curl -s http://localhost:8083/connectors >/dev/null; then
    printf ' ready.\n'
    break
  fi
  printf '.'
  sleep 2
  if [ "$_" -eq 60 ]; then
    printf '\nKafka Connect did not become ready in time.\n'
    exit 1
  fi
done

"$root_dir/scripts/register-connectors.sh"
