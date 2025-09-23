#!/bin/bash

# 🚀 Todo API Postman Collection - Quick Setup Script
# This script helps set up the Postman collection for comprehensive API testing

set -e

echo "🚀 Todo API Postman Collection - Quick Setup"
echo "=============================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "Todo-API-CRUD-Collection.json" ]; then
    print_error "Postman collection file not found. Please run this script from the postman-collection directory."
    exit 1
fi

print_status "Found Postman collection files"

# Check if API server is running
print_info "Checking if API server is running..."
if curl -s http://localhost:5000/api/health > /dev/null 2>&1; then
    print_status "API server is running on http://localhost:5000"
else
    print_warning "API server is not running on http://localhost:5000"
    echo ""
    echo "To start the API server:"
    echo "  cd ../express-js-rest-api"
    echo "  npm install"
    echo "  npm start"
    echo ""
fi

# Check if MongoDB is running
print_info "Checking if MongoDB is running..."
if curl -s http://localhost:5000/api/health 2>/dev/null | grep -q "success"; then
    print_status "MongoDB connection is working"
else
    print_warning "MongoDB might not be running or connected"
    echo ""
    echo "To start MongoDB:"
    echo "  cd ../mongo-db-docker-compose"
    echo "  ./scripts/start-mongodb.sh"
    echo ""
fi

# Display collection information
echo ""
echo "📋 Collection Information:"
echo "=========================="
echo "Collection File: Todo-API-CRUD-Collection.json"
echo "Environment File: Todo-API-Environment.json"
echo "Documentation: README.md"
echo ""

# Collection stats (count requests)
TOTAL_REQUESTS=$(grep -o '"name".*' Todo-API-CRUD-Collection.json | wc -l)
print_info "Total test requests: $TOTAL_REQUESTS"

echo ""
echo "🎯 Next Steps:"
echo "=============="
echo "1. Open Postman desktop application"
echo "2. Click 'Import' button"
echo "3. Select 'Todo-API-CRUD-Collection.json'"
echo "4. Import 'Todo-API-Environment.json' as well"
echo "5. Select '🌍 Todo API - Testing Environment' from environment dropdown"
echo "6. Run the collection or execute requests individually"
echo ""

echo "🔧 Manual Import Instructions:"
echo "==============================="
echo "Collection URL (if using Postman web):"
echo "file://$(pwd)/Todo-API-CRUD-Collection.json"
echo ""
echo "Environment URL:"
echo "file://$(pwd)/Todo-API-Environment.json"
echo ""

echo "📊 Test Execution Options:"
echo "=========================="
echo ""
echo "Option 1 - Full Collection Run:"
echo "  • Click collection name in Postman"
echo "  • Click 'Run collection'"
echo "  • Select all requests"
echo "  • Click 'Run Todo API - Complete CRUD Testing Collection'"
echo ""
echo "Option 2 - Sequential Manual Execution:"
echo "  • Start with '🏥 Health & Setup' folder"
echo "  • Execute each request in order"
echo "  • Monitor console output for results"
echo ""

echo "🧪 What this collection tests:"
echo "==============================="
echo "• ✅ API Health checks and connectivity"
echo "• ✅ Complete CRUD operations (Create, Read, Update, Delete)"
echo "• ✅ Data filtering and sorting"
echo "• ✅ Error handling and validation"
echo "• ✅ Statistics and counting"
echo "• ✅ Performance monitoring"
echo "• ✅ Automatic test data cleanup"
echo ""

echo "📚 Additional Resources:"
echo "========================"
echo "• Project Documentation: ../docs/"
echo "• API Endpoints: ../docs/use-me/api-documentation.md"
echo "• Curl Scripts: ../curl-scripts/"
echo "• Jupyter Testing: ../jupyter-api-testing/"
echo "• AI Agent Guide: ../AI-AGENT-TRACKING.md"
echo ""

print_status "Setup complete! Ready to test your Todo API with Postman"
echo ""
echo "💡 Pro Tip: Check the console output in Postman for detailed test results and debugging information."
echo ""

# Check Postman CLI availability
if command -v newman >/dev/null 2>&1; then
    print_info "Newman (Postman CLI) is available for command-line testing"
    echo ""
    echo "🔧 Command-line testing with Newman:"
    echo "newman run Todo-API-CRUD-Collection.json -e Todo-API-Environment.json"
    echo ""
else
    print_info "To run tests from command line, install Newman:"
    echo "npm install -g newman"
    echo ""
fi

echo "Happy Testing! 🚀📋✅"