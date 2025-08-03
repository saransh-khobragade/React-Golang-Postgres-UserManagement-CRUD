#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  ${GREEN}./scripts/start.sh${NC}                    # Start all services"
    echo -e "  ${GREEN}./scripts/start.sh --backend-only${NC}     # Start only Go backend"
    echo -e "  ${GREEN}./scripts/start.sh --postgres-only${NC}    # Start only PostgreSQL"
    echo -e "  ${GREEN}./scripts/start.sh --pgadmin-only${NC}     # Start only pgAdmin"
    echo -e "  ${GREEN}./scripts/start.sh --rebuild${NC}          # Rebuild all containers"
    echo -e "  ${GREEN}./scripts/start.sh --rebuild-backend${NC}  # Rebuild only the Go app"
    echo -e "  ${GREEN}./scripts/start.sh --rebuild-postgres${NC} # Rebuild only PostgreSQL"
    echo -e "  ${GREEN}./scripts/start.sh --rebuild-pgadmin${NC}  # Rebuild only pgAdmin"
    echo -e ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  ./scripts/start.sh --backend-only      # Start only backend service (Go)"
    echo -e "  ./scripts/start.sh --postgres-only     # Start only database"
    echo -e "  ./scripts/start.sh --rebuild-backend   # Rebuild app after code changes (Go)"
    echo -e "  ./scripts/start.sh --rebuild           # Complete fresh rebuild"
}

# Check for help flag
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_usage
    exit 0
fi

# Initialize flags
REBUILD_ALL=false
REBUILD_BACKEND=false
REBUILD_POSTGRES=false
REBUILD_PGADMIN=false
START_BACKEND_ONLY=false
START_POSTGRES_ONLY=false
START_PGADMIN_ONLY=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --rebuild|-r)
            REBUILD_ALL=true
            shift
            ;;
        --rebuild-backend)
            REBUILD_BACKEND=true
            shift
            ;;
        --rebuild-postgres)
            REBUILD_POSTGRES=true
            shift
            ;;
        --rebuild-pgadmin)
            REBUILD_PGADMIN=true
            shift
            ;;
        --backend-only)
            START_BACKEND_ONLY=true
            shift
            ;;
        --postgres-only)
            START_POSTGRES_ONLY=true
            shift
            ;;
        --pgadmin-only)
            START_PGADMIN_ONLY=true
            shift
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Check for conflicting options
if [ "$START_BACKEND_ONLY" = true ] && [ "$START_POSTGRES_ONLY" = true ]; then
    echo -e "${RED}❌ Cannot use --backend-only and --postgres-only together${NC}"
    exit 1
fi

if [ "$START_BACKEND_ONLY" = true ] && [ "$START_PGADMIN_ONLY" = true ]; then
    echo -e "${RED}❌ Cannot use --backend-only and --pgadmin-only together${NC}"
    exit 1
fi

if [ "$START_POSTGRES_ONLY" = true ] && [ "$START_PGADMIN_ONLY" = true ]; then
    echo -e "${RED}❌ Cannot use --postgres-only and --pgadmin-only together${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Starting Go CRUD API...${NC}"

# Handle rebuild scenarios
if [ "$REBUILD_ALL" = true ]; then
    echo -e "${YELLOW}🔨 Rebuild mode: Rebuilding ALL containers with no cache...${NC}"
    
    # Stop and remove existing containers
    echo -e "${YELLOW}📦 Stopping and removing existing containers...${NC}"
    docker-compose down
    
    # Remove all images related to this project
    echo -e "${YELLOW}🗑️  Removing existing images...${NC}"
    docker-compose down --rmi all
    
    # Rebuild with no cache
    echo -e "${YELLOW}🔨 Rebuilding all containers with no cache...${NC}"
    docker-compose build --no-cache

