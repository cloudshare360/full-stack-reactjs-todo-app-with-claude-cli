#!/bin/bash
# Get Todo Statistics - Test Script
# Usage: ./06-get-stats.sh [options]
# Options:
#   -v, --verbose    Show verbose output
#   -r, --refresh    Refresh stats multiple times

# Load dynamic configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh" 2>/dev/null || {
    echo "⚠️  Config script not found, using defaults"
    API_BASE="http://localhost:5000/api"
}

ENDPOINT="$API_BASE/todos/stats"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 Testing: GET Todo Statistics${NC}"
echo "Endpoint: $ENDPOINT"

# Default values
VERBOSE=false
REFRESH=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    -r|--refresh)
      REFRESH=true
      shift
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# Function to fetch and display stats
fetch_stats() {
  local show_time=$1
  echo -e "${YELLOW}Making request...${NC}"

  # Make the request
  if [[ "$show_time" == true ]]; then
    RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}\n" -X GET "$ENDPOINT")
  else
    RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" -X GET "$ENDPOINT")
  fi

  # Extract HTTP code and response body
  HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d':' -f2)
  BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE:/d' | sed '/TIME_TOTAL:/d')

  echo -e "\n${BLUE}Response:${NC}"
  echo "HTTP Status: $HTTP_CODE"

  if [[ "$show_time" == true ]]; then
    TIME_TOTAL=$(echo "$RESPONSE" | grep "TIME_TOTAL:" | cut -d':' -f2)
    echo "Response Time: ${TIME_TOTAL}s"
  fi

  # Check status and format response
  if [[ "$HTTP_CODE" == "200" ]]; then
    echo -e "${GREEN}✅ Statistics retrieved successfully!${NC}"

    # Display raw JSON if verbose
    if [[ "$VERBOSE" == true ]]; then
      echo -e "\n${BLUE}Raw JSON Response:${NC}"
      echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
    fi

    # Extract and display formatted statistics
    TOTAL=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('total', 0))" 2>/dev/null)
    COMPLETED=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('completed', 0))" 2>/dev/null)
    PENDING=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('pending', 0))" 2>/dev/null)
    COMPLETION_RATE=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('completionRate', 0))" 2>/dev/null)

    # Priority breakdown
    LOW=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('priorityBreakdown', {}).get('low', 0))" 2>/dev/null)
    MEDIUM=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('priorityBreakdown', {}).get('medium', 0))" 2>/dev/null)
    HIGH=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data', {}).get('priorityBreakdown', {}).get('high', 0))" 2>/dev/null)

    echo -e "\n${PURPLE}📈 TODO STATISTICS DASHBOARD${NC}"
    echo -e "${CYAN}════════════════════════════════${NC}"

    # Overall stats
    echo -e "${BLUE}📋 OVERVIEW${NC}"
    echo "   📊 Total Todos: $TOTAL"
    echo "   ✅ Completed: $COMPLETED"
    echo "   ⏳ Pending: $PENDING"
    echo "   📈 Completion Rate: ${COMPLETION_RATE}%"

    # Priority breakdown
    echo -e "\n${BLUE}⚡ PRIORITY BREAKDOWN${NC}"
    echo "   🔴 High Priority: $HIGH"
    echo "   🟡 Medium Priority: $MEDIUM"
    echo "   🟢 Low Priority: $LOW"

    # Progress bar for completion rate
    echo -e "\n${BLUE}📊 COMPLETION PROGRESS${NC}"
    PROGRESS_LENGTH=30
    COMPLETED_BARS=$((COMPLETION_RATE * PROGRESS_LENGTH / 100))
    REMAINING_BARS=$((PROGRESS_LENGTH - COMPLETED_BARS))

    PROGRESS_BAR=""
    for ((i=0; i<COMPLETED_BARS; i++)); do
      PROGRESS_BAR+="█"
    done
    for ((i=0; i<REMAINING_BARS; i++)); do
      PROGRESS_BAR+="░"
    done

    echo "   [$PROGRESS_BAR] ${COMPLETION_RATE}%"

    # Insights
    echo -e "\n${BLUE}💡 INSIGHTS${NC}"
    if [[ $TOTAL -eq 0 ]]; then
      echo "   🎯 No todos yet - create your first todo!"
    elif [[ $(echo "$COMPLETION_RATE > 80" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
      echo "   🎉 Great progress! Over 80% completion rate!"
    elif [[ $(echo "$COMPLETION_RATE > 50" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
      echo "   👍 Good progress! Over 50% completion rate!"
    else
      echo "   💪 Keep going! Focus on completing pending todos!"
    fi

    if [[ $HIGH -gt 0 ]]; then
      echo "   🚨 You have $HIGH high priority todo(s) - consider tackling these first!"
    fi

    echo -e "${CYAN}════════════════════════════════${NC}"

  else
    echo -e "${RED}❌ Failed to retrieve statistics!${NC}"
    echo "$BODY"
  fi
}

# Fetch stats initially
fetch_stats $VERBOSE

# If refresh mode is enabled, fetch stats every 3 seconds
if [[ "$REFRESH" == true ]]; then
  echo -e "\n${YELLOW}📱 Refresh mode enabled - press Ctrl+C to stop${NC}"
  echo -e "${BLUE}Refreshing every 3 seconds...${NC}"

  while true; do
    sleep 3
    clear
    echo -e "${BLUE}📊 Testing: GET Todo Statistics (Auto-refresh)${NC}"
    echo "Endpoint: $ENDPOINT"
    echo "$(date '+%Y-%m-%d %H:%M:%S')"
    fetch_stats false
  done
fi

echo -e "\n${BLUE}Example usage:${NC}"
echo "  ./06-get-stats.sh                    # Get current statistics"
echo "  ./06-get-stats.sh --verbose          # Get stats with detailed JSON response"
echo "  ./06-get-stats.sh --refresh          # Auto-refresh stats every 3 seconds"

# Show quick actions
echo -e "\n${BLUE}💡 Quick Actions:${NC}"
echo "  Create todo:   ./02-create-todo.sh --sample"
echo "  Update todo:   ./04-update-todo.sh --last --sample"
echo "  Complete todo: ./04-update-todo.sh --last -c true"
echo "  View all:      ./01-get-all-todos.sh"