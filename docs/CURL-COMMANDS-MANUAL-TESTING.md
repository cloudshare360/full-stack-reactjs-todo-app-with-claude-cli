# 🌐 Todo API - Manual Testing with cURL Commands

## 📋 **Overview**

This document provides comprehensive cURL commands for manual testing of all Todo API endpoints. Each command includes examples with different scenarios, expected responses, and error handling cases. Simply copy and paste these commands into your terminal to test the API manually.

## 🚀 **Prerequisites**

### Start the API Server
```bash
# Navigate to the Express.js API directory
cd /workspaces/full-stack-reactjs-todo-app-with-claude-cli/express-js-rest-api

# Install dependencies (if not already done)
npm install

# Start the development server
npm run dev
```

### Start MongoDB (if not already running)
```bash
# Navigate to MongoDB directory
cd /workspaces/full-stack-reactjs-todo-app-with-claude-cli/mongo-db-docker-compose

# Start MongoDB containers
docker-compose up -d
```

### Verify API is Running
```bash
curl -X GET http://localhost:5000/api/health
```

Expected Response:
```json
{
  "success": true,
  "message": "API is running",
  "timestamp": "2025-09-22T10:30:00.000Z"
}
```

---

## 🏥 **1. HEALTH CHECK ENDPOINTS**

### 1.1 API Health Check
```bash
curl -X GET \
  http://localhost:5000/api/health \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "API is running",
  "timestamp": "2025-09-22T10:30:00.000Z"
}
```

### 1.2 Root Endpoint
```bash
curl -X GET \
  http://localhost:5000/ \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "message": "Welcome to Todo API",
  "version": "1.0.0",
  "endpoints": {
    "todos": "/api/todos",
    "health": "/api/health"
  }
}
```

---

## 📚 **2. READ OPERATIONS**

### 2.1 Get All Todos
```bash
curl -X GET \
  http://localhost:5000/api/todos \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "count": 3,
  "data": [
    {
      "_id": "64f8d1234567890abcdef123",
      "title": "Complete project documentation",
      "description": "Write comprehensive API documentation",
      "priority": "high",
      "completed": false,
      "createdAt": "2025-09-22T08:00:00.000Z",
      "updatedAt": "2025-09-22T08:00:00.000Z"
    }
  ]
}
```

### 2.2 Get Completed Todos Only
```bash
curl -X GET \
  "http://localhost:5000/api/todos?completed=true" \
  -H "Content-Type: application/json"
```

### 2.3 Get Todos by Priority
```bash
# Get high priority todos
curl -X GET \
  "http://localhost:5000/api/todos?priority=high" \
  -H "Content-Type: application/json"

# Get medium priority todos
curl -X GET \
  "http://localhost:5000/api/todos?priority=medium" \
  -H "Content-Type: application/json"

# Get low priority todos
curl -X GET \
  "http://localhost:5000/api/todos?priority=low" \
  -H "Content-Type: application/json"
```

### 2.4 Get Pending (Incomplete) Todos
```bash
curl -X GET \
  "http://localhost:5000/api/todos?completed=false" \
  -H "Content-Type: application/json"
```

### 2.5 Get Todos with Sorting
```bash
# Sort by creation date (newest first)
curl -X GET \
  "http://localhost:5000/api/todos?sort=-createdAt" \
  -H "Content-Type: application/json"

# Sort by creation date (oldest first)
curl -X GET \
  "http://localhost:5000/api/todos?sort=createdAt" \
  -H "Content-Type: application/json"

# Sort by title (alphabetical)
curl -X GET \
  "http://localhost:5000/api/todos?sort=title" \
  -H "Content-Type: application/json"
```

### 2.6 Complex Filtering (Multiple Parameters)
```bash
# Get high priority incomplete todos, sorted by creation date
curl -X GET \
  "http://localhost:5000/api/todos?priority=high&completed=false&sort=-createdAt" \
  -H "Content-Type: application/json"
```