elif [ "$REBUILD_BACKEND" = true ] || [ "$REBUILD_POSTGRES" = true ] || [ "$REBUILD_PGADMIN" = true ]; then
    echo -e "${YELLOW}🔨 Partial rebuild mode...${NC}"
    
    # Stop specific services
    if [ "$REBUILD_BACKEND" = true ]; then
        echo -e "${YELLOW}📦 Stopping backend service...${NC}"
        docker-compose stop backend
        echo -e "${YELLOW}🔨 Rebuilding backend container...${NC}"
        docker-compose build --no-cache backend
    fi
    
    if [ "$REBUILD_POSTGRES" = true ]; then
        echo -e "${YELLOW}📦 Stopping postgres service...${NC}"
        docker-compose stop postgres
        echo -e "${YELLOW}🔨 Rebuilding postgres container...${NC}"
        docker-compose build --no-cache postgres
    fi
    
    if [ "$REBUILD_PGADMIN" = true ]; then
        echo -e "${YELLOW}📦 Stopping pgadmin service...${NC}"
        docker-compose stop pgadmin
        echo -e "${YELLOW}🔨 Rebuilding pgadmin container...${NC}"
        docker-compose build --no-cache pgadmin
    fi
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}📝 Creating .env file from template...${NC}"
    cp env.example .env
fi

# Start specific services based on flags
if [ "$START_BACKEND_ONLY" = true ]; then
    echo -e "${YELLOW}🚀 Starting only backend service...${NC}"
    docker-compose up -d backend
    
elif [ "$START_POSTGRES_ONLY" = true ]; then
    echo -e "${YELLOW}🚀 Starting only PostgreSQL service...${NC}"
    docker-compose up -d postgres
    
elif [ "$START_PGADMIN_ONLY" = true ]; then
    echo -e "${YELLOW}🚀 Starting only pgAdmin service...${NC}"
    docker-compose up -d pgadmin
    
else
    # Start all services
    echo -e "${YELLOW}🚀 Starting all services...${NC}"
    docker-compose up -d
fi

# Wait a moment for services to start
sleep 3

# Check if services are running
echo -e "${YELLOW}🔍 Checking service status...${NC}"
docker-compose ps

echo -e "${GREEN}✅ Services started successfully!${NC}"

# Show relevant endpoints based on what was started
if [ "$START_BACKEND_ONLY" = true ]; then
    echo -e "${BLUE}📋 Available endpoints:${NC}"
    echo -e "  • Go API: ${GREEN}http://localhost:8080${NC}"
    echo -e "  • Swagger Docs: ${GREEN}http://localhost:8080/api${NC}"
    echo -e "${YELLOW}⚠️  Note: Database services not started. Backend may not function properly.${NC}"
    
elif [ "$START_POSTGRES_ONLY" = true ]; then
    echo -e "${BLUE}📋 Available endpoints:${NC}"
    echo -e "  • PostgreSQL: ${GREEN}localhost:5432${NC}"
    echo -e "${YELLOW}⚠️  Note: Only database is running. Backend and pgAdmin not started.${NC}"
    
elif [ "$START_PGADMIN_ONLY" = true ]; then
    echo -e "${BLUE}📋 Available endpoints:${NC}"
    echo -e "  • pgAdmin: ${GREEN}http://localhost:5050${NC}"
    echo -e "    - Email: ${YELLOW}admin@admin.com${NC}"
    echo -e "    - Password: ${YELLOW}admin${NC}"
    echo -e "${YELLOW}⚠️  Note: Only pgAdmin is running. Backend and database not started.${NC}"
    
else
    echo -e "${BLUE}📋 Available endpoints:${NC}"
    echo -e "  • Go API: ${GREEN}http://localhost:8080${NC}"
    echo -e "  • Swagger Docs: ${GREEN}http://localhost:8080/api${NC}"
    echo -e "  • pgAdmin: ${GREEN}http://localhost:5050${NC}"
    echo -e "    - Email: ${YELLOW}admin@admin.com${NC}"
    echo -e "    - Password: ${YELLOW}admin${NC}"
fi

echo -e "${YELLOW}📝 Useful commands:${NC}"
echo -e "  • View logs: ${GREEN}docker-compose logs -f${NC}"
echo -e "  • Stop services: ${GREEN}docker-compose down${NC}"
echo -e "  • Start specific service: ${GREEN}./scripts/start.sh --backend-only${NC}"
echo -e "  • Rebuild all: ${GREEN}./scripts/start.sh --rebuild${NC}"
echo -e "  • Rebuild backend only: ${GREEN}./scripts/start.sh --rebuild-backend${NC}"
echo -e "  • Show help: ${GREEN}./scripts/start.sh --help${NC}" 