#!/bin/bash
# Get Single Todo - Test Script
# Usage: ./03-get-single-todo.sh [TODO_ID] [options]
# Options:
#   -l, --last       Use last created todo ID
#   -v, --verbose    Show verbose output

API_BASE="http://localhost:5000/api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Testing: GET Single Todo${NC}"

# Default values
TODO_ID=""
USE_LAST=false
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -l|--last)
      USE_LAST=true
      shift
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    *)
      if [[ -z "$TODO_ID" && ! "$1" =~ ^- ]]; then
        TODO_ID="$1"
      else
        echo "Unknown option $1"
        exit 1
      fi
      shift
      ;;
  esac
done

# Use last created todo ID if requested
if [[ "$USE_LAST" == true ]]; then
  if [[ -f "last-created-todo-id.txt" ]]; then
    TODO_ID=$(cat last-created-todo-id.txt)
    echo -e "${YELLOW}Using last created todo ID: $TODO_ID${NC}"
  else
    echo -e "${RED}❌ No last created todo ID found!${NC}"
    echo "Run ./02-create-todo.sh first, or provide a todo ID manually."
    exit 1
  fi
fi

# Validate todo ID
if [[ -z "$TODO_ID" ]]; then
  echo -e "${RED}❌ Error: Todo ID is required!${NC}"
  echo "Usage: ./03-get-single-todo.sh [TODO_ID]"
  echo "   Or: ./03-get-single-todo.sh --last"
  exit 1
fi

# Validate MongoDB ObjectId format (24 hex characters)
if [[ ! "$TODO_ID" =~ ^[0-9a-fA-F]{24}$ ]]; then
  echo -e "${YELLOW}⚠️  Warning: Todo ID format might be invalid (should be 24 hex characters)${NC}"
  echo "Provided ID: $TODO_ID"
fi

ENDPOINT="$API_BASE/todos/$TODO_ID"
echo "Endpoint: $ENDPOINT"
echo -e "${YELLOW}Making request...${NC}"

# Make the request
if [[ "$VERBOSE" == true ]]; then
  RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}\n" -X GET "$ENDPOINT")
else
  RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" -X GET "$ENDPOINT")
fi

# Extract HTTP code and response body
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d':' -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE:/d' | sed '/TIME_TOTAL:/d')

echo -e "\n${BLUE}Response:${NC}"
echo "HTTP Status: $HTTP_CODE"

if [[ "$VERBOSE" == true ]]; then
  TIME_TOTAL=$(echo "$RESPONSE" | grep "TIME_TOTAL:" | cut -d':' -f2)
  echo "Response Time: ${TIME_TOTAL}s"
fi

# Check status and format response
case $HTTP_CODE in
  200)
    echo -e "${GREEN}✅ Todo found!${NC}"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"

    # Extract and display todo details
    TODO_TITLE=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('title', 'N/A'))" 2>/dev/null)
    TODO_COMPLETED=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('completed', 'N/A'))" 2>/dev/null)
    TODO_PRIORITY=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('priority', 'N/A'))" 2>/dev/null)

    echo -e "\n${BLUE}Todo Details:${NC}"
    echo "📝 Title: $TODO_TITLE"
    echo "✅ Completed: $TODO_COMPLETED"
    echo "⚡ Priority: $TODO_PRIORITY"
    ;;
  404)
    echo -e "${RED}❌ Todo not found!${NC}"
    echo "$BODY"
    echo -e "\n${YELLOW}💡 Tip: Make sure the todo ID is correct or create a new todo first${NC}"
    ;;
  *)
    echo -e "${RED}❌ Request failed!${NC}"
    echo "$BODY"
    ;;
esac

echo -e "\n${BLUE}Example usage:${NC}"
echo "  ./03-get-single-todo.sh 64a1b2c3d4e5f6789012345    # Get specific todo"
echo "  ./03-get-single-todo.sh --last                      # Get last created todo"
echo "  ./03-get-single-todo.sh --last --verbose            # Get last created todo (verbose)"

# Show available todo IDs from recent creation
if [[ -f "last-created-todo-id.txt" && "$USE_LAST" != true ]]; then
  LAST_ID=$(cat last-created-todo-id.txt)
  echo -e "\n${BLUE}💡 Available todo ID: $LAST_ID${NC}"
fi