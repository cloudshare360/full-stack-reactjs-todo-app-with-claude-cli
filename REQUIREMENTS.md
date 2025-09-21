# ReactJS Todo Full-Stack Application Requirements

## Project Overview
A comprehensive full-stack todo application built with modern web technologies, featuring a React frontend, Express.js REST API backend, and MongoDB database with Docker containerization.

## Technology Stack

### Frontend
- **Framework**: React 18
- **Location**: `reactjs-18-front-end/`
- **Features**:
  - Modern React 18 features (Concurrent features, Suspense, etc.)
  - Todo CRUD operations
  - Responsive design
  - State management
  - API integration with backend

### Backend
- **Framework**: Express.js
- **Location**: `express-js-rest-api/`
- **Features**:
  - RESTful API endpoints
  - MongoDB integration
  - CORS support
  - Error handling
  - Input validation
  - Authentication (optional)

### Database
- **Database**: MongoDB
- **Location**: `mongo-db-docker-compose/`
- **Features**:
  - Docker containerization
  - Database schema definition
  - Seed data for initial testing
  - MongoDB UI access via Mongo Express
  - Persistent data storage

## Project Structure
```
reactjs-todo-application/
├── REQUIREMENTS.md
├── reactjs-18-front-end/
│   ├── package.json
│   ├── src/
│   └── public/
├── express-js-rest-api/
│   ├── package.json
│   ├── src/
│   └── routes/
└── mongo-db-docker-compose/
    ├── docker-compose.yml
    ├── init-scripts/
    ├── seed-data/
    └── scripts/
```

## API Endpoints
- `GET /api/todos` - Get all todos
- `POST /api/todos` - Create a new todo
- `GET /api/todos/:id` - Get a specific todo
- `PUT /api/todos/:id` - Update a todo
- `DELETE /api/todos/:id` - Delete a todo

## Database Schema
```javascript
Todo {
  _id: ObjectId,
  title: String (required),
  description: String,
  completed: Boolean (default: false),
  priority: String (enum: ['low', 'medium', 'high']),
  createdAt: Date,
  updatedAt: Date
}
```

## Docker Services
1. **MongoDB**: Primary database service
2. **Mongo Express**: Web-based MongoDB admin interface
3. **Volumes**: Persistent data storage

## Shell Scripts
- `start-mongodb.sh` - Start MongoDB services
- `stop-mongodb.sh` - Stop MongoDB services
- `seed-data.sh` - Load initial seed data
- `backup-data.sh` - Backup database

## Development Setup
1. Start MongoDB services using Docker Compose
2. Install and run Express.js backend
3. Install and run React frontend
4. Access Mongo Express UI for database management

## Features
- Full CRUD operations for todos
- Real-time data updates
- Responsive web design
- Database management UI
- Containerized development environment
- Seed data for testing

## Ports
- React Frontend: 3000
- Express Backend: 5000
- MongoDB: 27017
- Mongo Express: 8081