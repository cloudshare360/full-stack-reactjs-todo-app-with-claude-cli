// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('API Integration Tests', () => {
  const API_BASE = 'http://localhost:5000/api';

  test('should verify backend API is running', async ({ request }) => {
    const response = await request.get(`${API_BASE}/health`);
    expect(response.status()).toBe(200);

    const healthData = await response.json();
    expect(healthData.success).toBe(true);
    expect(healthData.message).toContain('API is running');
  });

  test('should fetch todos from API', async ({ request }) => {
    const response = await request.get(`${API_BASE}/todos`);
    expect(response.status()).toBe(200);

    const todosData = await response.json();
    expect(todosData.success).toBe(true);
    expect(todosData.data).toBeInstanceOf(Array);
    expect(todosData.count).toBeGreaterThan(0);
  });

  test('should create todo via API', async ({ request }) => {
    const newTodo = {
      title: 'API Test Todo',
      description: 'Created via Playwright API test',
      priority: 'medium',
      completed: false
    };

    const response = await request.post(`${API_BASE}/todos`, {
      data: newTodo
    });

    expect(response.status()).toBe(201);

    const createdTodo = await response.json();
    expect(createdTodo.success).toBe(true);
    expect(createdTodo.data.title).toBe(newTodo.title);
    expect(createdTodo.data._id).toBeTruthy();
  });

  test('should update todo via API', async ({ request }) => {
    // First create a todo
    const newTodo = {
      title: 'Todo to Update',
      completed: false
    };

    const createResponse = await request.post(`${API_BASE}/todos`, {
      data: newTodo
    });

    const createdTodo = await createResponse.json();
    const todoId = createdTodo.data._id;

    // Update the todo
    const updateData = {
      completed: true,
      title: 'Updated Todo Title'
    };

    const updateResponse = await request.put(`${API_BASE}/todos/${todoId}`, {
      data: updateData
    });

    expect(updateResponse.status()).toBe(200);

    const updatedTodo = await updateResponse.json();
    expect(updatedTodo.success).toBe(true);
    expect(updatedTodo.data.completed).toBe(true);
    expect(updatedTodo.data.title).toBe('Updated Todo Title');
  });

  test('should delete todo via API', async ({ request }) => {
    // First create a todo
    const newTodo = {
      title: 'Todo to Delete',
      completed: false
    };

    const createResponse = await request.post(`${API_BASE}/todos`, {
      data: newTodo
    });

    const createdTodo = await createResponse.json();
    const todoId = createdTodo.data._id;

    // Delete the todo
    const deleteResponse = await request.delete(`${API_BASE}/todos/${todoId}`);
    expect(deleteResponse.status()).toBe(200);

    const deleteResult = await deleteResponse.json();
    expect(deleteResult.success).toBe(true);
    expect(deleteResult.message).toContain('deleted successfully');
  });

  test('should get todo statistics', async ({ request }) => {
    const response = await request.get(`${API_BASE}/todos/stats`);
    expect(response.status()).toBe(200);

    const statsData = await response.json();
    expect(statsData.success).toBe(true);
    expect(statsData.data).toHaveProperty('total');
    expect(statsData.data).toHaveProperty('completed');
    expect(statsData.data).toHaveProperty('pending');
    expect(statsData.data).toHaveProperty('byPriority');
  });

  test('should handle API errors gracefully', async ({ request }) => {
    // Try to get non-existent todo
    const response = await request.get(`${API_BASE}/todos/nonexistent-id`);
    expect(response.status()).toBe(404);

    const errorData = await response.json();
    expect(errorData.success).toBe(false);
    expect(errorData.error).toBeTruthy();
  });

  test('should validate todo creation', async ({ request }) => {
    // Try to create todo without required title
    const invalidTodo = {
      description: 'No title provided',
      priority: 'low'
    };

    const response = await request.post(`${API_BASE}/todos`, {
      data: invalidTodo
    });

    expect(response.status()).toBe(400);

    const errorData = await response.json();
    expect(errorData.success).toBe(false);
    expect(errorData.error).toContain('Validation Error');
  });

  test('should filter todos by completion status', async ({ request }) => {
    // Get completed todos
    const completedResponse = await request.get(`${API_BASE}/todos?completed=true`);
    expect(completedResponse.status()).toBe(200);

    const completedData = await completedResponse.json();
    expect(completedData.success).toBe(true);

    // Verify all returned todos are completed
    completedData.data.forEach(todo => {
      expect(todo.completed).toBe(true);
    });

    // Get pending todos
    const pendingResponse = await request.get(`${API_BASE}/todos?completed=false`);
    expect(pendingResponse.status()).toBe(200);

    const pendingData = await pendingResponse.json();
    expect(pendingData.success).toBe(true);

    // Verify all returned todos are not completed
    pendingData.data.forEach(todo => {
      expect(todo.completed).toBe(false);
    });
  });
});