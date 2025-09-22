# MongoDB Interview Questions - Todo Database Application

## Basic MongoDB Concepts

### 1. Database Design & Schema

**Q: Explain the document structure used in this Todo application.**
**A:** The Todo document follows this structure:
```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439011"),
  title: "Learn React 18 features",
  description: "Study concurrent features and Suspense",
  completed: false,
  priority: "high",
  createdAt: ISODate("2025-01-01T08:00:00Z"),
  updatedAt: ISODate("2025-01-01T08:00:00Z")
}
```
Key characteristics:
- **_id**: MongoDB's default primary key (ObjectId)
- **title**: Required string field with 100 character limit
- **description**: Optional string with 500 character limit  
- **completed**: Boolean flag with default false
- **priority**: Enum field (low/medium/high) with default 'medium'
- **timestamps**: Automatic createdAt/updatedAt fields

**Q: Why use embedded documents vs. references in this schema?**
**A:** This Todo application uses a simple flat document structure because:
- **No complex relationships**: Todos are independent entities
- **Small document size**: All fields are primitive types
- **Read optimization**: All todo data retrieved in single query
- **Atomic updates**: All todo fields can be updated atomically

If the application had user relationships, we might use references:
```javascript
// With user reference
{
  _id: ObjectId("..."),
  title: "Learn React",
  userId: ObjectId("507f1f77bcf86cd799439012"), // Reference
  // ... other fields
}
```

### 2. Collections & Validation

**Q: How is schema validation implemented in this MongoDB setup?**
**A:** Multi-layered validation approach:
```javascript
// 1. Database-level JSON Schema validation
db.createCollection('todos', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['title'],
      properties: {
        title: {
          bsonType: 'string',
          maxLength: 100
        },
        priority: {
          enum: ['low', 'medium', 'high']
        }
      }
    }
  }
});

// 2. Mongoose schema validation (application level)
const todoSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Title is required'],
    maxLength: [100, 'Title cannot exceed 100 characters']
  }
});
```

**Q: What's the difference between MongoDB validation and Mongoose validation?**
**A:**
- **MongoDB validation**: Database-level, enforced regardless of client
- **Mongoose validation**: Application-level, provides better error messages
- **Defense in depth**: Both layers prevent invalid data
- **Performance**: Mongoose validation happens before database call

## Intermediate MongoDB Concepts

### 3. Indexing Strategy

**Q: Explain the indexing strategy used in this Todo application.**
**A:**
```javascript
// Indexes created for optimal query performance
db.todos.createIndex({ completed: 1 });        // Filter by completion
db.todos.createIndex({ priority: 1 });         // Filter by priority  
db.todos.createIndex({ createdAt: -1 });       // Sort chronologically
db.todos.createIndex({ 
  title: 'text', 
  description: 'text' 
});                                             // Text search
```

**Index usage patterns:**
- **completed**: Used in queries like `{ completed: false }`
- **priority**: Used in queries like `{ priority: 'high' }`
- **createdAt**: Used for sorting `sort({ createdAt: -1 })`
- **text**: Enables full-text search across title and description

**Q: How would you optimize a query that filters by both completed and priority?**
**A:**
```javascript
// Current query (uses index intersection)
db.todos.find({ completed: false, priority: 'high' });

// Optimization: Create compound index
db.todos.createIndex({ completed: 1, priority: 1 });

// Even better for common queries with sorting
db.todos.createIndex({ completed: 1, priority: 1, createdAt: -1 });

// Query performance comparison
db.todos.find({ completed: false, priority: 'high' }).explain('executionStats');
```

### 4. Query Optimization

**Q: How does MongoDB choose which index to use for a query?**
**A:** MongoDB's query planner follows this process:
```javascript
// Query: db.todos.find({ completed: false, priority: 'high' }).sort({ createdAt: -1 })

// 1. Query planner analyzes available indexes
// 2. Creates execution plans for each viable index
// 3. Runs plans in parallel for small dataset samples
// 4. Chooses the plan that returns results fastest
// 5. Caches the winning plan for similar queries

// Explain query execution
db.todos.find({ completed: false, priority: 'high' })
  .sort({ createdAt: -1 })
  .explain('executionStats');

// Key metrics to analyze:
// - totalDocsExamined vs. totalDocsReturned (selectivity)
// - executionTimeMillis (performance)
// - stage (IXSCAN vs. COLLSCAN)
```

