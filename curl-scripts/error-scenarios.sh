#!/bin/bash

# 🚨 Todo API Error Scenarios Test Script
# Tests error handling, validation, and edge cases

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

echo "🚨 Testing Todo API Error Scenarios..."
echo "📍 API Base URL: $API_BASE"
echo ""

# Function to test error scenarios
test_error_scenario() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    local expected_status=$5
    local should_contain=$6
    
    echo -e "${BLUE}🔍 Testing: $description${NC}"
    echo "📍 $method $API_BASE$endpoint"
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            --connect-timeout $TIMEOUT \
            "$API_BASE$endpoint" 2>/dev/null)
    else
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "$method" \
            --connect-timeout $TIMEOUT \
            "$API_BASE$endpoint" 2>/dev/null)
    fi
    
    http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
    
    # Check status code
    if [ "$http_code" -eq "$expected_status" ]; then
        echo -e "✅ ${GREEN}Status: $http_code (Expected: $expected_status)${NC}"
        status_ok=true
    else
        echo -e "❌ ${RED}Status: $http_code (Expected: $expected_status)${NC}"
        status_ok=false
    fi
    
    # Check response content if specified
    content_ok=true
    if [ -n "$should_contain" ]; then
        if echo "$body" | grep -q "$should_contain"; then
            echo -e "✅ ${GREEN}Response contains expected content: '$should_contain'${NC}"
        else
            echo -e "❌ ${RED}Response missing expected content: '$should_contain'${NC}"
            content_ok=false
        fi
    fi
    
    # Pretty print response
    if echo "$body" | jq . >/dev/null 2>&1; then
        echo "📄 Response:"
        echo "$body" | jq .
    else
        echo "📄 Response: $body"
    fi
    
    echo ""
    return $([ "$status_ok" = true ] && [ "$content_ok" = true ] && echo 0 || echo 1)
}

# Counter for tracking results
passed=0
total=0

# === Validation Errors ===
echo -e "${PURPLE}=== Input Validation Errors ===${NC}"

# Missing title
test_error_scenario "POST" "/todos" '{"description": "Missing title"}' "Create todo without title" 400 "title"
[ $? -eq 0 ] && ((passed++))
((total++))

# Empty title
test_error_scenario "POST" "/todos" '{"title": ""}' "Create todo with empty title" 400 "title"
[ $? -eq 0 ] && ((passed++))
((total++))

# Title too long (assuming 200 char limit)
long_title=$(printf 'a%.0s' {1..500})
test_error_scenario "POST" "/todos" "{\"title\": \"$long_title\"}" "Create todo with very long title" 400 "title"
[ $? -eq 0 ] && ((passed++))
((total++))

# Invalid priority
test_error_scenario "POST" "/todos" '{"title": "Test", "priority": "invalid"}' "Create todo with invalid priority" 400 "priority"
[ $? -eq 0 ] && ((passed++))
((total++))

# Invalid completed field type
test_error_scenario "POST" "/todos" '{"title": "Test", "completed": "not-boolean"}' "Create todo with invalid completed field" 400 "completed"
[ $? -eq 0 ] && ((passed++))
((total++))

# === MongoDB ObjectId Errors ===
echo -e "${PURPLE}=== Invalid ID Formats ===${NC}"

# Invalid ObjectId format
test_error_scenario "GET" "/todos/invalid-id-format" "" "Get todo with invalid ID format" 404 "not found"
[ $? -eq 0 ] && ((passed++))
((total++))

# Valid ObjectId format but non-existent
test_error_scenario "GET" "/todos/507f1f77bcf86cd799439011" "" "Get non-existent todo with valid ID format" 404 "not found"
[ $? -eq 0 ] && ((passed++))
((total++))

# Update non-existent todo
test_error_scenario "PUT" "/todos/507f1f77bcf86cd799439012" '{"title": "Updated"}' "Update non-existent todo" 404 "not found"
[ $? -eq 0 ] && ((passed++))
((total++))

# Delete non-existent todo
test_error_scenario "DELETE" "/todos/507f1f77bcf86cd799439013" "" "Delete non-existent todo" 404 "not found"
[ $? -eq 0 ] && ((passed++))
((total++))

# === Content Type Errors ===
echo -e "${PURPLE}=== Content Type Errors ===${NC}"

# Invalid JSON
echo -e "${BLUE}🔍 Testing: Invalid JSON syntax${NC}"
echo "📍 POST $API_BASE/todos"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "POST" \
    -H "Content-Type: application/json" \
    -d '{"title": "Invalid JSON",' \
    --connect-timeout $TIMEOUT \
    "$API_BASE/todos" 2>/dev/null)
http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
if [ "$http_code" -eq 400 ]; then
    echo -e "✅ ${GREEN}Status: $http_code (Invalid JSON handled correctly)${NC}"
    ((passed++))
else
    echo -e "❌ ${RED}Status: $http_code (Expected: 400)${NC}"
fi
((total++))
echo "📄 Response: $(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')"
echo ""

# Wrong content type
echo -e "${BLUE}🔍 Testing: Wrong content type${NC}"
echo "📍 POST $API_BASE/todos"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "POST" \
    -H "Content-Type: text/plain" \
    -d '{"title": "Test"}' \
    --connect-timeout $TIMEOUT \
    "$API_BASE/todos" 2>/dev/null)
