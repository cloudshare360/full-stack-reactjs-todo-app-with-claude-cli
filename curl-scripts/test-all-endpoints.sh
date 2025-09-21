#!/bin/bash
# Complete API Test Suite - Test All Endpoints
# Usage: ./test-all-endpoints.sh [options]
# Options:
#   -f, --full        Run full test suite with multiple scenarios
#   -q, --quiet       Quiet mode (less output)
#   -s, --stop-on-fail  Stop on first failure
#   -r, --report      Generate detailed report
#   -c, --cleanup     Cleanup test data after completion

API_BASE="http://localhost:5000/api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
TEST_START_TIME=$(date +%s)

# Test results array
declare -a TEST_RESULTS

# Parse command line arguments
FULL_TEST=false
QUIET=false
STOP_ON_FAIL=false
GENERATE_REPORT=false
CLEANUP=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--full)
      FULL_TEST=true
      shift
      ;;
    -q|--quiet)
      QUIET=true
      shift
      ;;
    -s|--stop-on-fail)
      STOP_ON_FAIL=true
      shift
      ;;
    -r|--report)
      GENERATE_REPORT=true
      shift
      ;;
    -c|--cleanup)
      CLEANUP=true
      shift
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# Function to log messages
log() {
  if [[ "$QUIET" != true ]]; then
    echo -e "$1"
  fi
}

# Function to run a test
run_test() {
  local test_name="$1"
  local test_command="$2"
  local expected_status="$3"

  TOTAL_TESTS=$((TOTAL_TESTS + 1))

  log "${CYAN}[TEST $TOTAL_TESTS] $test_name${NC}"

  if [[ "$QUIET" != true ]]; then
    echo "Command: $test_command"
  fi

  # Execute the test command
  eval "$test_command" > /tmp/test_output_$TOTAL_TESTS 2>&1
  local exit_code=$?
  local test_output=$(cat /tmp/test_output_$TOTAL_TESTS)

  # Check if test passed
  if [[ $exit_code -eq 0 ]]; then
    log "${GREEN}✅ PASSED${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    TEST_RESULTS+=("✅ PASS: $test_name")
  else
    log "${RED}❌ FAILED${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    TEST_RESULTS+=("❌ FAIL: $test_name")

    if [[ "$QUIET" != true ]]; then
      echo "Error output:"
      echo "$test_output"
    fi

    if [[ "$STOP_ON_FAIL" == true ]]; then
      log "${RED}Stopping on failure as requested${NC}"
      exit 1
    fi
  fi

  log ""
}

# Function to check API availability
check_api_availability() {
  log "${PURPLE}🌐 Checking API Availability${NC}"
  local response=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE/todos/stats")

  if [[ "$response" == "200" ]]; then
    log "${GREEN}✅ API is available at $API_BASE${NC}"
    return 0
  else
    log "${RED}❌ API is not available at $API_BASE${NC}"
    log "${YELLOW}Please ensure your Express server is running on port 5000${NC}"
    log "${BLUE}Run: cd express-js-rest-api && npm run dev${NC}"
    return 1
  fi
}

# Function to display header
display_header() {
  echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"
  echo -e "${WHITE}               🚀 TODO API COMPREHENSIVE TEST SUITE              ${NC}"
  echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}Date: $(date)${NC}"
  echo -e "${BLUE}API Base: $API_BASE${NC}"
  echo -e "${BLUE}Test Mode: $([ "$FULL_TEST" == true ] && echo "Full Suite" || echo "Standard")${NC}"
  echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"
  echo ""
}

# Function to cleanup test data
cleanup_test_data() {
  if [[ "$CLEANUP" == true && -f "last-created-todo-id.txt" ]]; then
    log "${YELLOW}🧹 Cleaning up test data...${NC}"
    local todo_id=$(cat last-created-todo-id.txt)
    curl -s -X DELETE "$API_BASE/todos/$todo_id" > /dev/null
    rm -f last-created-todo-id.txt
    log "${GREEN}✅ Test data cleaned up${NC}"
  fi
}

