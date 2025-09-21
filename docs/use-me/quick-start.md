# Quick Start Guide

Get up and running with the ReactJS Todo Application in 5 minutes!

## ⚡ Prerequisites

- ✅ Node.js 18+ installed
- ✅ MongoDB running (local or Docker)
- ✅ Terminal/Command prompt access

## 🚀 Installation Steps

### Step 1: Clone and Setup
```bash
# Clone the repository
git clone <repository-url>
cd reactjs-todo-application

# Quick verification of project structure
ls -la
# Should see: reactjs-18-front-end/, express-js-rest-api/, mongo-db-docker-compose/
```

### Step 2: Start Database
```bash
# Option A: Using Docker (Recommended)
cd mongo-db-docker-compose
docker-compose up -d

# Option B: Local MongoDB
# Make sure MongoDB is running on your system
sudo systemctl start mongod  # Linux
brew services start mongodb-community  # macOS
```

### Step 3: Start Backend
```bash
# Navigate to backend directory (from project root)
cd express-js-rest-api

# Install dependencies
npm install

# Start development server
npm run dev
```

You should see:
```
🚀 Server running in development mode on port 5000
MongoDB Connected: localhost
```

### Step 4: Start Frontend
```bash
# Open new terminal, navigate to frontend directory
cd reactjs-18-front-end

# Install dependencies
npm install

# Start React development server
PORT=3001 npm start
```

Browser should automatically open to `http://localhost:3001`

## 🎯 First Todo

### Creating Your First Todo
1. **Open Application**: Go to `http://localhost:3001`
2. **Add Title**: Type "My First Todo" in the title field
3. **Add Description**: (Optional) Add "Getting started with the app"
4. **Select Priority**: Choose "High" from the dropdown
5. **Click "Add Todo"**: Your todo appears instantly!

### Interacting with Todos
- **✅ Mark Complete**: Click the checkbox next to any todo
- **✏️ Edit**: Click the "Edit" button to modify title/description
- **🗑️ Delete**: Click the "Delete" button to remove a todo

## 🔍 Verification Checklist

### ✅ Application Health Check
```bash
# Test backend API directly
curl http://localhost:5000/api/health
# Should return: {"success":true,"message":"API is running"}

# Test todos endpoint
curl http://localhost:5000/api/todos
# Should return: {"success":true,"data":[...]}
```

### ✅ Frontend Verification
- [ ] Page loads without errors
- [ ] Can create new todos
- [ ] Can edit existing todos
- [ ] Can delete todos
- [ ] Can toggle completion status
- [ ] Priority colors display correctly

### ✅ Database Verification
```bash
# Connect to MongoDB and check data
mongo todoapp
db.todos.find().pretty()
exit
```

## 🚦 Service Status

Check that all services are running correctly:

| Service | URL | Status Check |
|---------|-----|-------------|
| Frontend | `http://localhost:3001` | Should load React app |
| Backend API | `http://localhost:5000/api/health` | Should return success JSON |
| MongoDB | `localhost:27017` | Connection shown in backend logs |

## ⚡ Quick Commands Reference

```bash
# Start all services (run in separate terminals)
# Terminal 1: Database
docker-compose -f mongo-db-docker-compose/docker-compose.yml up

# Terminal 2: Backend
cd express-js-rest-api && npm run dev

# Terminal 3: Frontend
cd reactjs-18-front-end && PORT=3001 npm start

# Test the application
curl http://localhost:5000/api/todos
```

## 🧪 Quick Test

Run this quick test to ensure everything works:

```bash
# Create a test todo via API
curl -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "API Test Todo",
    "description": "Created via API",
    "priority": "high"
  }'

# Verify it appears in the frontend
# Go to http://localhost:3001 and check if the todo appears
```

## 🐛 Common Issues

### Issue: "Port already in use"
```bash
# Find and kill the process
lsof -ti:3001  # or :5000 for backend
kill -9 <PID>

# Or use different ports
PORT=3002 npm start  # Frontend
PORT=5001 npm run dev  # Backend (update .env)
```

### Issue: "Cannot connect to MongoDB"
```bash
# Check if MongoDB is running
docker ps  # Should show mongodb container
# OR
sudo systemctl status mongod  # For local MongoDB

# Restart if needed
docker-compose restart mongodb
# OR
sudo systemctl restart mongod
```

### Issue: "CORS errors in browser"
- Check that backend is running on port 5000
- Verify CORS configuration allows localhost:3001
- Clear browser cache and reload

## 🎉 You're Ready!

Congratulations! You now have a fully functional todo application running.

### What's Next?
- 📖 Read the [User Manual](./user-manual.md) for detailed feature explanations
- 🧪 Check out the [Testing Guide](./testing-guide.md) to run automated tests
- 🔌 Review [API Documentation](./api-documentation.md) for integration details
- 📊 See [Project Status](../project-status/README.md) for current development state

### Need Help?
- 🐛 Found a bug? Create a GitHub issue
- ❓ Have questions? Check the detailed documentation
- 💡 Want to contribute? Review the development setup guide

---

*← [User Guides](./README.md) | [User Manual →](./user-manual.md)*