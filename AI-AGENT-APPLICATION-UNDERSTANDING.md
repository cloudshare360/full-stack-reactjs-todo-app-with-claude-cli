# AI-Agent Application Understanding Document

## Full-Stack Todo Application - Complete Reference Guide

---

## 🤖 **For AI Agents: How to Understand This Application**

This document provides AI agents with a complete understanding of the Todo application architecture, current state, and how to assist users effectively.

### **Quick Context Loading**

1. **Application Type:** Full-stack CRUD Todo application
2. **Tech Stack:** React.js + Express.js + MongoDB
3. **Current Status:** Development phase with debugging needs
4. **Main Issues:** Frontend loading problems, Swagger UI not working
5. **Development Environment:** Docker containers + local development

---

## 🏗️ **System Architecture Overview**

### **Three-Tier Architecture**
```
Frontend (React.js) ↔ Backend (Express.js) ↔ Database (MongoDB)
     Port 3000             Port 5000            Port 27017
```

### **Key Technologies**
- **Frontend:** React 18, TypeScript, Hooks, Fetch API
- **Backend:** Express.js, Mongoose ODM, JWT (planned), CORS
- **Database:** MongoDB, Docker containerized
- **Development:** VS Code, Docker Compose, Nodemon
- **Documentation:** Mermaid diagrams, Swagger UI

---

## 📋 **Current Application State**

### **What's Working ✅**
- MongoDB Docker container running
- Express.js server with debug mode
- Basic React components structure
- API endpoints (CRUD operations)
- Documentation with Mermaid diagrams
- Debug configuration for VS Code

### **What's Broken ❌** 
- Frontend can't load todo list (CORS/API connection issue)
- Swagger UI not rendering properly
- E2E tests incomplete
- Some documentation conversions pending

### **What's Missing 🔧**
- Comprehensive test suite
- Proper error handling in frontend
- Production deployment setup
- Authentication system

---

## 🎯 **Common User Requests & How to Help**

### **1. "Application isn't working"**
**Check these in order:**
1. MongoDB container status: `docker-compose ps`
2. Express.js server status: Check port 5000
3. React dev server status: Check port 3000
4. Network connectivity between services
5. Browser console errors
6. API response in Network tab

### **2. "Can't debug the Express server"**
**Solutions available:**
- VS Code debugger (F5) - launch.json configured
- Chrome DevTools - `chrome://inspect`
- Terminal debugging - `npm run debug:dev`
- Check `express-js-rest-api/DEBUG.md` for full guide

### **3. "Need to test API endpoints"**
**Multiple options:**
- Swagger UI (when fixed): `http://localhost:5000/swagger-ui.html`
- Curl scripts: Check `curl-scripts/` directory
- Postman collection: Can be created from Swagger spec
- Browser: Direct GET requests to endpoints

### **4. "Documentation needs updates"**
**Current documentation:**
- Architecture docs in `docs/` folder
- HTML versions with Mermaid diagrams in `docs/application-flow/`
- Debug guide in `express-js-rest-api/DEBUG.md`
- This AI tracking document

---

## 🔍 **Diagnostic Commands**

### **Quick Health Check**
```bash
# Check all services
docker-compose ps                          # MongoDB status
curl http://localhost:5000/api/health     # API health
curl http://localhost:3000                # React dev server

# Check logs
docker-compose logs mongodb               # Database logs
npm run dev --prefix express-js-rest-api  # API logs
npm start --prefix reactjs-18-front-end   # Frontend logs
```

### **Common Issues & Solutions**

| Issue | Symptoms | Solution |
|-------|----------|----------|
| MongoDB connection failed | API errors, connection refused | `docker-compose up -d` |
| CORS errors | Frontend API calls blocked | Check Express CORS config |
| Port conflicts | Cannot start services | Kill processes or change ports |
| Module not found | Import/require errors | `npm install` in respective folder |
| Build failures | Compilation errors | Check syntax, dependencies |

---

## 📁 **File Structure for AI Reference**

### **Critical Files to Understand**
```
express-js-rest-api/
├── server.js                    # Main server entry point
├── .env                         # Environment configuration
├── src/controllers/todoController.js  # API logic
├── src/models/Todo.js           # Database schema
└── src/routes/todoRoutes.js     # API routes

reactjs-18-front-end/
├── src/App.tsx                  # Main React component
├── src/components/TodoList.tsx  # Todo display component
├── src/services/todoAPI.ts      # API service layer
└── package.json                # Frontend dependencies

mongo-db-docker-compose/
└── docker-compose.yml           # MongoDB container config
```

### **Configuration Files**
- `express-js-rest-api/.env` - Backend environment variables
- `express-js-rest-api/.vscode/launch.json` - Debug configuration
- `mongo-db-docker-compose/docker-compose.yml` - Database setup
- `reactjs-18-front-end/package.json` - Frontend dependencies

---

