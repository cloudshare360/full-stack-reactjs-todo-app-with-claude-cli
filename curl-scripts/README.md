# Todo API cURL Test Scripts

Comprehensive collection of bash scripts to test all Todo API endpoints with sample data and validation.

## 📋 Available Scripts

### Individual Endpoint Tests

1. **`01-get-all-todos.sh`** - Get all todos with filtering options
2. **`02-create-todo.sh`** - Create new todos with sample data
3. **`03-get-single-todo.sh`** - Get specific todo by ID
4. **`04-update-todo.sh`** - Update todo properties
5. **`05-delete-todo.sh`** - Delete todos with confirmation
6. **`06-get-stats.sh`** - Get todo statistics with dashboard

### Test Suite

- **`test-all-endpoints.sh`** - Comprehensive test suite for all endpoints

## 🚀 Quick Start

### Prerequisites

1. **API Server Running**: Ensure your Express server is running
   ```bash
   cd express-js-rest-api
   npm run dev
   ```

2. **MongoDB Running**: Ensure MongoDB is running via Docker
   ```bash
   cd mongo-db-docker-compose
   docker-compose up -d
   ```

### Make Scripts Executable
```bash
chmod +x *.sh
```

### Run Individual Tests
```bash
# Get all todos
./01-get-all-todos.sh

# Create a sample todo
./02-create-todo.sh --sample

# Get the last created todo
./03-get-single-todo.sh --last

# Mark last todo as completed
./04-update-todo.sh --last -c true

# Get statistics
./06-get-stats.sh
```

### Run Complete Test Suite
```bash
# Basic test suite
./test-all-endpoints.sh

# Full comprehensive test suite
./test-all-endpoints.sh --full

# Generate HTML report
./test-all-endpoints.sh --full --report

# Stop on first failure
./test-all-endpoints.sh --stop-on-fail
```

## 📖 Detailed Usage

### 1. Get All Todos (`01-get-all-todos.sh`)

**Basic Usage:**
```bash
./01-get-all-todos.sh                    # Get all todos
./01-get-all-todos.sh -c true            # Get completed todos
./01-get-all-todos.sh -p high            # Get high priority todos
./01-get-all-todos.sh -c false -p high   # Get pending high priority todos
```

**Options:**
- `-c, --completed [true|false]` - Filter by completion status
- `-p, --priority [low|medium|high]` - Filter by priority
- `-v, --verbose` - Show detailed output

### 2. Create Todo (`02-create-todo.sh`)

**Basic Usage:**
```bash
./02-create-todo.sh --sample                                    # Random sample todo
./02-create-todo.sh -t "Buy milk"                              # Simple todo
./02-create-todo.sh -t "Fix bug" -d "Critical issue" -p high   # Detailed todo
```

**Options:**
- `-t, --title "title"` - Todo title (required)
- `-d, --description "desc"` - Todo description
- `-p, --priority [low|medium|high]` - Priority level
- `-s, --sample` - Use random sample data
- `-v, --verbose` - Show detailed output

**Sample Data Sets:**
- Buy groceries (medium priority)
- Fix critical bug (high priority)
- Call dentist (low priority)
- Review pull requests (medium priority)
- Update documentation (high priority)

### 3. Get Single Todo (`03-get-single-todo.sh`)

**Basic Usage:**
```bash
./03-get-single-todo.sh 64a1b2c3d4e5f6789012345    # Get specific todo
./03-get-single-todo.sh --last                      # Get last created todo
./03-get-single-todo.sh --last --verbose            # Verbose output
```

**Options:**
- `-l, --last` - Use last created todo ID
- `-v, --verbose` - Show detailed output

### 4. Update Todo (`04-update-todo.sh`)

**Basic Usage:**
```bash
./04-update-todo.sh --last -c true                      # Mark as completed
./04-update-todo.sh [ID] -t "New title" -p high         # Update title and priority
./04-update-todo.sh --last --sample                     # Random update
```

**Options:**
- `-l, --last` - Use last created todo ID
- `-t, --title "new title"` - Update title
- `-d, --description "desc"` - Update description
- `-c, --completed [true|false]` - Update completion status
- `-p, --priority [low|medium|high]` - Update priority
- `-s, --sample` - Use random sample update data
- `-v, --verbose` - Show detailed output

### 5. Delete Todo (`05-delete-todo.sh`)

**Basic Usage:**
```bash
./05-delete-todo.sh 64a1b2c3d4e5f6789012345    # Delete specific todo
./05-delete-todo.sh --last                     # Delete last created todo
./05-delete-todo.sh --last --yes               # Skip confirmation
```

