# Express.js Interview Questions - Todo API Application

## Basic Express.js Concepts

### 1. Server Setup & Configuration

**Q: Explain how the Express server is initialized in this Todo application.**
**A:** The server initialization follows a specific sequence:
```javascript
// 1. Load environment variables
dotenv.config();

// 2. Connect to database first
connectDB();

// 3. Create Express app
const app = express();

// 4. Setup middleware chain
app.use(helmet());           // Security headers
app.use(cors(corsOptions)); // Cross-origin resource sharing
app.use(morgan('dev'));     // HTTP request logging
app.use(express.json());    // Parse JSON bodies

// 5. Register routes
app.use('/api/todos', todoRoutes);

// 6. Error handling (must be last)
app.use(errorHandler);

// 7. Start server
app.listen(PORT);
```

**Q: Why is the middleware order important in Express?**
**A:** Middleware executes in the order it's registered:
- **Security first**: Helmet adds security headers before any processing
- **CORS**: Must validate origin before processing requests
- **Logging**: Log after security but before business logic
- **Body parsing**: Parse request body before route handlers need it
- **Routes**: Business logic after all preprocessing
- **Error handling**: Must be last to catch all errors

### 2. Middleware Chain

**Q: Describe the complete middleware chain for a POST request to /api/todos.**
**A:** For `POST /api/todos` with validation:
```javascript
Request → Helmet → CORS → Morgan → express.json() → 
Router → validateCreateTodo → createTodo → Response

// If error occurs at any point:
Error → errorHandler → Error Response
```

**Q: What is the purpose of each middleware in this application?**
**A:**
- **Helmet**: Adds security headers (XSS protection, content type options)
- **CORS**: Enables cross-origin requests from React frontend
- **Morgan**: Logs HTTP requests for debugging and monitoring
- **express.json()**: Parses JSON request bodies
- **express.urlencoded()**: Parses URL-encoded form data
- **Routes**: Business logic and API endpoints
- **Error Handler**: Centralized error processing and response formatting

## Intermediate Express.js Concepts

### 3. Routing & REST API Design

**Q: Explain the RESTful API design implemented in this application.**
**A:**
```javascript
// Resource: todos
GET    /api/todos      → getAllTodos    (Read all)
POST   /api/todos      → createTodo     (Create)
GET    /api/todos/:id  → getTodo        (Read one)
PUT    /api/todos/:id  → updateTodo     (Update)
DELETE /api/todos/:id  → deleteTodo     (Delete)
GET    /api/todos/stats → getTodosStats (Custom action)
```

This follows REST principles:
- **Resource-based URLs**: `/todos` represents the todo resource
- **HTTP verbs**: Appropriate methods for each action
- **Stateless**: Each request contains all needed information
- **Consistent response format**: All endpoints return similar JSON structure

**Q: How does Express routing handle the /api/todos/stats vs /api/todos/:id conflict?**
**A:** Express routes are matched in order of registration:
```javascript
router.route('/stats').get(getTodosStats);     // Static route first
router.route('/:id').get(getTodo);             // Parameterized route second
```
Static routes must be defined before parameterized routes to avoid `/stats` being interpreted as an `id`.

### 4. Request/Response Handling

**Q: How does the application handle different types of request data?**
**A:**
```javascript
// Query parameters (GET /api/todos?completed=true&sort=-createdAt)
const { completed, priority, sort } = req.query;

// URL parameters (GET /api/todos/507f1f77bcf86cd799439011)
const { id } = req.params;

// Request body (POST /api/todos)
const { title, description, priority } = req.body;

// Headers
const contentType = req.get('Content-Type');
```

**Q: Explain the consistent response format used across all endpoints.**
**A:**
```javascript
// Success responses
{
  "success": true,
  "data": {...},      // Single item or array
  "count": 5          // For arrays
}

// Error responses  
{
  "success": false,
  "error": "Error message",
  "details": [...]    // For validation errors
}
```

### 5. Validation & Input Sanitization

