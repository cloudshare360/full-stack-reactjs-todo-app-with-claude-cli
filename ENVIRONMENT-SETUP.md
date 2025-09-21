# 🌐 Dynamic Environment Configuration

This Todo application now supports dynamic hostname resolution and CORS for seamless deployment across different environments and machines.

## ✨ Features

- **Dynamic Hostname Detection**: Automatically detects and uses the current machine's hostname/IP
- **Environment-Agnostic**: Works on localhost, different machines, and production environments
- **Full CORS Support**: Configured for cross-origin requests from all components
- **No Hardcoded URLs**: All components use dynamic configuration

## 📋 Components Updated

### 1. 🚀 Express.js API Server
- **File**: `express-js-rest-api/server.js`
- **Configuration**: `config/environment.js`
- **Features**:
  - Dynamic CORS origins based on hostname detection
  - Flexible MongoDB connection with environment variables
  - Real-time environment configuration display

### 2. ⚛️ React Frontend
- **Files**:
  - `reactjs-18-front-end/src/utils/environment.js`
  - `reactjs-18-front-end/.env`
- **Features**:
  - Client-side hostname detection
  - Dynamic API endpoint resolution
  - Environment-based configuration

### 3. 📚 Swagger UI
- **File**: `swagger-ui/swagger-ui.html`
- **Features**:
  - Dynamic server URL detection
  - Real-time API status monitoring
  - Cross-origin request handling

### 4. 🧪 cURL Test Scripts
- **File**: `curl-scripts/config.sh`
- **Features**:
  - Auto-detection of API server location
  - Fallback to alternative hosts
  - Configuration persistence

### 5. 🎭 E2E Tests
- **File**: `swagger-ui-e2e.test.js`
- **Features**:
  - Environment variable support
  - Dynamic URL configuration
  - Flexible test execution

## 🔧 Environment Variables

### Express API Server
```bash
# MongoDB Configuration
MONGODB_HOST=localhost          # MongoDB hostname
MONGODB_PORT=27017             # MongoDB port
MONGODB_DATABASE=todoapp       # Database name
MONGODB_USERNAME=todouser      # Database username
MONGODB_PASSWORD=todopass123   # Database password
MONGODB_URI=mongodb://...      # Full connection string (overrides above)

# API Server Configuration
API_HOST=localhost             # API server hostname
API_PORT=5000                 # API server port
API_PROTOCOL=http             # Protocol (http/https)

# CORS Configuration
CORS_ORIGINS=http://localhost:3000,http://localhost:8080  # Allowed origins

# Environment
NODE_ENV=development          # Environment (development/production)
```

### React Frontend
```bash
# API Configuration
REACT_APP_API_HOST=localhost          # API server hostname
REACT_APP_API_PORT=5000              # API server port
REACT_APP_API_PROTOCOL=http          # Protocol
REACT_APP_API_URL=http://localhost:5000/api  # Full API URL (overrides above)

# Swagger UI Configuration
REACT_APP_SWAGGER_HOST=localhost     # Swagger UI hostname
REACT_APP_SWAGGER_PORT=8080         # Swagger UI port
REACT_APP_SWAGGER_PROTOCOL=http     # Protocol
```

### E2E Tests
```bash
# Test Configuration
API_HOST=localhost               # API server hostname
API_PORT=5000                   # API server port
API_PROTOCOL=http              # Protocol
API_BASE_URL=http://localhost:5000/api  # Full API URL

SWAGGER_HOST=localhost          # Swagger UI hostname
SWAGGER_PORT=8080              # Swagger UI port
SWAGGER_PROTOCOL=http          # Protocol
SWAGGER_UI_URL=http://localhost:8080/swagger-ui.html  # Full Swagger URL

TEST_HOSTNAME=localhost         # Override hostname for tests
```

### cURL Scripts
```bash
# Configuration (automatically detected)
API_PROTOCOL=http              # Protocol
API_HOST=localhost             # API server hostname
API_PORT=5000                  # API server port
```

## 🚀 Quick Start

### 1. Standard localhost Development
```bash
# No configuration needed - works out of the box
cd express-js-rest-api && npm run dev
cd reactjs-18-front-end && npm start
cd swagger-ui && python3 -m http.server 8080
cd curl-scripts && ./config.sh
```

