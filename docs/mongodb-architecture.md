# MongoDB Database Architecture Documentation

## Overview
This document provides a comprehensive overview of the MongoDB database architecture for the Todo Application, including detailed sequence diagrams for database operations, data flow, and CRUD operations.

## Database Architecture Components

### 1. Database Configuration (`src/config/database.js`)
MongoDB connection setup using Mongoose ODM with connection management and graceful shutdown handling.

**Key Features:**
- **Connection Management**: Automatic reconnection and error handling
- **Event Monitoring**: Connection status logging and monitoring  
- **Graceful Shutdown**: Proper cleanup on application termination
- **Environment Configuration**: URI-based connection configuration

### 2. Todo Schema (`src/models/Todo.js`)
Mongoose schema defining the data structure, validation rules, and indexing strategy.

**Schema Structure:**
```javascript
{
  title: String (required, max 100 chars),
  description: String (optional, max 500 chars),
  completed: Boolean (default: false),
  priority: Enum ['low', 'medium', 'high'] (default: 'medium'),
  createdAt: Date (auto-generated),
  updatedAt: Date (auto-generated)
}
```

**Indexing Strategy:**
- `completed`: Single field index for filtering completed/pending todos
- `priority`: Single field index for priority-based queries
- `createdAt`: Descending index for chronological sorting
- `title + description`: Text index for search functionality

### 3. Database Initialization (`init-scripts/01-create-user.js`)
Automated database setup with user creation, collection setup, and initial configuration.

**Initialization Components:**
- **User Management**: Create application-specific database user
- **Collection Creation**: Setup todos collection with validation schema
- **Index Creation**: Performance optimization indexes
- **Validation Rules**: Schema-level validation for data integrity

### 4. Docker Configuration (`docker-compose.yml`)
Complete MongoDB environment setup with administration tools and backup capabilities.

**Services:**
- **MongoDB**: Primary database server with authentication
- **Mongo Express**: Web-based administration interface
- **Backup Service**: Automated backup and restore capabilities

### 5. Sample Data (`seed-data/sample-todos.json`)
Initial dataset for development and testing purposes.

---

## Database Operation Sequence Diagrams

### 1. Database Connection Initialization Flow

```mermaid
sequenceDiagram
    participant App
    participant ConfigDB
    participant Mongoose
    participant MongoDB
    participant DockerCompose

    App->>ConfigDB: require('./src/config/database')
    App->>ConfigDB: connectDB()
    
    ConfigDB->>Mongoose: mongoose.connect(MONGODB_URI)
    Mongoose->>MongoDB: Establish connection
    
    alt Connection Successful
        MongoDB-->>Mongoose: Connection established
        Mongoose-->>ConfigDB: Connection object
        ConfigDB->>ConfigDB: Log successful connection
        ConfigDB->>Mongoose: Setup event listeners
        
        Note over Mongoose: Event listeners setup:
        Note over Mongoose: - 'connected'
        Note over Mongoose: - 'error'  
        Note over Mongoose: - 'disconnected'
        
        ConfigDB-->>App: Database ready
        
    else Connection Failed
        MongoDB-->>Mongoose: Connection error
        Mongoose-->>ConfigDB: Error object
        ConfigDB->>ConfigDB: Log error and exit
        ConfigDB->>App: process.exit(1)
    end
    
    Note over App: Application continues with database ready
```

### 2. Create Todo Operation Flow

