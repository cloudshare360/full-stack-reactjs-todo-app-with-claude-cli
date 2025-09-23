const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');
const dotenv = require('dotenv');

// Load env vars first
dotenv.config();

// Debug setup
const debug = require('debug');
const appDebug = debug('app:server');
const dbDebug = debug('app:database');

const connectDB = require('./src/config/database');
const todoRoutes = require('./src/routes/todoRoutes');
const errorHandler = require('./src/middleware/errorHandler');

// Environment validation
const requiredEnvVars = ['MONGODB_URI'];
const missingEnvVars = requiredEnvVars.filter(envVar => !process.env[envVar]);

if (missingEnvVars.length > 0) {
  console.error('❌ Missing required environment variables:', missingEnvVars);
  console.log('💡 Create a .env file with the following variables:');
  missingEnvVars.forEach(envVar => {
    console.log(`   ${envVar}=your_value_here`);
  });
  process.exit(1);
}

appDebug('🚀 Starting Express.js Todo API Server');
appDebug('📝 Environment: %s', process.env.NODE_ENV || 'development');
appDebug('🔧 Debug mode enabled');

// Connect to database
connectDB();

const app = express();

// Security middleware
app.use(helmet());

// CORS middleware
const allowedOrigins = process.env.NODE_ENV === 'production'
  ? ['https://yourdomain.com']
  : [
      'http://localhost:3000', 
      'http://localhost:3001',
      'http://localhost:8000',
      process.env.FRONTEND_URL,
      process.env.SWAGGER_UI_URL,
      process.env.CODESPACES_FRONTEND_URL,
      process.env.CODESPACES_SWAGGER_UI_URL
    ].filter(Boolean); // Remove any undefined values

app.use(cors({
  origin: allowedOrigins,
  credentials: true
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

const PORT = process.env.PORT || 5000;

const server = app.listen(PORT, '0.0.0.0', () => {
  
  console.log('\n' + '='.repeat(60));
  console.log('🚀 EXPRESS.JS TODO API SERVER STARTED');
  console.log('='.repeat(60));
  console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🌐 Server Address: http://localhost:${PORT}`);
  console.log(`🔧 API Base URL: http://localhost:${PORT}/api`);
  console.log(`📊 Health Check: http://localhost:${PORT}/api/health`);
  console.log(`📱 Frontend URL: ${process.env.FRONTEND_URL || 'http://localhost:3000'}`);
  
  if (process.env.NODE_ENV === 'development') {
    console.log('\n🔧 DEBUG MODE ENABLED');
    console.log(`🐛 Debug Inspector: chrome://inspect`);
    console.log(`🔍 Server Port: ${PORT}`);
    console.log(`🔍 Debug Port: 9229 (default inspector port)`);
    console.log('📝 Debug Namespaces: app:*, express:*');
    console.log('💡 Set DEBUG=* for verbose logging');
  }
  
  console.log('\n📋 Available Endpoints:');
  console.log('   GET    /api/todos        - Get all todos');
  console.log('   POST   /api/todos        - Create new todo');
  console.log('   GET    /api/todos/:id    - Get todo by ID');
  console.log('   PUT    /api/todos/:id    - Update todo');
  console.log('   DELETE /api/todos/:id    - Delete todo');
  console.log('   GET    /api/health       - Health check');
  console.log('='.repeat(60) + '\n');
  
  appDebug('✅ Server listening on port %d', PORT);
});

// Enhanced error handling
process.on('unhandledRejection', (err, promise) => {
  console.error('🔴 Unhandled Promise Rejection:', err.message);
  appDebug('Unhandled Promise Rejection: %O', err);
  
  // Close server & exit process
  console.log('🛑 Shutting down server due to unhandled promise rejection...');
  server.close(() => {
    process.exit(1);
  });
});

process.on('uncaughtException', (err) => {
  console.error('🔴 Uncaught Exception:', err.message);
  appDebug('Uncaught Exception: %O', err);
  
  console.log('🛑 Shutting down server due to uncaught exception...');
  process.exit(1);
});

// Handle SIGTERM
process.on('SIGTERM', () => {
  console.log('\n👋 SIGTERM received');
  console.log('✋ Shutting down gracefully...');
  appDebug('SIGTERM received, shutting down gracefully');
  
  server.close(() => {
    console.log('💥 Process terminated');
    appDebug('HTTP server closed');
  });
});

// Handle SIGINT (Ctrl+C)
process.on('SIGINT', () => {
  console.log('\n👋 SIGINT received (Ctrl+C)');
  console.log('✋ Shutting down gracefully...');
  appDebug('SIGINT received, shutting down gracefully');
  
  server.close(() => {
    console.log('💥 Process terminated');
    appDebug('HTTP server closed');
    process.exit(0);
  });
});

module.exports = app;