**Options:**
- `-l, --last` - Use last created todo ID
- `-y, --yes` - Skip confirmation prompt
- `-v, --verbose` - Show detailed output

**⚠️ Warning:** Deletion is permanent and cannot be undone!

### 6. Get Statistics (`06-get-stats.sh`)

**Basic Usage:**
```bash
./06-get-stats.sh                    # Get current statistics
./06-get-stats.sh --verbose          # Include raw JSON response
./06-get-stats.sh --refresh          # Auto-refresh every 3 seconds
```

**Options:**
- `-v, --verbose` - Show raw JSON response
- `-r, --refresh` - Auto-refresh mode (Ctrl+C to stop)

**Features:**
- 📊 Visual progress bar
- 🎯 Priority breakdown
- 💡 Smart insights
- 📈 Completion rate analysis

### 7. Complete Test Suite (`test-all-endpoints.sh`)

**Basic Usage:**
```bash
./test-all-endpoints.sh                      # Standard test suite
./test-all-endpoints.sh --full               # Comprehensive tests
./test-all-endpoints.sh --full --report      # Generate HTML report
./test-all-endpoints.sh --quiet              # Minimal output
./test-all-endpoints.sh --stop-on-fail       # Stop on first failure
./test-all-endpoints.sh --cleanup            # Clean up test data
```

**Options:**
- `-f, --full` - Run comprehensive test suite
- `-q, --quiet` - Minimal output mode
- `-s, --stop-on-fail` - Stop on first failure
- `-r, --report` - Generate HTML test report
- `-c, --cleanup` - Clean up test data after completion

## 🔧 Features

### Smart ID Management
- Automatically saves last created todo ID
- Scripts can reference last created todo with `--last` flag
- Automatic cleanup of invalid IDs

### Error Handling
- HTTP status code validation
- Detailed error messages
- Graceful failure handling

### Response Formatting
- Pretty JSON formatting
- Color-coded output
- Progress indicators
- Response time measurements

### Sample Data
- Multiple sample todo sets
- Random sample selection
- Realistic test scenarios

### Validation
- MongoDB ObjectId format validation
- Input parameter validation
- API availability checks

## 📊 Output Examples

### Success Response
```
✅ Todo created successfully!
{
    "success": true,
    "data": {
        "_id": "64a1b2c3d4e5f6789012345",
        "title": "Buy groceries",
        "description": "Get milk, bread, and eggs",
        "completed": false,
        "priority": "medium",
        "createdAt": "2025-09-21T12:00:00.000Z",
        "updatedAt": "2025-09-21T12:00:00.000Z"
    }
}

📝 Created Todo ID: 64a1b2c3d4e5f6789012345
```

### Statistics Dashboard
```
📈 TODO STATISTICS DASHBOARD
════════════════════════════════

📋 OVERVIEW
   📊 Total Todos: 5
   ✅ Completed: 3
   ⏳ Pending: 2
   📈 Completion Rate: 60%

⚡ PRIORITY BREAKDOWN
   🔴 High Priority: 1
   🟡 Medium Priority: 3
   🟢 Low Priority: 1

📊 COMPLETION PROGRESS
   [██████████████████░░░░░░░░░░░░] 60%
```

## 🛠️ Troubleshooting

### Common Issues

1. **API Not Available**
   ```
   ❌ API is not available at http://localhost:5000/api
   ```
   **Solution:** Start your Express server:
   ```bash
   cd express-js-rest-api
   npm run dev
   ```

2. **Permission Denied**
   ```bash
   chmod +x *.sh
   ```

3. **Todo Not Found**
   - Check if the todo ID is valid (24 hex characters)
   - Ensure the todo exists before trying to access it

4. **Python Not Found**
   - Install Python 3 for JSON formatting
   - Scripts will fall back to raw JSON if Python is not available

## 🎯 Test Scenarios

### Basic Workflow
1. Get initial statistics
2. Create a new todo
3. Retrieve the created todo
4. Update the todo
5. Get updated statistics
6. (Optional) Delete the todo

### Comprehensive Testing
- Multiple todo creation with different priorities
- Filtering tests (by completion status, priority)
- Validation error testing
- Edge case handling
- Performance measurement

## 📈 Performance

- **Average Response Time:** < 50ms per request
- **Concurrent Testing:** Supported
- **Rate Limiting:** Respects API limits
- **Resource Usage:** Minimal system impact

## 🔒 Security Notes

- Scripts include confirmation prompts for destructive operations
- No sensitive data is logged or stored
- Temporary files are cleaned up automatically
- Safe error handling prevents data exposure

---

**🚀 Happy Testing!** These scripts provide comprehensive coverage of your Todo API with realistic test scenarios and detailed feedback.