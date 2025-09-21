# API Documentation

Complete reference for the ReactJS Todo Application REST API.

## 🔗 Base URL

**Development**: `http://localhost:5000/api`
**Production**: `https://your-domain.com/api`

## 📋 API Overview

The API follows REST principles with JSON request/response format. All endpoints return a consistent response structure.

### Response Format
```json
{
  "success": boolean,
  "data": any,
  "message": string,
  "timestamp": string
}
```

### Error Response Format
```json
{
  "success": false,
  "error": string,
  "message": string,
  "timestamp": string
}
```

## 🔧 Endpoints

### Health Check

#### GET /api/health
Check if the API is running and accessible.

**Request:**
```bash
GET /api/health
```

**Response:**
```json
{
  "success": true,
  "message": "API is running",
  "timestamp": "2025-09-21T17:30:00.000Z"
}
```

---

### Todo Operations

#### GET /api/todos
Retrieve all todos.

**Request:**
```bash
GET /api/todos
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "title": "Complete project documentation",
      "description": "Write comprehensive API docs",
      "completed": false,
      "priority": "high",
      "createdAt": "2025-09-21T10:00:00.000Z",
      "updatedAt": "2025-09-21T10:00:00.000Z"
    }
  ],
  "timestamp": "2025-09-21T17:30:00.000Z"
}
```

#### GET /api/todos/:id
Retrieve a specific todo by ID.

**Request:**
```bash
GET /api/todos/507f1f77bcf86cd799439011
```

**Response:**
```json
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "title": "Complete project documentation",
    "description": "Write comprehensive API docs",
    "completed": false,
    "priority": "high",
    "createdAt": "2025-09-21T10:00:00.000Z",
    "updatedAt": "2025-09-21T10:00:00.000Z"
  },
  "timestamp": "2025-09-21T17:30:00.000Z"
}
```

#### POST /api/todos
Create a new todo.

**Request:**
```bash
POST /api/todos
Content-Type: application/json

{
  "title": "New Todo Item",
  "description": "Optional description",
  "priority": "medium"
}
```

**Request Body Schema:**
```typescript
{
  title: string,        // Required, 1-100 characters
  description?: string, // Optional, max 500 characters
  priority: 'low' | 'medium' | 'high' // Default: 'medium'
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439012",
    "title": "New Todo Item",
    "description": "Optional description",
    "completed": false,
    "priority": "medium",
    "createdAt": "2025-09-21T17:30:00.000Z",
    "updatedAt": "2025-09-21T17:30:00.000Z"
  },
  "timestamp": "2025-09-21T17:30:00.000Z"
}
```

#### PUT /api/todos/:id
Update an existing todo.

**Request:**
```bash
PUT /api/todos/507f1f77bcf86cd799439011
Content-Type: application/json

{
  "title": "Updated Todo Title",
  "completed": true
}
```

**Request Body Schema:**
```typescript
{
  title?: string,        // Optional, 1-100 characters
  description?: string,  // Optional, max 500 characters
  completed?: boolean,   // Optional
  priority?: 'low' | 'medium' | 'high' // Optional
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "title": "Updated Todo Title",
    "description": "Write comprehensive API docs",
    "completed": true,
    "priority": "high",
    "createdAt": "2025-09-21T10:00:00.000Z",
    "updatedAt": "2025-09-21T17:30:00.000Z"
  },
  "timestamp": "2025-09-21T17:30:00.000Z"
}
```

#### DELETE /api/todos/:id
Delete a specific todo.

**Request:**
```bash
DELETE /api/todos/507f1f77bcf86cd799439011
```

**Response:**
```json
{
  "success": true,
  "message": "Todo deleted successfully",
  "timestamp": "2025-09-21T17:30:00.000Z"
}
```

## 📊 HTTP Status Codes

| Status Code | Description | Usage |
|-------------|-------------|--------|
| 200 | OK | Successful GET, PUT requests |
| 201 | Created | Successful POST requests |
| 400 | Bad Request | Invalid request data |
| 404 | Not Found | Todo ID not found |
| 500 | Internal Server Error | Server-side errors |

## 🔍 Data Models

### Todo Model
```typescript
interface Todo {
  _id: string;              // MongoDB ObjectId as string
  title: string;            // 1-100 characters, required
  description?: string;     // Optional, max 500 characters
  completed: boolean;       // Default: false
  priority: 'low' | 'medium' | 'high'; // Default: 'medium'
  createdAt: string;        // ISO 8601 timestamp
  updatedAt: string;        // ISO 8601 timestamp
}
```

