# Go API with PostgreSQL

A complete CRUD API application built with Go (Gin framework), PostgreSQL, and Docker Compose.

## 🚀 Features

- **Full CRUD Operations**: Complete Create, Read, Update, Delete functionality
- **PostgreSQL Database**: Robust relational database with native SQL queries
- **Docker Compose**: Easy development and deployment setup
- **Swagger Documentation**: Interactive API documentation with OpenAPI 3
- **Input Validation**: Request validation using Gin binding
- **Password Security**: BCrypt password hashing for secure authentication
- **Go 1.21**: Modern Go features and performance
- **User Management**: Complete CRUD operations for users
- **Authentication**: Login and signup functionality with secure password handling
- **pgAdmin**: Web-based database management interface
- **Automatic Database Setup**: PostgreSQL initialization handled automatically
- **Flexible Service Management**: Start individual services or rebuild specific containers

## 📋 Prerequisites

- Go 1.21 or higher
- Docker and Docker Compose

## ⚡ Quick Start

### Start All Services (Recommended)

```bash
# Start all services (PostgreSQL, Go API, pgAdmin)
./scripts/start.sh
```

This will start:
- **Go API** at http://localhost:8080
- **Swagger Docs** at http://localhost:8080/api
- **pgAdmin** at http://localhost:5050
- **PostgreSQL** on port 5432

### Start Specific Services

```bash
# Start only the Go backend
./scripts/start.sh --backend-only

# Start only PostgreSQL database
./scripts/start.sh --postgres-only

# Start only pgAdmin interface
./scripts/start.sh --pgadmin-only
```

### Manual Start

```bash
# Start with Docker Compose
docker-compose up -d

# Start the application locally
go run main.go
```

## 🔧 Service Management

### Start Script Options

The `./scripts/start.sh` script provides flexible service management:

```bash
# Start all services
./scripts/start.sh

# Start specific services only
./scripts/start.sh --backend-only     # Only Go API
./scripts/start.sh --postgres-only    # Only PostgreSQL
./scripts/start.sh --pgadmin-only     # Only pgAdmin

# Rebuild specific services
./scripts/start.sh --rebuild-backend  # Rebuild Go app only
./scripts/start.sh --rebuild-postgres # Rebuild PostgreSQL only
./scripts/start.sh --rebuild-pgadmin  # Rebuild pgAdmin only

# Rebuild everything
./scripts/start.sh --rebuild

# Show help
./scripts/start.sh --help
```

### Use Cases for Service-Specific Starts

- **`--backend-only`**: When you only need to test the API without database overhead
- **`--postgres-only`**: When you need to work with the database directly
- **`--pgadmin-only`**: When you need database management interface
- **`--rebuild-backend`**: After making code changes to the Go application
- **`--rebuild-postgres`**: When you need to reset the database
- **`--rebuild-pgadmin`**: When pgAdmin configuration needs updating

## 🗄️ Database Management

### pgAdmin Web Interface
- **URL**: http://localhost:5050
- **Email**: admin@admin.com
- **Password**: admin

### Database Connection Details
- **Host**: postgres (or localhost)
- **Port**: 5432
- **Database**: test_db
- **Username**: postgres
- **Password**: password

### Quick Database Commands
```bash
# View all tables
docker exec -it postgres psql -U postgres -d test_db -c "\dt"

# View users
docker exec -it postgres psql -U postgres -d test_db -c "SELECT * FROM users;"

# Check database status
docker exec -it postgres psql -U postgres -c "\l"
```

### Database Initialization
The `test_db` database is automatically created when the PostgreSQL container starts for the first time using:
- **Environment variable**: `POSTGRES_DB: test_db`
- **Init script**: `init.sql` (runs automatically on first startup)

No manual database initialization is needed!

## 🔌 API Endpoints

### Users
- `POST /api/users` - Create a new user
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `PATCH /api/users/:id` - Partially update user
- `DELETE /api/users/:id` - Delete user

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/signup` - User registration

### Health & Documentation
- `GET /` - Root endpoint
- `GET /health` - Health check
- `GET /api` - Swagger documentation

## 🧪 Testing

### Test All APIs
```bash
./scripts/test-api.sh
```

### Manual Testing Examples
```bash
# Create a user
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "age": 30,
    "is_active": true
  }'

# Get all users
curl http://localhost:8080/api/users

# Get user by ID
curl http://localhost:8080/api/users/1

# Update user
curl -X PUT http://localhost:8080/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Doe",
    "age": 31
  }'

# Delete user
curl -X DELETE http://localhost:8080/api/users/1

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

## 🛠️ Development

### Available Commands
```bash
go run main.go         # Start in development mode
go build               # Build the application
go test                # Run tests
go mod tidy            # Clean up dependencies
go mod download        # Download dependencies
```

### Environment Variables
Copy `env.example` to `.env` and configure:

