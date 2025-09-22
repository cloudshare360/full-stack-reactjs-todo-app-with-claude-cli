#!/bin/bash

echo "🚀 Starting Express.js Todo API in Debug Mode"
echo "=============================================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating default .env file..."
    cat > .env << EOL
# Environment Configuration
NODE_ENV=development
PORT=5000

# Database Configuration
MONGODB_URI=mongodb://localhost:27017/todo_app

# CORS Configuration
FRONTEND_URL=http://localhost:3000

# Debug Configuration
DEBUG=express:*,app:*
EOL
    echo "✅ Created .env file with default settings"
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Check if MongoDB is running
echo "🔍 Checking MongoDB connection..."
if ! nc -z localhost 27017 2>/dev/null; then
    echo "⚠️  MongoDB is not running on localhost:27017"
    echo "💡 Please start MongoDB first:"
    echo "   - Using Docker: cd ../mongo-db-docker-compose && ./scripts/start-mongodb.sh"
    echo "   - Or start local MongoDB service"
    echo ""
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLYH =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "🐛 Starting server in debug mode..."
echo "📝 Debug output will show detailed logs"
echo "🔧 Chrome DevTools: chrome://inspect"
echo ""

# Set debug environment and start with nodemon
export DEBUG=express:*,app:*
export NODE_ENV=development

# Start the server with debug flag
nodemon --inspect server.js