### 2.7 Get Single Todo by ID
```bash
# Replace {TODO_ID} with an actual todo ID from the previous requests
curl -X GET \
  http://localhost:5000/api/todos/{TODO_ID} \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "_id": "64f8d1234567890abcdef123",
    "title": "Complete project documentation",
    "description": "Write comprehensive API documentation",
    "priority": "high",
    "completed": false,
    "createdAt": "2025-09-22T08:00:00.000Z",
    "updatedAt": "2025-09-22T08:00:00.000Z"
  }
}
```

### 2.8 Get Non-Existent Todo (Error Case)
```bash
curl -X GET \
  http://localhost:5000/api/todos/507f1f77bcf86cd799439011 \
  -H "Content-Type: application/json"
```

**Expected Response (404):**
```json
{
  "success": false,
  "error": "Todo not found"
}
```

### 2.9 Get Todo with Invalid ID Format (Error Case)
```bash
curl -X GET \
  http://localhost:5000/api/todos/invalid-id-format \
  -H "Content-Type: application/json"
```

**Expected Response (404):**
```json
{
  "success": false,
  "error": "Todo not found"
}
```

---

## ➕ **3. CREATE OPERATIONS**

### 3.1 Create Basic Todo
```bash
curl -X POST \
  http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Manual Test Todo",
    "description": "This todo was created using cURL for manual testing",
    "priority": "medium",
    "completed": false
  }'
```

**Expected Response (201):**
```json
{
  "success": true,
  "data": {
    "_id": "64f8d1234567890abcdef124",
    "title": "Manual Test Todo",
    "description": "This todo was created using cURL for manual testing",
    "priority": "medium",
    "completed": false,
    "createdAt": "2025-09-22T10:30:00.000Z",
    "updatedAt": "2025-09-22T10:30:00.000Z"
  }
}
```

### 3.2 Create High Priority Todo
```bash
curl -X POST \
  http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Urgent Task",
    "description": "This is a high priority task that needs immediate attention",
    "priority": "high",
    "completed": false
  }'
```

### 3.3 Create Low Priority Todo
```bash
curl -X POST \
  http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Nice to Have Feature",
    "description": "This can be done when time permits",
    "priority": "low",
    "completed": false
  }'
```

### 3.4 Create Already Completed Todo
```bash
curl -X POST \
  http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Already Done Task",
    "description": "This task was marked as completed when created",
    "priority": "medium",
    "completed": true
  }'
```

### 3.5 Create Todo with Minimal Data
```bash
curl -X POST \
  http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Minimal Todo"
  }'
```

### 3.6 Create Todo with Long Description
```bash
curl -X POST \
  http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Comprehensive Planning Task",
    "description": "This is a very detailed description that explains exactly what needs to be done, including all the steps, requirements, dependencies, and expected outcomes. It serves as a comprehensive guide for anyone who needs to work on this task in the future.",
    "priority": "medium",
    "completed": false
  }'
```

### 3.7 Create Todo with Special Characters
```bash
curl -X POST \
  http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Special Characters Test: !@#$%^&*()[]{}|;'\''\":,./<>?`~",
    "description": "Testing special characters in todo content",
    "priority": "low",
    "completed": false
  }'
```

### 3.8 Create Todo with Unicode/Emojis
```bash
curl -X POST \
  http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Unicode Test: 🚀 📋 ✅ 🎯 你好 мир العالم",
    "description": "Testing Unicode characters and emojis in todo content",
    "priority": "medium",
    "completed": false
  }'
```

### 3.9 Create Invalid Todo - Missing Title (Error Case)
```bash
curl -X POST \
  http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Todo without title should fail validation",
    "priority": "medium"
  }'
```

**Expected Response (400):**
```json
{
  "success": false,
  "error": "Validation Error",
  "details": [
    {
      "field": "title",
      "message": "Title is required"
    }
  ]
}
```

### 3.10 Create Invalid Todo - Invalid Priority (Error Case)
```bash
curl -X POST \
  http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Invalid Priority Test",
    "description": "Testing invalid priority value",
    "priority": "super-urgent"
  }'