## 🚀 **How to Start Everything**

### **Step-by-Step Startup**
```bash
# 1. Start MongoDB
cd mongo-db-docker-compose
docker-compose up -d

# 2. Start Express.js API (new terminal)
cd express-js-rest-api
npm run dev

# 3. Start React.js (another terminal)
cd reactjs-18-front-end  
npm start

# 4. Verify everything is running
curl http://localhost:5000/api/health
open http://localhost:3000
```

### **Alternative Debug Startup**
```bash
# Use VS Code debugger instead of npm run dev
# 1. Open express-js-rest-api in VS Code
# 2. Press F5 to start with debugger attached
# 3. Set breakpoints as needed
```

---

## 🧪 **Testing Strategy**

### **Current Test Structure**
- **E2E Tests:** Playwright configuration exists
- **Unit Tests:** Jest setup in React app
- **API Tests:** Manual curl scripts available
- **Integration:** Database connection tests needed

### **Testing Priorities**
1. API endpoint functionality
2. Frontend component rendering
3. Database CRUD operations
4. End-to-end user workflows
5. Error handling scenarios

---

## 🔧 **Development Workflow**

### **Making Changes**
1. **Backend Changes:** Edit in `express-js-rest-api/src/`
2. **Frontend Changes:** Edit in `reactjs-18-front-end/src/`
3. **Database Changes:** Modify `express-js-rest-api/src/models/`
4. **API Changes:** Update `express-js-rest-api/src/controllers/` and `src/routes/`

### **Testing Changes**
1. **API:** Use curl scripts or Swagger UI
2. **Frontend:** Browser testing with DevTools
3. **Database:** Check MongoDB Express UI at `http://localhost:8081`
4. **Integration:** Run E2E tests when available

---

## 📊 **API Documentation**

### **Available Endpoints**
```http
GET    /api/health              # Health check
GET    /api/todos               # List all todos
POST   /api/todos               # Create new todo  
GET    /api/todos/:id           # Get specific todo
PUT    /api/todos/:id           # Update todo
DELETE /api/todos/:id           # Delete todo
GET    /api/todos/stats         # Get statistics
```

### **Sample Data Structure**
```json
{
  "_id": "64f...",
  "title": "Sample Todo",
  "description": "Todo description", 
  "priority": "medium",
  "completed": false,
  "createdAt": "2025-09-22T...",
  "updatedAt": "2025-09-22T..."
}
```

---

## 🎯 **AI Agent Action Guidelines**

### **When User Reports Issues**

1. **Gather Information**
   - What were they trying to do?
   - What error messages did they see?
   - Which component (Frontend/Backend/Database)?
   - Current browser/terminal output?

2. **Systematic Diagnosis**
   - Check service status (MongoDB, Express, React)
   - Verify configuration files (.env, package.json)
   - Test API endpoints independently
   - Check browser console and network requests

3. **Provide Solutions**
   - Specific commands to run
   - Configuration changes needed
   - Code fixes with context
   - Testing steps to verify fix

### **When Creating New Features**

1. **Architecture Consideration**
   - Which tier needs changes (Frontend/Backend/Database)?
   - What existing patterns to follow?
   - What dependencies might be needed?
   - How to test the new feature?

2. **Implementation Order**
   - Database model changes first
   - Backend API endpoint creation
   - Frontend service layer updates
   - UI component modifications
   - Testing and documentation

### **When Debugging**

1. **Use Available Tools**
   - VS Code debugger for Express.js
   - Browser DevTools for React.js
   - MongoDB Express for database
   - Docker logs for container issues

2. **Follow Debug Patterns**
   - Set breakpoints in VS Code
   - Check network requests in browser
   - Verify API responses with curl
   - Monitor database changes

---

## 📞 **Quick Reference**

### **URLs & Access Points**
- **Frontend:** http://localhost:3000
- **API:** http://localhost:5000
- **API Health:** http://localhost:5000/api/health  
- **MongoDB Admin:** http://localhost:8081 (admin/admin123)
- **Swagger UI:** http://localhost:5000/swagger-ui.html (when working)

### **Important Commands**
```bash
# Service management
docker-compose up -d              # Start MongoDB
docker-compose down              # Stop MongoDB
npm run dev                      # Start Express.js
npm start                        # Start React.js
npm run debug:dev               # Debug Express.js

# Quick tests
curl localhost:5000/api/health   # API health check
curl localhost:5000/api/todos    # List todos
```

### **File Locations for Quick Access**
- Main server: `express-js-rest-api/server.js`
- API routes: `express-js-rest-api/src/routes/todoRoutes.js`
- React App: `reactjs-18-front-end/src/App.tsx`
- Database config: `express-js-rest-api/src/config/database.js`
- Environment: `express-js-rest-api/.env`

---

**AI Agent Note:** This document should be referenced for every interaction to provide accurate, contextual assistance based on the current application state and architecture.