**Q: What's the difference between IXSCAN and COLLSCAN in query execution?**
**A:**
- **IXSCAN (Index Scan)**: Uses index to find documents efficiently
- **COLLSCAN (Collection Scan)**: Scans entire collection sequentially
- **Performance impact**: IXSCAN is O(log n), COLLSCAN is O(n)
- **When COLLSCAN occurs**: No suitable index, small collections, or query optimizer decides it's faster

### 5. CRUD Operations

**Q: Walk through the complete lifecycle of creating a Todo document.**
**A:**
```javascript
// 1. Application layer (Express + Mongoose)
const todo = new Todo({
  title: "Learn MongoDB",
  priority: "high"
});

// 2. Mongoose pre-save middleware (if any)
todoSchema.pre('save', function(next) {
  // Custom logic before save
  next();
});

// 3. Mongoose validation
// - Check required fields
// - Validate string lengths
// - Validate enum values

// 4. MongoDB insertion
// - Generate ObjectId
// - Add timestamps
// - Apply database validation
// - Write to storage engine
// - Update all relevant indexes

// 5. Return created document
await todo.save(); // Returns document with _id and timestamps
```

**Q: How does MongoDB handle concurrent updates to the same document?**
**A:**
```javascript
// MongoDB uses optimistic concurrency control
// Last write wins for field-level updates

// Example: Two users updating same todo simultaneously
// User A: Updates title
// User B: Updates completed status

// Both operations succeed because they modify different fields
// Final document contains both changes

// For atomic operations requiring coordination:
await Todo.findByIdAndUpdate(
  id,
  { $inc: { viewCount: 1 } }, // Atomic increment
  { new: true }
);

// For transactions across multiple documents:
const session = await mongoose.startSession();
await session.withTransaction(async () => {
  await Todo.findByIdAndUpdate(id, updates, { session });
  await AuditLog.create(logEntry, { session });
});
```

## Advanced MongoDB Concepts

### 6. Aggregation Framework

**Q: Explain the aggregation pipeline used for todo statistics.**
**A:**
```javascript
// Statistics aggregation pipeline
const stats = await Todo.aggregate([
  // Stage 1: Group by completion status
  {
    $group: {
      _id: '$completed',
      count: { $sum: 1 }
    }
  }
]);

// Priority statistics pipeline
const priorityStats = await Todo.aggregate([
  {
    $group: {
      _id: '$priority',
      count: { $sum: 1 }
    }
  }
]);

// More complex aggregation example
const detailedStats = await Todo.aggregate([
  // Stage 1: Add computed fields
  {
    $addFields: {
      titleLength: { $strLenCP: '$title' },
      isOverdue: {
        $lt: ['$dueDate', new Date()] // If dueDate exists
      }
    }
  },
  // Stage 2: Group by multiple fields
  {
    $group: {
      _id: {
        completed: '$completed',
        priority: '$priority'
      },
      count: { $sum: 1 },
      avgTitleLength: { $avg: '$titleLength' },
      overdueCount: { $sum: { $cond: ['$isOverdue', 1, 0] } }
    }
  },
  // Stage 3: Sort results
  {
    $sort: { '_id.priority': 1, '_id.completed': 1 }
  }
]);
```

**Q: How would you implement pagination with aggregation?**
**A:**
```javascript
const paginatedTodos = async (page = 1, limit = 10, filters = {}) => {
  const pipeline = [
    // Stage 1: Match filters
    { $match: filters },
    
    // Stage 2: Add total count
    {
      $facet: {
        data: [
          { $sort: { createdAt: -1 } },
          { $skip: (page - 1) * limit },
          { $limit: limit }
        ],
        totalCount: [
          { $count: 'total' }
        ]
      }
    }
  ];
  
  const [result] = await Todo.aggregate(pipeline);
  const total = result.totalCount[0]?.total || 0;
  
  return {
    data: result.data,
    pagination: {
      page,
      limit,
      total,
      pages: Math.ceil(total / limit)
    }
  };
};
```

### 7. Text Search & Full-Text Indexing

