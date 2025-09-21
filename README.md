# ReactJS Todo Full-Stack Application

A modern full-stack todo application built with React 18, Express.js, and MongoDB, featuring Docker containerization for easy development and deployment.

## 🚀 Features

- **React 18 Frontend**: Modern React application with TypeScript
- **Express.js REST API**: Robust backend with comprehensive error handling
- **MongoDB Database**: NoSQL database with proper indexing and validation
- **Docker Support**: Complete containerization with Docker Compose
- **Mongo Express**: Web-based MongoDB administration interface
- **Input Validation**: Both client-side and server-side validation
- **Responsive Design**: Mobile-friendly user interface
- **CRUD Operations**: Complete Create, Read, Update, Delete functionality
- **Priority System**: High, medium, and low priority todos
- **Search & Filter**: Find todos by completion status and priority
- **Backup & Restore**: Database backup and restoration tools

## 📁 Project Structure

```
reactjs-todo-application/
├── README.md                      # This file
├── REQUIREMENTS.md                # Project requirements
├── reactjs-18-front-end/         # React 18 frontend
│   ├── src/
│   │   ├── components/           # React components
│   │   ├── services/            # API service layer
│   │   ├── types/               # TypeScript definitions
│   │   └── App.tsx              # Main App component
│   ├── package.json
│   └── .env                     # Frontend environment variables
├── express-js-rest-api/          # Express.js backend
│   ├── src/
│   │   ├── config/              # Database configuration
│   │   ├── controllers/         # Request handlers
│   │   ├── middleware/          # Custom middleware
│   │   ├── models/              # MongoDB models
│   │   └── routes/              # API routes
│   ├── server.js                # Main server file
│   ├── package.json
│   └── .env                     # Backend environment variables
└── mongo-db-docker-compose/      # MongoDB setup
    ├── docker-compose.yml       # Docker services configuration
    ├── init-scripts/            # Database initialization scripts
    ├── seed-data/               # Sample data for testing
    ├── scripts/                 # Shell scripts for database operations
    └── .env                     # Database environment variables
```

## 🛠 Technology Stack

### Frontend
- **React 18** - Latest React with concurrent features
- **TypeScript** - Type safety and better developer experience
- **CSS3** - Modern styling with flexbox and grid
- **Fetch API** - HTTP client for API communication

### Backend
- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **MongoDB** - NoSQL database
- **Mongoose** - MongoDB object modeling
- **Express Validator** - Input validation middleware
- **Helmet** - Security middleware
- **CORS** - Cross-origin resource sharing
- **Morgan** - HTTP request logger

### Infrastructure
- **Docker** - Containerization platform
- **Docker Compose** - Multi-container orchestration
- **Mongo Express** - Web-based MongoDB admin interface

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Node.js 18+ (for local development)
- Git

### 1. Clone the Repository
```bash
git clone <repository-url>
cd reactjs-todo-application
```

### 2. Start MongoDB Services
```bash
cd mongo-db-docker-compose
./scripts/start-mongodb.sh
```

### 3. Start Backend API
```bash
cd ../express-js-rest-api
npm install
npm run dev
```

### 4. Start Frontend Application
```bash
cd ../reactjs-18-front-end
npm install
npm start
```

### 5. Access the Applications
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000
- **Mongo Express**: http://localhost:8081 (admin/admin123)

## 📊 API Endpoints

### Todos
- `GET /api/todos` - Get all todos
  - Query parameters: `completed`, `priority`, `sort`
- `POST /api/todos` - Create a new todo
- `GET /api/todos/:id` - Get a specific todo
- `PUT /api/todos/:id` - Update a todo
- `DELETE /api/todos/:id` - Delete a todo
- `GET /api/todos/stats` - Get todos statistics

### System
- `GET /api/health` - Health check endpoint
- `GET /` - API information and endpoints

## 🗄 Database Schema

```javascript
Todo {
  _id: ObjectId,
  title: String (required, max: 100),
  description: String (optional, max: 500),
  completed: Boolean (default: false),
  priority: String (enum: ['low', 'medium', 'high'], default: 'medium'),
  createdAt: Date,
  updatedAt: Date
}
```

## 🐳 Docker Services

The application uses Docker Compose to orchestrate the following services:

### MongoDB
- **Image**: mongo:7.0
- **Port**: 27017
- **Authentication**: Enabled
- **Persistent Storage**: Docker volume

### Mongo Express
- **Image**: mongo-express:1.0.2
- **Port**: 8081
- **Authentication**: admin/admin123

## 🔧 Database Operations

### Start Services
```bash
./scripts/start-mongodb.sh
```

### Load Sample Data
```bash
./scripts/seed-data.sh
```

### Backup Database
```bash
./scripts/backup-data.sh
```

### Restore Database
```bash
./scripts/restore-data.sh <backup-file>
```

### Stop Services
```bash
./scripts/stop-mongodb.sh
```

## 🔒 Security Features

- **Helmet**: Security headers middleware
- **CORS**: Properly configured cross-origin resource sharing
- **Input Validation**: Server-side validation using express-validator
- **MongoDB Authentication**: Database access control
- **Error Handling**: Comprehensive error handling without exposing sensitive data

## 🧪 Testing

### Frontend
```bash
cd reactjs-18-front-end
npm test
```

### Backend
```bash
cd express-js-rest-api
npm test
```

## 🔍 Environment Variables

### Frontend (.env)
```
REACT_APP_API_URL=http://localhost:5000/api
```

### Backend (.env)
```
PORT=5000
MONGODB_URI=mongodb://localhost:27017/todoapp
NODE_ENV=development
```

### Database (.env)
```
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=password123
MONGO_INITDB_DATABASE=todoapp
```

## 📱 Usage Examples

### Create a Todo
```javascript
POST /api/todos
{
  "title": "Learn React 18",
  "description": "Study new concurrent features",
  "priority": "high"
}
```

### Update a Todo
```javascript
PUT /api/todos/:id
{
  "completed": true,
  "priority": "medium"
}
```

### Filter Todos
```
GET /api/todos?completed=false&priority=high&sort=-createdAt
```

## 🐛 Troubleshooting

### MongoDB Connection Issues
1. Ensure Docker is running
2. Check if MongoDB container is running: `docker ps`
3. Verify environment variables in `.env` files
4. Check logs: `docker-compose logs mongodb`

### API Connection Issues
1. Verify backend is running on port 5000
2. Check CORS configuration
3. Ensure MongoDB is accessible from the backend

### Frontend Issues
1. Check if API URL is correct in `.env`
2. Verify backend is responding: `curl http://localhost:5000/api/health`
3. Check browser console for errors

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the ISC License.

## 📞 Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review the logs using Docker Compose

---

Made with ❤️ using React 18, Express.js, and MongoDB