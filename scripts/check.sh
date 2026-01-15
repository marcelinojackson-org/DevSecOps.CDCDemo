#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_file="$root_dir/.secrets/secrets.env"

if [ ! -f "$env_file" ]; then
  echo "Missing $env_file. Run ./scripts/init.sh first." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$env_file"
set +a

cd "$root_dir"

echo "MySQL row counts:"
docker compose exec -T mysql mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" appdb <<'SQL'
SELECT 'customers' AS table_name, COUNT(*) AS total FROM customers;
SELECT 'orders' AS table_name, COUNT(*) AS total FROM orders;
SELECT 'order_items' AS table_name, COUNT(*) AS total FROM order_items;
SQL

echo

echo "Postgres row counts:"
docker compose exec -T postgres env PGPASSWORD="$POSTGRES_PASSWORD" psql -U "$POSTGRES_USER" -d appdb <<'SQL'
SELECT 'customers' AS table_name, COUNT(*) AS total FROM customers;
SELECT 'orders' AS table_name, COUNT(*) AS total FROM orders;
SELECT 'order_items' AS table_name, COUNT(*) AS total FROM order_items;
SQL

echo

echo "Latest customer in Postgres:"
docker compose exec -T postgres env PGPASSWORD="$POSTGRES_PASSWORD" psql -U "$POSTGRES_USER" -d appdb <<'SQL'
SELECT id, first_name, last_name, email, created_at
FROM customers
ORDER BY id DESC
LIMIT 1;
SQL