### 2. Different Machine/IP Development
```bash
# Set your machine's IP as the API host
export API_HOST=192.168.1.100
export REACT_APP_API_HOST=192.168.1.100

# Start services
cd express-js-rest-api && npm run dev
cd reactjs-18-front-end && npm start
cd swagger-ui && python3 -m http.server 8080
```

### 3. Custom Hostname Setup
```bash
# Set custom hostname
export API_HOST=mydev.local
export REACT_APP_API_HOST=mydev.local
export MONGODB_HOST=mydev.local

# Ensure hostname resolves in /etc/hosts:
echo "192.168.1.100 mydev.local" | sudo tee -a /etc/hosts

# Start services
cd express-js-rest-api && npm run dev
```

## 🔍 Testing the Configuration

### 1. Test API Server
```bash
# Test direct API access
curl http://YOUR_HOST:5000/api/todos/stats

# Test CORS headers
curl -H "Origin: http://localhost:3000" -v http://YOUR_HOST:5000/api/todos/stats
```

### 2. Test cURL Scripts
```bash
cd curl-scripts
./config.sh                    # Auto-configure and test
./06-get-stats.sh              # Test with dynamic config
```

### 3. Test Swagger UI
- Open: `http://YOUR_HOST:8080/swagger-ui.html`
- Check API status indicator (should show green)
- Try any endpoint - should connect to dynamic API server

### 4. Test React Frontend
- Open: `http://YOUR_HOST:3000`
- Check browser console for environment config
- Test API calls from frontend

### 5. Test E2E
```bash
# Test with custom environment
API_HOST=YOUR_HOST SWAGGER_HOST=YOUR_HOST npx playwright test
```

## 🎯 Production Deployment

### Docker Compose Example
```yaml
version: '3.8'
services:
  mongodb:
    image: mongo:latest
    environment:
      MONGO_INITDB_ROOT_USERNAME: todouser
      MONGO_INITDB_ROOT_PASSWORD: todopass123

  api:
    build: ./express-js-rest-api
    environment:
      - MONGODB_HOST=mongodb
      - API_HOST=0.0.0.0
      - NODE_ENV=production
      - CORS_ORIGINS=https://yourdomain.com

  frontend:
    build: ./reactjs-18-front-end
    environment:
      - REACT_APP_API_HOST=api.yourdomain.com
      - REACT_APP_API_PROTOCOL=https
```

## 🔧 Troubleshooting

### Common Issues

1. **CORS Errors**
   - Check `express-js-rest-api/server.js` CORS configuration
   - Ensure your origin is in the allowed list
   - Check console for blocked origin messages

2. **API Not Found**
   - Verify API server is running: `curl http://HOST:5000/api/health`
   - Check hostname resolution: `ping YOUR_HOST`
   - Review environment variables: `env | grep API`

3. **Swagger UI Not Loading**
   - Check if running on correct port: `netstat -tulpn | grep :8080`
   - Verify Swagger UI files exist in `swagger-ui/` directory
   - Check browser console for JavaScript errors

4. **E2E Tests Failing**
   - Ensure all services are running before tests
   - Check test configuration URLs are accessible
   - Use `--headed` mode to debug visually

### Debug Commands

```bash
# Check environment configuration
cd config && node -e "const { printConfig } = require('./environment.js'); printConfig()"

# Test API connectivity
curl -v http://YOUR_HOST:5000/api/health

# Check MongoDB connection
cd express-js-rest-api && npm run dev | grep "MongoDB"

# Verify CORS headers
curl -H "Origin: http://localhost:3000" -H "Access-Control-Request-Method: GET" -H "Access-Control-Request-Headers: Content-Type" -X OPTIONS -v http://YOUR_HOST:5000/api/todos
```

## 📈 Benefits

1. **Flexibility**: Deploy on any machine without code changes
2. **Development Friendly**: Works across team members' different setups
3. **Production Ready**: Supports proper hostname and HTTPS configuration
4. **Testing**: Comprehensive E2E and API testing with dynamic endpoints
5. **Maintainability**: Centralized configuration management
6. **Security**: Proper CORS configuration for production deployment

---

**🎉 Your Todo application is now fully environment-agnostic and ready for deployment anywhere!**