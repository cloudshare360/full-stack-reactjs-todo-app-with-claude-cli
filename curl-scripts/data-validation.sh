#!/bin/bash

# 🛡️ Todo API Data Validation Test Script
# Tests input validation, data constraints, and field requirements

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

echo "🛡️ Testing Todo API Data Validation..."
echo "📍 API Base URL: $API_BASE"
echo ""

# Function to test validation scenarios
test_validation() {
    local test_name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local expected_status=$5
    local should_fail=$6
    
    echo -e "${BLUE}🔍 Testing: $test_name${NC}"
    
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "$method" \
        -H "Content-Type: application/json" \
        -d "$data" \
        --connect-timeout $TIMEOUT \
        "$API_BASE$endpoint" 2>/dev/null)
    
    http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
    
    if [ "$should_fail" = "true" ]; then
        # Expect validation to fail
        if [ "$http_code" -eq "$expected_status" ]; then
            echo -e "✅ ${GREEN}Validation correctly rejected: $http_code${NC}"
            success=true
        else
            echo -e "❌ ${RED}Validation should have failed: $http_code (Expected: $expected_status)${NC}"
            success=false
        fi
    else
        # Expect validation to pass
        if [ "$http_code" -eq "$expected_status" ]; then
            echo -e "✅ ${GREEN}Valid data accepted: $http_code${NC}"
            success=true
        else
            echo -e "❌ ${RED}Valid data rejected: $http_code (Expected: $expected_status)${NC}"
            success=false
        fi
    fi
    
    # Show error message if validation failed as expected
    if [ "$should_fail" = "true" ] && [ "$success" = "true" ]; then
        error_msg=$(echo "$body" | jq -r '.error // .message // "No error message"' 2>/dev/null)
        echo "📄 Error Message: $error_msg"
    fi
    
    # Extract todo ID if creation was successful
    if [ "$method" = "POST" ] && [ "$http_code" -eq 201 ] && [ "$success" = "true" ]; then
        todo_id=$(echo "$body" | jq -r '.data._id // empty' 2>/dev/null)
        echo "🆔 Created Todo ID: $todo_id"
        echo "$todo_id" >> /tmp/test_todo_ids_$$
    fi
    
    echo ""
    return $([ "$success" = "true" ] && echo 0 || echo 1)
}

# Initialize counter and cleanup file
passed=0
total=0
> /tmp/test_todo_ids_$$

# === Title Field Validation ===
echo -e "${PURPLE}=== Title Field Validation ===${NC}"

# Valid title
test_validation "Valid title" "POST" "/todos" \
    '{"title": "Valid Todo Title", "description": "Test description"}' \
    201 "false"
[ $? -eq 0 ] && ((passed++))
((total++))

# Missing title
test_validation "Missing title field" "POST" "/todos" \
    '{"description": "Missing title"}' \
    400 "true"
[ $? -eq 0 ] && ((passed++))
((total++))

# Empty title
test_validation "Empty title" "POST" "/todos" \
    '{"title": "", "description": "Empty title"}' \
    400 "true"
[ $? -eq 0 ] && ((passed++))
((total++))

# Null title
test_validation "Null title" "POST" "/todos" \
    '{"title": null, "description": "Null title"}' \
    400 "true"
[ $? -eq 0 ] && ((passed++))
((total++))

# Title with only spaces
test_validation "Title with only spaces" "POST" "/todos" \
    '{"title": "   ", "description": "Spaces only"}' \
    400 "true"
[ $? -eq 0 ] && ((passed++))
((total++))

# Very long title (500 characters)
long_title=$(printf 'a%.0s' {1..500})
test_validation "Very long title (500 chars)" "POST" "/todos" \
    "{\"title\": \"$long_title\", \"description\": \"Long title test\"}" \
    400 "true"
[ $? -eq 0 ] && ((passed++))
((total++))

# Title with special characters (should be allowed)
test_validation "Title with special characters" "POST" "/todos" \
    '{"title": "Todo with émojis 🚀 & symbols @#$%", "description": "Special chars test"}' \
    201 "false"
[ $? -eq 0 ] && ((passed++))
((total++))

# === Description Field Validation ===
echo -e "${PURPLE}=== Description Field Validation ===${NC}"

# Valid description
test_validation "Valid description" "POST" "/todos" \
    '{"title": "Test Todo", "description": "This is a valid description"}' \
    201 "false"
[ $? -eq 0 ] && ((passed++))
((total++))

