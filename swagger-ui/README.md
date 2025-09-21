# Todo API - Swagger UI Documentation

Interactive API documentation for the Todo REST API with live testing capabilities.

## 📋 Overview

This Swagger UI provides comprehensive documentation for all Todo API endpoints including:

- **6 REST API Endpoints** with full CRUD operations
- **Interactive Testing** - Try endpoints directly from the browser
- **Request/Response Examples** with realistic sample data
- **Schema Definitions** for all data models
- **Real-time API Status** monitoring

## 🚀 Quick Start

### Prerequisites

1. **API Server Running**:
   ```bash
   cd express-js-rest-api
   npm run dev
   ```
   Server should be running on `http://localhost:5000`

2. **MongoDB Running**:
   ```bash
   cd mongo-db-docker-compose
   docker-compose up -d
   ```

### Access Swagger UI

**Option 1: Direct File Access**
```bash
# Open in your browser
open swagger-ui/swagger-ui.html
# Or navigate to: file:///path/to/swagger-ui.html
```

**Option 2: Local Web Server** (Recommended)
```bash
# Using Python
cd swagger-ui
python3 -m http.server 8080

# Using Node.js (if you have http-server installed)
npx http-server swagger-ui -p 8080

# Then visit: http://localhost:8080/swagger-ui.html
```

## 📖 API Endpoints

### 🔍 **GET /api/todos**
- **Description**: Retrieve all todos with optional filtering
- **Query Parameters**:
  - `completed` (boolean): Filter by completion status
  - `priority` (string): Filter by priority (low, medium, high)
- **Response**: Array of todo objects with metadata

### ➕ **POST /api/todos**
- **Description**: Create a new todo
- **Request Body**:
  ```json
  {
    "title": "Buy groceries",
    "description": "Get milk, bread, and eggs",
    "priority": "medium"
  }
  ```
- **Response**: Created todo object

### 🔍 **GET /api/todos/{id}**
- **Description**: Get a specific todo by ID
- **Path Parameters**:
  - `id` (string): MongoDB ObjectId (24 hex characters)
- **Response**: Single todo object

### ✏️ **PUT /api/todos/{id}**
- **Description**: Update an existing todo
- **Path Parameters**:
  - `id` (string): MongoDB ObjectId
- **Request Body**: Any combination of todo fields
- **Response**: Updated todo object

### 🗑️ **DELETE /api/todos/{id}**
- **Description**: Delete a todo by ID
- **Path Parameters**:
  - `id` (string): MongoDB ObjectId
- **Response**: Success confirmation message

### 📊 **GET /api/todos/stats**
- **Description**: Get todo statistics and analytics
- **Response**: Statistics object with counts and completion rates

## 🎯 Features

### Interactive Testing
- **Try It Out**: Click "Try it out" on any endpoint
- **Live Requests**: Execute real API calls from the browser
- **Response Inspection**: View actual API responses
- **Parameter Testing**: Test different query parameters and request bodies

### Real-time API Status
- **Status Indicator**: Shows if API is online/offline
- **Auto Refresh**: Status updates every 30 seconds
- **Connection Monitoring**: Visual feedback for API availability

### Comprehensive Examples
- **Multiple Scenarios**: Different request/response examples
- **Sample Data**: Realistic todo examples
- **Error Responses**: Examples of validation and error cases

### Schema Documentation
- **Data Models**: Complete Todo schema definition
- **Field Descriptions**: Detailed field explanations
- **Validation Rules**: Min/max lengths, required fields, enums

## 📋 Data Schema

### Todo Object
```json
{
  "_id": "64a1b2c3d4e5f6789012345",
  "title": "Complete project documentation",
  "description": "Write comprehensive API documentation",
  "completed": false,
  "priority": "high",
  "createdAt": "2025-09-21T10:30:00.000Z",
  "updatedAt": "2025-09-21T10:30:00.000Z"
}
```

### Field Specifications
- **`_id`**: MongoDB ObjectId (auto-generated)
- **`title`**: String, required, max 100 characters
- **`description`**: String, optional, max 500 characters
- **`completed`**: Boolean, default false
- **`priority`**: Enum ["low", "medium", "high"], default "medium"
- **`createdAt`**: ISO 8601 timestamp (auto-generated)
- **`updatedAt`**: ISO 8601 timestamp (auto-updated)