# Function to generate report
generate_report() {
  local test_end_time=$(date +%s)
  local test_duration=$((test_end_time - test_start_time))

  cat > test-report.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Todo API Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #2E86AB; color: white; padding: 20px; border-radius: 5px; }
        .summary { background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .pass { color: #4CAF50; }
        .fail { color: #f44336; }
        .test-result { padding: 5px; border-left: 3px solid #ddd; margin: 5px 0; }
        .pass-result { border-left-color: #4CAF50; }
        .fail-result { border-left-color: #f44336; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Todo API Test Report</h1>
        <p>Generated on: $(date)</p>
    </div>

    <div class="summary">
        <h2>Test Summary</h2>
        <p><strong>Total Tests:</strong> $TOTAL_TESTS</p>
        <p><strong class="pass">Passed:</strong> $PASSED_TESTS</p>
        <p><strong class="fail">Failed:</strong> $FAILED_TESTS</p>
        <p><strong>Success Rate:</strong> $(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc)%</p>
        <p><strong>Duration:</strong> ${test_duration}s</p>
    </div>

    <h2>Test Results</h2>
EOF

  for result in "${TEST_RESULTS[@]}"; do
    if [[ $result == *"PASS"* ]]; then
      echo "    <div class=\"test-result pass-result\">$result</div>" >> test-report.html
    else
      echo "    <div class=\"test-result fail-result\">$result</div>" >> test-report.html
    fi
  done

  cat >> test-report.html << EOF
</body>
</html>
EOF

  log "${GREEN}📊 Test report generated: test-report.html${NC}"
}

# Function to display summary
display_summary() {
  local test_end_time=$(date +%s)
  local test_duration=$((test_end_time - test_start_time))

  echo ""
  echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"
  echo -e "${WHITE}                        📊 TEST SUMMARY                         ${NC}"
  echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}Total Tests: $TOTAL_TESTS${NC}"
  echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
  echo -e "${RED}Failed: $FAILED_TESTS${NC}"

  if [[ $TOTAL_TESTS -gt 0 ]]; then
    local success_rate=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc)
    echo -e "${CYAN}Success Rate: ${success_rate}%${NC}"
  fi

  echo -e "${PURPLE}Duration: ${test_duration}s${NC}"

  if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
  else
    echo -e "${RED}⚠️  Some tests failed. Check the output above for details.${NC}"
  fi

  echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"
}

# Main test execution
main() {
  display_header

  # Check API availability first
  if ! check_api_availability; then
    exit 1
  fi

  log ""
  log "${PURPLE}🧪 Starting Test Execution${NC}"
  log ""

  # Test 1: Get Statistics (baseline)
  run_test "Get Todo Statistics" \
    "curl -s \"$API_BASE/todos/stats\" | grep -q '\"success\":true'" \
    200

  # Test 2: Get All Todos (empty state)
  run_test "Get All Todos (Initial)" \
    "curl -s \"$API_BASE/todos\" | grep -q '\"success\":true'" \
    200

  # Test 3: Create Todo (Sample 1)
  run_test "Create Todo - Sample 1" \
    "./02-create-todo.sh --sample" \
    0

  # Test 4: Get Single Todo (last created)
  run_test "Get Single Todo (Last Created)" \
    "./03-get-single-todo.sh --last" \
    0

  # Test 5: Update Todo (mark as completed)
  run_test "Update Todo - Mark Completed" \
    "./04-update-todo.sh --last -c true" \
    0

  # Test 6: Get All Todos (with data)
  run_test "Get All Todos (With Data)" \
    "./01-get-all-todos.sh" \
    0

  if [[ "$FULL_TEST" == true ]]; then
    log "${YELLOW}🔄 Running Full Test Suite...${NC}"

    # Additional comprehensive tests
    run_test "Create Todo - Sample 2" \
      "./02-create-todo.sh --sample" \
      0

    run_test "Create Todo - Custom High Priority" \
      "./02-create-todo.sh -t 'Critical Bug Fix' -d 'Fix production issue' -p high" \
      0

    run_test "Get Todos - Filter by Completed" \
      "./01-get-all-todos.sh -c true" \
      0

    run_test "Get Todos - Filter by Priority" \
      "./01-get-all-todos.sh -p high" \
      0

    run_test "Update Todo - Change Priority" \
      "./04-update-todo.sh --last -p low" \
      0

    run_test "Update Todo - Update Description" \
      "./04-update-todo.sh --last -d 'Updated description for testing'" \
      0

    run_test "Get Updated Statistics" \
      "curl -s \"$API_BASE/todos/stats\" | grep -q '\"success\":true'" \
      200
  fi

  # Final cleanup test (if requested)
  if [[ "$CLEANUP" == true ]]; then
    run_test "Delete Todo (Cleanup)" \
      "./05-delete-todo.sh --last --yes" \
      0
  fi

  # Generate report if requested
  if [[ "$GENERATE_REPORT" == true ]]; then
    generate_report
  fi

  # Cleanup test data
  cleanup_test_data

  # Display summary
  display_summary
}

# Make scripts executable
chmod +x *.sh

# Run main function
main

# Exit with appropriate code
if [[ $FAILED_TESTS -eq 0 ]]; then
  exit 0
else
  exit 1
fi