```

**Expected Response (400):**
```json
{
  "success": false,
  "error": "Validation Error",
  "details": [
    {
      "field": "priority",
      "message": "Priority must be one of: low, medium, high"
    }
  ]
}
```

---

## ✏️ **4. UPDATE OPERATIONS**

### 4.1 Update Todo Title and Description
```bash
# Replace {TODO_ID} with an actual todo ID
curl -X PUT \
  http://localhost:5000/api/todos/{TODO_ID} \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Title from cURL",
    "description": "This todo has been updated with new title and description using cURL"
  }'
```

**Expected Response (200):**
```json
{
  "success": true,
  "data": {
    "_id": "64f8d1234567890abcdef123",
    "title": "Updated Title from cURL",
    "description": "This todo has been updated with new title and description using cURL",
    "priority": "medium",
    "completed": false,
    "createdAt": "2025-09-22T08:00:00.000Z",
    "updatedAt": "2025-09-22T10:35:00.000Z"
  }
}
```

### 4.2 Mark Todo as Completed
```bash
# Replace {TODO_ID} with an actual todo ID
curl -X PUT \
  http://localhost:5000/api/todos/{TODO_ID} \
  -H "Content-Type: application/json" \
  -d '{
    "completed": true
  }'
```

### 4.3 Mark Todo as Incomplete
```bash
# Replace {TODO_ID} with an actual todo ID
curl -X PUT \
  http://localhost:5000/api/todos/{TODO_ID} \
  -H "Content-Type: application/json" \
  -d '{
    "completed": false
  }'
```

### 4.4 Change Todo Priority
```bash
# Replace {TODO_ID} with an actual todo ID
curl -X PUT \
  http://localhost:5000/api/todos/{TODO_ID} \
  -H "Content-Type: application/json" \
  -d '{
    "priority": "high"
  }'
```

### 4.5 Update Multiple Fields at Once
```bash
# Replace {TODO_ID} with an actual todo ID
curl -X PUT \
  http://localhost:5000/api/todos/{TODO_ID} \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Multi-field Updated Todo",
    "description": "Updated description, priority, and completion status",
    "priority": "low",
    "completed": true
  }'
```

### 4.6 Update Todo with Empty Description
```bash
# Replace {TODO_ID} with an actual todo ID
curl -X PUT \
  http://localhost:5000/api/todos/{TODO_ID} \
  -H "Content-Type: application/json" \
  -d '{
    "description": ""
  }'
```

### 4.7 Update Non-Existent Todo (Error Case)
```bash
curl -X PUT \
  http://localhost:5000/api/todos/507f1f77bcf86cd799439011 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "This should fail"
  }'
```

**Expected Response (404):**
```json
{
  "success": false,
  "error": "Todo not found"
}
```

### 4.8 Update with Invalid Priority (Error Case)
```bash
# Replace {TODO_ID} with an actual todo ID
curl -X PUT \
  http://localhost:5000/api/todos/{TODO_ID} \
  -H "Content-Type: application/json" \
  -d '{
    "priority": "invalid-priority"
  }'
```

**Expected Response (400):**
```json
{
  "success": false,
  "error": "Validation Error",
  "details": [
    {
      "field": "priority",
      "message": "Priority must be one of: low, medium, high"
    }
  ]
}
```

### 4.9 Update with Invalid ID Format (Error Case)
```bash
curl -X PUT \
  http://localhost:5000/api/todos/invalid-id-format \
  -H "Content-Type: application/json" \
  -d '{
    "title": "This should fail"
  }'
```

**Expected Response (404):**
```json
{
  "success": false,
  "error": "Todo not found"
}
```

---

## 🗑️ **5. DELETE OPERATIONS**

### 5.1 Delete Existing Todo
```bash
# Replace {TODO_ID} with an actual todo ID
curl -X DELETE \
  http://localhost:5000/api/todos/{TODO_ID} \
  -H "Content-Type: application/json"
```

**Expected Response (200):**
```json
{
  "success": true,
  "message": "Todo deleted successfully"
}
```

### 5.2 Delete Non-Existent Todo (Error Case)
```bash
curl -X DELETE \
  http://localhost:5000/api/todos/507f1f77bcf86cd799439011 \
  -H "Content-Type: application/json"
```

**Expected Response (404):**
```json
{
  "success": false,
  "error": "Todo not found"
}
```

### 5.3 Delete with Invalid ID Format (Error Case)
```bash
curl -X DELETE \
  http://localhost:5000/api/todos/invalid-id-format \
  -H "Content-Type: application/json"