**Q: How does text search work in this MongoDB application?**
**A:**
```javascript
// 1. Text index creation
db.todos.createIndex({ 
  title: 'text', 
  description: 'text' 
}, {
  weights: {
    title: 10,        // Title matches scored higher
    description: 5    // Description matches scored lower
  }
});

// 2. Text search query
db.todos.find({
  $text: { 
    $search: 'learn react hooks',
    $caseSensitive: false,
    $diacriticSensitive: false
  }
}).sort({ score: { $meta: 'textScore' } });

// 3. Mongoose implementation
const searchTodos = async (searchTerm) => {
  return await Todo.find(
    { $text: { $search: searchTerm } },
    { score: { $meta: 'textScore' } }
  ).sort({ score: { $meta: 'textScore' } });
};

// 4. Advanced text search with filters
const advancedSearch = await Todo.find({
  $and: [
    { $text: { $search: 'react' } },
    { priority: 'high' },
    { completed: false }
  ]
});
```

### 8. Performance & Optimization

**Q: How would you identify and resolve performance issues in MongoDB queries?**
**A:**
```javascript
// 1. Use explain() to analyze query performance
const explain = await db.todos.find({ priority: 'high' }).explain('executionStats');

// Key metrics to check:
// - executionTimeMillis: Query execution time
// - totalDocsExamined: Documents scanned
// - totalDocsReturned: Documents returned
// - indexesUsed: Which indexes were utilized

// 2. Monitor slow queries
db.setProfilingLevel(2, { slowms: 100 }); // Profile queries > 100ms

// 3. Query optimization strategies
// Bad: No index usage
db.todos.find({ 'tags.category': 'work' }); // Full collection scan

// Good: Create appropriate index
db.todos.createIndex({ 'tags.category': 1 });

// 4. Use projection to limit data transfer
db.todos.find(
  { completed: false }, 
  { title: 1, priority: 1, _id: 0 } // Only return needed fields
);

// 5. Batch operations for multiple updates
db.todos.bulkWrite([
  { updateOne: { filter: { _id: id1 }, update: { completed: true } } },
  { updateOne: { filter: { _id: id2 }, update: { completed: true } } }
]);
```

**Q: How would you implement database connection pooling optimization?**
**A:**
```javascript
// Mongoose connection optimization
mongoose.connect(uri, {
  maxPoolSize: 10,          // Maintain up to 10 socket connections
  serverSelectionTimeoutMS: 5000, // Keep trying to send operations for 5 seconds
  socketTimeoutMS: 45000,   // Close sockets after 45 seconds of inactivity
  bufferMaxEntries: 0,      // Disable mongoose buffering
  bufferCommands: false,    // Disable mongoose buffering
});

// Monitor connection pool
mongoose.connection.on('connected', () => {
  console.log('MongoDB connected');
});

mongoose.connection.on('error', (err) => {
  console.error('MongoDB connection error:', err);
});

mongoose.connection.on('disconnected', () => {
  console.log('MongoDB disconnected');
});

// Connection pool metrics monitoring
const poolStats = mongoose.connection.db.serverConfig.connections();
console.log('Active connections:', poolStats.length);
```

## Database Administration

### 9. Backup & Recovery

**Q: Explain the backup strategy implemented in this MongoDB setup.**
**A:**
```bash
# 1. Regular backup using mongodump
mongodump \
  --host localhost:27017 \
  --username todouser \
  --password todopass123 \
  --db todoapp \
  --out /backups/$(date +%Y%m%d_%H%M%S)

# 2. Automated backup script
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="todoapp"

# Create backup
mongodump --db $DB_NAME --out $BACKUP_DIR/$DATE

# Compress backup
tar -czf $BACKUP_DIR/todoapp_backup_$DATE.tar.gz -C $BACKUP_DIR $DATE

# Remove uncompressed files
rm -rf $BACKUP_DIR/$DATE

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

# 3. Restore process
mongorestore \
  --host localhost:27017 \
  --username todouser \
  --password todopass123 \
  --db todoapp_restored \
  /backups/20250101_120000/todoapp
```

