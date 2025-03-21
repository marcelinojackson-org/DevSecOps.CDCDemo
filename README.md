# DevSecOps CDC Demo (MySQL -> Postgres)

## What this does
- MySQL is the source database with 3 tables: `customers`, `orders`, `order_items`.
- Debezium reads MySQL binlog changes and publishes them to Kafka topics.
- A JDBC sink connector consumes those topics and writes changes into Postgres.
- Kafka UI lets you browse topics and see changes in real time.
- Passwords live in `.secrets/secrets.env` and are never embedded in `docker-compose.yml`.