# Missing description (should be optional)
test_validation "Missing description (optional)" "POST" "/todos" \
    '{"title": "Todo without description"}' \
    201 "false"
[ $? -eq 0 ] && ((passed++))
((total++))

# Empty description (should be allowed)
test_validation "Empty description" "POST" "/todos" \
    '{"title": "Todo with empty description", "description": ""}' \
    201 "false"
[ $? -eq 0 ] && ((passed++))
((total++))

# Very long description
long_desc=$(printf 'x%.0s' {1..10000})
test_validation "Very long description (10000 chars)" "POST" "/todos" \
    "{\"title\": \"Long desc test\", \"description\": \"$long_desc\"}" \
    400 "true"
# Note: This might pass if no length limit is set
if [ $? -eq 0 ] || [ "$http_code" -eq 201 ]; then
    ((passed++))
fi
((total++))

# === Priority Field Validation ===
echo -e "${PURPLE}=== Priority Field Validation ===${NC}"

# Valid priorities
for priority in "low" "medium" "high"; do
    test_validation "Valid priority: $priority" "POST" "/todos" \
        "{\"title\": \"Priority test $priority\", \"priority\": \"$priority\"}" \
        201 "false"
    [ $? -eq 0 ] && ((passed++))
    ((total++))
done

# Invalid priority
test_validation "Invalid priority" "POST" "/todos" \
    '{"title": "Invalid priority test", "priority": "urgent"}' \
    400 "true"
[ $? -eq 0 ] && ((passed++))
((total++))

# Priority with wrong type
test_validation "Priority as number" "POST" "/todos" \
    '{"title": "Priority as number", "priority": 1}' \
    400 "true"
[ $? -eq 0 ] && ((passed++))
((total++))

# Missing priority (should default or be optional)
test_validation "Missing priority (should default)" "POST" "/todos" \
    '{"title": "No priority specified"}' \
    201 "false"
[ $? -eq 0 ] && ((passed++))
((total++))

# === Completed Field Validation ===
echo -e "${PURPLE}=== Completed Field Validation ===${NC}"

# Valid boolean values
test_validation "Completed: true" "POST" "/todos" \
    '{"title": "Completed true", "completed": true}' \
    201 "false"
[ $? -eq 0 ] && ((passed++))
((total++))

test_validation "Completed: false" "POST" "/todos" \
    '{"title": "Completed false", "completed": false}' \
    201 "false"
[ $? -eq 0 ] && ((passed++))
((total++))

# Invalid boolean values
test_validation "Completed as string" "POST" "/todos" \
    '{"title": "Completed as string", "completed": "true"}' \
    400 "true"
[ $? -eq 0 ] && ((passed++))
((total++))

test_validation "Completed as number" "POST" "/todos" \
    '{"title": "Completed as number", "completed": 1}' \
    400 "true"
[ $? -eq 0 ] && ((passed++))
((total++))

# === Additional Fields Validation ===
echo -e "${PURPLE}=== Additional Fields Validation ===${NC}"

# Unknown fields (should be ignored or rejected)
test_validation "Unknown fields" "POST" "/todos" \
    '{"title": "Unknown fields test", "unknownField": "value", "anotherField": 123}' \
    201 "false"
# Note: This might pass if unknown fields are ignored
if [ $? -eq 0 ] || [ "$http_code" -eq 400 ]; then
    ((passed++))
fi
((total++))

# === Update Validation ===
echo -e "${PURPLE}=== Update Field Validation ===${NC}"

# Create a todo for update tests
echo "📝 Creating todo for update validation tests..."
create_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"title": "Update Test Todo", "description": "For testing updates"}' \
    "$API_BASE/todos")
update_todo_id=$(echo "$create_response" | jq -r '.data._id // empty' 2>/dev/null)

if [ -n "$update_todo_id" ] && [ "$update_todo_id" != "null" ]; then
    echo "🆔 Update Test Todo ID: $update_todo_id"
    
    # Valid update
    test_validation "Valid update" "PUT" "/todos/$update_todo_id" \
        '{"title": "Updated Title", "completed": true}' \
        200 "false"
    [ $? -eq 0 ] && ((passed++))
    ((total++))
    
    # Update with empty title
    test_validation "Update with empty title" "PUT" "/todos/$update_todo_id" \
        '{"title": ""}' \
        400 "true"
    [ $? -eq 0 ] && ((passed++))
    ((total++))
    
    # Update with invalid priority
    test_validation "Update with invalid priority" "PUT" "/todos/$update_todo_id" \
        '{"priority": "invalid"}' \
        400 "true"
    [ $? -eq 0 ] && ((passed++))
    ((total++))
    
    # Partial update (should be allowed)
    test_validation "Partial update (only description)" "PUT" "/todos/$update_todo_id" \
        '{"description": "Updated description only"}' \
        200 "false"
    [ $? -eq 0 ] && ((passed++))
    ((total++))
    
    # Add to cleanup list
    echo "$update_todo_id" >> /tmp/test_todo_ids_$$
