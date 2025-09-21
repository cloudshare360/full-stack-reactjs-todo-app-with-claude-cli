# System Architecture

## 🏗 High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   Database      │
│   (React 18)    │    │   (Express.js)  │    │   (MongoDB)     │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • React Components │◄──►│ • REST API      │◄──►│ • Collections   │
│ • State Management │    │ • Business Logic│    │ • Indexes       │
│ • HTTP Client     │    │ • Data Models   │    │ • Validation    │
│ • UI/UX          │    │ • Middleware    │    │ • Relationships │
└─────────────────┘    └─────────────────┘    └─────────────────┘
       Port 3001              Port 5000             Port 27017
```

## 📋 Component Architecture

### Frontend Architecture (React 18)

```
src/
├── components/           # React Components
│   ├── AddTodoForm.tsx  # Todo creation form
│   ├── TodoList.tsx     # Todo list container
│   └── TodoItem.tsx     # Individual todo item
├── services/            # External service integrations
│   └── todoAPI.ts       # API communication layer
├── types/               # TypeScript type definitions
│   └── Todo.ts          # Todo interface definitions
├── styles/              # CSS styling
│   └── App.css          # Application styles
└── App.tsx              # Main application component
```

**Component Hierarchy:**
```
App
├── AddTodoForm
└── TodoList
    └── TodoItem (multiple)
```

### Backend Architecture (Express.js)

```
src/
├── controllers/         # Request handlers
│   └── todoController.js
├── models/             # Data models
│   └── Todo.js         # Mongoose schema
├── routes/             # API route definitions
│   └── todoRoutes.js   # Todo CRUD routes
├── middleware/         # Custom middleware
│   └── errorHandler.js # Error handling
├── config/            # Configuration
│   └── database.js    # MongoDB connection
└── server.js          # Application entry point
```

## 🔄 Data Flow Architecture

### Request Flow
```
User Action → React Component → API Service → Express Route → Controller → Model → MongoDB
     ↓            ↓                ↓            ↓            ↓         ↓        ↓
Response ← Component Update ← HTTP Response ← JSON Response ← Business Logic ← Query Result
```

### Detailed Data Flow

1. **User Interaction**
   - User performs action (create, update, delete todo)
   - React component handles user input

2. **Frontend Processing**
   - Component validates input locally
   - Calls appropriate API service method
   - Updates UI optimistically (where applicable)

3. **API Communication**
   - HTTP request sent to Express.js backend
   - Request includes necessary data and headers

4. **Backend Processing**
   - Express route receives and validates request
   - Controller processes business logic
   - Mongoose model interacts with MongoDB

5. **Database Operation**
   - MongoDB performs CRUD operation
   - Returns result to Mongoose model

6. **Response Processing**
   - Model returns data to controller
   - Controller formats response
   - Express sends HTTP response

7. **Frontend Update**
   - React component receives response
   - UI updates with new data
   - Error handling if request fails

## 💾 Database Schema

### Todo Collection
```javascript
{
  _id: ObjectId,              // MongoDB auto-generated ID
  title: String,              // Required, max 100 chars
  description: String,        // Optional, max 500 chars
  completed: Boolean,         // Default: false
  priority: String,           // Enum: ['low', 'medium', 'high']
  createdAt: Date,           // Auto-generated timestamp
  updatedAt: Date            // Auto-updated timestamp
}
```

### Indexes
```javascript
// Primary index (automatically created)
{ _id: 1 }

// Query optimization indexes (future enhancement)
{ createdAt: -1 }           // For chronological ordering
{ completed: 1 }            // For filtering by status
{ priority: 1, createdAt: -1 } // Compound index for priority + time
```

## 🌐 API Architecture

### REST Endpoints
```
GET    /api/todos          # Retrieve all todos
POST   /api/todos          # Create new todo
GET    /api/todos/:id      # Retrieve specific todo
PUT    /api/todos/:id      # Update specific todo
DELETE /api/todos/:id      # Delete specific todo
```

### Request/Response Format

**Standard Response Format:**
```json
{
  "success": boolean,
  "data": any,
  "message": string,
  "timestamp": string
}
```

**Error Response Format:**
```json
{
  "success": false,
  "error": string,
  "message": string,
  "timestamp": string
}
```

## 🐳 Deployment Architecture

### Container Architecture
```
┌─────────────────────────────────────────┐
│              Docker Host                │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────────┐│
│  │   Frontend  │  │      Backend        ││
│  │   React     │  │    Express.js       ││
│  │   Port:3001 │  │     Port:5000       ││
│  └─────────────┘  └─────────────────────┘│
│         │                   │            │
│         └───────┬───────────┘            │
│                 │                        │
│  ┌─────────────────────────────────────┐ │
│  │           MongoDB                   │ │
│  │         Port:27017                  │ │
│  └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Docker Compose Configuration
```yaml
version: '3.8'
services:
  frontend:
    build: ./reactjs-18-front-end
    ports: ["3001:3000"]
    depends_on: [backend]

  backend:
    build: ./express-js-rest-api
    ports: ["5000:5000"]
    depends_on: [mongodb]

  mongodb:
    image: mongo:6.0
    ports: ["27017:27017"]
    volumes: [mongodb_data:/data/db]
```

## 🔧 Development Architecture

### Development Environment
```
Developer Machine
├── Code Editor (VS Code)
├── Node.js 18+ Runtime
├── Docker Desktop
├── Git Version Control
└── Browser DevTools
```

### Build Process
```
Source Code → TypeScript Compilation → Bundle Creation → Container Build → Deployment
     │              │                      │               │              │
   ESLint        tsc/webpack           Create React App   Docker Build   Docker Run
  Prettier       Type Checking         Optimization      Image Creation  Container Start
```

## 📊 Performance Architecture

### Caching Strategy
- **Browser Cache**: Static assets (CSS, JS)
- **API Response Cache**: Not implemented (future enhancement)
- **Database Connection Pool**: Mongoose default pooling
- **Memory Management**: React component optimization

### Scalability Considerations
```
Current Architecture:
Single Instance → Single Database

Future Scalability:
Load Balancer → Multiple App Instances → Database Cluster
                      ↓
              Shared Cache Layer (Redis)
```

## 🔒 Security Architecture

### Security Layers
```
Internet → HTTPS/TLS → CORS → Input Validation → Business Logic → Database
    │          │         │         │               │              │
   DDoS     Encryption  Origin   Sanitization   Authorization   Data Security
Protection             Control    & Validation    (Future)      Backup/Recovery
```

### Security Controls
- **Frontend**: Input validation, XSS prevention
- **API Gateway**: CORS configuration, request validation
- **Application**: SQL injection prevention, error handling
- **Database**: Connection security, data validation

## 🧪 Testing Architecture

### Test Pyramid
```
                    E2E Tests (Playwright)
                   /                    \
              Integration Tests         UI Tests
             /                                  \
        Unit Tests (Jest)                Component Tests
       /                                              \
  API Tests                                    React Testing Library
```

### Test Coverage Strategy
- **Unit Tests**: Individual functions and components
- **Integration Tests**: API endpoints and database operations
- **Component Tests**: React component behavior
- **E2E Tests**: Complete user workflows

---

*← [Technical Requirements](./technical-requirements.md) | [Application Setup →](../application-setup/README.md)*