```mermaid
sequenceDiagram
    participant Controller
    participant TodoModel
    participant Mongoose
    participant MongoDB
    participant ValidationLayer

    Controller->>TodoModel: Todo.create(todoData)
    TodoModel->>ValidationLayer: Apply schema validation
    
    ValidationLayer->>ValidationLayer: Validate required fields
    ValidationLayer->>ValidationLayer: Check field lengths (title ≤ 100, desc ≤ 500)
    ValidationLayer->>ValidationLayer: Validate priority enum
    ValidationLayer->>ValidationLayer: Validate boolean types
    
    alt Validation Passes
        ValidationLayer->>Mongoose: Proceed with document creation
        Mongoose->>Mongoose: Add timestamps (createdAt, updatedAt)
        Mongoose->>Mongoose: Generate ObjectId
        Mongoose->>MongoDB: Insert document into todos collection
        
        MongoDB->>MongoDB: Apply database-level validation
        MongoDB->>MongoDB: Update indexes
        Note over MongoDB: Updated indexes:
        Note over MongoDB: - completed index
        Note over MongoDB: - priority index  
        Note over MongoDB: - createdAt index
        Note over MongoDB: - text search index
        
        MongoDB-->>Mongoose: Return inserted document with _id
        Mongoose-->>TodoModel: Return todo object
        TodoModel-->>Controller: Return created todo
        
    else Validation Fails
        ValidationLayer-->>TodoModel: ValidationError
        TodoModel-->>Controller: Validation error with details
    end
```

### 3. Find/Query Operations Flow

```mermaid
sequenceDiagram
    participant Controller
    participant TodoModel
    participant Mongoose
    participant MongoDB
    participant IndexEngine

    Controller->>TodoModel: Todo.find(filter).sort(sort)
    TodoModel->>Mongoose: Build query with filters
    
    Note over Controller: Example: { completed: false, priority: 'high' }
    
    Mongoose->>MongoDB: Execute query
    MongoDB->>IndexEngine: Check available indexes
    
    IndexEngine->>IndexEngine: Analyze query filters
    Note over IndexEngine: Query uses:
    Note over IndexEngine: - completed index (completed: false)
    Note over IndexEngine: - priority index (priority: 'high')
    Note over IndexEngine: - createdAt index (sort: -createdAt)
    
    IndexEngine->>MongoDB: Use optimal index strategy
    MongoDB->>MongoDB: Scan indexed documents
    MongoDB->>MongoDB: Apply filters and sorting
    MongoDB-->>Mongoose: Return matching documents
    
    Mongoose->>Mongoose: Convert to Mongoose documents
    Mongoose-->>TodoModel: Return todo array
    TodoModel-->>Controller: Return filtered/sorted todos
```

### 4. Update Todo Operation Flow

```mermaid
sequenceDiagram
    participant Controller
    participant TodoModel
    participant Mongoose
    participant MongoDB
    participant IndexEngine

    Controller->>TodoModel: Todo.findByIdAndUpdate(id, updates, options)
    Note over Controller: options: { new: true, runValidators: true }
    
    TodoModel->>Mongoose: Build update query
    Mongoose->>MongoDB: Find document by _id
    
    MongoDB->>IndexEngine: Use _id index (primary key)
    IndexEngine-->>MongoDB: Return document location
    
    alt Document Found
        MongoDB->>MongoDB: Apply schema validation on updates
        MongoDB->>MongoDB: Update document fields
        MongoDB->>MongoDB: Set updatedAt timestamp
        
        MongoDB->>MongoDB: Update affected indexes
        Note over MongoDB: Index updates for changed fields:
        Note over MongoDB: - completed index (if completed changed)
        Note over MongoDB: - priority index (if priority changed)
        Note over MongoDB: - text index (if title/desc changed)
        
        MongoDB-->>Mongoose: Return updated document
        Mongoose-->>TodoModel: Return updated todo
        TodoModel-->>Controller: Return updated todo
        
    else Document Not Found
        MongoDB-->>Mongoose: Return null
        Mongoose-->>TodoModel: Return null  
        TodoModel-->>Controller: Return null (404 handling)
    end
```

### 5. Delete Todo Operation Flow

