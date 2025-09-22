#!/bin/bash

# ⚡ Todo API Performance Test Script
# Tests API performance under load and concurrent requests

# Configuration
API_BASE=${API_BASE:-"http://localhost:5000/api"}
TIMEOUT=${TIMEOUT:-30}
CONCURRENT_REQUESTS=${CONCURRENT_REQUESTS:-10}
TOTAL_REQUESTS=${TOTAL_REQUESTS:-100}

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo "⚡ Testing Todo API Performance..."
echo "📍 API Base URL: $API_BASE"
echo "🔄 Concurrent Requests: $CONCURRENT_REQUESTS"
echo "📊 Total Requests: $TOTAL_REQUESTS"
echo ""

# Function to make a single request and measure time
make_timed_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local request_id=$4
    
    start_time=$(date +%s%N)
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            --connect-timeout $TIMEOUT \
            "$API_BASE$endpoint" 2>/dev/null)
    else
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "$method" \
            --connect-timeout $TIMEOUT \
            "$API_BASE$endpoint" 2>/dev/null)
    fi
    
    end_time=$(date +%s%N)
    duration_ns=$((end_time - start_time))
    duration_ms=$((duration_ns / 1000000))
    
    http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    
    echo "Request $request_id: $http_code ($duration_ms ms)"
    
    # Return: success(0/1),response_time_ms,status_code
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
        echo "1,$duration_ms,$http_code"
    else
        echo "0,$duration_ms,$http_code"
    fi
}

# Function to run concurrent requests
run_concurrent_test() {
    local test_name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local num_requests=$5
    
    echo -e "${BLUE}🚀 Running: $test_name${NC}"
    echo "📊 Making $num_requests concurrent $method requests to $endpoint"
    
    # Create temporary files for results
    results_file="/tmp/api_perf_results_$$"
    > "$results_file"
    
    # Start concurrent requests
    for i in $(seq 1 $num_requests); do
        (make_timed_request "$method" "$endpoint" "$data" "$i" >> "$results_file") &
    done
    
    # Wait for all requests to complete
    wait
    
    # Analyze results
    total_requests=$(wc -l < "$results_file")
    successful_requests=$(grep "^1," "$results_file" | wc -l)
    failed_requests=$(grep "^0," "$results_file" | wc -l)
    
    if [ "$successful_requests" -gt 0 ]; then
        min_time=$(grep "^1," "$results_file" | cut -d',' -f2 | sort -n | head -n1)
        max_time=$(grep "^1," "$results_file" | cut -d',' -f2 | sort -n | tail -n1)
        avg_time=$(grep "^1," "$results_file" | cut -d',' -f2 | awk '{sum+=$1} END {print int(sum/NR)}')
        
        # Calculate percentiles
        p95_time=$(grep "^1," "$results_file" | cut -d',' -f2 | sort -n | awk -v p=0.95 'BEGIN{c=0} {a[c++]=$1} END{print a[int(c*p)]}')
    else
        min_time=0
        max_time=0
        avg_time=0
        p95_time=0
    fi
    
    # Display results
    echo -e "📈 Results for $test_name:"
    echo -e "   ✅ Successful: ${GREEN}$successful_requests${NC}"
    echo -e "   ❌ Failed: ${RED}$failed_requests${NC}"
    echo -e "   📊 Success Rate: $(( (successful_requests * 100) / total_requests ))%"
    
    if [ "$successful_requests" -gt 0 ]; then
        echo -e "   ⚡ Min Response Time: ${min_time}ms"
        echo -e "   🐌 Max Response Time: ${max_time}ms"
        echo -e "   📊 Avg Response Time: ${avg_time}ms"
        echo -e "   📈 95th Percentile: ${p95_time}ms"
    fi
    
    echo ""
    
    # Cleanup
    rm -f "$results_file"
    
    # Return success rate
    echo "$(( (successful_requests * 100) / total_requests ))"
}

# === Performance Tests ===

# Test 1: Health Check Performance
echo -e "${PURPLE}=== Health Check Performance ===${NC}"
health_success_rate=$(run_concurrent_test "Health Check Load Test" "GET" "/health" "" $CONCURRENT_REQUESTS)

# Test 2: Get All Todos Performance  
echo -e "${PURPLE}=== Get All Todos Performance ===${NC}"
todos_success_rate=$(run_concurrent_test "Get All Todos Load Test" "GET" "/todos" "" $CONCURRENT_REQUESTS)

# Test 3: Create Todos Performance
echo -e "${PURPLE}=== Create Todos Performance ===${NC}"
create_data='{"title": "Performance Test Todo", "description": "Created during performance testing", "priority": "medium", "completed": false}'
create_success_rate=$(run_concurrent_test "Create Todos Load Test" "POST" "/todos" "$create_data" $CONCURRENT_REQUESTS)

# Test 4: Mixed Operations Performance
echo -e "${PURPLE}=== Mixed Operations Performance ===${NC}"
echo -e "${BLUE}🔄 Running mixed READ/WRITE operations${NC}"

# Create some test todos first for reading
echo "📝 Setting up test data..."
for i in {1..5}; do
    curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "{\"title\": \"Perf Test Todo $i\", \"priority\": \"medium\"}" \
        "$API_BASE/todos" > /dev/null
done

# Run mixed operations
mixed_results_file="/tmp/mixed_perf_results_$$"
> "$mixed_results_file"

