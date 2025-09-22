# Express.js Todo API - Debug Guide

## 🚀 Quick Start - Debug Mode

### Option 1: Using Debug Script (Recommended)
```bash
./debug-start.sh
```

### Option 2: Using NPM Scripts
```bash
# Debug with auto-restart (nodemon)
npm run debug:dev

# Debug without auto-restart
npm run debug

# Debug with breakpoint on start
npm run debug:break
```

### Option 3: Using VS Code Debugger
1. Open this folder in VS Code
2. Go to Run and Debug panel (Ctrl+Shift+D)
3. Select "Debug Express Server" or "Debug Express with Nodemon"
4. Press F5 to start debugging

## 🔧 Debug Configuration

### Environment Variables (.env)
```bash
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://localhost:27017/todo_app
FRONTEND_URL=http://localhost:3000
DEBUG=express:*,app:*
```

### Debug Namespaces
- `app:server` - Server-related logs
- `app:database` - Database connection logs
- `express:*` - Express.js framework logs

### Chrome DevTools Debugging
1. Start server with: `npm run debug` or `npm run debug:dev`
2. Open Chrome and go to: `chrome://inspect`
3. Click "Open dedicated DevTools for Node"

## 🐛 Debugging Features

### Breakpoint Support
- Set breakpoints in VS Code
- Use Chrome DevTools
- Debug both synchronous and asynchronous code

### Enhanced Logging
- Color-coded console output
- Detailed server startup information
- Database connection status
- Request/response logging with Morgan
- Environment-specific log levels

### Error Handling
- Unhandled promise rejection tracking
- Uncaught exception handling
- Graceful shutdown on SIGTERM/SIGINT
- Stack trace preservation in development

## 📋 Troubleshooting

### Common Issues

1. **MongoDB Connection Error**
   ```bash
   # Start MongoDB with Docker
   cd ../mongo-db-docker-compose
   ./scripts/start-mongodb.sh
   ```

2. **Port Already in Use**
   ```bash
   # Kill process on port 5000
   lsof -ti:5000 | xargs kill -9
   ```

3. **Environment Variables Not Loaded**
   - Check if `.env` file exists
   - Verify file permissions
   - Restart the debug session

4. **VS Code Debugger Not Attaching**
   - Ensure launch.json is configured
   - Check port 9229 is not in use
   - Restart VS Code

### Debug Commands
```bash
# Check if server is running
curl http://localhost:5000/api/health

# Test API endpoints
curl -X GET http://localhost:5000/api/todos
curl -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Todo","priority":"medium"}'

# Check debug port
netstat -tulpn | grep 9229
```

## 📊 Available Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/todos` | Get all todos |
| POST | `/api/todos` | Create new todo |
| GET | `/api/todos/:id` | Get todo by ID |
| PUT | `/api/todos/:id` | Update todo |
| DELETE | `/api/todos/:id` | Delete todo |

## 🎯 Performance Debugging

### Memory Monitoring
```bash
# Monitor memory usage
node --inspect --trace-warnings server.js
```

### CPU Profiling
1. Start with `--prof` flag
2. Generate load
3. Analyze with `--prof-process`

### Database Query Debugging
- Enable MongoDB query logging
- Use Mongoose debug mode: `mongoose.set('debug', true)`
- Monitor connection pool size

## 🔐 Security in Debug Mode

- Never use debug mode in production
- Debug port (9229) should not be exposed publicly
- Environment variables are logged (be careful with secrets)
- Stack traces may contain sensitive information