else
    echo "⚠️ Could not create todo for update tests"
    ((total += 4)) # Account for skipped tests
fi

# === JSON Structure Validation ===
echo -e "${PURPLE}=== JSON Structure Validation ===${NC}"

# Invalid JSON syntax
echo -e "${BLUE}🔍 Testing: Invalid JSON syntax${NC}"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "POST" \
    -H "Content-Type: application/json" \
    -d '{"title": "Invalid JSON"' \
    --connect-timeout $TIMEOUT \
    "$API_BASE/todos" 2>/dev/null)
http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
if [ "$http_code" -eq 400 ]; then
    echo -e "✅ ${GREEN}Invalid JSON correctly rejected: $http_code${NC}"
    ((passed++))
else
    echo -e "❌ ${RED}Invalid JSON not handled: $http_code${NC}"
fi
((total++))
echo ""

# === Content Type Validation ===
echo -e "${PURPLE}=== Content Type Validation ===${NC}"

# Wrong content type
echo -e "${BLUE}🔍 Testing: Wrong content type${NC}"
response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "POST" \
    -H "Content-Type: text/plain" \
    -d '{"title": "Wrong content type"}' \
    --connect-timeout $TIMEOUT \
    "$API_BASE/todos" 2>/dev/null)
http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
if [ "$http_code" -eq 400 ] || [ "$http_code" -eq 415 ]; then
    echo -e "✅ ${GREEN}Wrong content type rejected: $http_code${NC}"
    ((passed++))
else
    echo -e "❌ ${RED}Wrong content type not handled: $http_code${NC}"
fi
((total++))
echo ""

# === Cleanup Test Data ===
echo -e "${PURPLE}=== Cleanup ===${NC}"
echo "🧹 Cleaning up test todos..."
if [ -f /tmp/test_todo_ids_$$ ]; then
    while read -r todo_id; do
        if [ -n "$todo_id" ] && [ "$todo_id" != "null" ]; then
            curl -s -X DELETE "$API_BASE/todos/$todo_id" > /dev/null
            echo "🗑️ Deleted todo: $todo_id"
        fi
    done < /tmp/test_todo_ids_$$
    rm -f /tmp/test_todo_ids_$$
fi
echo ""

# === Validation Summary ===
echo ""
echo "📊 Data Validation Test Summary:"
echo "================================="
echo -e "✅ Passed: ${GREEN}$passed${NC}"
echo -e "❌ Failed: ${RED}$((total - passed))${NC}"
echo -e "📝 Total Tests: $total"
echo -e "📈 Success Rate: $(( (passed * 100) / total ))%"

echo ""
echo "🔍 Validation Areas Tested:"
echo "• Title field requirements and constraints"
echo "• Description field validation"
echo "• Priority field values and types"
echo "• Completed field boolean validation"
echo "• Unknown/extra fields handling"
echo "• Update operation validation"
echo "• JSON syntax validation"
echo "• Content type validation"

# Validation score
validation_score=$(( (passed * 100) / total ))
if [ "$validation_score" -ge 90 ]; then
    echo -e "${GREEN}🛡️ Excellent input validation!${NC}"
elif [ "$validation_score" -ge 75 ]; then
    echo -e "${GREEN}✅ Good input validation${NC}"
elif [ "$validation_score" -ge 60 ]; then
    echo -e "${YELLOW}⚠️ Moderate input validation${NC}"
else
    echo -e "${RED}❌ Poor input validation - Security risk!${NC}"
fi

echo ""
echo "💡 Validation Best Practices:"
echo "• Always validate required fields"
echo "• Set appropriate length limits"
echo "• Validate data types strictly"
echo "• Sanitize input to prevent injection"
echo "• Provide clear error messages"
echo "• Handle edge cases gracefully"

echo -e "${GREEN}🏁 Data validation testing completed!${NC}"