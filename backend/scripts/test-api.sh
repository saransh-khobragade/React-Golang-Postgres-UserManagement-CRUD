#!/bin/bash

# Go API - API Testing Script
# This script tests all the API endpoints of the Go-based CRUD API

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# API base URL
API_BASE="http://localhost:8080/api"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  API Testing - Go Version${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to check if API is running
check_api() {
    print_status "Checking if API is running..."
    
    if curl -s -f "$API_BASE/users" > /dev/null 2>&1; then
        print_success "API is running and accessible"
        return 0
    else
        print_error "API is not running or not accessible at $API_BASE"
        print_warning "Make sure to start the services first: ./scripts/start.sh"
        return 1
    fi
}

# Function to make API requests
make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4
    local description=$5
    
    print_status "Testing: $description"
    
    local response
    local status_code
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$API_BASE$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            "$API_BASE$endpoint")
    fi
    
    # Extract status code (last line)
    status_code=$(echo "$response" | tail -n1)
    # Extract response body (all lines except last)
    response_body=$(echo "$response" | head -n -1)
    
    if [ "$status_code" -eq "$expected_status" ]; then
        print_success "✓ $description (Status: $status_code)"
        echo "Response: $response_body" | jq '.' 2>/dev/null || echo "Response: $response_body"
    else
        print_error "✗ $description (Expected: $expected_status, Got: $status_code)"
        echo "Response: $response_body"
    fi
    
    echo ""
}

# Function to test user creation
test_create_user() {
    local test_data='{
        "name": "John Doe",
        "email": "john.doe@example.com",
        "password": "password123",
        "age": 30,
        "is_active": true
    }'
    
    make_request "POST" "/users" "$test_data" 201 "Create user"
}

# Function to test user creation with duplicate email
test_create_duplicate_user() {
    local test_data='{
        "name": "Jane Doe",
        "email": "john.doe@example.com",
        "password": "password456",
        "age": 25,
        "is_active": true
    }'
    
    make_request "POST" "/users" "$test_data" 409 "Create user with duplicate email"
}

# Function to test get all users
test_get_all_users() {
    make_request "GET" "/users" "" 200 "Get all users"
}

# Function to test get user by ID
test_get_user_by_id() {
    make_request "GET" "/users/1" "" 200 "Get user by ID"
}

# Function to test get non-existent user
test_get_nonexistent_user() {
    make_request "GET" "/users/999" "" 404 "Get non-existent user"
}

# Function to test update user
test_update_user() {
    local update_data='{
        "name": "John Updated",
        "age": 31
    }'
    
    make_request "PUT" "/users/1" "$update_data" 200 "Update user"
}

# Function to test update user with PATCH
test_patch_user() {
    local patch_data='{
        "is_active": false
    }'
    
    make_request "PATCH" "/users/1" "$patch_data" 200 "Update user with PATCH"
}

# Function to test update user with duplicate email
test_update_duplicate_email() {
    # First create another user
    local user2_data='{
        "name": "Jane Smith",
        "email": "jane.smith@example.com",
        "password": "password789",
        "age": 28,
        "is_active": true
    }'
    
    curl -s -X POST -H "Content-Type: application/json" \
        -d "$user2_data" "$API_BASE/users" > /dev/null
    
    # Now try to update first user with second user's email
    local update_data='{
        "email": "jane.smith@example.com"
    }'
    
    make_request "PUT" "/users/1" "$update_data" 409 "Update user with duplicate email"
}

# Function to test delete user
test_delete_user() {
    make_request "DELETE" "/users/2" "" 200 "Delete user"
}

# Function to test delete non-existent user
test_delete_nonexistent_user() {
    make_request "DELETE" "/users/999" "" 404 "Delete non-existent user"
}

# Function to test authentication
test_auth() {
    print_status "Testing Authentication Endpoints"
    echo ""
    
    # Test signup
    local signup_data='{
        "name": "Test User",
        "email": "test.user@example.com",
        "password": "testpass123",
        "age": 25
    }'
    
    make_request "POST" "/auth/signup" "$signup_data" 201 "User signup"
    
    # Test login with correct credentials
    local login_data='{
        "email": "test.user@example.com",
        "password": "testpass123"
    }'
    
    make_request "POST" "/auth/login" "$login_data" 200 "User login with correct credentials"
    
    # Test login with incorrect password
    local wrong_login_data='{
        "email": "test.user@example.com",
        "password": "wrongpassword"
    }'
    
    make_request "POST" "/auth/login" "$wrong_login_data" 401 "User login with incorrect password"
    
    # Test login with non-existent user
    local nonexistent_login_data='{
        "email": "nonexistent@example.com",
        "password": "password123"
    }'
    
    make_request "POST" "/auth/login" "$nonexistent_login_data" 401 "User login with non-existent user"
}

# Function to test validation
test_validation() {
    print_status "Testing Input Validation"
    echo ""
    
    # Test invalid email
    local invalid_email_data='{
        "name": "Test User",
        "email": "invalid-email",
        "password": "password123",
        "age": 25
    }'
    
    make_request "POST" "/users" "$invalid_email_data" 400 "Create user with invalid email"
    
    # Test short password
    local short_password_data='{
        "name": "Test User",
        "email": "test@example.com",
        "password": "123",
        "age": 25
    }'
    
    make_request "POST" "/users" "$short_password_data" 400 "Create user with short password"
    
    # Test short name
    local short_name_data='{
        "name": "A",
        "email": "test@example.com",
        "password": "password123",
        "age": 25
    }'
    
    make_request "POST" "/users" "$short_name_data" 400 "Create user with short name"
    
    # Test invalid age
    local invalid_age_data='{
        "name": "Test User",
        "email": "test@example.com",
        "password": "password123",
        "age": 200
    }'
    
    make_request "POST" "/users" "$invalid_age_data" 400 "Create user with invalid age"
}

# Function to test health endpoint
test_health() {
    print_status "Testing Health Endpoint"
    echo ""
    
    local response=$(curl -s -w "\n%{http_code}" "http://localhost:8080/health")
    local status_code=$(echo "$response" | tail -n1)
    local response_body=$(echo "$response" | head -n -1)
    
    if [ "$status_code" -eq 200 ]; then
        print_success "✓ Health check (Status: $status_code)"
        echo "Response: $response_body" | jq '.' 2>/dev/null || echo "Response: $response_body"
    else
        print_error "✗ Health check (Expected: 200, Got: $status_code)"
        echo "Response: $response_body"
    fi
    
    echo ""
}

# Main testing function
main() {
    print_header
    
    # Check if API is running
    if ! check_api; then
        exit 1
    fi
    
    print_status "Starting API tests..."
    echo ""
    
    # Test health endpoint
    test_health
    
    # Test user CRUD operations
    print_status "Testing User CRUD Operations"
    echo ""
    
    test_create_user
    test_create_duplicate_user
    test_get_all_users
    test_get_user_by_id
    test_get_nonexistent_user
    test_update_user
    test_patch_user
    test_update_duplicate_email
    test_delete_user
    test_delete_nonexistent_user
    
    # Test authentication
    test_auth
    
    # Test validation
    test_validation
    
    print_success "All tests completed!"
    echo ""
    print_status "API Documentation available at: http://localhost:8080/api"
}

# Run main function
main "$@" 