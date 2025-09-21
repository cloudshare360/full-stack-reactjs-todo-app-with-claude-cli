#!/bin/bash

# Load seed data into MongoDB for Todo Application
# This script loads sample todos into the database

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

# Navigate to the directory containing docker-compose.yml
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

print_status "Loading seed data into MongoDB..."

# Check if MongoDB container is running
if ! docker ps | grep -q "todo-mongodb"; then
    print_error "MongoDB container is not running. Please start it first with './scripts/start-mongodb.sh'"
    exit 1
fi

# Wait for MongoDB to be ready
print_status "Waiting for MongoDB to be ready..."
sleep 5

# Check if seed data file exists
if [ ! -f "seed-data/sample-todos.json" ]; then
    print_error "Seed data file not found: seed-data/sample-todos.json"
    exit 1
fi

# Clear existing data (optional)
if [ "$1" = "--clear" ]; then
    print_warning "Clearing existing todos..."
    docker exec todo-mongodb mongosh \
        --username admin \
        --password password123 \
        --authenticationDatabase admin \
        --eval "db.getSiblingDB('todoapp').todos.deleteMany({})"
fi

# Load seed data using mongoimport
print_status "Importing sample todos..."
docker exec -i todo-mongodb mongoimport \
    --username admin \
    --password password123 \
    --authenticationDatabase admin \
    --db todoapp \
    --collection todos \
    --file /seed-data/sample-todos.json \
    --jsonArray \
    --upsert

# Verify data was loaded
TOTAL_TODOS=$(docker exec todo-mongodb mongosh \
    --username admin \
    --password password123 \
    --authenticationDatabase admin \
    --quiet \
    --eval "db.getSiblingDB('todoapp').todos.countDocuments()")

if [ "$TOTAL_TODOS" -gt 0 ]; then
    print_success "Seed data loaded successfully!"
    print_status "Total todos in database: $TOTAL_TODOS"

    # Show some statistics
    print_status "Getting database statistics..."
    docker exec todo-mongodb mongosh \
        --username admin \
        --password password123 \
        --authenticationDatabase admin \
        --quiet \
        --eval "
        db = db.getSiblingDB('todoapp');
        const stats = {
            total: db.todos.countDocuments(),
            completed: db.todos.countDocuments({ completed: true }),
            pending: db.todos.countDocuments({ completed: false }),
            high_priority: db.todos.countDocuments({ priority: 'high' }),
            medium_priority: db.todos.countDocuments({ priority: 'medium' }),
            low_priority: db.todos.countDocuments({ priority: 'low' })
        };
        console.log('📊 Database Statistics:');
        console.log('- Total todos:', stats.total);
        console.log('- Completed:', stats.completed);
        console.log('- Pending:', stats.pending);
        console.log('- High priority:', stats.high_priority);
        console.log('- Medium priority:', stats.medium_priority);
        console.log('- Low priority:', stats.low_priority);
        "

else
    print_error "Failed to load seed data"
    exit 1
fi

# Show access information
echo ""
print_success "You can now access your todos via:"
echo "  🌐 Mongo Express: http://localhost:8081"
echo "  🔗 API Endpoint: http://localhost:5000/api/todos"
echo "  📱 Frontend: http://localhost:3000"

echo ""
print_status "To reload seed data, run: '$0 --clear'"