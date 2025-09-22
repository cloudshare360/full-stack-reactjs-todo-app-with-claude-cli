#!/bin/bash

# 🔍 Todo API Health Check Script
# Tests basic API connectivity and health status

# Configuration
API_BASE=${API_BASE:-"http://localhost:5000/api"}
TIMEOUT=${TIMEOUT:-10}

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 Testing Todo API Health..."
echo "📍 API Base URL: $API_BASE"
echo "⏱️  Timeout: ${TIMEOUT}s"
echo ""

# Test API Health Endpoint
echo "📡 Testing health endpoint..."
response=$(curl -s -w "HTTPSTATUS:%{http_code}" --connect-timeout $TIMEOUT "$API_BASE/health")
http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')

if [ "$http_code" -eq 200 ]; then
    echo -e "✅ ${GREEN}Health check passed${NC}"
    echo "📄 Response: $body"
    
    # Parse JSON to check success field
    success=$(echo "$body" | grep -o '"success":[^,]*' | cut -d: -f2)
    if [ "$success" = "true" ]; then
        echo -e "✅ ${GREEN}API is healthy and running${NC}"
    else
        echo -e "⚠️  ${YELLOW}API responded but reported unhealthy status${NC}"
    fi
else
    echo -e "❌ ${RED}Health check failed${NC}"
    echo "📄 HTTP Status: $http_code"
    echo "📄 Response: $body"
fi

echo ""

# Test Server Connectivity (ping-like test)
echo "🏓 Testing server connectivity..."
if curl -s --connect-timeout 5 --max-time 10 "$API_BASE/health" > /dev/null; then
    echo -e "✅ ${GREEN}Server is reachable${NC}"
else
    echo -e "❌ ${RED}Cannot connect to server${NC}"
    echo "💡 Tips:"
    echo "   - Check if Express API is running: npm run dev (in express-js-rest-api folder)"
    echo "   - Check if port 5000 is available: lsof -i :5000"
    echo "   - Check if MongoDB is running: docker-compose ps (in mongo-db-docker-compose folder)"
fi

echo ""
echo "🏁 Health check completed!"