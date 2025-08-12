# React + NestJS + Postgres (CRUD)

Full‑stack user management app with React (frontend), NestJS (backend), and Postgres.

## 🚀 Quick start (Docker)

```bash
# Build and start selected services (or use "all")
./scripts/build.sh all

# Or only app core
./scripts/build.sh frontend backend postgres pgadmin

## Services

- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- Swagger: http://localhost:8080/api
- pgAdmin: http://localhost:5050 (admin@admin.com / admin)
```

To start everything:

```bash
./scripts/build.sh all
```

## ♻️ Rebuild workflow

Use a single script with two modes:

```bash
# For config/env updates → SOFT (no image build)
./scripts/rebuild.sh <service|all> soft

# For code/Dockerfile changes → HARD (rebuild image)
./scripts/rebuild.sh <service|all> hard
```

Examples:

```bash
# After backend code edits
./scripts/rebuild.sh backend hard

# Recreate frontend to pick up env/static content changes
./scripts/rebuild.sh frontend soft
```

Supported services: `frontend backend postgres pgadmin`. Use `all` for everything.

## Database access

pgAdmin is included for DB administration at http://localhost:5050 (default: admin@admin.com / admin). Default Postgres connection inside Docker uses host `postgres`, port `5432`.

## 🧑‍💻 Local frontend dev

```bash
cd frontend
yarn install
yarn dev   # http://localhost:3000
```

## 🧑‍💻 Local frontend dev

```bash
cd backend
yarn install
yarn start   # http://localhost:8080
```

## 🔧 Useful commands

```bash
# Tail service logs
docker compose logs -f backend

# Run simple API smoke tests
./scripts/test-api.sh.sh

# Health-check API
curl -s http://localhost:8080/api | jq .
```