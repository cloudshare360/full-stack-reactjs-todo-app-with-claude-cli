#!/bin/bash
# Get All Todos - Test Script
# Usage: ./01-get-all-todos.sh [options]
# Options:
#   -c, --completed [true|false]  Filter by completion status
#   -p, --priority [low|medium|high]  Filter by priority
#   -v, --verbose  Show verbose output

API_BASE="http://localhost:5000/api"
ENDPOINT="$API_BASE/todos"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Testing: GET All Todos${NC}"
echo "Endpoint: $ENDPOINT"

# Parse command line arguments
QUERY_PARAMS=""
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -c|--completed)
      QUERY_PARAMS="${QUERY_PARAMS}completed=$2&"
      shift 2
      ;;
    -p|--priority)
      QUERY_PARAMS="${QUERY_PARAMS}priority=$2&"
      shift 2
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# Remove trailing &
QUERY_PARAMS=${QUERY_PARAMS%&}

# Build final URL
if [[ -n "$QUERY_PARAMS" ]]; then
  FULL_URL="$ENDPOINT?$QUERY_PARAMS"
else
  FULL_URL="$ENDPOINT"
fi

echo "Full URL: $FULL_URL"
echo -e "${YELLOW}Making request...${NC}"

# Make the request
if [[ "$VERBOSE" == true ]]; then
  RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}\n" -X GET "$FULL_URL")
else
  RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" -X GET "$FULL_URL")
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
if [[ "$HTTP_CODE" == "200" ]]; then
  echo -e "${GREEN}✅ Success!${NC}"
  echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"

  # Extract count if available
  COUNT=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('count', 'N/A'))" 2>/dev/null)
  echo -e "\n${BLUE}Total todos found: ${COUNT}${NC}"
else
  echo -e "${RED}❌ Failed!${NC}"
  echo "$BODY"
fi

echo -e "\n${BLUE}Example queries:${NC}"
echo "  ./01-get-all-todos.sh                           # Get all todos"
echo "  ./01-get-all-todos.sh -c true                   # Get completed todos"
echo "  ./01-get-all-todos.sh -c false                  # Get pending todos"
echo "  ./01-get-all-todos.sh -p high                   # Get high priority todos"
echo "  ./01-get-all-todos.sh -c false -p high -v       # Get pending high priority todos (verbose)"