#!/bin/bash

# 🔄 Todo API CRUD Operations Test Script
# Comprehensive test of Create, Read, Update, Delete operations

# Configuration
API_BASE=${API_BASE:-"http://localhost:5000/api"}
TIMEOUT=${TIMEOUT:-30}

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test data
TEST_TODO_TITLE="CRUD Test Todo $(date +%s)"
TEST_TODO_DESCRIPTION="This todo was created by the CRUD test script"
UPDATED_TITLE="Updated CRUD Test Todo"
UPDATED_DESCRIPTION="This todo was updated by the test script"

echo "🔄 Testing Todo API CRUD Operations..."
echo "📍 API Base URL: $API_BASE"
echo "📝 Test Todo: $TEST_TODO_TITLE"
echo ""

# Function to make HTTP requests with error handling
make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo "🌐 $description"
    
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
    
    echo "📊 HTTP Status: $http_code"
    echo "📄 Response: $body"
    echo ""
    
    # Return the response body and status code
    echo "$body|$http_code"
}

# Step 1: CREATE - Add a new todo
echo -e "${BLUE}📝 Step 1: CREATE - Adding new todo${NC}"
create_data=$(cat <<EOF
{
    "title": "$TEST_TODO_TITLE",
    "description": "$TEST_TODO_DESCRIPTION",
    "priority": "medium",
    "completed": false
}
EOF
)

create_result=$(make_request "POST" "/todos" "$create_data" "Creating new todo...")
create_response=$(echo "$create_result" | cut -d'|' -f1)
create_status=$(echo "$create_result" | cut -d'|' -f2)

if [ "$create_status" -eq 201 ] || [ "$create_status" -eq 200 ]; then
    echo -e "✅ ${GREEN}CREATE operation successful${NC}"
    # Extract todo ID for further operations
    TODO_ID=$(echo "$create_response" | grep -o '"_id":"[^"]*' | cut -d'"' -f4)
    echo "🆔 Created Todo ID: $TODO_ID"
else
    echo -e "❌ ${RED}CREATE operation failed${NC}"
    exit 1
fi

# Step 2: READ - Get all todos
echo -e "${BLUE}📖 Step 2: READ - Getting all todos${NC}"
read_all_result=$(make_request "GET" "/todos" "" "Fetching all todos...")
read_all_response=$(echo "$read_all_result" | cut -d'|' -f1)
read_all_status=$(echo "$read_all_result" | cut -d'|' -f2)

if [ "$read_all_status" -eq 200 ]; then
    echo -e "✅ ${GREEN}READ ALL operation successful${NC}"
    # Count todos
    todo_count=$(echo "$read_all_response" | grep -o '"title":' | wc -l)
    echo "📊 Total todos found: $todo_count"
else
    echo -e "❌ ${RED}READ ALL operation failed${NC}"
fi

# Step 3: READ - Get specific todo by ID
if [ -n "$TODO_ID" ]; then
    echo -e "${BLUE}🔍 Step 3: READ - Getting specific todo by ID${NC}"
    read_one_result=$(make_request "GET" "/todos/$TODO_ID" "" "Fetching todo by ID...")
    read_one_response=$(echo "$read_one_result" | cut -d'|' -f1)
    read_one_status=$(echo "$read_one_result" | cut -d'|' -f2)

    if [ "$read_one_status" -eq 200 ]; then
        echo -e "✅ ${GREEN}READ BY ID operation successful${NC}"
        # Verify the title matches
        if echo "$read_one_response" | grep -q "$TEST_TODO_TITLE"; then
            echo -e "✅ ${GREEN}Todo content matches expected data${NC}"
        else
            echo -e "⚠️  ${YELLOW}Todo found but content doesn't match${NC}"
        fi
    else
        echo -e "❌ ${RED}READ BY ID operation failed${NC}"
    fi
fi

# Step 4: UPDATE - Modify the todo
if [ -n "$TODO_ID" ]; then
    echo -e "${BLUE}✏️  Step 4: UPDATE - Modifying todo${NC}"
    update_data=$(cat <<EOF
{
    "title": "$UPDATED_TITLE",
    "description": "$UPDATED_DESCRIPTION",
    "priority": "high",
    "completed": true
}
EOF
)
    
    update_result=$(make_request "PUT" "/todos/$TODO_ID" "$update_data" "Updating todo...")
    update_response=$(echo "$update_result" | cut -d'|' -f1)
    update_status=$(echo "$update_result" | cut -d'|' -f2)

    if [ "$update_status" -eq 200 ]; then
        echo -e "✅ ${GREEN}UPDATE operation successful${NC}"
        # Verify the update by reading the todo again
        verify_result=$(make_request "GET" "/todos/$TODO_ID" "" "Verifying update...")
        verify_response=$(echo "$verify_result" | cut -d'|' -f1)
        verify_status=$(echo "$verify_result" | cut -d'|' -f2)
        
        if [ "$verify_status" -eq 200 ] && echo "$verify_response" | grep -q "$UPDATED_TITLE"; then
            echo -e "✅ ${GREEN}Update verification successful${NC}"
        else
            echo -e "⚠️  ${YELLOW}Update may not have been applied correctly${NC}"
        fi
    else
        echo -e "❌ ${RED}UPDATE operation failed${NC}"
    fi
fi

# Step 5: DELETE - Remove the todo
if [ -n "$TODO_ID" ]; then
    echo -e "${BLUE}🗑️  Step 5: DELETE - Removing todo${NC}"
    delete_result=$(make_request "DELETE" "/todos/$TODO_ID" "" "Deleting todo...")
    delete_response=$(echo "$delete_result" | cut -d'|' -f1)
    delete_status=$(echo "$delete_result" | cut -d'|' -f2)

    if [ "$delete_status" -eq 200 ]; then
        echo -e "✅ ${GREEN}DELETE operation successful${NC}"
        
        # Verify deletion by trying to fetch the todo again
        verify_delete_result=$(make_request "GET" "/todos/$TODO_ID" "" "Verifying deletion...")
        verify_delete_status=$(echo "$verify_delete_result" | cut -d'|' -f2)
        
        if [ "$verify_delete_status" -eq 404 ]; then
            echo -e "✅ ${GREEN}Deletion verification successful (todo not found)${NC}"
        else
            echo -e "⚠️  ${YELLOW}Todo may still exist after deletion${NC}"
        fi
    else
        echo -e "❌ ${RED}DELETE operation failed${NC}"
    fi
fi

# Summary
echo ""
echo "📊 CRUD Operations Test Summary:"
echo "================================"
echo -e "CREATE: $([ "$create_status" -eq 201 ] || [ "$create_status" -eq 200 ] && echo "${GREEN}✅ PASSED${NC}" || echo "${RED}❌ FAILED${NC}")"
echo -e "READ ALL: $([ "$read_all_status" -eq 200 ] && echo "${GREEN}✅ PASSED${NC}" || echo "${RED}❌ FAILED${NC}")"
echo -e "READ BY ID: $([ "$read_one_status" -eq 200 ] && echo "${GREEN}✅ PASSED${NC}" || echo "${RED}❌ FAILED${NC}")"
echo -e "UPDATE: $([ "$update_status" -eq 200 ] && echo "${GREEN}✅ PASSED${NC}" || echo "${RED}❌ FAILED${NC}")"
echo -e "DELETE: $([ "$delete_status" -eq 200 ] && echo "${GREEN}✅ PASSED${NC}" || echo "${RED}❌ FAILED${NC}")"
echo ""
echo "🏁 CRUD operations test completed!"