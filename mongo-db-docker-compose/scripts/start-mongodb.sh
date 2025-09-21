#!/bin/bash

# Start MongoDB services for Todo Application
# This script starts MongoDB and Mongo Express services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose > /dev/null 2>&1; then
    if ! docker compose version > /dev/null 2>&1; then
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

print_status "Starting MongoDB services for Todo Application..."

# Navigate to the directory containing docker-compose.yml
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found in $(pwd)"
    exit 1
fi

# Start the services
print_status "Starting MongoDB and Mongo Express..."
$DOCKER_COMPOSE up -d

# Wait for services to be ready
print_status "Waiting for services to be ready..."
sleep 10

# Check if MongoDB is running
if docker ps | grep -q "todo-mongodb"; then
    print_success "MongoDB is running on port 27017"
else
    print_error "Failed to start MongoDB"
    exit 1
fi

# Check if Mongo Express is running
if docker ps | grep -q "todo-mongo-express"; then
    print_success "Mongo Express is running on port 8081"
    print_status "Access Mongo Express at: http://localhost:8081"
    print_status "Username: admin | Password: admin123"
else
    print_warning "Mongo Express may not be ready yet. Please wait a moment and check http://localhost:8081"
fi

# Show running containers
print_status "Running containers:"
docker ps --filter "name=todo-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Show logs command
print_status "To view logs, run:"
echo "  $DOCKER_COMPOSE logs -f"

# Show connection information
echo ""
print_success "MongoDB Connection Information:"
echo "  Host: localhost"
echo "  Port: 27017"
echo "  Database: todoapp"
echo "  Admin User: admin"
echo "  Admin Password: password123"
echo "  App User: todouser"
echo "  App Password: todopass123"

echo ""
print_success "Mongo Express Web Interface:"
echo "  URL: http://localhost:8081"
echo "  Username: admin"
echo "  Password: admin123"

echo ""
print_status "MongoDB services started successfully!"
print_status "Run './scripts/stop-mongodb.sh' to stop the services"