```mermaid
sequenceDiagram
    participant Controller
    participant TodoModel
    participant Mongoose
    participant MongoDB
    participant IndexEngine

    Controller->>TodoModel: Todo.findByIdAndDelete(id)
    TodoModel->>Mongoose: Build delete query
    Mongoose->>MongoDB: Find and delete by _id
    
    MongoDB->>IndexEngine: Use _id index
    IndexEngine-->>MongoDB: Locate document
    
    alt Document Found
        MongoDB->>MongoDB: Remove document from collection
        MongoDB->>MongoDB: Update all indexes
        Note over MongoDB: Index cleanup:
        Note over MongoDB: - Remove from completed index
        Note over MongoDB: - Remove from priority index
        Note over MongoDB: - Remove from createdAt index
        Note over MongoDB: - Remove from text search index
        
        MongoDB-->>Mongoose: Return deleted document
        Mongoose-->>TodoModel: Return deleted todo
        TodoModel-->>Controller: Return deleted todo (for confirmation)
        
    else Document Not Found
        MongoDB-->>Mongoose: Return null
        Mongoose-->>TodoModel: Return null
        TodoModel-->>Controller: Return null (404 handling)
    end
```

### 6. Aggregation Statistics Flow

```mermaid
sequenceDiagram
    participant Controller
    participant TodoModel
    participant Mongoose
    participant MongoDB
    participant AggregationEngine

    par Completion Statistics
        Controller->>TodoModel: Todo.aggregate([completion pipeline])
        TodoModel->>Mongoose: Build aggregation pipeline
        Mongoose->>MongoDB: Execute aggregation
        MongoDB->>AggregationEngine: Process pipeline stages
        
        AggregationEngine->>AggregationEngine: Stage 1: $group by completed
        AggregationEngine->>AggregationEngine: Stage 2: $sum counts
        AggregationEngine-->>MongoDB: Return completion stats
        MongoDB-->>Controller: { _id: true, count: 4 }, { _id: false, count: 6 }
        
    and Priority Statistics  
        Controller->>TodoModel: Todo.aggregate([priority pipeline])
        TodoModel->>Mongoose: Build aggregation pipeline
        Mongoose->>MongoDB: Execute aggregation  
        MongoDB->>AggregationEngine: Process pipeline stages
        
        AggregationEngine->>AggregationEngine: Stage 1: $group by priority
        AggregationEngine->>AggregationEngine: Stage 2: $sum counts
        AggregationEngine-->>MongoDB: Return priority stats
        MongoDB-->>Controller: [{ _id: 'low', count: 2 }, { _id: 'medium', count: 5 }...]
        
    and Total Count
        Controller->>TodoModel: Todo.countDocuments()
        TodoModel->>Mongoose: Build count query
        Mongoose->>MongoDB: Execute count
        MongoDB-->>Controller: Return total count: 10
    end
    
    Controller->>Controller: Combine all statistics
    Controller-->>Controller: Format final statistics object
```

---

## Database Schema Validation Flow

### 1. Schema-Level Validation

```mermaid
sequenceDiagram
    participant Application
    participant MongooseSchema
    participant MongoDBValidator
    participant Database

    Application->>MongooseSchema: Document save/update operation
    
    MongooseSchema->>MongooseSchema: Apply Mongoose validations
    Note over MongooseSchema: Validation checks:
    Note over MongooseSchema: - Required fields (title)
    Note over MongooseSchema: - String length limits
    Note over MongooseSchema: - Enum values (priority)
    Note over MongooseSchema: - Data types (boolean, string)
    
    alt Mongoose Validation Passes
        MongooseSchema->>MongoDBValidator: Send to database validation
        MongoDBValidator->>MongoDBValidator: Apply JSON Schema validation
        Note over MongoDBValidator: Database-level validation:
        Note over MongoDBValidator: - BSON type checking
        Note over MongoDBValidator: - Additional constraints
        Note over MongoDBValidator: - Collection-level rules
        
        alt Database Validation Passes
            MongoDBValidator->>Database: Persist document
            Database-->>Application: Success response with document
        else Database Validation Fails
            MongoDBValidator-->>Application: Database validation error
        end
        
    else Mongoose Validation Fails
        MongooseSchema-->>Application: Mongoose validation error
    end
```

### 2. Index Management Flow

