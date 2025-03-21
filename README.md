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
