# 🚀 Todo API Postman Collection

## 📋 Overview

This comprehensive Postman collection provides complete CRUD testing for the Todo API with proper sequential ordering, automatic test validation, and cleanup functionality. The collection is designed to be run from start to finish to test all API endpoints systematically.

## 🎯 Collection Features

### ✅ **Complete CRUD Operations**
- **Create**: Multiple todo creation scenarios with different priorities and states
- **Read**: Single and bulk retrieval, filtering, and sorting operations
- **Update**: Partial and complete todo modifications
- **Delete**: Individual todo deletion with verification

### 🧪 **Comprehensive Testing**
- **Health Checks**: API availability and connectivity verification
- **Statistics Tracking**: Before/after comparisons of todo counts
- **Error Handling**: Validation of error responses and status codes
- **Data Validation**: Response structure and content verification
- **Performance Testing**: Response time monitoring

### 🛠️ **Advanced Features**
- **Automatic ID Management**: Dynamic variable storage and retrieval
- **Sequential Execution**: Proper order for dependent operations
- **Cleanup Functionality**: Automatic test data cleanup
- **Environment Support**: Configurable base URLs and settings
- **Comprehensive Logging**: Detailed console output for debugging

## 📁 Collection Structure

```
🚀 Todo API - Complete CRUD Testing Collection
├── 🏥 Health & Setup
│   ├── 🩺 API Health Check
│   └── 🌐 Root Endpoint Info
├── 📊 Statistics (Before Tests)
│   └── 📈 Get Initial Todo Statistics
├── 📚 READ Operations
│   ├── 📋 Get All Todos (Initial)
│   └── 🔍 Get Single Todo (If Exists)
├── ➕ CREATE Operations
│   ├── 🚀 Create High Priority Todo
│   ├── 📝 Create Medium Priority Todo
│   ├── 📚 Create Low Priority Todo
│   ├── ✅ Create Completed Todo
│   └── 🔤 Create Todo with Special Characters
├── 📚 READ Operations (After Creation)
│   ├── 📋 Get All Todos (After Creation)
│   ├── 🔍 Get Single Created Todo
│   ├── 🔍 Filter Todos by Priority (High)
│   ├── ✅ Filter Completed Todos
│   └── 📅 Sort Todos by Creation Date
├── ✏️ UPDATE Operations
│   ├── 📝 Update Todo Title and Description
│   ├── ✅ Mark Todo as Completed
│   ├── 🔄 Change Todo Priority
│   └── 🔄 Update Multiple Fields
├── 📊 Statistics (After Updates)
│   └── 📈 Get Updated Todo Statistics
├── 🗑️ DELETE Operations
│   ├── 🗑️ Delete Single Todo
│   └── 🔍 Verify Todo Deletion
├── ❌ Error Handling Tests
│   ├── ❌ Get Non-Existent Todo
│   ├── ❌ Create Todo with Invalid Data
│   ├── ❌ Update Non-Existent Todo
│   └── ❌ Delete Non-Existent Todo
└── 🧹 Cleanup & Final Verification
    ├── 📊 Final Statistics Check
    └── 🗑️ Cleanup Created Test Todos
```

## 🚀 Quick Start Guide

### 1. Prerequisites
```bash
# Ensure your Todo API server is running
cd express-js-rest-api
npm start

# Verify MongoDB is running
cd mongo-db-docker-compose
./scripts/start-mongodb.sh
```

### 2. Import the Collection
1. Open Postman
2. Click **Import** button
3. Select `Todo-API-CRUD-Collection.json`
4. Import the environment file `Todo-API-Environment.json`

### 3. Set Up Environment
1. Select **🌍 Todo API - Testing Environment** from the environment dropdown
2. Verify `baseUrl` is set to your API server URL (default: `http://localhost:5000`)

### 4. Run the Collection
**Option A: Full Collection Run**
```
1. Click on the collection name
2. Click "Run collection"
3. Select all requests
4. Click "Run Todo API - Complete CRUD Testing Collection"
```

**Option B: Sequential Manual Execution**
```
1. Start with "🏥 Health & Setup" folder
2. Execute each request in order
3. Monitor console output for detailed results
4. Continue through each folder sequentially
```

