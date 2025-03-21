# DevSecOps CDC Demo (MySQL -> Postgres)

## What this does
- MySQL is the source database with 3 tables: `customers`, `orders`, `order_items`.
- Debezium reads MySQL binlog changes and publishes them to Kafka topics.
- A JDBC sink connector consumes those topics and writes changes into Postgres.
- Kafka UI lets you browse topics and see changes in real time.
- Passwords live in `.secrets/secrets.env` and are never embedded in `docker-compose.yml`.

## Quick start (the "initiate" button)
1) From the repo root:
```
./scripts/init.sh
```
This generates `.secrets/secrets.env` (if missing), brings up the stack, and registers connectors.

2) Open Kafka UI:
- http://localhost:8080
  - Topics to watch: `dbserver1.appdb.customers`, `dbserver1.appdb.orders`, `dbserver1.appdb.order_items`

3) Add more data to MySQL:
```
./scripts/add-data.sh
```

4) Verify replication into Postgres:
```
./scripts/check.sh
```

## Seeded data
- `customers`: 100 rows
- `orders`: 2,000 rows
- `order_items`: 10,000 rows

## Services and ports
- MySQL: `localhost:3306`
- Postgres: `localhost:5432`
- Kafka: `localhost:9092`
- Kafka Connect: `localhost:8083`
- Schema Registry: `localhost:8081`
- Kafka UI: `localhost:8080`

## Secrets
- Stored in `.secrets/secrets.env`
- Generated defaults are non-sensitive and can be changed anytime

## Notes
- If you update connector templates, re-run:
```
./scripts/register-connectors.sh
```
