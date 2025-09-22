# Express.js Backend Architecture Documentation

## Overview
This document provides a comprehensive overview of the Express.js backend architecture for the Todo Application, including detailed sequence diagrams for each API endpoint and flow.

## Architecture Components

### 1. Server Entry Point (`server.js`)
The main server file that sets up the Express application with middleware, routes, and error handling.

**Key Components:**
- **Security Middleware**: Helmet for security headers, CORS for cross-origin requests
- **Logging**: Morgan for HTTP request logging in development
- **Body Parsing**: Express built-in JSON and URL-encoded parsers
- **Routes**: Todo API routes mounted at `/api/todos`
- **Error Handling**: Global error handler middleware
- **Health Checks**: Health endpoint for monitoring

### 2. Route Layer (`src/routes/todoRoutes.js`)
Defines all API endpoints and maps them to controller functions.

**Available Routes:**
- `GET /api/todos` - Get all todos (with optional filters)
- `POST /api/todos` - Create a new todo
- `GET /api/todos/stats` - Get todo statistics
- `GET /api/todos/:id` - Get a specific todo
- `PUT /api/todos/:id` - Update a specific todo
- `DELETE /api/todos/:id` - Delete a specific todo

### 3. Controller Layer (`src/controllers/todoController.js`)
Contains business logic for handling requests and responses.

**Controller Functions:**
- `getAllTodos()` - Handles fetching todos with filtering and sorting
- `getTodo()` - Handles fetching a single todo by ID
- `createTodo()` - Handles creating a new todo
- `updateTodo()` - Handles updating an existing todo
- `deleteTodo()` - Handles deleting a todo
- `getTodosStats()` - Handles fetching todo statistics

### 4. Model Layer (`src/models/Todo.js`)
Mongoose schema defining the data structure and validation rules.

**Schema Fields:**
- `title` (String, required, max 100 chars)
- `description` (String, optional, max 500 chars)
- `completed` (Boolean, default: false)
- `priority` (Enum: low/medium/high, default: medium)
- `timestamps` (createdAt, updatedAt - auto-generated)

### 5. Middleware Layer
- **Validation Middleware** (`src/middleware/validation.js`): Input validation using express-validator
- **Error Handler** (`src/middleware/errorHandler.js`): Centralized error handling

### 6. Database Configuration (`src/config/database.js`)
MongoDB connection setup with Mongoose ODM.

---

## API Endpoint Sequence Diagrams

### 1. GET /api/todos - Retrieve All Todos

```mermaid
sequenceDiagram
    participant Client
    participant Express
    participant Router
    participant Controller
    participant Model
    participant MongoDB

    Client->>Express: GET /api/todos?completed=false&priority=high&sort=-createdAt
    Express->>Express: Apply security middleware (helmet, cors)
    Express->>Express: Log request (morgan)
    Express->>Express: Parse query parameters
    Express->>Router: Route to /api/todos
    Router->>Controller: getAllTodos(req, res)
    
    Controller->>Controller: Extract query parameters
    Note over Controller: Build filter object based on query params
    Controller->>Controller: Validate sort parameter
    
    Controller->>Model: Todo.find(filter).sort(sort)
    Model->>MongoDB: Query with filters and sorting
    MongoDB-->>Model: Return matched documents
    Model-->>Controller: Return todo array
    
    Controller->>Controller: Format response
    Controller-->>Router: JSON response with todos
    Router-->>Express: Response data
    Express-->>Client: 200 OK with todos array

    Note over Client, MongoDB: Success Response Format:
    Note over Client, MongoDB: {
    Note over Client, MongoDB:   "success": true,
    Note over Client, MongoDB:   "count": 5,
    Note over Client, MongoDB:   "data": [...todos]
    Note over Client, MongoDB: }
```

### 2. POST /api/todos - Create New Todo

```mermaid
sequenceDiagram
    participant Client
    participant Express
    participant Router
    participant Validation
    participant Controller
    participant Model
    participant MongoDB

    Client->>Express: POST /api/todos
    Note over Client: Body: { "title": "Learn React", "description": "Study hooks", "priority": "high" }
    
    Express->>Express: Apply security & parsing middleware
    Express->>Router: Route to POST /api/todos
    Router->>Validation: validateCreateTodo middleware
    
    Validation->>Validation: Check title (required, max 100 chars)
    Validation->>Validation: Check description (optional, max 500 chars)
    Validation->>Validation: Check priority (low/medium/high)
    Validation->>Validation: Check completed (boolean)
    
    alt Validation Passes
        Validation->>Controller: createTodo(req, res)
        Controller->>Controller: Check validationResult
        Controller->>Model: Todo.create(req.body)
        
        Model->>Model: Apply schema validation
        Model->>MongoDB: Insert document
        MongoDB-->>Model: Return created document with _id
        Model-->>Controller: Return new todo
        
        Controller->>Controller: Format response
        Controller-->>Client: 201 Created with new todo
    else Validation Fails
        Validation-->>Client: 400 Bad Request with validation errors
    end

    Note over Client, MongoDB: Success Response:
    Note over Client, MongoDB: {
    Note over Client, MongoDB:   "success": true,
    Note over Client, MongoDB:   "data": { ...newTodo }
    Note over Client, MongoDB: }
```