## 📊 Test Data Examples

### 🚀 High Priority Todo
```json
{
    "title": "🚨 Urgent: Complete Postman API Testing",
    "description": "Set up comprehensive API testing using Postman collection with all CRUD operations.",
    "priority": "high",
    "completed": false
}
```

### 📝 Medium Priority Todo
```json
{
    "title": "📊 Implement API Documentation",
    "description": "Create comprehensive API documentation with examples and error codes.",
    "priority": "medium",
    "completed": false
}
```

### 📚 Low Priority Todo
```json
{
    "title": "🎨 Improve UI/UX Design",
    "description": "Enhance the user interface with better colors, typography, and layout.",
    "priority": "low",
    "completed": false
}
```

### ✅ Completed Todo
```json
{
    "title": "✅ Setup Development Environment",
    "description": "Initialize project structure, install dependencies, configure database.",
    "priority": "high",
    "completed": true
}
```

### 🔤 Special Characters Todo
```json
{
    "title": "🌍 Special Characters & Unicode Test: !@#$%^&*()[]{}|;':,.<>?",
    "description": "Testing special characters, Unicode symbols, and emojis: 你好 мир العالم 🚀📋✅🎯",
    "priority": "medium",
    "completed": false
}
```

## 🧪 Validation & Testing

### ✅ **Automatic Test Scripts**
Each request includes comprehensive test scripts that validate:

- **Status Codes**: Correct HTTP response codes (200, 201, 404, 400)
- **Response Structure**: Proper JSON structure with required fields
- **Data Integrity**: Content matches expectations
- **Performance**: Response times within acceptable limits
- **Error Handling**: Proper error messages and structures

### 📊 **Statistics Tracking**
The collection tracks todo statistics throughout the test run:

```javascript
// Example statistics verification
pm.test('Statistics reflect changes', function () {
    const responseJson = pm.response.json();
    const initialTotal = parseInt(pm.environment.get('initialTotalTodos') || '0');
    const createdTodos = JSON.parse(pm.environment.get('createdTodos') || '[]');
    
    pm.expect(responseJson.data.total).to.equal(initialTotal + createdTodos.length);
});
```

### 🔄 **Dynamic Variable Management**
Variables are automatically managed throughout the collection:

```javascript
// Store created todo ID for later operations
const createdTodo = pm.response.json().data;
pm.environment.set('highPriorityTodoId', createdTodo._id);

// Track all created todos for cleanup
let createdTodos = JSON.parse(pm.environment.get('createdTodos') || '[]');
createdTodos.push(createdTodo._id);
pm.environment.set('createdTodos', JSON.stringify(createdTodos));
```

## 🔧 API Endpoints Covered

| Method | Endpoint | Description | Test Scenarios |
|--------|----------|-------------|----------------|
| `GET` | `/` | Root endpoint info | Basic connectivity |
| `GET` | `/api/health` | Health check | API availability |
| `GET` | `/api/todos` | Get all todos | Pagination, filtering, sorting |
| `GET` | `/api/todos/:id` | Get single todo | Valid/invalid IDs |
| `POST` | `/api/todos` | Create new todo | Various priorities, validation |
| `PUT` | `/api/todos/:id` | Update todo | Partial/complete updates |
| `DELETE` | `/api/todos/:id` | Delete todo | Successful/failed deletion |
| `GET` | `/api/todos/stats` | Get statistics | Count tracking |

## 🎛️ Environment Variables

| Variable | Purpose | Example Value |
|----------|---------|---------------|
| `baseUrl` | API server URL | `http://localhost:5000` |
| `highPriorityTodoId` | Store high priority todo ID | Auto-generated |
| `mediumPriorityTodoId` | Store medium priority todo ID | Auto-generated |
| `lowPriorityTodoId` | Store low priority todo ID | Auto-generated |
| `completedTodoId` | Store completed todo ID | Auto-generated |
| `specialCharsTodoId` | Store special chars todo ID | Auto-generated |
| `createdTodos` | Array of all created todo IDs | `["id1", "id2", ...]` |
| `initialTotalTodos` | Initial todo count | Auto-captured |