```env
# Database Configuration
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=test_db
DATABASE_USER=postgres
DATABASE_PASSWORD=password

# Application Configuration
PORT=8080
```

## 🐳 Docker Commands

```bash
# Start all services
docker-compose up -d

# Start specific services
docker-compose up -d backend
docker-compose up -d postgres
docker-compose up -d pgadmin

# View logs
docker-compose logs -f
docker-compose logs -f backend
docker-compose logs -f postgres

# Stop all services
docker-compose down

# Rebuild and start
docker-compose up -d --build

# Remove volumes (will delete database data)
docker-compose down -v

# Clean up everything
./scripts/cleanup.sh
```

## 🔧 Scripts

### Start Script with All Options
```bash
# Normal start
./scripts/start.sh

# Start specific services
./scripts/start.sh --backend-only     # Start only Go app
./scripts/start.sh --postgres-only    # Start only PostgreSQL
./scripts/start.sh --pgadmin-only     # Start only pgAdmin

# Rebuild specific containers
./scripts/start.sh --rebuild-backend   # Rebuild Go app only
./scripts/start.sh --rebuild-postgres  # Rebuild PostgreSQL only
./scripts/start.sh --rebuild-pgadmin   # Rebuild pgAdmin only

# Rebuild everything
./scripts/start.sh --rebuild

# Show help
./scripts/start.sh --help
```

### Other Scripts
- `./scripts/test-api.sh` - Test all API endpoints
- `./scripts/cleanup.sh` - Clean up all Docker resources

## 📊 Database Schema

### Users Table
- `id` (Primary Key, Auto-increment)
- `name` (VARCHAR 100, Not Null)
- `email` (VARCHAR 255, Unique, Not Null)
- `password` (VARCHAR 255, Not Null, BCrypt hashed)
- `age` (INT, Optional)
- `is_active` (BOOLEAN, Default true)
- `created_at` (TIMESTAMP, Auto-generated)
- `updated_at` (TIMESTAMP, Auto-updated)

## 📁 Project Structure

```
backend/
├── main.go                    # Main application entry point
├── go.mod                     # Go module file
├── go.sum                     # Go dependency checksums
├── Dockerfile                 # Docker configuration
├── docker-compose.yml         # Docker Compose configuration
├── init.sql                   # Database initialization script
├── models/
│   └── user.go               # User model and DTOs
├── handlers/
│   ├── user_handlers.go      # User CRUD handlers
│   └── auth_handlers.go      # Authentication handlers
├── scripts/
│   ├── start.sh              # Service management script
│   ├── test-api.sh           # API testing script
│   └── cleanup.sh            # Cleanup script
└── README.md                 # This file
```

## 📚 Dependencies

### Core Dependencies
- **gin-gonic/gin**: HTTP web framework
- **lib/pq**: PostgreSQL driver
- **golang-jwt/jwt**: JWT token handling
- **golang.org/x/crypto**: BCrypt password hashing
- **swaggo/gin-swagger**: Swagger documentation
- **swaggo/swag**: Swagger code generation

### Development Dependencies
- **go-playground/validator**: Input validation

## 🔍 Troubleshooting

### Common Issues

**Backend not connecting to database:**
- Ensure PostgreSQL container is running: `docker-compose ps`
- Check database exists: `docker exec postgres psql -U postgres -c "\l"`
- Restart backend: `docker-compose restart backend`
- Rebuild database: `./scripts/start.sh --rebuild-postgres`

**pgAdmin not showing servers:**
- Check servers.json configuration
- Restart pgAdmin: `docker-compose restart pgadmin`
- Rebuild pgAdmin: `./scripts/start.sh --rebuild-pgadmin`
- Verify PostgreSQL is accessible from pgAdmin container

**Port conflicts:**
- Check if ports 8080, 5432, or 5050 are in use
- Stop conflicting services or change ports in docker-compose.yml

**Service-specific issues:**
- Use service-specific start options to isolate problems
- Check individual service logs: `docker-compose logs -f [service_name]`
- Rebuild specific services as needed

### Useful Commands
```bash
# Check container status
docker-compose ps

# View logs for specific service
docker-compose logs -f backend
docker-compose logs -f postgres
docker-compose logs -f pgadmin

# Access PostgreSQL
docker exec -it postgres psql -U postgres -d test_db

# Rebuild specific service
./scripts/start.sh --rebuild-backend
./scripts/start.sh --rebuild-postgres
./scripts/start.sh --rebuild-pgadmin

# Start only what you need
./scripts/start.sh --backend-only
./scripts/start.sh --postgres-only
```

### Service Isolation Testing

When debugging issues, you can isolate services:

```bash
# Test only the database
./scripts/start.sh --postgres-only
docker exec -it postgres psql -U postgres -d test_db

# Test only the backend (will fail without database)
./scripts/start.sh --backend-only

# Test only pgAdmin
./scripts/start.sh --pgadmin-only
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License. 