```mermaid
sequenceDiagram
    participant Application
    participant Mongoose
    participant MongoDB
    participant IndexManager

    Note over Application: Application startup or schema changes
    
    Application->>Mongoose: Schema with index definitions
    Mongoose->>MongoDB: Ensure indexes command
    MongoDB->>IndexManager: Process index requirements
    
    IndexManager->>IndexManager: Check existing indexes
    IndexManager->>IndexManager: Compare with required indexes
    
    par Create New Indexes
        IndexManager->>IndexManager: Create completed index
        IndexManager->>IndexManager: Create priority index  
        IndexManager->>IndexManager: Create createdAt index
        IndexManager->>IndexManager: Create text search index
        
    and Drop Unused Indexes
        IndexManager->>IndexManager: Identify unused indexes
        IndexManager->>IndexManager: Drop obsolete indexes
    end
    
    IndexManager-->>MongoDB: Index management complete
    MongoDB-->>Mongoose: Confirmation
    Mongoose-->>Application: Indexes ready for optimal queries
```

---

## Docker Environment Setup Flow

### 1. Docker Compose Initialization

```mermaid
sequenceDiagram
    participant Developer
    participant DockerCompose
    participant MongoDB
    participant MongoExpress
    participant InitScripts

    Developer->>DockerCompose: docker-compose up
    DockerCompose->>MongoDB: Start MongoDB container
    
    MongoDB->>MongoDB: Initialize with admin credentials
    MongoDB->>InitScripts: Execute initialization scripts
    
    InitScripts->>InitScripts: Run 01-create-user.js
    InitScripts->>MongoDB: Create todoapp database
    InitScripts->>MongoDB: Create todouser with readWrite permissions
    InitScripts->>MongoDB: Setup todos collection with validation
    InitScripts->>MongoDB: Create performance indexes
    
    par Seed Data Loading
        InitScripts->>InitScripts: Run 02-seed-data.js (if exists)
        InitScripts->>MongoDB: Insert sample todos
        
    and Start Admin Interface
        DockerCompose->>MongoExpress: Start Mongo Express container
        MongoExpress->>MongoDB: Connect with admin credentials
        MongoExpress-->>Developer: Web interface available at :8081
    end
    
    MongoDB-->>DockerCompose: Database ready
    DockerCompose-->>Developer: Full environment running
```

### 2. Backup and Restore Flow

```mermaid
sequenceDiagram
    participant Admin
    participant BackupService
    participant MongoDB
    participant FileSystem

    Admin->>BackupService: Trigger backup operation
    BackupService->>MongoDB: mongodump command
    MongoDB->>MongoDB: Create database snapshot
    MongoDB-->>BackupService: Binary backup data
    BackupService->>FileSystem: Store backup with timestamp
    FileSystem-->>BackupService: Backup confirmation
    BackupService-->>Admin: Backup complete
    
    Note over Admin: Later, restore operation needed
    
    Admin->>BackupService: Trigger restore operation
    BackupService->>FileSystem: Read backup file
    FileSystem-->>BackupService: Backup data
    BackupService->>MongoDB: mongorestore command
    MongoDB->>MongoDB: Restore data and indexes
    MongoDB-->>BackupService: Restore complete
    BackupService-->>Admin: Database restored successfully
```

---

## Performance Optimization Strategies

### 1. Query Optimization

**Index Usage Patterns:**
- **Point Queries**: `_id` index for single document retrieval
- **Range Queries**: `createdAt` index for date-based sorting
- **Equality Queries**: `completed` and `priority` indexes for filtering
- **Text Search**: Compound text index on `title` and `description`

**Query Performance Flow:**
```mermaid
sequenceDiagram
    participant Query
    participant QueryPlanner  
    participant IndexScan
    participant CollectionScan

    Query->>QueryPlanner: Analyze query conditions
    QueryPlanner->>QueryPlanner: Evaluate available indexes
    
    alt Suitable Index Available
        QueryPlanner->>IndexScan: Use optimal index
        IndexScan-->>Query: Return results efficiently
    else No Suitable Index
        QueryPlanner->>CollectionScan: Full collection scan
        CollectionScan-->>Query: Return results (slower)
    end
```

### 2. Connection Management

