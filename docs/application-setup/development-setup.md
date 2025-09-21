# Development Environment Setup

## 🛠 Prerequisites Installation

### Node.js Installation
```bash
# Check if Node.js is installed
node --version  # Should be 18.0.0 or higher
npm --version   # Should be 8.0.0 or higher

# Install Node.js (if not installed)
# Option 1: Download from https://nodejs.org/
# Option 2: Using package manager
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS (using Homebrew)
brew install node@18

# Windows (using Chocolatey)
choco install nodejs
```

### MongoDB Installation

#### Option 1: Local MongoDB
```bash
# Ubuntu/Debian
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# macOS (using Homebrew)
brew tap mongodb/brew
brew install mongodb-community@6.0

# Windows
# Download from https://www.mongodb.com/try/download/community
```

#### Option 2: MongoDB with Docker
```bash
# Install Docker Desktop
# Visit: https://www.docker.com/products/docker-desktop

# Pull MongoDB image
docker pull mongo:6.0

# Run MongoDB container
docker run -d -p 27017:27017 --name mongodb mongo:6.0
```

### Git Installation
```bash
# Check if Git is installed
git --version

# Install Git (if not installed)
# Ubuntu/Debian
sudo apt-get install git

# macOS (usually pre-installed)
git --version

# Windows
# Download from https://git-scm.com/download/win
```

## 🚀 Project Setup

### 1. Clone Repository
```bash
# Clone the repository
git clone <repository-url>
cd reactjs-todo-application

# Verify project structure
ls -la
# Should see: docs/, reactjs-18-front-end/, express-js-rest-api/, mongo-db-docker-compose/
```

### 2. Backend Setup
```bash
# Navigate to backend directory
cd express-js-rest-api

# Install dependencies
npm install

# Create environment file
cp .env.example .env  # If example exists, or create manually

# Edit .env file
nano .env
```

**Backend .env Configuration:**
```bash
# express-js-rest-api/.env
MONGODB_URI=mongodb://todouser:todopass123@localhost:27017/todoapp
PORT=5000
NODE_ENV=development
```

### 3. Frontend Setup
```bash
# Navigate to frontend directory (from project root)
cd reactjs-18-front-end

# Install dependencies
npm install

# Create environment file (if needed)
touch .env.local
```

**Frontend .env Configuration:**
```bash
# reactjs-18-front-end/.env.local
REACT_APP_API_URL=http://localhost:5000/api
PORT=3001
```

### 4. Database Setup
```bash
# Option 1: Start local MongoDB
sudo systemctl start mongod  # Linux
brew services start mongodb/brew/mongodb-community  # macOS

# Option 2: Use Docker MongoDB
cd mongo-db-docker-compose
docker-compose up -d

# Initialize database with sample data
cd ../mongo-db-scripts
chmod +x create_user.sh seed_data.sh
./create_user.sh
./seed_data.sh
```

## 💻 IDE Configuration

### VS Code Setup (Recommended)

#### 1. Install VS Code Extensions
```bash
# Install VS Code (if not installed)
# Visit: https://code.visualstudio.com/

# Recommended extensions (install via VS Code marketplace):
# - ES7+ React/Redux/React-Native snippets
# - TypeScript Importer
# - Prettier - Code formatter
# - ESLint
# - MongoDB for VS Code
# - Docker
# - GitLens
```

#### 2. VS Code Workspace Configuration
Create `.vscode/settings.json` in project root:
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "emmet.includeLanguages": {
    "typescript": "typescriptreact"
  },
  "files.exclude": {
    "**/node_modules": true,
    "**/build": true,
    "**/dist": true
  }
}
```

#### 3. Launch Configuration
Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Backend",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/express-js-rest-api/server.js",
      "env": {
        "NODE_ENV": "development"
      },
      "console": "integratedTerminal"
    }
  ]
}
```

## 🔧 Development Tools Setup

### 1. ESLint Configuration
```bash
# Frontend ESLint setup (if not already configured)
cd reactjs-18-front-end
npx eslint --init

# Backend ESLint setup
cd ../express-js-rest-api
npm install --save-dev eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser
```

### 2. Prettier Configuration
Create `.prettierrc` in project root:
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
```

### 3. Git Hooks (Optional)
```bash
# Install Husky for pre-commit hooks
npm install --save-dev husky lint-staged

# Initialize Husky
npx husky install

# Add pre-commit hook
npx husky add .husky/pre-commit "npx lint-staged"
```

Create `.lintstagedrc.json`:
```json
{
  "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.{json,css,md}": ["prettier --write"]
}
```

## 🧪 Testing Setup

### 1. Install Testing Dependencies
```bash
# Frontend testing (usually included with CRA)
cd reactjs-18-front-end
npm install --save-dev @testing-library/user-event

# Backend testing
cd ../express-js-rest-api
npm install --save-dev jest supertest

# E2E testing (project root)
cd ..
npm install playwright
npx playwright install
```

### 2. Test Configuration Files
**Frontend Jest config (package.json):**
```json
{
  "scripts": {
    "test": "react-scripts test",
    "test:coverage": "react-scripts test --coverage --watchAll=false"
  }
}
```

**Backend Jest config (jest.config.js):**
```javascript
module.exports = {
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  testMatch: ['**/__tests__/**/*.js', '**/?(*.)+(spec|test).js'],
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/index.js',
    '!**/node_modules/**'
  ]
};
```

## 🚀 Development Workflow

### 1. Daily Development Commands
```bash
# Terminal 1: Start MongoDB
docker-compose -f mongo-db-docker-compose/docker-compose.yml up

# Terminal 2: Start Backend
cd express-js-rest-api
npm run dev

# Terminal 3: Start Frontend
cd reactjs-18-front-end
npm start

# Terminal 4: Run tests (when developing)
npm test
```

### 2. Development URLs
- **Frontend**: `http://localhost:3001`
- **Backend API**: `http://localhost:5000/api`
- **MongoDB**: `localhost:27017`
- **Health Check**: `http://localhost:5000/api/health`

### 3. Useful Development Commands
```bash
# Check application health
curl http://localhost:5000/api/health

# View MongoDB data
mongo todoapp --eval "db.todos.find().pretty()"

# Check logs
# Backend logs: Console output from npm run dev
# Frontend logs: Browser console + terminal output

# Reset database
cd mongo-db-scripts
./reset_database.sh
```

## 🔍 Verification Steps

### 1. Backend Verification
```bash
# Test API endpoints
curl -X GET http://localhost:5000/api/todos
curl -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Todo","description":"Test Description","priority":"medium"}'
```

### 2. Frontend Verification
- Open `http://localhost:3001` in browser
- Check browser console for errors
- Verify React DevTools extension works
- Test CRUD operations through UI

### 3. Database Verification
```bash
# Connect to MongoDB
mongo todoapp

# List collections
show collections

# View todos
db.todos.find().pretty()

# Exit MongoDB shell
exit
```

## 🐛 Troubleshooting

### Common Issues and Solutions

**Issue: Node.js version mismatch**
```bash
# Solution: Use Node Version Manager
npm install -g n
sudo n 18.0.0
```

**Issue: Port already in use**
```bash
# Find process using port
lsof -ti:3001
kill -9 <PID>

# Or change port in .env files
```

**Issue: MongoDB connection failed**
```bash
# Check MongoDB status
sudo systemctl status mongod

# Restart MongoDB
sudo systemctl restart mongod

# Or check Docker container
docker ps
docker restart mongodb
```

**Issue: npm install fails**
```bash
# Clear npm cache
npm cache clean --force

# Remove node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

---

*← [Application Setup](./README.md) | [Database Setup →](./database-setup.md)*