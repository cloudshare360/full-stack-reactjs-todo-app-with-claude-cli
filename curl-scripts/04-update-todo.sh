#!/bin/bash
# Update Todo - Test Script
# Usage: ./04-update-todo.sh [TODO_ID] [options]
# Options:
#   -l, --last                 Use last created todo ID
#   -t, --title "new title"    Update title
#   -d, --description "desc"   Update description
#   -c, --completed [true|false]  Update completion status
#   -p, --priority [low|medium|high]  Update priority
#   -s, --sample              Use sample update data
#   -v, --verbose             Show verbose output

API_BASE="http://localhost:5000/api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}✏️  Testing: UPDATE Todo${NC}"

# Default values
TODO_ID=""
USE_LAST=false
TITLE=""
DESCRIPTION=""
COMPLETED=""
PRIORITY=""
USE_SAMPLE=false
VERBOSE=false

# Sample update data sets
SAMPLE_UPDATES=(
  '{"completed":true}'
  '{"priority":"high","title":"URGENT: Fix critical bug"}'
  '{"description":"Updated description with more details","priority":"medium"}'
  '{"completed":false,"priority":"low"}'
  '{"title":"Updated title","description":"Updated description","completed":true}'
)

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -l|--last)
      USE_LAST=true
      shift
      ;;
    -t|--title)
      TITLE="$2"
      shift 2
      ;;
    -d|--description)
      DESCRIPTION="$2"
      shift 2
      ;;
    -c|--completed)
      COMPLETED="$2"
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
  echo "Usage: ./04-update-todo.sh [TODO_ID] [options]"
  echo "   Or: ./04-update-todo.sh --last [options]"
  exit 1
fi

# Validate MongoDB ObjectId format
if [[ ! "$TODO_ID" =~ ^[0-9a-fA-F]{24}$ ]]; then
  echo -e "${YELLOW}⚠️  Warning: Todo ID format might be invalid${NC}"
fi

ENDPOINT="$API_BASE/todos/$TODO_ID"
echo "Endpoint: $ENDPOINT"

# Build JSON payload
if [[ "$USE_SAMPLE" == true ]]; then
  # Pick a random sample update
  RANDOM_INDEX=$((RANDOM % ${#SAMPLE_UPDATES[@]}))
  JSON_DATA="${SAMPLE_UPDATES[$RANDOM_INDEX]}"
  echo -e "${YELLOW}Using sample update set #$((RANDOM_INDEX + 1))${NC}"
else
  # Check if at least one field is provided
  if [[ -z "$TITLE" && -z "$DESCRIPTION" && -z "$COMPLETED" && -z "$PRIORITY" ]]; then
    echo -e "${RED}❌ Error: At least one field must be provided for update!${NC}"
    echo "Available options: -t (title), -d (description), -c (completed), -p (priority)"
    echo "   Or use: --sample for random update"
    exit 1
  fi

  # Build JSON payload
  JSON_DATA="{"
  FIRST_FIELD=true

  if [[ -n "$TITLE" ]]; then
    JSON_DATA="$JSON_DATA\"title\":\"$TITLE\""
    FIRST_FIELD=false
  fi

  if [[ -n "$DESCRIPTION" ]]; then
    [[ "$FIRST_FIELD" == false ]] && JSON_DATA="$JSON_DATA,"
    JSON_DATA="$JSON_DATA\"description\":\"$DESCRIPTION\""
    FIRST_FIELD=false
  fi

  if [[ -n "$COMPLETED" ]]; then
    [[ "$FIRST_FIELD" == false ]] && JSON_DATA="$JSON_DATA,"
    JSON_DATA="$JSON_DATA\"completed\":$COMPLETED"
    FIRST_FIELD=false
  fi

  if [[ -n "$PRIORITY" ]]; then
    [[ "$FIRST_FIELD" == false ]] && JSON_DATA="$JSON_DATA,"
    JSON_DATA="$JSON_DATA\"priority\":\"$PRIORITY\""
    FIRST_FIELD=false
  fi

  JSON_DATA="$JSON_DATA}"
fi

echo "Update Data: $JSON_DATA" | python3 -m json.tool 2>/dev/null || echo "Update Data: $JSON_DATA"
echo -e "${YELLOW}Making request...${NC}"

# Make the request
if [[ "$VERBOSE" == true ]]; then
  RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}\n" \
    -X PUT \
    -H "Content-Type: application/json" \
    -d "$JSON_DATA" \
    "$ENDPOINT")
else
  RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" \
    -X PUT \
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
case $HTTP_CODE in
  200)
    echo -e "${GREEN}✅ Todo updated successfully!${NC}"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"

    # Extract and display updated todo details
    TODO_TITLE=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('title', 'N/A'))" 2>/dev/null)
    TODO_COMPLETED=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('completed', 'N/A'))" 2>/dev/null)
    TODO_PRIORITY=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('priority', 'N/A'))" 2>/dev/null)

    echo -e "\n${BLUE}Updated Todo:${NC}"
    echo "📝 Title: $TODO_TITLE"
    echo "✅ Completed: $TODO_COMPLETED"
    echo "⚡ Priority: $TODO_PRIORITY"
    ;;
  400)
    echo -e "${RED}❌ Validation error!${NC}"
    echo "$BODY"
    ;;
  404)
    echo -e "${RED}❌ Todo not found!${NC}"
    echo "$BODY"
    ;;
  *)
    echo -e "${RED}❌ Update failed!${NC}"
    echo "$BODY"
    ;;
esac

echo -e "\n${BLUE}Example usage:${NC}"
echo "  ./04-update-todo.sh --last --sample                     # Random update to last todo"
echo "  ./04-update-todo.sh --last -c true                      # Mark last todo as completed"
echo "  ./04-update-todo.sh [ID] -t \"New title\" -p high        # Update title and priority"
echo "  ./04-update-todo.sh [ID] -c false -d \"Updated desc\"    # Update completion and description"