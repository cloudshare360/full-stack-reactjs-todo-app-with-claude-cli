// Switch to todoapp database
db = db.getSiblingDB('todoapp');

// Read and insert sample todos
const sampleTodos = [
  {
    title: "Learn React 18 new features",
    description: "Study concurrent features, Suspense, automatic batching, and other React 18 improvements",
    completed: false,
    priority: "high",
    createdAt: new Date("2025-01-01T08:00:00.000Z"),
    updatedAt: new Date("2025-01-01T08:00:00.000Z")
  },
  {
    title: "Setup development environment",
    description: "Configure Node.js, MongoDB, and Docker for the todo application",
    completed: true,
    priority: "high",
    createdAt: new Date("2024-12-28T10:00:00.000Z"),
    updatedAt: new Date("2025-01-01T12:00:00.000Z")
  },
  {
    title: "Implement REST API endpoints",
    description: "Create CRUD operations for todos using Express.js and MongoDB",
    completed: true,
    priority: "high",
    createdAt: new Date("2024-12-29T09:00:00.000Z"),
    updatedAt: new Date("2025-01-02T14:00:00.000Z")
  },
  {
    title: "Design responsive UI components",
    description: "Create modern and accessible todo list components with React",
    completed: false,
    priority: "medium",
    createdAt: new Date("2025-01-02T11:00:00.000Z"),
    updatedAt: new Date("2025-01-02T11:00:00.000Z")
  },
  {
    title: "Add input validation",
    description: "Implement both client-side and server-side validation for todo forms",
    completed: false,
    priority: "medium",
    createdAt: new Date("2025-01-02T15:00:00.000Z"),
    updatedAt: new Date("2025-01-02T15:00:00.000Z")
  },
  {
    title: "Write unit tests",
    description: "Create comprehensive test coverage for API endpoints and React components",
    completed: false,
    priority: "medium",
    createdAt: new Date("2025-01-03T09:00:00.000Z"),
    updatedAt: new Date("2025-01-03T09:00:00.000Z")
  },
  {
    title: "Setup CI/CD pipeline",
    description: "Configure automated testing and deployment using GitHub Actions",
    completed: false,
    priority: "low",
    createdAt: new Date("2025-01-03T16:00:00.000Z"),
    updatedAt: new Date("2025-01-03T16:00:00.000Z")
  },
  {
    title: "Optimize database queries",
    description: "Add proper indexing and optimize MongoDB queries for better performance",
    completed: false,
    priority: "low",
    createdAt: new Date("2025-01-04T10:00:00.000Z"),
    updatedAt: new Date("2025-01-04T10:00:00.000Z")
  },
  {
    title: "Add search functionality",
    description: "Implement text search across todo titles and descriptions",
    completed: false,
    priority: "low",
    createdAt: new Date("2025-01-04T14:00:00.000Z"),
    updatedAt: new Date("2025-01-04T14:00:00.000Z")
  },
  {
    title: "Create user documentation",
    description: "Write README and API documentation for the todo application",
    completed: false,
    priority: "low",
    createdAt: new Date("2025-01-05T08:00:00.000Z"),
    updatedAt: new Date("2025-01-05T08:00:00.000Z")
  }
];

try {
  // Insert sample todos
  const result = db.todos.insertMany(sampleTodos);
  print(`Successfully inserted ${result.insertedIds.length} sample todos`);

  // Show some statistics
  const stats = {
    total: db.todos.countDocuments(),
    completed: db.todos.countDocuments({ completed: true }),
    pending: db.todos.countDocuments({ completed: false }),
    high_priority: db.todos.countDocuments({ priority: "high" }),
    medium_priority: db.todos.countDocuments({ priority: "medium" }),
    low_priority: db.todos.countDocuments({ priority: "low" })
  };

  print('Database seeded successfully!');
  print('Statistics:');
  print(`- Total todos: ${stats.total}`);
  print(`- Completed: ${stats.completed}`);
  print(`- Pending: ${stats.pending}`);
  print(`- High priority: ${stats.high_priority}`);
  print(`- Medium priority: ${stats.medium_priority}`);
  print(`- Low priority: ${stats.low_priority}`);

} catch (error) {
  print('Error seeding database:');
  print(error);
}