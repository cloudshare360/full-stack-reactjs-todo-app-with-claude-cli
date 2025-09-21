# Application Setup Documentation

This section contains comprehensive guides for setting up and running the ReactJS Todo Application in various environments.

## 🚀 Quick Start

1. **Prerequisites**: Node.js 18+, MongoDB, Docker (optional)
2. **Clone Repository**: `git clone <repository-url>`
3. **Install Dependencies**: Run setup scripts in each directory
4. **Start Services**: Backend first, then frontend
5. **Access Application**: `http://localhost:3001`

## 📚 Setup Guides

### [🔧 Development Environment Setup](./development-setup.md)
- Prerequisites installation
- IDE configuration
- Development tools setup
- Environment variables configuration

### [💾 Database Setup](./database-setup.md)
- MongoDB installation options
- Local database configuration
- Docker MongoDB setup
- Database initialization and seeding

### [⚛️ Frontend Setup](./frontend-setup.md)
- React application setup
- Dependency installation
- Development server configuration
- Build process setup

### [🔙 Backend Setup](./backend-setup.md)
- Express.js server setup
- API configuration
- Environment variables
- Development and production modes

### [🐳 Docker Setup](./docker-setup.md)
- Container configuration
- Docker Compose setup
- Multi-service orchestration
- Development vs production containers

## 🛠 Setup Checklist

### Prerequisites Checklist
- [ ] Node.js 18+ installed
- [ ] npm or yarn package manager
- [ ] MongoDB (local or Docker)
- [ ] Git version control
- [ ] Code editor (VS Code recommended)
- [ ] Docker (optional, for containerized setup)

### Installation Checklist
- [ ] Repository cloned
- [ ] Backend dependencies installed
- [ ] Frontend dependencies installed
- [ ] Environment files configured
- [ ] Database connection tested
- [ ] Development servers running

### Verification Checklist
- [ ] Backend API accessible at `http://localhost:5000`
- [ ] Frontend application accessible at `http://localhost:3001`
- [ ] Database connection successful
- [ ] CRUD operations working
- [ ] Tests passing
- [ ] No console errors

## ⚡ Quick Commands

### Development Commands
```bash
# Start MongoDB (if local)
mongod

# Start Backend (in express-js-rest-api/)
npm install
npm run dev

# Start Frontend (in reactjs-18-front-end/)
npm install
npm start

# Run Tests
npm test

# Run E2E Tests
npm run test:e2e
```

### Docker Commands
```bash
# Build and start all services
docker-compose up --build

# Start services (after first build)
docker-compose up

# Stop services
docker-compose down

# View logs
docker-compose logs -f
```

## 🔧 Configuration Files

### Environment Files Required
```
express-js-rest-api/.env
├── MONGODB_URI=mongodb://localhost:27017/todoapp
├── PORT=5000
└── NODE_ENV=development

reactjs-18-front-end/.env
├── REACT_APP_API_URL=http://localhost:5000/api
└── PORT=3001
```

### Package.json Scripts
Each service includes these npm scripts:
- `start` - Production start
- `dev` - Development with hot reload
- `test` - Run test suite
- `build` - Production build
- `lint` - Code linting

## 🐛 Common Setup Issues

### Port Conflicts
- **Issue**: Port already in use
- **Solution**: Change ports in environment files
- **Default Ports**: Frontend (3001), Backend (5000), MongoDB (27017)

### Database Connection
- **Issue**: Cannot connect to MongoDB
- **Solutions**:
  - Ensure MongoDB is running
  - Check connection string in .env
  - Verify network connectivity

### CORS Errors
- **Issue**: Cross-origin request blocked
- **Solution**: Verify CORS configuration in backend
- **Check**: Frontend URL in CORS whitelist

### Dependency Issues
- **Issue**: npm install failures
- **Solutions**:
  - Clear npm cache: `npm cache clean --force`
  - Delete node_modules and reinstall
  - Check Node.js version compatibility

## 💡 Development Tips

### VS Code Setup
```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "typescript.preferences.importModuleSpecifier": "relative"
}
```

### Git Hooks
```bash
# Install husky for pre-commit hooks
npm install --save-dev husky
npx husky install
```

### Performance Optimization
- Use `npm ci` instead of `npm install` in production
- Enable React DevTools for debugging
- Use MongoDB Compass for database inspection

## 📁 Project Structure
```
reactjs-todo-application/
├── docs/                    # Documentation
├── reactjs-18-front-end/    # React frontend
├── express-js-rest-api/     # Express backend
├── mongo-db-docker-compose/ # MongoDB Docker setup
├── test-manual.js          # Manual testing script
├── test-crud.js           # CRUD testing script
└── README.md              # Project overview
```

---

*Next: [Development Environment Setup →](./development-setup.md)*