```

**Expected Response (404):**
```json
{
  "success": false,
  "error": "Todo not found"
}
```

---

## 📊 **6. STATISTICS OPERATIONS**

### 6.1 Get Todo Statistics
```bash
curl -X GET \
  http://localhost:5000/api/todos/stats \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "total": 15,
    "completed": 7,
    "pending": 8,
    "byPriority": {
      "high": 3,
      "medium": 8,
      "low": 4
    }
  }
}
```

---

## 🧪 **7. TESTING WORKFLOWS**

### 7.1 Complete CRUD Workflow Test
```bash
# Step 1: Create a test todo
echo "=== Step 1: Creating test todo ==="
TODO_RESPONSE=$(curl -s -X POST \
  http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "CRUD Workflow Test",
    "description": "Testing complete CRUD workflow",
    "priority": "medium",
    "completed": false
  }')

echo $TODO_RESPONSE

# Extract todo ID (requires jq - install with: sudo apt-get install jq)
TODO_ID=$(echo $TODO_RESPONSE | jq -r '.data._id')
echo "Created todo with ID: $TODO_ID"

# Step 2: Read the created todo
echo -e "\n=== Step 2: Reading created todo ==="
curl -s -X GET \
  http://localhost:5000/api/todos/$TODO_ID \
  -H "Content-Type: application/json" | jq

# Step 3: Update the todo
echo -e "\n=== Step 3: Updating todo ==="
curl -s -X PUT \
  http://localhost:5000/api/todos/$TODO_ID \
  -H "Content-Type: application/json" \
  -d '{
    "title": "UPDATED: CRUD Workflow Test",
    "completed": true,
    "priority": "high"
  }' | jq

# Step 4: Verify the update
echo -e "\n=== Step 4: Verifying update ==="
curl -s -X GET \
  http://localhost:5000/api/todos/$TODO_ID \
  -H "Content-Type: application/json" | jq

# Step 5: Delete the todo
echo -e "\n=== Step 5: Deleting todo ==="
curl -s -X DELETE \
  http://localhost:5000/api/todos/$TODO_ID \
  -H "Content-Type: application/json" | jq

# Step 6: Verify deletion
echo -e "\n=== Step 6: Verifying deletion ==="
curl -s -X GET \
  http://localhost:5000/api/todos/$TODO_ID \
  -H "Content-Type: application/json" | jq
```

### 7.2 Bulk Create Test Todos
```bash
echo "=== Creating multiple test todos ==="

# Create high priority todo
curl -s -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "High Priority Task", "priority": "high", "completed": false}' | jq

# Create medium priority todo
curl -s -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Medium Priority Task", "priority": "medium", "completed": false}' | jq

# Create low priority todo
curl -s -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Low Priority Task", "priority": "low", "completed": true}' | jq

# Get all todos to see the created items
echo -e "\n=== All todos after bulk creation ==="
curl -s -X GET http://localhost:5000/api/todos -H "Content-Type: application/json" | jq
```

### 7.3 Performance Test (Simple Load Test)
```bash
echo "=== Simple Performance Test ==="
echo "Creating 50 todos and measuring time..."

start_time=$(date +%s)

for i in {1..50}; do
  curl -s -X POST http://localhost:5000/api/todos \
    -H "Content-Type: application/json" \
    -d "{\"title\": \"Performance Test Todo $i\", \"priority\": \"low\"}" > /dev/null
done

end_time=$(date +%s)
duration=$((end_time - start_time))

echo "Created 50 todos in $duration seconds"
echo "Average: $(echo "scale=3; $duration/50" | bc) seconds per request"

# Get stats to see the total
curl -s -X GET http://localhost:5000/api/todos/stats -H "Content-Type: application/json" | jq
```

---

## 🔧 **8. UTILITY COMMANDS**

### 8.1 Pretty Print JSON Response (requires jq)
```bash
# Install jq if not available
sudo apt-get update && sudo apt-get install -y jq