**Q: How does input validation work in this Express application?**
**A:** Multi-layer validation approach:
```javascript
// 1. express-validator middleware
exports.validateCreateTodo = [
  body('title')
    .trim()
    .notEmpty()
    .withMessage('Title is required')
    .isLength({ max: 100 }),
  // ... other validations
];

// 2. Controller validation check
const errors = validationResult(req);
if (!errors.isEmpty()) {
  return res.status(400).json({
    success: false,
    error: 'Validation Error',
    details: errors.array()
  });
}

// 3. Mongoose schema validation (backup)
const todo = await Todo.create(req.body); // Will throw if invalid
```

**Q: Why use both express-validator and Mongoose schema validation?**
**A:**
- **express-validator**: Fast client feedback, custom error messages, sanitization
- **Mongoose validation**: Data integrity, database-level constraints, type coercion
- **Defense in depth**: Multiple layers prevent bad data from reaching database

## Advanced Express.js Concepts

### 6. Error Handling

**Q: Describe the error handling strategy in this application.**
**A:** Centralized error handling with multiple layers:
```javascript
// 1. Controller-level error handling
exports.createTodo = async (req, res) => {
  try {
    const todo = await Todo.create(req.body);
    res.status(201).json({ success: true, data: todo });
  } catch (error) {
    console.error('Error in createTodo:', error);
    
    // Handle specific error types
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        error: 'Validation Error',
        details: Object.values(error.errors).map(err => err.message)
      });
    }
    
    // Generic error
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};

// 2. Global error handler (last middleware)
app.use((error, req, res, next) => {
  console.error(error.stack);
  res.status(500).json({
    success: false,
    error: process.env.NODE_ENV === 'production' 
      ? 'Something went wrong!' 
      : error.message
  });
});
```

**Q: How would you implement request logging and monitoring?**
**A:**
```javascript
// Enhanced logging middleware
const advancedLogger = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log({
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration: `${duration}ms`,
      userAgent: req.get('User-Agent'),
      ip: req.ip,
      timestamp: new Date().toISOString()
    });
  });
  
  next();
};

// Error tracking
const errorTracker = (error, req, res, next) => {
  // Send to monitoring service (Sentry, LogRocket, etc.)
  errorService.captureException(error, {
    user: req.user?.id,
    url: req.url,
    method: req.method
  });
  
  next(error);
};
```

### 7. Database Integration

**Q: Explain how Mongoose is integrated with Express in this application.**
**A:**
```javascript
// 1. Connection management (src/config/database.js)
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI);
    console.log(`MongoDB Connected: ${conn.connection.host}`);
    
    // Event listeners for connection monitoring
    mongoose.connection.on('connected', () => {...});
    mongoose.connection.on('error', (err) => {...});
    mongoose.connection.on('disconnected', () => {...});
  } catch (error) {
    console.error('Error connecting to MongoDB:', error.message);
    process.exit(1);
  }
};

// 2. Model usage in controllers
const Todo = require('../models/Todo');

exports.getAllTodos = async (req, res) => {
  const todos = await Todo.find(filter).sort(sort);
  res.json({ success: true, count: todos.length, data: todos });
};
```

**Q: How does the application handle database connection failures?**
**A:**
- **Initial connection**: App exits if database connection fails at startup
- **Runtime errors**: Mongoose automatically handles reconnection attempts
- **Graceful shutdown**: SIGTERM handler closes connection cleanly
- **Error propagation**: Database errors are caught and returned as 500 responses

### 8. Security Implementation

**Q: What security measures are implemented in this Express application?**
**A:**
```javascript
// 1. Helmet - Security headers
app.use(helmet()); // Adds 11+ security headers

// 2. CORS - Cross-Origin Resource Sharing
app.use(cors({
  origin: process.env.NODE_ENV === 'production'
    ? 'https://yourdomain.com'
    : ['http://localhost:3000', 'http://localhost:3001'],
  credentials: true
}));

// 3. Input validation and sanitization
body('title').trim().escape(); // Prevents XSS

// 4. Request size limiting
app.use(express.json({ limit: '10mb' }));

// 5. Environment-based configuration
const mongoURI = process.env.MONGODB_URI; // No hardcoded credentials
```

**Q: How would you implement rate limiting?**
**A:**
```javascript
const rateLimit = require('express-rate-limit');

const createTodoLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: {
    success: false,
    error: 'Too many todos created, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false
});

app.use('/api/todos', createTodoLimiter);
```

## Performance & Scalability

### 9. Performance Optimization