echo "🚀 Running mixed operations (70% reads, 30% writes)..."
for i in $(seq 1 $TOTAL_REQUESTS); do
    if [ $((i % 10)) -lt 7 ]; then
        # 70% read operations
        (make_timed_request "GET" "/todos" "" "Mixed-$i" >> "$mixed_results_file") &
    else
        # 30% write operations
        write_data="{\"title\": \"Mixed Test $i\", \"priority\": \"low\"}"
        (make_timed_request "POST" "/todos" "$write_data" "Mixed-$i" >> "$mixed_results_file") &
    fi
    
    # Limit concurrent connections
    if [ $((i % CONCURRENT_REQUESTS)) -eq 0 ]; then
        wait
    fi
done

wait

# Analyze mixed results
total_mixed=$(wc -l < "$mixed_results_file")
successful_mixed=$(grep "^1," "$mixed_results_file" | wc -l)
mixed_success_rate=$(( (successful_mixed * 100) / total_mixed ))

echo -e "📈 Mixed Operations Results:"
echo -e "   📊 Total Requests: $total_mixed"
echo -e "   ✅ Successful: $successful_mixed"
echo -e "   📈 Success Rate: $mixed_success_rate%"

if [ "$successful_mixed" -gt 0 ]; then
    mixed_avg_time=$(grep "^1," "$mixed_results_file" | cut -d',' -f2 | awk '{sum+=$1} END {print int(sum/NR)}')
    echo -e "   📊 Avg Response Time: ${mixed_avg_time}ms"
fi

rm -f "$mixed_results_file"
echo ""

# Test 5: Stress Test (Gradual Load Increase)
echo -e "${PURPLE}=== Stress Test (Gradual Load) ===${NC}"
echo -e "${BLUE}🔥 Running stress test with increasing load${NC}"

stress_results=""
for load in 1 5 10 20 50; do
    echo "📊 Testing with $load concurrent requests..."
    stress_rate=$(run_concurrent_test "Stress Test ($load concurrent)" "GET" "/todos" "" $load)
    stress_results="$stress_results\nLoad $load: $stress_rate% success"
    
    # Add a small delay between tests
    sleep 1
done

echo -e "${BLUE}📈 Stress Test Summary:${NC}"
echo -e "$stress_results"
echo ""

# Test 6: Response Size Impact
echo -e "${PURPLE}=== Response Size Impact ===${NC}"
echo -e "${BLUE}📏 Testing impact of response size on performance${NC}"

# Test with limit parameter to get different response sizes
for limit in 1 10 50 100; do
    echo "📊 Testing with limit=$limit (response size test)..."
    size_rate=$(run_concurrent_test "Response Size Test (limit=$limit)" "GET" "/todos?limit=$limit" "" 5)
    echo -e "   Limit $limit: $size_rate% success rate"
done
echo ""

# Test 7: Database Query Performance
echo -e "${PURPLE}=== Database Query Performance ===${NC}"
echo -e "${BLUE}🔍 Testing different query patterns${NC}"

# Test different query patterns
queries=(
    "/todos"
    "/todos?completed=true" 
    "/todos?priority=high"
    "/todos?completed=false&priority=medium"
    "/todos/stats"
)

for query in "${queries[@]}"; do
    echo "📊 Testing query: $query"
    query_rate=$(run_concurrent_test "Query Test" "GET" "$query" "" 5)
    echo -e "   Query success rate: $query_rate%"
done
echo ""

# === Performance Summary ===
echo ""
echo "📊 Performance Test Summary:"
echo "============================"

# Calculate overall performance score
overall_score=$(( (health_success_rate + todos_success_rate + create_success_rate + mixed_success_rate) / 4 ))

echo -e "🏥 Health Check: $health_success_rate% success"
echo -e "📋 Get Todos: $todos_success_rate% success"  
echo -e "➕ Create Todos: $create_success_rate% success"
echo -e "🔄 Mixed Operations: $mixed_success_rate% success"
echo ""
echo -e "📈 Overall Performance Score: $overall_score%"

# Performance rating
if [ "$overall_score" -ge 95 ]; then
    echo -e "${GREEN}🌟 Excellent Performance!${NC}"
elif [ "$overall_score" -ge 85 ]; then
    echo -e "${GREEN}✅ Good Performance${NC}"
elif [ "$overall_score" -ge 70 ]; then
    echo -e "${YELLOW}⚠️  Acceptable Performance${NC}"
else
    echo -e "${RED}❌ Poor Performance - Needs Optimization${NC}"
fi

# Recommendations
echo ""
echo "💡 Performance Recommendations:"
echo "• Monitor response times during peak usage"
echo "• Consider implementing caching for read-heavy operations"
echo "• Add database indexing for frequently queried fields"  
echo "• Implement request rate limiting to prevent abuse"
echo "• Use connection pooling for database connections"
echo "• Consider horizontal scaling for high traffic"

# Cleanup any remaining test todos
echo ""
echo "🧹 Cleaning up test data..."
curl -s "$API_BASE/todos" | jq -r '.data[]? | select(.title | contains("Performance Test") or contains("Perf Test") or contains("Mixed Test")) | ._id' | while read -r todo_id; do
    [ -n "$todo_id" ] && curl -s -X DELETE "$API_BASE/todos/$todo_id" > /dev/null
done

echo -e "${GREEN}🏁 Performance testing completed!${NC}"