# Use jq to pretty print any curl response
curl -s -X GET http://localhost:5000/api/todos | jq
```

### 8.2 Save Response to File
```bash
# Save response to a file
curl -X GET http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -o todos_response.json

# View the saved file
cat todos_response.json | jq
```

### 8.3 Measure Response Time
```bash
# Measure response time
curl -X GET http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -w "Response Time: %{time_total}s\nHTTP Code: %{http_code}\n" \
  -o /dev/null -s
```

### 8.4 Test with Verbose Output
```bash
# Use -v flag for verbose output (useful for debugging)
curl -v -X GET http://localhost:5000/api/todos \
  -H "Content-Type: application/json"
```

### 8.5 Test Headers and Status Only
```bash
# Get only headers (useful for checking status codes)
curl -I -X GET http://localhost:5000/api/todos
```

---

## ❌ **9. ERROR SCENARIOS TESTING**

### 9.1 Test Invalid JSON Format
```bash
curl -X POST \
  http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Invalid JSON", "description": "Missing closing quote}'
```

### 9.2 Test Missing Content-Type Header
```bash
curl -X POST \
  http://localhost:5000/api/todos \
  -d '{"title": "No Content Type Header"}'
```

### 9.3 Test Invalid HTTP Method
```bash
# PATCH is not supported - should return 404
curl -X PATCH \
  http://localhost:5000/api/todos/507f1f77bcf86cd799439011 \
  -H "Content-Type: application/json" \
  -d '{"title": "PATCH not supported"}'
```

### 9.4 Test Invalid Route
```bash
curl -X GET \
  http://localhost:5000/api/invalid-route \
  -H "Content-Type: application/json"
```

**Expected Response (404):**
```json
{
  "success": false,
  "error": "Route /api/invalid-route not found"
}
```

---

## 📋 **10. QUICK REFERENCE**

### All Available Endpoints:
```
GET    /                      - Root endpoint with API info
GET    /api/health            - API health check
GET    /api/todos             - Get all todos (with optional filters)
POST   /api/todos             - Create new todo
GET    /api/todos/stats       - Get todo statistics
GET    /api/todos/:id         - Get specific todo by ID
PUT    /api/todos/:id         - Update existing todo
DELETE /api/todos/:id         - Delete specific todo
```

### Query Parameters for GET /api/todos:
- `completed=true|false` - Filter by completion status
- `priority=low|medium|high` - Filter by priority level
- `sort=createdAt|-createdAt|title` - Sort results

### Common HTTP Status Codes:
- `200` - Success (GET, PUT, DELETE)
- `201` - Created (POST)
- `400` - Bad Request (Validation error)
- `404` - Not Found (Invalid ID or route)
- `500` - Server Error

### Required Fields for POST/PUT:
- `title` (string, required for POST)
- `description` (string, optional)
- `priority` (enum: "low"|"medium"|"high", optional, default: "medium")
- `completed` (boolean, optional, default: false)

---

## 🎯 **Tips for Manual Testing**

1. **Install jq** for better JSON formatting:
   ```bash
   sudo apt-get install jq
   ```

2. **Save todo IDs** from create operations for use in read/update/delete operations

3. **Use variables** in bash to store frequently used values:
   ```bash
   API_BASE="http://localhost:5000/api"
   TODO_ID="your-todo-id-here"
   curl -X GET $API_BASE/todos/$TODO_ID
   ```

4. **Test in sequence** - create todos first, then test read/update/delete operations

5. **Check response status codes** using the `-w` flag:
   ```bash
   curl -w "%{http_code}" -s -o /dev/null http://localhost:5000/api/health
   ```

6. **Use verbose mode** (`-v`) when debugging connection issues

7. **Test error scenarios** to ensure proper error handling

---

## 🏁 **Conclusion**

This document provides comprehensive cURL commands for testing all Todo API endpoints manually. Use these commands to:

- ✅ Verify API functionality after deployment
- 🧪 Test individual endpoints during development  
- 🔍 Debug API issues and error scenarios
- 📊 Monitor API performance and response times
- 🎯 Validate API behavior in different environments

Copy and paste the commands directly into your terminal for immediate testing. Modify the data payloads and parameters as needed for your specific testing scenarios.

**Happy Testing!** 🚀