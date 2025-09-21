#!/bin/bash

# Backup MongoDB data for Todo Application
# This script creates a backup of the todoapp database

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

# Create backup directory if it doesn't exist
mkdir -p backups

# Check if MongoDB container is running
if ! docker ps | grep -q "todo-mongodb"; then
    print_error "MongoDB container is not running. Please start it first with './scripts/start-mongodb.sh'"
    exit 1
fi

# Generate backup filename with timestamp
BACKUP_DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="backups/todoapp_backup_$BACKUP_DATE"
BACKUP_FILE="backups/todoapp_backup_$BACKUP_DATE.tar.gz"

print_status "Creating backup of todoapp database..."
print_status "Backup will be saved as: $BACKUP_FILE"

# Create backup using mongodump
print_status "Running mongodump..."
docker exec todo-mongodb mongodump \
    --username admin \
    --password password123 \
    --authenticationDatabase admin \
    --db todoapp \
    --out /backups/todoapp_backup_$BACKUP_DATE

# Check if backup was created successfully
if docker exec todo-mongodb test -d /backups/todoapp_backup_$BACKUP_DATE/todoapp; then
    print_success "Database dump created successfully"

    # Create compressed archive
    print_status "Creating compressed archive..."
    docker exec todo-mongodb tar -czf \
        /backups/todoapp_backup_$BACKUP_DATE.tar.gz \
        -C /backups \
        todoapp_backup_$BACKUP_DATE

    # Remove the uncompressed directory
    docker exec todo-mongodb rm -rf /backups/todoapp_backup_$BACKUP_DATE

    # Get backup file size
    BACKUP_SIZE=$(docker exec todo-mongodb stat -f %z /backups/todoapp_backup_$BACKUP_DATE.tar.gz 2>/dev/null || \
                  docker exec todo-mongodb stat -c %s /backups/todoapp_backup_$BACKUP_DATE.tar.gz 2>/dev/null || \
                  echo "unknown")

    print_success "Backup completed successfully!"
    print_status "Backup file: $BACKUP_FILE"
    print_status "Backup size: $BACKUP_SIZE bytes"

    # Show backup contents
    print_status "Backup contents:"
    docker exec todo-mongodb tar -tzf /backups/todoapp_backup_$BACKUP_DATE.tar.gz | head -10

    # List all backups
    echo ""
    print_status "Available backups:"
    docker exec todo-mongodb ls -lh /backups/*.tar.gz 2>/dev/null || print_warning "No previous backups found"

else
    print_error "Backup failed!"
    exit 1
fi

echo ""
print_success "Backup process completed!"
print_status "To restore this backup, run:"
echo "  ./scripts/restore-data.sh $BACKUP_FILE"

# Cleanup old backups (keep last 5)
print_status "Cleaning up old backups (keeping last 5)..."
docker exec todo-mongodb sh -c "ls -t /backups/todoapp_backup_*.tar.gz 2>/dev/null | tail -n +6 | xargs rm -f" || true
print_status "Cleanup completed"