## 🧹 Cleanup Process

The collection includes automatic cleanup functionality:

1. **Track Created Todos**: All created todos are stored in environment variables
2. **Verify Operations**: Each operation is validated before cleanup
3. **Sequential Deletion**: Cleanup requests remove test todos one by one
4. **Final Verification**: Statistics are checked to ensure proper cleanup

### Manual Cleanup
If needed, you can manually clean up test todos:

```bash
# Get all todos and identify test todos by title patterns
curl -X GET http://localhost:5000/api/todos

# Delete specific test todos
curl -X DELETE http://localhost:5000/api/todos/{todo-id}
```

## 📝 Console Output

The collection provides detailed console logging:

```
🚀 Starting request: Create High Priority Todo
📍 URL: http://localhost:5000/api/todos
✅ High priority todo created successfully
💾 Stored todo ID: 507f1f77bcf86cd799439011
📋 Title: 🚨 Urgent: Complete Postman API Testing
⏱️ Response time: 45 ms
📊 Status code: 201
```

## 🐛 Troubleshooting

### Common Issues

**1. Connection Refused**
```
Error: connect ECONNREFUSED 127.0.0.1:5000
Solution: Ensure the API server is running on the correct port
```

**2. MongoDB Connection Error**
```
Error: MongoDB connection failed
Solution: Start MongoDB using docker-compose
```

**3. Environment Variables Not Set**
```
Issue: {{variableName}} showing as undefined
Solution: Ensure environment is selected and variables are populated
```

### Debug Tips

1. **Check Console Output**: Monitor Postman console for detailed logs
2. **Verify Environment**: Ensure correct environment is selected
3. **Sequential Execution**: Run requests in the specified order
4. **Response Validation**: Check response structure matches expectations

## 🔄 Integration with Other Testing Tools

This Postman collection complements other testing tools in the project:

- **Curl Scripts**: Located in `curl-scripts/` folder
- **E2E Tests**: Playwright tests in `reactjs-18-front-end/tests/`
- **Jupyter Notebooks**: Interactive testing in `jupyter-api-testing/`
- **Manual Testing**: Documentation in `docs/CURL-COMMANDS-MANUAL-TESTING.md`

## 📈 Performance Monitoring

The collection includes performance tests:

```javascript
// Global performance test
pm.test('Response time is reasonable', function () {
    pm.expect(pm.response.responseTime).to.be.below(5000);
});

// Specific performance logging
console.log('⏱️ Response time:', pm.response.responseTime, 'ms');
```

## 🤝 Contributing

To extend this collection:

1. **Add New Requests**: Follow the existing naming convention with emojis
2. **Include Test Scripts**: Add comprehensive validation for each request
3. **Update Variables**: Manage dynamic variables appropriately
4. **Document Changes**: Update this README with new functionality

## 📚 Additional Resources

- [Postman Documentation](https://learning.postman.com/)
- [Todo API Documentation](../docs/use-me/api-documentation.md)
- [Project Quick Start Guide](../docs/use-me/quick-start.md)
- [AI Agent Tracking](../AI-AGENT-TRACKING.md)

---

## 🎯 Test Execution Summary

When you run this collection, you'll execute:

- **2** Health and Setup checks
- **1** Initial statistics capture
- **2** Initial read operations
- **5** Create operations (different priorities and scenarios)
- **5** Read operations after creation (verification and filtering)
- **4** Update operations (various field modifications)
- **1** Statistics verification after updates
- **2** Delete operations with verification
- **4** Error handling scenarios
- **2** Final cleanup and verification

**Total: 28 comprehensive test scenarios**

This ensures complete coverage of your Todo API functionality with proper CRUD operation testing, error handling, and data integrity verification.

## ✅ Success Criteria

A successful test run should show:
- ✅ All health checks pass
- ✅ All CRUD operations work correctly
- ✅ Statistics reflect proper counts
- ✅ Error handling works as expected
- ✅ Test data is properly cleaned up
- ✅ Performance is within acceptable limits

Happy Testing! 🚀📋✅