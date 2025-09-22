#!/bin/bash

# 🚀 Run All Todo API Tests Script
# Executes the complete test suite in the correct order

# Configuration
API_BASE=${API_BASE:-"http://localhost:5000/api"}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test results tracking
declare -a test_results
declare -a test_names

echo -e "${CYAN}🚀 Todo API - Complete Test Suite${NC}"
echo "=================================="
echo "📍 API Base URL: $API_BASE"
echo "📁 Script Directory: $SCRIPT_DIR"
echo "📅 Test Run: $(date)"
echo ""

# Function to run a test script and track results
run_test_script() {
    local script_name=$1
    local display_name=$2
    local script_path="$SCRIPT_DIR/$script_name"
    
    echo -e "${BLUE}🧪 Running: $display_name${NC}"
    echo "=================================================="
    
    # Check if script exists and is executable
    if [ ! -f "$script_path" ]; then
        echo -e "${RED}❌ Script not found: $script_path${NC}"
        test_results+=("MISSING")
        test_names+=("$display_name")
        echo ""
        return 1
    fi
    
    if [ ! -x "$script_path" ]; then
        echo "🔧 Making script executable..."
        chmod +x "$script_path"
    fi
    
    # Run the test script and capture exit code
    local start_time=$(date +%s)
    "$script_path"
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Record result
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ $display_name completed successfully in ${duration}s${NC}"
        test_results+=("PASS")
    else
        echo -e "${RED}❌ $display_name failed (exit code: $exit_code) in ${duration}s${NC}"
        test_results+=("FAIL")
    fi
    
    test_names+=("$display_name")
    echo ""
    
    return $exit_code
}

# Pre-test checks
echo -e "${PURPLE}🔍 Pre-Test Environment Checks${NC}"
echo "============================================"

# Check if API is reachable
echo "📡 Checking API connectivity..."
if curl -s --connect-timeout 10 "$API_BASE/health" > /dev/null; then
    echo -e "✅ ${GREEN}API is reachable at $API_BASE${NC}"
else
    echo -e "❌ ${RED}Cannot connect to API at $API_BASE${NC}"
    echo "💡 Make sure the Express server is running:"
    echo "   cd express-js-rest-api && npm run dev"
    echo ""
    echo "💡 Make sure MongoDB is running:"
    echo "   cd mongo-db-docker-compose && docker-compose up -d"
    exit 1
fi

# Check if required tools are available
echo "🛠️  Checking required tools..."
required_tools=("curl" "jq")
for tool in "${required_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}$tool is available${NC}"
    else
        echo -e "⚠️  ${YELLOW}$tool is not installed (some tests may fail)${NC}"
    fi
done

echo ""

# === Test Execution Phase ===
echo -e "${CYAN}🧪 Test Execution Phase${NC}"
echo "========================"

# Test 1: Health Check (Prerequisites)
run_test_script "test-health.sh" "API Health Check"

# Only continue if health check passes
if [ "${test_results[-1]}" != "PASS" ]; then
    echo -e "${RED}❌ Health check failed. Stopping test suite.${NC}"
    exit 1
fi

# Test 2: Basic CRUD Operations
run_test_script "crud-operations.sh" "CRUD Operations"

# Test 3: All API Endpoints
run_test_script "api-endpoints.sh" "All API Endpoints"

# Test 4: Data Validation
run_test_script "data-validation.sh" "Data Validation"

# Test 5: Error Scenarios
run_test_script "error-scenarios.sh" "Error Handling"

# Test 6: Performance Testing
echo -e "${BLUE}🧪 Running: Performance Testing${NC}"
echo "=================================================="
echo "⚠️  Performance tests may take longer and create temporary load..."
read -p "Do you want to run performance tests? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    run_test_script "performance-test.sh" "Performance Testing"
else
    echo -e "${YELLOW}⏭️  Skipping performance tests${NC}"
    test_results+=("SKIP")
    test_names+=("Performance Testing")
    echo ""
fi

# === Test Results Summary ===
echo -e "${CYAN}📊 Test Results Summary${NC}"
echo "========================"

total_tests=${#test_results[@]}
passed_tests=0
failed_tests=0
skipped_tests=0
missing_tests=0

# Count results
for result in "${test_results[@]}"; do
    case $result in
        "PASS") ((passed_tests++));;
        "FAIL") ((failed_tests++));;
        "SKIP") ((skipped_tests++));;
        "MISSING") ((missing_tests++));;
    esac