### 3. GET /api/todos/:id - Retrieve Single Todo

```mermaid
sequenceDiagram
    participant Client
    participant Express
    participant Router
    participant Controller
    participant Model
    participant MongoDB

    Client->>Express: GET /api/todos/507f1f77bcf86cd799439011
    Express->>Express: Apply middleware
    Express->>Router: Route to /:id handler
    Router->>Controller: getTodo(req, res)
    
    Controller->>Controller: Extract ID from req.params.id
    Controller->>Model: Todo.findById(id)
    Model->>MongoDB: Find document by ObjectId
    
    alt Todo Found
        MongoDB-->>Model: Return todo document
        Model-->>Controller: Return todo
        Controller-->>Client: 200 OK with todo data
    else Todo Not Found
        MongoDB-->>Model: Return null
        Model-->>Controller: Return null
        Controller-->>Client: 404 Not Found
    else Invalid ObjectId
        Model-->>Controller: CastError
        Controller-->>Client: 404 Not Found
    end

    Note over Client, MongoDB: Success Response:
    Note over Client, MongoDB: {
    Note over Client, MongoDB:   "success": true,
    Note over Client, MongoDB:   "data": { ...todo }
    Note over Client, MongoDB: }
```

### 4. PUT /api/todos/:id - Update Todo

```mermaid
sequenceDiagram
    participant Client
    participant Express
    participant Router
    participant Validation
    participant Controller
    participant Model
    participant MongoDB

    Client->>Express: PUT /api/todos/507f1f77bcf86cd799439011
    Note over Client: Body: { "completed": true, "priority": "low" }
    
    Express->>Express: Apply middleware
    Express->>Router: Route to PUT /:id
    Router->>Validation: validateUpdateTodo middleware
    
    Validation->>Validation: Validate partial update fields
    Validation->>Controller: updateTodo(req, res)
    
    Controller->>Controller: Check validation results
    Controller->>Controller: Extract ID and update data
    
    Controller->>Model: Todo.findByIdAndUpdate(id, updates, options)
    Note over Model: options: { new: true, runValidators: true }
    
    Model->>MongoDB: Update document and return new version
    
    alt Todo Updated Successfully
        MongoDB-->>Model: Return updated document
        Model-->>Controller: Return updated todo
        Controller-->>Client: 200 OK with updated todo
    else Todo Not Found
        MongoDB-->>Model: Return null
        Model-->>Controller: Return null
        Controller-->>Client: 404 Not Found
    else Validation Error
        MongoDB-->>Model: ValidationError
        Model-->>Controller: Validation error
        Controller-->>Client: 400 Bad Request
    end
```

### 5. DELETE /api/todos/:id - Delete Todo

```mermaid
sequenceDiagram
    participant Client
    participant Express
    participant Router
    participant Controller
    participant Model
    participant MongoDB

    Client->>Express: DELETE /api/todos/507f1f77bcf86cd799439011
    Express->>Express: Apply middleware
    Express->>Router: Route to DELETE /:id
    Router->>Controller: deleteTodo(req, res)
    
    Controller->>Controller: Extract ID from params
    Controller->>Model: Todo.findByIdAndDelete(id)
    Model->>MongoDB: Find and delete document
    
    alt Todo Deleted Successfully
        MongoDB-->>Model: Return deleted document
        Model-->>Controller: Return deleted todo
        Controller-->>Client: 200 OK with success message
    else Todo Not Found
        MongoDB-->>Model: Return null
        Model-->>Controller: Return null
        Controller-->>Client: 404 Not Found
    else Invalid ObjectId
        Model-->>Controller: CastError
        Controller-->>Client: 404 Not Found
    end

    Note over Client, MongoDB: Success Response:
    Note over Client, MongoDB: {
    Note over Client, MongoDB:   "success": true,
    Note over Client, MongoDB:   "message": "Todo deleted successfully"
    Note over Client, MongoDB: }
```

