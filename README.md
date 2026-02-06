# DevSecOps.CDCDemo

Local change data capture (CDC) pipeline demo for streaming MySQL changes into PostgreSQL with Debezium and Kafka Connect.

## Repository Status

The `main` branch currently contains governance files:

- `CONTRIBUTING.md`
- `LICENSE`
- `NOTICE`

The runnable CDC stack and scripts are currently on the `features` branch.

## What The Demo Covers

- MySQL source database with seeded transactional data
- Debezium source connector reading MySQL binlog changes
- Kafka topics for CDC event transport
- JDBC sink connector writing into PostgreSQL
- Kafka UI for topic and consumer inspection

## CDC Flow

1. Changes are written to MySQL tables.
2. Debezium captures row-level changes from binlog.
3. Kafka Connect publishes events to Kafka topics.
4. JDBC sink connector consumes those topics.
5. PostgreSQL receives and materializes downstream rows.

## Working Branch Layout

On `features`, the project contains:

- `docker-compose.yml` for the full local stack
- `connect/` and `connectors/` for source and sink connector setup
- `mysql/` and `postgres/` initialization scripts
- `scripts/` helper scripts for bootstrap and validation
- `docs/screenshots/` for Kafka UI verification images

## Run The Demo

From this repo, switch to the implementation branch:

```bash
git checkout features
./scripts/init.sh
./scripts/add-data.sh
./scripts/check.sh
```

## Service Endpoints

- Kafka UI: `http://localhost:8080`
- Kafka Connect: `http://localhost:8083`
- Schema Registry: `http://localhost:8081`
- MySQL: `localhost:3306`
- PostgreSQL: `localhost:5432`

## License

Licensed under Apache License 2.0. See `LICENSE`.