done

# Display detailed results
echo "📋 Detailed Results:"
echo "==================="
for i in "${!test_names[@]}"; do
    local result="${test_results[$i]}"
    local name="${test_names[$i]}"
    
    case $result in
        "PASS") echo -e "✅ ${GREEN}PASS${NC} - $name";;
        "FAIL") echo -e "❌ ${RED}FAIL${NC} - $name";;
        "SKIP") echo -e "⏭️  ${YELLOW}SKIP${NC} - $name";;
        "MISSING") echo -e "❓ ${RED}MISS${NC} - $name";;
    esac
done

echo ""
echo "📈 Summary Statistics:"
echo "====================="
echo -e "✅ Passed: ${GREEN}$passed_tests${NC}"
echo -e "❌ Failed: ${RED}$failed_tests${NC}"
echo -e "⏭️  Skipped: ${YELLOW}$skipped_tests${NC}"
echo -e "❓ Missing: ${RED}$missing_tests${NC}"
echo -e "📝 Total: $total_tests"

# Calculate success rate (excluding skipped and missing)
executed_tests=$((passed_tests + failed_tests))
if [ $executed_tests -gt 0 ]; then
    success_rate=$(( (passed_tests * 100) / executed_tests ))
    echo -e "📊 Success Rate: $success_rate% (of executed tests)"
else
    success_rate=0
fi

# === Overall Assessment ===
echo ""
echo -e "${CYAN}🎯 Overall Assessment${NC}"
echo "====================="

if [ $failed_tests -eq 0 ] && [ $missing_tests -eq 0 ] && [ $passed_tests -gt 0 ]; then
    echo -e "${GREEN}🌟 Excellent! All tests passed successfully.${NC}"
    overall_status="EXCELLENT"
elif [ $success_rate -ge 80 ]; then
    echo -e "${GREEN}✅ Good! Most tests passed successfully.${NC}"
    overall_status="GOOD"
elif [ $success_rate -ge 60 ]; then
    echo -e "${YELLOW}⚠️  Moderate. Some issues need attention.${NC}"
    overall_status="MODERATE"
else
    echo -e "${RED}❌ Poor. Significant issues found.${NC}"
    overall_status="POOR"
fi

# === Recommendations ===
echo ""
echo "💡 Recommendations:"
echo "==================="

if [ $failed_tests -gt 0 ]; then
    echo "• Fix failing tests before deploying to production"
    echo "• Review error messages and API error handling"
fi

if [ $missing_tests -gt 0 ]; then
    echo "• Ensure all test scripts are present and executable"
fi

if [ $success_rate -lt 100 ] && [ $executed_tests -gt 0 ]; then
    echo "• Investigate failed test scenarios"
    echo "• Consider adding more comprehensive error handling"
fi

echo "• Run tests regularly during development"
echo "• Add these tests to your CI/CD pipeline"
echo "• Monitor API performance in production"

# === CI/CD Integration Info ===
echo ""
echo -e "${CYAN}🔄 CI/CD Integration${NC}"
echo "===================="
echo "To integrate these tests into your CI/CD pipeline:"
echo ""
echo "1. GitHub Actions example:"
echo "   - name: Run API Tests"
echo "     run: |"
echo "       cd curl-scripts"
echo "       ./run-all-tests.sh"
echo ""
echo "2. Exit codes:"
echo "   - 0: All tests passed"
echo "   - 1: Some tests failed"
echo ""
echo "3. Environment variables:"
echo "   - API_BASE: Set custom API URL"
echo "   - TIMEOUT: Set request timeout"

# === Test Artifacts ===
echo ""
echo -e "${CYAN}📁 Test Artifacts${NC}"
echo "=================="
echo "Generated files:"
echo "• Test logs: Available in terminal output"
echo "• Temporary files: Cleaned up automatically"
echo "• Results: Available in this summary"

# Final status
echo ""
echo -e "${CYAN}🏁 Test Suite Complete${NC}"
echo "======================="
echo "📅 Completed: $(date)"
echo "⏱️  Duration: Run time varies by test selection"
echo -e "🎯 Status: $overall_status"

# Set exit code based on results
if [ $failed_tests -eq 0 ] && [ $missing_tests -eq 0 ]; then
    echo -e "${GREEN}✅ All tests completed successfully!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed or are missing.${NC}"
    exit 1
fi