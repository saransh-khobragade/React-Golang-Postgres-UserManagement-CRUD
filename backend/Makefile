.PHONY: help build run test clean deps docker-build docker-run

# Default target
help:
	@echo "Available commands:"
	@echo "  make build        - Build the application"
	@echo "  make run          - Run the application locally"
	@echo "  make test         - Run tests"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make deps         - Download dependencies"
	@echo "  make docker-build - Build Docker image"
	@echo "  make docker-run   - Run with Docker Compose"

# Build the application
build:
	go build -o main .

# Run the application locally
run:
	go run main.go

# Run tests
test:
	go test ./...

# Clean build artifacts
clean:
	go clean
	rm -f main

# Download dependencies
deps:
	go mod download
	go mod tidy

# Build Docker image
docker-build:
	docker-compose build

# Run with Docker Compose
docker-run:
	docker-compose up -d

# Stop Docker Compose
docker-stop:
	docker-compose down

# View logs
docker-logs:
	docker-compose logs -f

# Full rebuild
docker-rebuild:
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d 