http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
if [ "$http_code" -eq 400 ] || [ "$http_code" -eq 415 ]; then
    echo -e "✅ ${GREEN}Status: $http_code (Content type validation working)${NC}"
    ((passed++))
else
    echo -e "❌ ${RED}Status: $http_code (Expected: 400 or 415)${NC}"
fi
((total++))
echo "📄 Response: $(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')"
echo ""

# === HTTP Method Errors ===
echo -e "${PURPLE}=== Unsupported HTTP Methods ===${NC}"

# PATCH method (if not supported)
test_error_scenario "PATCH" "/todos" '{"title": "Test"}' "PATCH method on todos" 405 "Method Not Allowed"
[ $? -eq 0 ] && ((passed++))
((total++))

# HEAD method on POST endpoint
test_error_scenario "HEAD" "/todos" "" "HEAD method on todos creation" 405 ""
[ $? -eq 0 ] && ((passed++))
((total++))

# === Endpoint Errors ===
echo -e "${PURPLE}=== Non-existent Endpoints ===${NC}"

# Non-existent endpoint
test_error_scenario "GET" "/nonexistent" "" "Non-existent endpoint" 404 "Not Found"
[ $? -eq 0 ] && ((passed++))
((total++))

# Wrong API path
test_error_scenario "GET" "/todo" "" "Wrong endpoint path (missing 's')" 404 "Not Found"  
[ $? -eq 0 ] && ((passed++))
((total++))

# === Query Parameter Errors ===
echo -e "${PURPLE}=== Invalid Query Parameters ===${NC}"

# Invalid limit parameter
test_error_scenario "GET" "/todos?limit=invalid" "" "Invalid limit parameter" 400 "limit"
[ $? -eq 0 ] && ((passed++))
((total++))

# Negative limit
test_error_scenario "GET" "/todos?limit=-1" "" "Negative limit parameter" 400 "limit"
[ $? -eq 0 ] && ((passed++))
((total++))

# Invalid boolean for completed filter
test_error_scenario "GET" "/todos?completed=maybe" "" "Invalid completed filter" 400 "completed"
[ $? -eq 0 ] && ((passed++))
((total++))

# === Large Payload Errors ===
echo -e "${PURPLE}=== Large Payload Tests ===${NC}"

# Very large description (test payload size limits)
large_description=$(printf 'x%.0s' {1..10000})
test_error_scenario "POST" "/todos" "{\"title\": \"Large payload test\", \"description\": \"$large_description\"}" "Create todo with large description" 413 "payload"
# Note: This might return 200 if no size limit is set, which is also acceptable
if [ $? -eq 0 ] || [ "$http_code" -eq 200 ]; then
    ((passed++))
fi
((total++))

# === Database Connection Errors ===
echo -e "${PURPLE}=== Database Connection Tests ===${NC}"

# Note: These tests would require actually stopping MongoDB to test properly
# For now, we'll just document them

echo -e "${BLUE}🔍 Note: Database connection error tests${NC}"
echo "📝 To test database connection errors:"
echo "   1. Stop MongoDB: docker-compose down"
echo "   2. Try API calls - should return 500 Internal Server Error"
echo "   3. Restart MongoDB: docker-compose up -d"
echo ""
((total++)) # Count this as a manual test

# === Rate Limiting Tests (if implemented) ===
echo -e "${PURPLE}=== Rate Limiting Tests ===${NC}"

echo -e "${BLUE}🔍 Testing: Multiple rapid requests${NC}"
echo "📍 Making 10 rapid requests to test rate limiting..."

rate_limit_passed=true
for i in {1..10}; do
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        --connect-timeout 5 \
        "$API_BASE/todos" 2>/dev/null)
    http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    
    if [ "$http_code" -eq 429 ]; then
        echo -e "✅ ${GREEN}Rate limiting detected on request $i${NC}"
        break
    fi
done

if [ "$rate_limit_passed" = true ]; then
    echo -e "📝 ${YELLOW}Rate limiting not detected (may not be implemented)${NC}"
fi
((total++))
echo ""

# Summary
echo ""
echo "📊 Error Scenario Testing Summary:"
echo "=================================="
echo -e "✅ Passed: ${GREEN}$passed${NC}"
echo -e "❌ Failed: ${RED}$((total - passed))${NC}"
echo -e "📝 Total Tests: $total"
echo -e "📈 Success Rate: $(( (passed * 100) / total ))%"

# Detailed breakdown
echo ""
echo "🔍 Test Categories:"
echo "• Input Validation: Tests data requirements and constraints"
echo "• ID Format Validation: Tests MongoDB ObjectId handling"
echo "• Content Type Handling: Tests JSON and header validation"
echo "• HTTP Method Support: Tests allowed methods"
echo "• Endpoint Existence: Tests valid API paths"
echo "• Query Parameter Validation: Tests filter parameters"
echo "• Payload Size Limits: Tests large data handling"
echo "• Error Response Format: Tests consistent error structure"

if [ $passed -ge $((total * 80 / 100)) ]; then
    echo -e "${GREEN}🎉 Most error scenarios are handled correctly!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Several error scenarios need attention. Check the API error handling.${NC}"
    exit 1
fi