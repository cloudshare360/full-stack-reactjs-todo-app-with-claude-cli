#!/bin/bash

# Stop MongoDB services for Todo Application
# This script stops and removes MongoDB and Mongo Express containers

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

print_status "Stopping MongoDB services for Todo Application..."

# Navigate to the directory containing docker-compose.yml
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found in $(pwd)"
    exit 1
fi

# Stop and remove containers
print_status "Stopping containers..."
$DOCKER_COMPOSE down

# Optionally remove volumes (commented out by default to preserve data)
if [ "$1" = "--remove-data" ]; then
    print_warning "Removing data volumes..."
    $DOCKER_COMPOSE down -v
    print_warning "All data has been removed!"
fi

# Verify containers are stopped
if docker ps | grep -q "todo-"; then
    print_warning "Some containers may still be running:"
    docker ps --filter "name=todo-"
else
    print_success "All Todo Application containers have been stopped"
fi

# Show instructions
echo ""
print_status "MongoDB services stopped successfully!"
print_status "To start services again, run: './scripts/start-mongodb.sh'"

if [ "$1" != "--remove-data" ]; then
    print_status "Data is preserved in Docker volumes"
    print_status "To remove data completely, run: '$0 --remove-data'"
fi

# Show remaining resources
if docker volume ls | grep -q "todo-"; then
    echo ""
    print_status "Remaining volumes:"
    docker volume ls --filter "name=todo-"
fi