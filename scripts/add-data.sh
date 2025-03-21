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

docker compose exec -T mysql mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" appdb <<'SQL'
INSERT INTO customers (first_name, last_name, email)
VALUES ('Added', 'Customer', CONCAT('added_', UNIX_TIMESTAMP(), '@example.com'));

SET @customer_id = LAST_INSERT_ID();

INSERT INTO orders (customer_id, order_total, status)
VALUES (@customer_id, 123.45, 'NEW');

SET @order_id = LAST_INSERT_ID();

INSERT INTO order_items (order_id, sku, quantity, price)
VALUES
  (@order_id, 'SKU-ADD-001', 2, 9.99),
  (@order_id, 'SKU-ADD-002', 1, 19.99);
SQL

printf 'Inserted 1 customer, 1 order, 2 items into MySQL.\n'