**Connection Pooling Flow:**
```mermaid
sequenceDiagram
    participant Application
    participant ConnectionPool
    participant MongoDB

    Application->>ConnectionPool: Request database connection
    
    alt Pool Has Available Connection
        ConnectionPool-->>Application: Return existing connection
    else Pool At Capacity
        ConnectionPool->>ConnectionPool: Queue request
        ConnectionPool-->>Application: Wait for available connection
    else Pool Empty, Under Limit
        ConnectionPool->>MongoDB: Create new connection
        MongoDB-->>ConnectionPool: New connection established
        ConnectionPool-->>Application: Return new connection
    end
    
    Application->>MongoDB: Execute database operation
    MongoDB-->>Application: Return results
    Application->>ConnectionPool: Return connection to pool
```

---

## Data Flow Architecture

### 1. Application to Database Flow

```mermaid
sequenceDiagram
    participant ReactApp
    participant ExpressAPI
    participant Mongoose
    participant MongoDB

    ReactApp->>ExpressAPI: HTTP Request (todo operation)
    ExpressAPI->>ExpressAPI: Validate request data
    ExpressAPI->>Mongoose: Execute database operation
    
    Mongoose->>Mongoose: Apply schema validation
    Mongoose->>MongoDB: Database query/update
    MongoDB->>MongoDB: Process operation with indexes
    MongoDB-->>Mongoose: Return results
    
    Mongoose->>Mongoose: Convert to JavaScript objects
    Mongoose-->>ExpressAPI: Return formatted data
    ExpressAPI->>ExpressAPI: Format API response
    ExpressAPI-->>ReactApp: HTTP Response (JSON)
```

### 2. Error Propagation Flow

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant Mongoose
    participant MongoDB

    Client->>API: Request with invalid data
    API->>Mongoose: Attempt database operation
    
    alt Mongoose Validation Error
        Mongoose-->>API: ValidationError with details
        API->>API: Format validation error
        API-->>Client: 400 Bad Request with validation details
        
    else MongoDB Connection Error
        Mongoose->>MongoDB: Database operation
        MongoDB-->>Mongoose: Connection/timeout error
        Mongoose-->>API: Database error
        API->>API: Log error and format response
        API-->>Client: 500 Internal Server Error
        
    else Document Not Found
        Mongoose->>MongoDB: Find operation
        MongoDB-->>Mongoose: Empty result
        Mongoose-->>API: null/empty result
        API->>API: Check for null result
        API-->>Client: 404 Not Found
    end
```

---

## Key Features and Benefits

### 1. **Data Integrity**
- Schema-level validation with Mongoose
- Database-level validation with JSON Schema
- Required field enforcement
- Data type validation
- Enum constraint validation

### 2. **Performance Optimization**
- Strategic indexing for common query patterns
- Connection pooling for efficient resource usage
- Query optimization with index hints
- Aggregation pipelines for complex statistics

### 3. **Scalability**
- Horizontal scaling capabilities with MongoDB
- Efficient indexing for large datasets
- Connection pooling for concurrent requests
- Optimized queries to minimize database load

### 4. **Reliability**
- Automatic reconnection handling
- Graceful error handling and logging
- Backup and restore capabilities
- Health monitoring and alerting

### 5. **Development Experience**
- Docker-based development environment
- Automated database setup and seeding
- Web-based administration interface
- Comprehensive logging and debugging

### 6. **Security**
- Authentication-based access control
- User-specific database permissions
- Network isolation in Docker environment
- Secure connection practices

---

## Database Configuration Summary

### Connection Configuration
```javascript
// Environment variables
MONGODB_URI=mongodb://todouser:todopass123@localhost:27017/todoapp
```

### Schema Configuration
```javascript
// Validation rules
title: required, max 100 characters
description: optional, max 500 characters  
completed: boolean, default false
priority: enum ['low', 'medium', 'high'], default 'medium'
timestamps: automatic createdAt/updatedAt
```

### Index Configuration
```javascript
// Performance indexes
{ completed: 1 }           // Filter by completion status
{ priority: 1 }            // Filter by priority level
{ createdAt: -1 }          // Sort by creation date
{ title: 'text', description: 'text' } // Text search
```

This MongoDB architecture provides a robust, scalable, and maintainable database solution for the Todo application with proper data validation, performance optimization, and operational management capabilities.