### 6. GET /api/todos/stats - Get Todo Statistics

```mermaid
sequenceDiagram
    participant Client
    participant Express
    participant Router
    participant Controller
    participant Model
    participant MongoDB

    Client->>Express: GET /api/todos/stats
    Express->>Express: Apply middleware
    Express->>Router: Route to /stats
    Router->>Controller: getTodosStats(req, res)
    
    Controller->>Model: Todo.aggregate([completion stats])
    Model->>MongoDB: Aggregation pipeline for completion stats
    MongoDB-->>Model: Return completion statistics
    
    Controller->>Model: Todo.aggregate([priority stats])
    Model->>MongoDB: Aggregation pipeline for priority stats
    MongoDB-->>Model: Return priority statistics
    
    Controller->>Model: Todo.countDocuments()
    Model->>MongoDB: Count total documents
    MongoDB-->>Model: Return total count
    
    Controller->>Controller: Format combined statistics
    Controller-->>Client: 200 OK with stats object

    Note over Client, MongoDB: Success Response:
    Note over Client, MongoDB: {
    Note over Client, MongoDB:   "success": true,
    Note over Client, MongoDB:   "data": {
    Note over Client, MongoDB:     "total": 10,
    Note over Client, MongoDB:     "completed": 4,
    Note over Client, MongoDB:     "pending": 6,
    Note over Client, MongoDB:     "byPriority": { "low": 2, "medium": 5, "high": 3 }
    Note over Client, MongoDB:   }
    Note over Client, MongoDB: }
```

---

## Error Handling Flow

```mermaid
sequenceDiagram
    participant Client
    participant Express
    participant Controller
    participant ErrorHandler
    participant MongoDB

    Client->>Express: Invalid API Request
    Express->>Controller: Process request
    Controller->>MongoDB: Database operation
    
    alt Database Error
        MongoDB-->>Controller: Error (e.g., ValidationError, CastError)
        Controller->>Controller: Log error
        Controller->>ErrorHandler: next(error)
        ErrorHandler->>ErrorHandler: Determine error type and status
        ErrorHandler-->>Client: Formatted error response
    else Controller Error
        Controller->>Controller: Catch application error
        Controller-->>Client: Direct error response
    end

    Note over Client, MongoDB: Error Response Format:
    Note over Client, MongoDB: {
    Note over Client, MongoDB:   "success": false,
    Note over Client, MongoDB:   "error": "Error message",
    Note over Client, MongoDB:   "details": [...] // for validation errors
    Note over Client, MongoDB: }
```

---

## Middleware Chain Flow

```mermaid
sequenceDiagram
    participant Client
    participant Helmet
    participant CORS
    participant Morgan
    participant BodyParser
    participant Router
    participant Validation
    participant Controller
    participant ErrorHandler

    Client->>Helmet: HTTP Request
    Helmet->>CORS: Add security headers
    CORS->>Morgan: Handle CORS
    Morgan->>BodyParser: Log request
    BodyParser->>Router: Parse body
    Router->>Validation: Route to handler
    
    alt Validation Required
        Validation->>Controller: Validate input
        Controller->>Controller: Process business logic
        Controller-->>Client: Send response
    else No Validation
        Router->>Controller: Direct to controller
        Controller->>Controller: Process business logic
        Controller-->>Client: Send response
    end
    
    alt Error Occurs
        Controller->>ErrorHandler: next(error)
        ErrorHandler-->>Client: Error response
    end
```

---

## Key Features

### 1. **Security**
- Helmet.js for security headers
- CORS configuration for cross-origin requests
- Input validation with express-validator
- MongoDB injection protection through Mongoose

### 2. **Error Handling**
- Centralized error handling middleware
- Proper HTTP status codes
- Consistent error response format
- Validation error details

### 3. **Performance**
- Database indexing for common queries
- Query optimization with filtering and sorting
- Proper HTTP caching headers
- Request logging for monitoring

### 4. **Maintainability**
- Modular architecture with separation of concerns
- Consistent code structure
- Comprehensive error logging
- Environment-based configuration

### 5. **API Standards**
- RESTful endpoint design
- Consistent JSON response format
- Proper HTTP methods and status codes
- Request/response validation

---

## Environment Configuration

The application uses environment variables for configuration:

```env
# Server Configuration
PORT=5000
NODE_ENV=development

# Database Configuration
MONGODB_URI=mongodb://todouser:todopass123@localhost:27017/todoapp

# CORS Configuration
# Automatically configured based on NODE_ENV
```

This architecture provides a robust, scalable, and maintainable backend for the Todo application with proper error handling, validation, and security measures.