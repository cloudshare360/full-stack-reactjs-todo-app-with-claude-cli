#!/bin/bash

# Restore MongoDB data for Todo Application
# This script restores a backup of the todoapp database

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

# Check if backup file is provided
if [ $# -eq 0 ]; then
    print_error "Usage: $0 <backup_file.tar.gz>"
    print_status "Example: $0 backups/todoapp_backup_20250101_120000.tar.gz"
    echo ""
    print_status "Available backups:"
    ls -lh backups/*.tar.gz 2>/dev/null || print_warning "No backups found"
    exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    print_error "Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Navigate to the directory containing docker-compose.yml
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Check if MongoDB container is running
if ! docker ps | grep -q "todo-mongodb"; then
    print_error "MongoDB container is not running. Please start it first with './scripts/start-mongodb.sh'"
    exit 1
fi

print_warning "⚠️  IMPORTANT: This will replace all existing data in the todoapp database!"
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Restore cancelled."
    exit 0
fi

# Extract backup filename for temporary directory
BACKUP_BASENAME=$(basename "$BACKUP_FILE" .tar.gz)

print_status "Restoring database from: $BACKUP_FILE"

# Copy backup file to container if it's not already there
if [[ "$BACKUP_FILE" == backups/* ]]; then
    # File is already in the backups directory (mounted volume)
    CONTAINER_BACKUP_FILE="/backups/$(basename "$BACKUP_FILE")"
else
    # Copy file to container
    print_status "Copying backup file to container..."
    docker cp "$BACKUP_FILE" todo-mongodb:/tmp/
    CONTAINER_BACKUP_FILE="/tmp/$(basename "$BACKUP_FILE")"
fi

# Extract backup in container
print_status "Extracting backup..."
docker exec todo-mongodb tar -xzf "$CONTAINER_BACKUP_FILE" -C /tmp/

# Find the extracted directory
EXTRACTED_DIR="/tmp/$BACKUP_BASENAME"

# Check if extraction was successful
if docker exec todo-mongodb test -d "$EXTRACTED_DIR/todoapp"; then
    print_success "Backup extracted successfully"
else
    print_error "Failed to extract backup or backup structure is invalid"
    exit 1
fi

# Drop existing database (with confirmation)
print_warning "Dropping existing todoapp database..."
docker exec todo-mongodb mongosh \
    --username admin \
    --password password123 \
    --authenticationDatabase admin \
    --eval "db.getSiblingDB('todoapp').dropDatabase()"

# Restore database using mongorestore
print_status "Restoring database..."
docker exec todo-mongodb mongorestore \
    --username admin \
    --password password123 \
    --authenticationDatabase admin \
    --db todoapp \
    "$EXTRACTED_DIR/todoapp"

# Verify restoration
TOTAL_TODOS=$(docker exec todo-mongodb mongosh \
    --username admin \
    --password password123 \
    --authenticationDatabase admin \
    --quiet \
    --eval "db.getSiblingDB('todoapp').todos.countDocuments()")

if [ "$TOTAL_TODOS" -gt 0 ]; then
    print_success "Database restored successfully!"
    print_status "Total todos restored: $TOTAL_TODOS"

    # Show restoration statistics
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
        console.log('📊 Restored Database Statistics:');
        console.log('- Total todos:', stats.total);
        console.log('- Completed:', stats.completed);
        console.log('- Pending:', stats.pending);
        console.log('- High priority:', stats.high_priority);
        console.log('- Medium priority:', stats.medium_priority);
        console.log('- Low priority:', stats.low_priority);
        "

else
    print_error "Database restoration may have failed - no todos found"
    exit 1
fi

# Cleanup temporary files
print_status "Cleaning up temporary files..."
docker exec todo-mongodb rm -rf "$EXTRACTED_DIR"
if [[ "$BACKUP_FILE" != backups/* ]]; then
    docker exec todo-mongodb rm -f "$CONTAINER_BACKUP_FILE"
fi

echo ""
print_success "Database restoration completed successfully!"
print_status "You can now access your restored todos via:"
echo "  🌐 Mongo Express: http://localhost:8081"
echo "  🔗 API Endpoint: http://localhost:5000/api/todos"
echo "  📱 Frontend: http://localhost:3000"