**Q: How would you optimize database queries in this application?**
**A:**
```javascript
// 1. Proper indexing (already implemented)
todoSchema.index({ completed: 1 });
todoSchema.index({ priority: 1 });
todoSchema.index({ createdAt: -1 });

// 2. Query optimization
// Bad: Loading all todos then filtering in JS
const todos = await Todo.find({});
const highPriority = todos.filter(t => t.priority === 'high');

// Good: Database-level filtering
const highPriority = await Todo.find({ priority: 'high' });

// 3. Pagination for large datasets
exports.getAllTodos = async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const skip = (page - 1) * limit;
  
  const todos = await Todo.find(filter)
    .sort(sort)
    .skip(skip)
    .limit(limit);
    
  const total = await Todo.countDocuments(filter);
  
  res.json({
    success: true,
    data: todos,
    pagination: {
      page,
      limit,
      total,
      pages: Math.ceil(total / limit)
    }
  });
};
```

**Q: How would you implement caching for this API?**
**A:**
```javascript
const redis = require('redis');
const client = redis.createClient();

// Cache middleware
const cache = (duration = 300) => {
  return async (req, res, next) => {
    const key = `cache:${req.method}:${req.originalUrl}`;
    
    try {
      const cached = await client.get(key);
      if (cached) {
        return res.json(JSON.parse(cached));
      }
      
      // Store original res.json
      const originalJson = res.json;
      res.json = function(data) {
        // Cache the response
        client.setex(key, duration, JSON.stringify(data));
        originalJson.call(this, data);
      };
      
      next();
    } catch (error) {
      next(); // Continue without cache on error
    }
  };
};

// Use cache for read operations
router.get('/', cache(300), getAllTodos); // Cache for 5 minutes
```

### 10. Testing Express Applications

**Q: How would you test the Express API endpoints?**
**A:**
```javascript
const request = require('supertest');
const app = require('../server');

describe('Todo API', () => {
  beforeEach(async () => {
    // Clear database before each test
    await Todo.deleteMany({});
  });

  describe('POST /api/todos', () => {
    it('should create a new todo', async () => {
      const todoData = {
        title: 'Test Todo',
        description: 'Test Description',
        priority: 'high'
      };

      const response = await request(app)
        .post('/api/todos')
        .send(todoData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.title).toBe('Test Todo');
    });

    it('should return 400 for invalid data', async () => {
      const response = await request(app)
        .post('/api/todos')
        .send({}) // No title
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('Validation Error');
    });
  });
});
```

## Production Deployment

### 11. Environment Configuration

**Q: How should environment variables be managed for different deployment stages?**
**A:**
```javascript
// .env.development
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://localhost:27017/todoapp_dev
LOG_LEVEL=debug

// .env.production
NODE_ENV=production
PORT=80
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/todoapp
LOG_LEVEL=error

// .env.test
NODE_ENV=test
MONGODB_URI=mongodb://localhost:27017/todoapp_test
LOG_LEVEL=silent
```

**Q: What considerations are important for production deployment?**
**A:**
```javascript
// 1. Process management
process.on('SIGTERM', () => {
  console.log('👋 SIGTERM received');
  server.close(() => {
    mongoose.connection.close();
    console.log('💥 Process terminated');
  });
});

// 2. Health checks
app.get('/health', (req, res) => {
  const health = {
    uptime: process.uptime(),
    message: 'OK',
    timestamp: Date.now(),
    database: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected'
  };
  
  res.status(200).send(health);
});

// 3. Logging for production
const winston = require('winston');
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});
```

### 12. API Documentation & Versioning

**Q: How would you implement API versioning?**
**A:**
```javascript
// URL-based versioning
app.use('/api/v1/todos', v1TodoRoutes);
app.use('/api/v2/todos', v2TodoRoutes);

// Header-based versioning
const versionMiddleware = (req, res, next) => {
  const version = req.headers['api-version'] || 'v1';
  req.apiVersion = version;
  next();
};

// Backwards compatibility
app.use('/api/todos', versionMiddleware, (req, res, next) => {
  if (req.apiVersion === 'v2') {
    return v2TodoRoutes(req, res, next);
  }
  return v1TodoRoutes(req, res, next);
});
```

These questions cover Express.js from basic concepts to advanced production considerations, helping prepare for interviews ranging from junior to senior backend developer positions.