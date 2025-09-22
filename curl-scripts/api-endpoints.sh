#!/bin/bash

# 🌐 Todo API - All Endpoints Test Script
# Tests all available API endpoints with various scenarios

# Configuration
API_BASE=${API_BASE:-"http://localhost:5000/api"}
TIMEOUT=${TIMEOUT:-30}

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo "🌐 Testing All Todo API Endpoints..."
echo "📍 API Base URL: $API_BASE"
echo ""

# Function to make HTTP requests
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    local expected_status=$5
    
    echo -e "${BLUE}🔍 Testing: $description${NC}"
    echo "📍 $method $API_BASE$endpoint"
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            --connect-timeout $TIMEOUT \
            "$API_BASE$endpoint")
    else
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "$method" \
            --connect-timeout $TIMEOUT \
            "$API_BASE$endpoint")
    fi
    
    http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
    
    # Check if status matches expected
    if [ "$http_code" -eq "$expected_status" ]; then
        echo -e "✅ ${GREEN}Status: $http_code (Expected: $expected_status)${NC}"
    else
        echo -e "❌ ${RED}Status: $http_code (Expected: $expected_status)${NC}"
    fi
    
    # Pretty print JSON response (if it's JSON)
    if echo "$body" | jq . >/dev/null 2>&1; then
        echo "📄 Response:"
        echo "$body" | jq .
    else
        echo "📄 Response: $body"
    fi
    
    echo ""
    return $([ "$http_code" -eq "$expected_status" ] && echo 0 || echo 1)
}

# Counter for tracking results
passed=0
total=0

# Test 1: Health Check
echo -e "${PURPLE}=== Health Check Endpoint ===${NC}"
test_endpoint "GET" "/health" "" "API Health Check" 200
[ $? -eq 0 ] && ((passed++))
((total++))

# Test 2: Get All Todos
echo -e "${PURPLE}=== Get All Todos ===${NC}"
test_endpoint "GET" "/todos" "" "Get all todos" 200
[ $? -eq 0 ] && ((passed++))
((total++))

# Test 3: Create Todo (Valid)
echo -e "${PURPLE}=== Create Todo (Valid Data) ===${NC}"
create_data='{"title": "API Test Todo", "description": "Created via API endpoint test", "priority": "medium", "completed": false}'
test_endpoint "POST" "/todos" "$create_data" "Create todo with valid data" 201
[ $? -eq 0 ] && ((passed++))
((total++))

# Store the created todo ID for further tests
if [ $? -eq 0 ]; then
    CREATED_TODO_ID=$(echo "$body" | jq -r '.data._id' 2>/dev/null)
    echo "🆔 Created Todo ID: $CREATED_TODO_ID"
    echo ""
fi

# Test 4: Get Specific Todo
if [ -n "$CREATED_TODO_ID" ] && [ "$CREATED_TODO_ID" != "null" ]; then
    echo -e "${PURPLE}=== Get Specific Todo ===${NC}"
    test_endpoint "GET" "/todos/$CREATED_TODO_ID" "" "Get specific todo by ID" 200
    [ $? -eq 0 ] && ((passed++))
    ((total++))
fi

# Test 5: Update Todo
if [ -n "$CREATED_TODO_ID" ] && [ "$CREATED_TODO_ID" != "null" ]; then
    echo -e "${PURPLE}=== Update Todo ===${NC}"
    update_data='{"title": "Updated API Test Todo", "description": "Updated via API endpoint test", "priority": "high", "completed": true}'
    test_endpoint "PUT" "/todos/$CREATED_TODO_ID" "$update_data" "Update todo" 200
    [ $? -eq 0 ] && ((passed++))
    ((total++))
fi

# Test 6: Get Todo Statistics
echo -e "${PURPLE}=== Get Todo Statistics ===${NC}"
test_endpoint "GET" "/todos/stats" "" "Get todo statistics" 200
[ $? -eq 0 ] && ((passed++))
((total++))

# Test 7: Query Todos with Filters
echo -e "${PURPLE}=== Query Todos with Filters ===${NC}"
test_endpoint "GET" "/todos?completed=false" "" "Get incomplete todos" 200
[ $? -eq 0 ] && ((passed++))
((total++))

test_endpoint "GET" "/todos?priority=high" "" "Get high priority todos" 200
[ $? -eq 0 ] && ((passed++))
((total++))

test_endpoint "GET" "/todos?limit=5" "" "Get todos with limit" 200
[ $? -eq 0 ] && ((passed++))
((total++))

# Test 8: Error Cases
echo -e "${PURPLE}=== Error Handling Tests ===${NC}"

# Invalid todo ID
test_endpoint "GET" "/todos/invalid-id" "" "Get todo with invalid ID" 404
[ $? -eq 0 ] && ((passed++))
((total++))

# Create todo with missing title
invalid_create='{"description": "Missing title", "priority": "low"}'
test_endpoint "POST" "/todos" "$invalid_create" "Create todo without title" 400
[ $? -eq 0 ] && ((passed++))
((total++))

# Update non-existent todo
test_endpoint "PUT" "/todos/507f1f77bcf86cd799439011" "$update_data" "Update non-existent todo" 404
[ $? -eq 0 ] && ((passed++))
((total++))

# Delete non-existent todo  
test_endpoint "DELETE" "/todos/507f1f77bcf86cd799439012" "" "Delete non-existent todo" 404
[ $? -eq 0 ] && ((passed++))
((total++))

# Test 9: Delete the Created Todo (cleanup)
if [ -n "$CREATED_TODO_ID" ] && [ "$CREATED_TODO_ID" != "null" ]; then
    echo -e "${PURPLE}=== Delete Todo (Cleanup) ===${NC}"
    test_endpoint "DELETE" "/todos/$CREATED_TODO_ID" "" "Delete created todo" 200
    [ $? -eq 0 ] && ((passed++))
    ((total++))
fi

# Test 10: Unsupported Methods
echo -e "${PURPLE}=== Unsupported Methods ===${NC}"
test_endpoint "PATCH" "/todos" "" "Unsupported PATCH method" 405
[ $? -eq 0 ] && ((passed++))
((total++))

# Test 11: Non-existent Endpoints
echo -e "${PURPLE}=== Non-existent Endpoints ===${NC}"
test_endpoint "GET" "/nonexistent" "" "Non-existent endpoint" 404
[ $? -eq 0 ] && ((passed++))
((total++))

# Test 12: Content Type Validation
echo -e "${PURPLE}=== Content Type Tests ===${NC}"
echo "🔍 Testing: Create todo with invalid content type"
echo "📍 POST $API_BASE/todos"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "POST" \
    -H "Content-Type: text/plain" \
    -d "invalid data" \
    --connect-timeout $TIMEOUT \
    "$API_BASE/todos")
http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
if [ "$http_code" -eq 400 ] || [ "$http_code" -eq 415 ]; then
    echo -e "✅ ${GREEN}Status: $http_code (Content type validation working)${NC}"
    ((passed++))
else
    echo -e "❌ ${RED}Status: $http_code (Expected 400 or 415)${NC}"
fi
((total++))
echo ""

# Summary
echo ""
echo "📊 API Endpoint Testing Summary:"
echo "================================"
echo -e "✅ Passed: ${GREEN}$passed${NC}"
echo -e "❌ Failed: ${RED}$((total - passed))${NC}"
echo -e "📝 Total Tests: $total"
echo -e "📈 Success Rate: $(( (passed * 100) / total ))%"

if [ $passed -eq $total ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some tests failed. Check the results above.${NC}"
    exit 1
fi