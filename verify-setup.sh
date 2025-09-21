#!/bin/bash
# Complete Setup Verification Script
# Verifies both Swagger UI and cURL scripts are working correctly

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

API_BASE="http://localhost:5000/api"

echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}           🔧 TODO API SETUP VERIFICATION SCRIPT                 ${NC}"
echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Date: $(date)${NC}"
echo -e "${BLUE}API Base: $API_BASE${NC}"
echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# Verification counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Function to run a check
run_check() {
  local check_name="$1"
  local check_command="$2"
  local success_message="$3"
  local fail_message="$4"

  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  echo -e "${CYAN}[CHECK $TOTAL_CHECKS] $check_name${NC}"

  if eval "$check_command" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ $success_message${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
  else
    echo -e "${RED}❌ $fail_message${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
  fi
  echo ""
}

# Check 1: Verify directory structure
echo -e "${PURPLE}📁 Directory Structure Verification${NC}"
run_check "Swagger UI Directory" \
  "test -d swagger-ui" \
  "Swagger UI directory exists" \
  "Swagger UI directory missing"

run_check "cURL Scripts Directory" \
  "test -d curl-scripts" \
  "cURL scripts directory exists" \
  "cURL scripts directory missing"

# Check 2: Verify Swagger UI files
echo -e "${PURPLE}📄 Swagger UI Files Verification${NC}"
run_check "Swagger YAML Specification" \
  "test -f swagger-ui/todo-api-swagger.yaml" \
  "Swagger YAML file exists" \
  "Swagger YAML file missing"

run_check "Swagger HTML Interface" \
  "test -f swagger-ui/swagger-ui.html" \
  "Swagger HTML file exists" \
  "Swagger HTML file missing"

run_check "Swagger README Documentation" \
  "test -f swagger-ui/README.md" \
  "Swagger README exists" \
  "Swagger README missing"

# Check 3: Verify cURL scripts
echo -e "${PURPLE}📜 cURL Scripts Verification${NC}"
CURL_SCRIPTS=(
  "01-get-all-todos.sh"
  "02-create-todo.sh"
  "03-get-single-todo.sh"
  "04-update-todo.sh"
  "05-delete-todo.sh"
  "06-get-stats.sh"
  "test-all-endpoints.sh"
)

for script in "${CURL_SCRIPTS[@]}"; do
  run_check "cURL Script: $script" \
    "test -f curl-scripts/$script && test -x curl-scripts/$script" \
    "$script exists and is executable" \
    "$script missing or not executable"
done

run_check "cURL Scripts README" \
  "test -f curl-scripts/README.md" \
  "cURL README exists" \
  "cURL README missing"

# Check 4: API Server availability
echo -e "${PURPLE}🌐 API Server Verification${NC}"
run_check "Express API Server" \
  "curl -s -f $API_BASE/todos/stats" \
  "API server is running and responding" \
  "API server is not running or not responding"

# Check 5: Dependencies verification
echo -e "${PURPLE}🔧 Dependencies Verification${NC}"
run_check "cURL Command Available" \
  "command -v curl" \
  "cURL is installed and available" \
  "cURL is not installed"

run_check "Python 3 Available" \
  "command -v python3" \
  "Python 3 is available for JSON formatting" \
  "Python 3 not available (JSON formatting will be limited)"

run_check "bc Calculator Available" \
  "command -v bc" \
  "bc calculator is available for statistics" \
  "bc calculator not available (some calculations may not work)"

# Check 6: Test basic functionality
echo -e "${PURPLE}🧪 Functionality Tests${NC}"

if [[ $PASSED_CHECKS -gt $((TOTAL_CHECKS / 2)) ]]; then
  # Only run functionality tests if basic setup is good

  run_check "Get Statistics Endpoint" \
    "curl -s $API_BASE/todos/stats | grep -q '\"success\":true'" \
    "Statistics endpoint working correctly" \
    "Statistics endpoint not working"

  run_check "Get All Todos Endpoint" \
    "curl -s $API_BASE/todos | grep -q '\"success\":true'" \
    "Get all todos endpoint working correctly" \
    "Get all todos endpoint not working"

  # Test cURL script execution
  if [[ -x "curl-scripts/06-get-stats.sh" ]]; then
    run_check "cURL Script Execution" \
      "cd curl-scripts && ./06-get-stats.sh >/dev/null 2>&1" \
      "cURL scripts execute successfully" \
      "cURL scripts have execution issues"
  fi
fi

# Check 7: Swagger UI accessibility test
echo -e "${PURPLE}📱 Swagger UI Accessibility${NC}"
run_check "Swagger YAML Syntax" \
  "python3 -c 'import yaml; yaml.safe_load(open(\"swagger-ui/todo-api-swagger.yaml\"))'" \
  "Swagger YAML has valid syntax" \
  "Swagger YAML has syntax errors (install PyYAML: pip install pyyaml)"

# Display results summary
echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}                           📊 VERIFICATION SUMMARY                ${NC}"
echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"

echo -e "${BLUE}Total Checks: $TOTAL_CHECKS${NC}"
echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
echo -e "${RED}Failed: $FAILED_CHECKS${NC}"

if [[ $TOTAL_CHECKS -gt 0 ]]; then
  SUCCESS_RATE=$(echo "scale=1; $PASSED_CHECKS * 100 / $TOTAL_CHECKS" | bc 2>/dev/null || echo "N/A")
  echo -e "${CYAN}Success Rate: ${SUCCESS_RATE}%${NC}"
fi

echo ""

# Status determination
if [[ $FAILED_CHECKS -eq 0 ]]; then
  echo -e "${GREEN}🎉 ALL CHECKS PASSED!${NC}"
  echo -e "${GREEN}✅ Your Todo API documentation and testing setup is complete and ready to use!${NC}"
elif [[ $PASSED_CHECKS -gt $((TOTAL_CHECKS * 2 / 3)) ]]; then
  echo -e "${YELLOW}⚠️  MOSTLY WORKING${NC}"
  echo -e "${YELLOW}Most components are working. Check failed items above.${NC}"
else
  echo -e "${RED}❌ SETUP ISSUES DETECTED${NC}"
  echo -e "${RED}Several components need attention. Please review failed checks.${NC}"
fi

echo ""
echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}                              📋 NEXT STEPS                      ${NC}"
echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"

echo -e "${BLUE}🔧 If API Server is not running:${NC}"
echo "   cd express-js-rest-api && npm run dev"
echo ""

echo -e "${BLUE}🐳 If MongoDB is not running:${NC}"
echo "   cd mongo-db-docker-compose && docker-compose up -d"
echo ""

echo -e "${BLUE}📖 To view Swagger UI:${NC}"
echo "   1. cd swagger-ui"
echo "   2. python3 -m http.server 8080"
echo "   3. Open: http://localhost:8080/swagger-ui.html"
echo ""

echo -e "${BLUE}🧪 To run cURL tests:${NC}"
echo "   cd curl-scripts"
echo "   ./test-all-endpoints.sh --full --report"
echo ""

echo -e "${BLUE}📚 For detailed documentation:${NC}"
echo "   - Swagger UI: swagger-ui/README.md"
echo "   - cURL Scripts: curl-scripts/README.md"

echo -e "${WHITE}════════════════════════════════════════════════════════════════${NC}"

# Exit with appropriate code
if [[ $FAILED_CHECKS -eq 0 ]]; then
  exit 0
elif [[ $PASSED_CHECKS -gt $((TOTAL_CHECKS / 2)) ]]; then
  exit 1
else
  exit 2
fi