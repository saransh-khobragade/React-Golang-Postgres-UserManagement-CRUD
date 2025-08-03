# React-Go-UserManagement-CRUD

A full-stack authentication and user management application built with React, Go, and PostgreSQL.

## 🚀 Quick Start

### 1. Start Backend Services

```bash
cd backend
# just want to start backend local
./gradlew bootRun
./scripts/start.sh --postgres-only 
./scripts/start.sh --pgadmin-only 


# Start all services (recommended for first time)
./scripts/start.sh

# Or start specific services
./scripts/start.sh --backend-only     # Only Go API
./scripts/start.sh --postgres-only    # Only database
./scripts/start.sh --pgadmin-only     # Only pgAdmin
```

### 2. Start Frontend

```bash
cd frontend
yarn dev
```

### 3. Access the Application

- **Frontend**: http://localhost:5173
- **API**: http://localhost:8080
- **API Docs**: http://localhost:8080/api
- **pgAdmin**: http://localhost:5050 (database password : password) 