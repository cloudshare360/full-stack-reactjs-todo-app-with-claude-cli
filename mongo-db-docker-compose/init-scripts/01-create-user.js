// Create database and user for the todo application
db = db.getSiblingDB('todoapp');

// Create a user for the todo application
db.createUser({
  user: 'todouser',
  pwd: 'todopass123',
  roles: [
    {
      role: 'readWrite',
      db: 'todoapp'
    }
  ]
});

// Create collections with validation
db.createCollection('todos', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['title'],
      properties: {
        title: {
          bsonType: 'string',
          description: 'Title is required and must be a string',
          maxLength: 100
        },
        description: {
          bsonType: 'string',
          description: 'Description must be a string',
          maxLength: 500
        },
        completed: {
          bsonType: 'bool',
          description: 'Completed must be a boolean'
        },
        priority: {
          enum: ['low', 'medium', 'high'],
          description: 'Priority must be low, medium, or high'
        },
        createdAt: {
          bsonType: 'date',
          description: 'Created date must be a date'
        },
        updatedAt: {
          bsonType: 'date',
          description: 'Updated date must be a date'
        }
      }
    }
  }
});

// Create indexes for better performance
db.todos.createIndex({ completed: 1 });
db.todos.createIndex({ priority: 1 });
db.todos.createIndex({ createdAt: -1 });
db.todos.createIndex({ title: 'text', description: 'text' });

print('Database todoapp initialized successfully!');
print('Created user: todouser');
print('Created collection: todos with validation schema');
print('Created indexes for optimal query performance');