### Priority System
- **high**: Important, urgent tasks (Red: #ff4757)
- **medium**: Normal importance (Orange: #ffa502)
- **low**: Nice-to-have tasks (Green: #26de81)

## 💻 Code Examples

### JavaScript/Fetch API
```javascript
// Get all todos
const getAllTodos = async () => {
  try {
    const response = await fetch('http://localhost:5000/api/todos');
    const result = await response.json();

    if (result.success) {
      return result.data;
    } else {
      throw new Error(result.message);
    }
  } catch (error) {
    console.error('Error fetching todos:', error);
    throw error;
  }
};

// Create a new todo
const createTodo = async (todoData) => {
  try {
    const response = await fetch('http://localhost:5000/api/todos', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(todoData),
    });

    const result = await response.json();

    if (result.success) {
      return result.data;
    } else {
      throw new Error(result.message);
    }
  } catch (error) {
    console.error('Error creating todo:', error);
    throw error;
  }
};

// Update a todo
const updateTodo = async (id, updates) => {
  try {
    const response = await fetch(`http://localhost:5000/api/todos/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(updates),
    });

    const result = await response.json();

    if (result.success) {
      return result.data;
    } else {
      throw new Error(result.message);
    }
  } catch (error) {
    console.error('Error updating todo:', error);
    throw error;
  }
};
```

### cURL Examples
```bash
# Get all todos
curl -X GET http://localhost:5000/api/todos

# Create a new todo
curl -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Learn API integration",
    "description": "Practice with cURL and Postman",
    "priority": "high"
  }'

# Update a todo
curl -X PUT http://localhost:5000/api/todos/507f1f77bcf86cd799439011 \
  -H "Content-Type: application/json" \
  -d '{
    "completed": true,
    "title": "Completed: Learn API integration"
  }'

# Delete a todo
curl -X DELETE http://localhost:5000/api/todos/507f1f77bcf86cd799439011
```

### Python/Requests
```python
import requests
import json

BASE_URL = "http://localhost:5000/api"

def get_all_todos():
    response = requests.get(f"{BASE_URL}/todos")
    result = response.json()

    if result["success"]:
        return result["data"]
    else:
        raise Exception(result["message"])

def create_todo(title, description=None, priority="medium"):
    todo_data = {
        "title": title,
        "priority": priority
    }

    if description:
        todo_data["description"] = description

    response = requests.post(
        f"{BASE_URL}/todos",
        headers={"Content-Type": "application/json"},
        data=json.dumps(todo_data)
    )

    result = response.json()

    if result["success"]:
        return result["data"]
    else:
        raise Exception(result["message"])

def update_todo(todo_id, **updates):
    response = requests.put(
        f"{BASE_URL}/todos/{todo_id}",
        headers={"Content-Type": "application/json"},
        data=json.dumps(updates)
    )

    result = response.json()

    if result["success"]:
        return result["data"]
    else:
        raise Exception(result["message"])
```

## ⚠️ Error Handling

### Validation Errors
```json
{
  "success": false,
  "error": "Validation failed",
  "message": "Title is required and must be between 1-100 characters",
  "timestamp": "2025-09-21T17:30:00.000Z"
}
```

### Not Found Errors
```json
{
  "success": false,
  "error": "Todo not found",
  "message": "No todo found with the provided ID",
  "timestamp": "2025-09-21T17:30:00.000Z"
}
```

### Server Errors
```json
{
  "success": false,
  "error": "Internal server error",
  "message": "An unexpected error occurred",
  "timestamp": "2025-09-21T17:30:00.000Z"
}
```

## 🔒 CORS Configuration

The API is configured to accept requests from:
- `http://localhost:3000` (Default React port)
- `http://localhost:3001` (Alternative React port)

For production, update the CORS configuration in the backend server.

## 📝 Rate Limiting

Currently, no rate limiting is implemented. For production deployment, consider implementing rate limiting to prevent abuse.

## 🧪 Testing the API

### Using Postman
1. Import the collection: [Download Postman Collection](../postman-collection.json)
2. Set base URL variable to `http://localhost:5000/api`
3. Run the collection to test all endpoints

### Using Thunder Client (VS Code)
1. Install Thunder Client extension
2. Import the [Thunder Client collection](../thunder-client.json)
3. Test all endpoints with pre-configured requests

---

*← [Quick Start](./quick-start.md) | [Testing Guide →](./testing-guide.md)*