### Statistics Object
```json
{
  "total": 15,
  "completed": 8,
  "pending": 7,
  "completionRate": 53.33,
  "priorityBreakdown": {
    "low": 5,
    "medium": 7,
    "high": 3
  }
}
```

## 🎨 UI Features

### Custom Styling
- **Modern Design**: Clean, professional interface
- **Color Coding**: Status-based color indicators
- **Responsive Layout**: Works on desktop and mobile
- **Custom Header**: Branded header with API status

### Navigation
- **Organized Sections**: Grouped by functionality
- **Search/Filter**: Built-in endpoint filtering
- **Collapsible Sections**: Expandable endpoint details
- **Anchor Links**: Direct links to specific endpoints

### Additional Tools
- **Test Results Button**: Link to test results page
- **Refresh Button**: Manual API status refresh
- **Export Options**: OpenAPI spec download

## 🔧 Testing Workflow

### Basic Testing Sequence
1. **Check API Status**: Ensure green status indicator
2. **Get Statistics**: Start with `/api/todos/stats` endpoint
3. **Create Todo**: Use `/api/todos` POST with sample data
4. **Retrieve Todo**: Get the created todo by ID
5. **Update Todo**: Modify the todo using PUT
6. **Get Updated Stats**: Check statistics again
7. **Clean Up**: Delete test todo (optional)

### Sample Test Data

**Create Todo Examples:**
```json
// Basic todo
{
  "title": "Buy groceries",
  "description": "Get milk, bread, and eggs",
  "priority": "medium"
}

// High priority todo
{
  "title": "Fix critical bug",
  "description": "Urgent: Users cannot complete checkout",
  "priority": "high"
}

// Minimal todo
{
  "title": "Call dentist"
}
```

**Update Examples:**
```json
// Mark as completed
{
  "completed": true
}

// Change priority and description
{
  "priority": "low",
  "description": "Updated description with more details"
}

// Complete update
{
  "title": "Updated title",
  "description": "Updated description",
  "completed": true,
  "priority": "high"
}
```

## 🚨 Error Handling

### Common Error Responses

**400 Bad Request - Validation Error:**
```json
{
  "success": false,
  "error": "Title is required"
}
```

**404 Not Found:**
```json
{
  "success": false,
  "error": "Todo not found"
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "error": "Internal server error"
}
```

## 📊 Response Format

All API responses follow a consistent format:

**Success Response:**
```json
{
  "success": true,
  "data": { ... },      // Single object for individual operations
  "count": 5            // Number for list operations
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Error message"
}
```

## 🔗 Integration

### cURL Script Integration
The Swagger UI complements the cURL test scripts:
- Use Swagger UI for **interactive exploration**
- Use cURL scripts for **automated testing**
- Both test the same API endpoints
- Cross-reference examples between both tools

### Development Workflow
1. **Design**: Use Swagger UI to explore API capabilities
2. **Test**: Interactive testing with sample data
3. **Automate**: Create cURL scripts for repeated testing
4. **Validate**: Use both tools to ensure consistent behavior

## 🛠️ Customization

### Modifying the Documentation
1. Edit `todo-api-swagger.yaml` for API specification changes
2. Update `swagger-ui.html` for UI customizations
3. Refresh browser to see changes

### Adding New Endpoints
1. Add endpoint definition to YAML file
2. Include request/response examples
3. Update schema definitions if needed
4. Test the new endpoint in the UI

## 📈 Best Practices

### Testing Tips
1. **Start Simple**: Begin with GET requests
2. **Use Examples**: Copy provided sample data
3. **Check Status**: Monitor the API status indicator
4. **Save IDs**: Note created todo IDs for subsequent operations
5. **Clean Up**: Delete test data when finished

### Documentation Maintenance
- Keep examples up to date with API changes
- Add new scenarios as features are added
- Validate all examples regularly
- Update error response examples

---

**🎯 Interactive API Documentation** - Explore, test, and integrate with confidence!