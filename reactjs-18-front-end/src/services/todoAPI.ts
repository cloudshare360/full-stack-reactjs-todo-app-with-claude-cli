import { Todo, CreateTodoRequest, UpdateTodoRequest } from '../types/Todo';

// Dynamic API URL detection for different environments
const getAPIBaseURL = (): string => {
  // Use environment variable if explicitly set
  if (process.env.REACT_APP_API_URL) {
    return process.env.REACT_APP_API_URL;
  }

  // Auto-detect environment
  const hostname = window.location.hostname;
  
  // GitHub Codespaces detection
  if (hostname.includes('.app.github.dev')) {
    // Replace the React port with API port
    const apiUrl = hostname.replace('-3001.app.github.dev', '-5000.app.github.dev');
    return `https://${apiUrl}/api`;
  }
  
  // Default to localhost for local development
  return 'http://localhost:5000/api';
};

const API_BASE_URL = getAPIBaseURL();

class TodoAPI {
  async getAllTodos(): Promise<Todo[]> {
    const response = await fetch(`${API_BASE_URL}/todos`);
    if (!response.ok) {
      throw new Error('Failed to fetch todos');
    }
    const result = await response.json();
    return result.data;
  }

  async getTodoById(id: string): Promise<Todo> {
    const response = await fetch(`${API_BASE_URL}/todos/${id}`);
    if (!response.ok) {
      throw new Error('Failed to fetch todo');
    }
    const result = await response.json();
    return result.data;
  }

  async createTodo(todo: CreateTodoRequest): Promise<Todo> {
    const response = await fetch(`${API_BASE_URL}/todos`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(todo),
    });

    if (!response.ok) {
      throw new Error('Failed to create todo');
    }

    const result = await response.json();
    return result.data;
  }

  async updateTodo(id: string, updates: UpdateTodoRequest): Promise<Todo> {
    const response = await fetch(`${API_BASE_URL}/todos/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(updates),
    });

    if (!response.ok) {
      throw new Error('Failed to update todo');
    }

    const result = await response.json();
    return result.data;
  }

  async deleteTodo(id: string): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/todos/${id}`, {
      method: 'DELETE',
    });

    if (!response.ok) {
      throw new Error('Failed to delete todo');
    }
  }
}

export const todoAPI = new TodoAPI();