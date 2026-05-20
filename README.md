# n8n Railway Deployment

Simple production-oriented deployment of [n8n](https://n8n.io/) on [Railway](https://railway.com/) using:

- Docker
- Railway Postgres
- Persistent volumes
- Public webhooks

This setup avoids the common Railway permissions issue with `/home/node/.n8n` while keeping the deployment simple and portable.

---

# Stack

- n8n
- PostgreSQL
- Railway
- Docker

---

# Dockerfile

```dockerfile
FROM n8nio/n8n:latest

USER root

COPY docker-entrypoint.sh /usr/local/bin/railway-entrypoint.sh

RUN mkdir -p /home/node/.n8n \
  && chown -R node:node /home/node/.n8n \
  && chmod +x /usr/local/bin/railway-entrypoint.sh

ENTRYPOINT ["/bin/sh", "/usr/local/bin/railway-entrypoint.sh"]
CMD ["start"]
```

---

# Railway Setup

## 1. Create Project

Create a new Railway project.

---

## 2. Add PostgreSQL

Add a PostgreSQL service from Railway.

---

## 3. Deploy This Repository

Deploy this repository as a service from GitHub.

Railway will automatically detect the `Dockerfile`.

---

## 4. Add Persistent Volume

Add a volume to the n8n service.

Mount path:

```txt
/home/node/.n8n
```

This stores:
- credentials
- encryption state
- instance configuration
- community packages

Without this volume, credentials and instance state may reset between deploys.

---

# Environment Variables

Set the following variables on the n8n service.

## Required

```env
PORT=5678
N8N_PORT=5678

DB_TYPE=postgresdb

DB_POSTGRESDB_HOST=${{Postgres.PGHOST}}
DB_POSTGRESDB_PORT=${{Postgres.PGPORT}}
DB_POSTGRESDB_DATABASE=${{Postgres.PGDATABASE}}
DB_POSTGRESDB_USER=${{Postgres.PGUSER}}
DB_POSTGRESDB_PASSWORD=${{Postgres.PGPASSWORD}}

N8N_ENCRYPTION_KEY=replace-with-long-random-secret
```

---

## Webhook Configuration

Replace `your-app.up.railway.app` with your Railway domain.

```env
N8N_HOST=your-app.up.railway.app
N8N_PROTOCOL=https

N8N_EDITOR_BASE_URL=https://your-app.up.railway.app
WEBHOOK_URL=https://your-app.up.railway.app/
```

---

## Timezone

```env
GENERIC_TIMEZONE=America/New_York
TZ=America/New_York
```

---

## Recommended Execution Cleanup

Recommended for preventing execution history from growing indefinitely.

```env
EXECUTIONS_DATA_PRUNE=true
EXECUTIONS_DATA_MAX_AGE=168
```

This removes execution history older than:
- 168 hours (7 days)

Adjust as needed.

---

# Recommended Railway Resources

## n8n

- 2 vCPU
- 2 GB RAM

## PostgreSQL

- 1–2 vCPU
- 1–2 GB RAM

This is typically more than enough for:
- webhooks
- scheduled workflows
- API integrations
- moderate concurrency

---

# Exposing n8n

After deployment:

1. Open the Railway service
2. Go to:
   - Settings
   - Networking
3. Generate a public domain

Use that domain in:
- `N8N_HOST`
- `N8N_EDITOR_BASE_URL`
- `WEBHOOK_URL`

---

# Notes

## Why PostgreSQL?

n8n supports SQLite, but PostgreSQL is recommended for:
- production usage
- workflow reliability
- concurrent executions
- larger execution history

---

## Why Persist `/home/node/.n8n`?

This directory contains:
- credentials encryption metadata
- instance settings
- installed community nodes
- local n8n configuration

Persisting it prevents credentials/configuration from resetting after deploys.

---

# Future Improvements

Possible future upgrades:

- Redis + queue mode
- multiple n8n workers
- custom domains
- S3 binary storage
- external secrets management
- automated backups

For most small-to-medium automation setups, the current architecture is sufficient.
