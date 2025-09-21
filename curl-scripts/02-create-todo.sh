#!/bin/bash
# Create Todo - Test Script
# Usage: ./02-create-todo.sh [options]
# Options:
#   -t, --title "title"        Todo title (required)
#   -d, --description "desc"   Todo description
#   -p, --priority [low|medium|high]  Priority level
#   -s, --sample              Use sample data
#   -v, --verbose             Show verbose output

API_BASE="http://localhost:5000/api"
ENDPOINT="$API_BASE/todos"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}➕ Testing: CREATE Todo${NC}"
echo "Endpoint: $ENDPOINT"

# Default values
TITLE=""
DESCRIPTION=""
PRIORITY="medium"
USE_SAMPLE=false
VERBOSE=false

# Sample data sets
SAMPLE_TODOS=(
  '{"title":"Buy groceries","description":"Get milk, bread, and eggs from the store","priority":"medium"}'
  '{"title":"Fix critical bug","description":"Urgent: Users cannot complete checkout process","priority":"high"}'
  '{"title":"Call dentist","priority":"low"}'
  '{"title":"Review pull requests","description":"Check and approve pending code reviews","priority":"medium"}'
  '{"title":"Update documentation","description":"Add new API endpoints to swagger docs","priority":"high"}'
)

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--title)
      TITLE="$2"
      shift 2
      ;;
    -d|--description)
      DESCRIPTION="$2"
      shift 2
      ;;
    -p|--priority)
      PRIORITY="$2"
      shift 2
      ;;
    -s|--sample)
      USE_SAMPLE=true
      shift
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

# Use sample data if requested
if [[ "$USE_SAMPLE" == true ]]; then
  # Pick a random sample todo
  RANDOM_INDEX=$((RANDOM % ${#SAMPLE_TODOS[@]}))
  JSON_DATA="${SAMPLE_TODOS[$RANDOM_INDEX]}"
  echo -e "${YELLOW}Using sample data set #$((RANDOM_INDEX + 1))${NC}"
else
  # Validate required fields
  if [[ -z "$TITLE" ]]; then
    echo -e "${RED}❌ Error: Title is required!${NC}"
    echo "Usage: ./02-create-todo.sh -t \"Todo title\" [-d \"description\"] [-p priority]"
    echo "   Or: ./02-create-todo.sh --sample"
    exit 1
  fi

  # Build JSON payload
  JSON_DATA="{\"title\":\"$TITLE\""

  if [[ -n "$DESCRIPTION" ]]; then
    JSON_DATA="$JSON_DATA,\"description\":\"$DESCRIPTION\""
  fi

  JSON_DATA="$JSON_DATA,\"priority\":\"$PRIORITY\"}"
fi

echo "Request Data: $JSON_DATA" | python3 -m json.tool 2>/dev/null || echo "Request Data: $JSON_DATA"
echo -e "${YELLOW}Making request...${NC}"

# Make the request
if [[ "$VERBOSE" == true ]]; then
  RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}\n" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "$JSON_DATA" \
    "$ENDPOINT")
else
  RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "$JSON_DATA" \
    "$ENDPOINT")
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
if [[ "$HTTP_CODE" == "201" ]]; then
  echo -e "${GREEN}✅ Todo created successfully!${NC}"
  echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"

  # Extract and display created todo ID
  TODO_ID=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('_id', 'N/A'))" 2>/dev/null)
  echo -e "\n${GREEN}📝 Created Todo ID: ${TODO_ID}${NC}"

  # Save ID for other scripts to use
  echo "$TODO_ID" > last-created-todo-id.txt
  echo -e "${BLUE}💾 Todo ID saved to: last-created-todo-id.txt${NC}"
else
  echo -e "${RED}❌ Failed to create todo!${NC}"
  echo "$BODY"
fi

echo -e "\n${BLUE}Example usage:${NC}"
echo "  ./02-create-todo.sh --sample                                    # Create random sample todo"
echo "  ./02-create-todo.sh -t \"Buy milk\"                            # Create simple todo"
echo "  ./02-create-todo.sh -t \"Fix bug\" -d \"Critical issue\" -p high  # Create detailed todo"
echo "  ./02-create-todo.sh -t \"Review code\" -v                      # Create todo with verbose output"