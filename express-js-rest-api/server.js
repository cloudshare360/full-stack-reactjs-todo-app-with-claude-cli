const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');
const dotenv = require('dotenv');

const connectDB = require('./src/config/database');
const todoRoutes = require('./src/routes/todoRoutes');
const errorHandler = require('./src/middleware/errorHandler');

// Load environment configuration
dotenv.config();
const { getConfig, getCORSOrigins, printConfig } = require('../config/environment');

// Connect to database
connectDB();

const app = express();

// Security middleware
app.use(helmet());

// Dynamic CORS middleware
const corsOrigins = getCORSOrigins();
app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or Postman)
    if (!origin) return callback(null, true);

    if (corsOrigins.indexOf(origin) !== -1 || process.env.NODE_ENV === 'development') {
      return callback(null, true);
    } else {
      console.log(`❌ CORS blocked origin: ${origin}`);
      return callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin'],
  exposedHeaders: ['X-Total-Count', 'X-Page-Count']
}));

// Logging middleware
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Body parser middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: false }));

// API routes
app.use('/api/todos', todoRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'API is running',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to Todo API',
    version: '1.0.0',
    endpoints: {
      todos: '/api/todos',
      health: '/api/health'
    }
  });
});

// Handle 404 routes
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: `Route ${req.originalUrl} not found`
  });
});

// Error handler middleware (must be last)
app.use(errorHandler);

const config = getConfig();
const PORT = config.api.port;

const server = app.listen(PORT, () => {
  console.log(`🚀 Todo API Server Started Successfully!`);

  // Print dynamic configuration
  printConfig();

  console.log(`📊 Health Check: ${config.api.baseURL}/api/health`);
  console.log(`✅ Server ready to accept connections\n`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err, promise) => {
  console.log(`Error: ${err.message}`);
  // Close server & exit process
  server.close(() => {
    process.exit(1);
  });
});

// Handle SIGTERM
process.on('SIGTERM', () => {
  console.log('👋 SIGTERM received');
  console.log('✋ Shutting down gracefully');
  server.close(() => {
    console.log('💥 Process terminated');
  });
});

module.exports = app;