#!/bin/bash
# Delete Todo - Test Script
# Usage: ./05-delete-todo.sh [TODO_ID] [options]
# Options:
#   -l, --last       Use last created todo ID
#   -y, --yes        Skip confirmation prompt
#   -v, --verbose    Show verbose output

API_BASE="http://localhost:5000/api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🗑️  Testing: DELETE Todo${NC}"

# Default values
TODO_ID=""
USE_LAST=false
SKIP_CONFIRMATION=false
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -l|--last)
      USE_LAST=true
      shift
      ;;
    -y|--yes)
      SKIP_CONFIRMATION=true
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
  echo "Usage: ./05-delete-todo.sh [TODO_ID]"
  echo "   Or: ./05-delete-todo.sh --last"
  exit 1
fi

# Validate MongoDB ObjectId format
if [[ ! "$TODO_ID" =~ ^[0-9a-fA-F]{24}$ ]]; then
  echo -e "${YELLOW}⚠️  Warning: Todo ID format might be invalid${NC}"
fi

ENDPOINT="$API_BASE/todos/$TODO_ID"
echo "Endpoint: $ENDPOINT"

# Get todo details first (for confirmation)
echo -e "${YELLOW}Fetching todo details...${NC}"
TODO_DETAILS=$(curl -s "$ENDPOINT")
TODO_TITLE=$(echo "$TODO_DETAILS" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('title', 'Unknown'))" 2>/dev/null)

if [[ "$TODO_TITLE" == "Unknown" ]]; then
  echo -e "${RED}❌ Todo not found or unable to fetch details!${NC}"
  exit 1
fi

echo -e "${BLUE}Todo to delete:${NC}"
echo "📝 Title: $TODO_TITLE"
echo "🆔 ID: $TODO_ID"

# Confirmation prompt (unless skipped)
if [[ "$SKIP_CONFIRMATION" == false ]]; then
  echo -e "\n${YELLOW}⚠️  Are you sure you want to delete this todo? This action cannot be undone!${NC}"
  read -p "Type 'yes' to confirm: " CONFIRMATION

  if [[ "$CONFIRMATION" != "yes" ]]; then
    echo -e "${BLUE}❌ Deletion cancelled.${NC}"
    exit 0
  fi
fi

echo -e "${YELLOW}Making delete request...${NC}"

# Make the request
if [[ "$VERBOSE" == true ]]; then
  RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}\n" -X DELETE "$ENDPOINT")
else
  RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" -X DELETE "$ENDPOINT")
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
    echo -e "${GREEN}✅ Todo deleted successfully!${NC}"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"

    # Clean up the saved ID if it was the one we just deleted
    if [[ "$USE_LAST" == true && -f "last-created-todo-id.txt" ]]; then
      rm last-created-todo-id.txt
      echo -e "${BLUE}🧹 Cleaned up saved todo ID${NC}"
    fi

    echo -e "\n${GREEN}🗑️  Todo '$TODO_TITLE' has been permanently deleted.${NC}"
    ;;
  404)
    echo -e "${RED}❌ Todo not found!${NC}"
    echo "$BODY"

    # Clean up invalid saved ID
    if [[ "$USE_LAST" == true && -f "last-created-todo-id.txt" ]]; then
      rm last-created-todo-id.txt
      echo -e "${BLUE}🧹 Cleaned up invalid saved todo ID${NC}"
    fi
    ;;
  *)
    echo -e "${RED}❌ Delete failed!${NC}"
    echo "$BODY"
    ;;
esac

echo -e "\n${BLUE}Example usage:${NC}"
echo "  ./05-delete-todo.sh 64a1b2c3d4e5f6789012345         # Delete specific todo"
echo "  ./05-delete-todo.sh --last                          # Delete last created todo"
echo "  ./05-delete-todo.sh --last --yes                    # Delete last created todo (no confirmation)"
echo "  ./05-delete-todo.sh [ID] --verbose                  # Delete todo with verbose output"

# Warning about permanent deletion
echo -e "\n${YELLOW}⚠️  Remember: Deletion is permanent and cannot be undone!${NC}"