**Q: How would you implement point-in-time recovery?**
**A:**
```javascript
// MongoDB replica sets enable point-in-time recovery
// through oplog (operations log)

// 1. Enable replica set
rs.initiate({
  _id: 'todoapp-rs',
  members: [
    { _id: 0, host: 'localhost:27017' }
  ]
});

// 2. Oplog backup strategy
// Backup oplog entries continuously
mongodump --host localhost:27017 --db local --collection oplog.rs

// 3. Point-in-time restore
// Restore base backup + replay oplog to specific timestamp
mongorestore --oplogReplay --oplogLimit 1641024000:1 /backup/path
```

### 10. Security & Authentication

**Q: Describe the security measures implemented in this MongoDB setup.**
**A:**
```javascript
// 1. Authentication enabled
// MongoDB started with --auth flag

// 2. User creation with specific roles
db.createUser({
  user: 'todouser',
  pwd: 'todopass123',
  roles: [
    { role: 'readWrite', db: 'todoapp' }  // Limited permissions
  ]
});

// 3. Network security (Docker)
// MongoDB only accessible within Docker network
// No external port exposure in production

// 4. Connection security
const uri = 'mongodb://todouser:todopass123@localhost:27017/todoapp';
// In production: use TLS/SSL
const secureUri = 'mongodb+srv://user:pass@cluster.mongodb.net/todoapp?ssl=true';

// 5. Application-level security
// Mongoose connection with auth
mongoose.connect(uri, {
  authSource: 'todoapp',
  ssl: process.env.NODE_ENV === 'production'
});
```

## Production Deployment

### 11. Replica Sets & High Availability

**Q: How would you set up MongoDB for production with high availability?**
**A:**
```javascript
// 1. Replica set configuration
rs.initiate({
  _id: 'todoapp-rs',
  members: [
    { _id: 0, host: 'mongo1:27017', priority: 2 },  // Primary preferred
    { _id: 1, host: 'mongo2:27017', priority: 1 },  // Secondary
    { _id: 2, host: 'mongo3:27017', arbiterOnly: true } // Arbiter for voting
  ]
});

// 2. Application connection to replica set
mongoose.connect('mongodb://mongo1:27017,mongo2:27017,mongo3:27017/todoapp?replicaSet=todoapp-rs', {
  readPreference: 'secondaryPreferred', // Read from secondary when possible
  writeConcern: { w: 'majority', j: true } // Ensure writes to majority
});

// 3. Monitoring replica set health
rs.status(); // Check replica set status
db.isMaster(); // Check current primary

// 4. Failover handling
mongoose.connection.on('error', (err) => {
  if (err.message.includes('not master')) {
    // Primary has changed, mongoose will automatically reconnect
    console.log('Primary changed, reconnecting...');
  }
});
```

### 12. Monitoring & Analytics

**Q: How would you implement comprehensive MongoDB monitoring?**
**A:**
```javascript
// 1. Built-in MongoDB monitoring
// Enable profiling for slow queries
db.setProfilingLevel(1, { slowms: 100 });

// Check profiling data
db.system.profile.find().sort({ ts: -1 }).limit(5);

// 2. Server statistics
db.serverStatus(); // Comprehensive server metrics
db.stats(); // Database statistics
db.todos.stats(); // Collection statistics

// 3. Custom monitoring with Node.js
const monitorDB = async () => {
  const stats = await mongoose.connection.db.stats();
  const serverStatus = await mongoose.connection.db.admin().serverStatus();
  
  console.log({
    dbSize: stats.dataSize,
    indexSize: stats.indexSize,
    connections: serverStatus.connections,
    uptime: serverStatus.uptime,
    opcounters: serverStatus.opcounters
  });
};

// 4. Query performance monitoring
const monitorQuery = async (queryFn) => {
  const start = Date.now();
  const result = await queryFn();
  const duration = Date.now() - start;
  
  if (duration > 100) { // Log slow queries
    console.warn(`Slow query detected: ${duration}ms`);
  }
  
  return result;
};

// 5. Connection pool monitoring
const poolInfo = mongoose.connection.readyState;
console.log('Connection state:', {
  0: 'disconnected',
  1: 'connected', 
  2: 'connecting',
  3: 'disconnecting'
}[poolInfo]);
```

These MongoDB interview questions cover the spectrum from basic document design to advanced production deployment scenarios, helping prepare for database developer and DevOps positions.