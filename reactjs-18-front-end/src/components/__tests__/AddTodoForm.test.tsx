import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import AddTodoForm from '../AddTodoForm';
import { todoAPI } from '../../services/todoAPI';

// Mock the todoAPI
jest.mock('../../services/todoAPI');
const mockedTodoAPI = todoAPI as jest.Mocked<typeof todoAPI>;

describe('AddTodoForm', () => {
  const mockOnTodoAdded = jest.fn();

  beforeEach(() => {
    mockOnTodoAdded.mockClear();
    mockedTodoAPI.createTodo.mockClear();
  });

  test('renders form elements correctly', () => {
    render(<AddTodoForm onTodoAdded={mockOnTodoAdded} />);

    expect(screen.getByTestId('todo-input')).toBeInTheDocument();
    expect(screen.getByTestId('todo-description')).toBeInTheDocument();
    expect(screen.getByTestId('priority-select')).toBeInTheDocument();
    expect(screen.getByTestId('add-todo-btn')).toBeInTheDocument();

    expect(screen.getByText('Add New Todo')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('What needs to be done?')).toBeInTheDocument();
  });

  test('allows user to type in title input', async () => {
    const user = userEvent.setup();
    render(<AddTodoForm onTodoAdded={mockOnTodoAdded} />);

    const titleInput = screen.getByTestId('todo-input');
    await user.type(titleInput, 'Test Todo');

    expect(titleInput).toHaveValue('Test Todo');
  });

  test('allows user to select priority', async () => {
    const user = userEvent.setup();
    render(<AddTodoForm onTodoAdded={mockOnTodoAdded} />);

    const prioritySelect = screen.getByTestId('priority-select');
    await user.selectOptions(prioritySelect, 'high');

    expect(prioritySelect).toHaveValue('high');
  });

  test('submits form with correct data', async () => {
    const user = userEvent.setup();
    const mockTodo = {
      _id: '1',
      title: 'Test Todo',
      description: 'Test Description',
      priority: 'high' as const,
      completed: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    mockedTodoAPI.createTodo.mockResolvedValueOnce(mockTodo);

    render(<AddTodoForm onTodoAdded={mockOnTodoAdded} />);

    // Fill in form
    await user.type(screen.getByTestId('todo-input'), 'Test Todo');
    await user.type(screen.getByTestId('todo-description'), 'Test Description');
    await user.selectOptions(screen.getByTestId('priority-select'), 'high');

    // Submit form
    await user.click(screen.getByTestId('add-todo-btn'));

    await waitFor(() => {
      expect(mockedTodoAPI.createTodo).toHaveBeenCalledWith({
        title: 'Test Todo',
        description: 'Test Description',
        priority: 'high',
        completed: false
      });
      expect(mockOnTodoAdded).toHaveBeenCalledWith(mockTodo);
    });
  });

  test('clears form after successful submission', async () => {
    const user = userEvent.setup();
    const mockTodo = {
      _id: '1',
      title: 'Test Todo',
      description: '',
      priority: 'medium' as const,
      completed: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    mockedTodoAPI.createTodo.mockResolvedValueOnce(mockTodo);

    render(<AddTodoForm onTodoAdded={mockOnTodoAdded} />);

    const titleInput = screen.getByTestId('todo-input');
    const descriptionInput = screen.getByTestId('todo-description');

    // Fill in form
    await user.type(titleInput, 'Test Todo');
    await user.type(descriptionInput, 'Test Description');

    // Submit form
    await user.click(screen.getByTestId('add-todo-btn'));

    await waitFor(() => {
      expect(titleInput).toHaveValue('');
      expect(descriptionInput).toHaveValue('');
      expect(screen.getByTestId('priority-select')).toHaveValue('medium');
    });
  });

  test('disables submit button when title is empty', () => {
    render(<AddTodoForm onTodoAdded={mockOnTodoAdded} />);

    const submitButton = screen.getByTestId('add-todo-btn');
    expect(submitButton).toBeDisabled();
  });

  test('enables submit button when title has content', async () => {
    const user = userEvent.setup();
    render(<AddTodoForm onTodoAdded={mockOnTodoAdded} />);

    const titleInput = screen.getByTestId('todo-input');
    const submitButton = screen.getByTestId('add-todo-btn');

    await user.type(titleInput, 'Test Todo');
    expect(submitButton).not.toBeDisabled();
  });

  test('shows loading state during submission', async () => {
    const user = userEvent.setup();
    let resolveCreateTodo: (value: any) => void;
    const createTodoPromise = new Promise(resolve => {
      resolveCreateTodo = resolve;
    });

    mockedTodoAPI.createTodo.mockReturnValueOnce(createTodoPromise);

    render(<AddTodoForm onTodoAdded={mockOnTodoAdded} />);

    await user.type(screen.getByTestId('todo-input'), 'Test Todo');
    await user.click(screen.getByTestId('add-todo-btn'));

    expect(screen.getByText('Adding...')).toBeInTheDocument();
    expect(screen.getByTestId('add-todo-btn')).toBeDisabled();

    // Resolve the promise to complete the test
    resolveCreateTodo!({
      _id: '1',
      title: 'Test Todo',
      description: '',
      priority: 'medium',
      completed: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });
  });

  test('handles API error gracefully', async () => {
    const user = userEvent.setup();
    const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
    const alertSpy = jest.spyOn(window, 'alert').mockImplementation(() => {});

    mockedTodoAPI.createTodo.mockRejectedValueOnce(new Error('API Error'));

    render(<AddTodoForm onTodoAdded={mockOnTodoAdded} />);

    await user.type(screen.getByTestId('todo-input'), 'Test Todo');
    await user.click(screen.getByTestId('add-todo-btn'));

    await waitFor(() => {
      expect(consoleSpy).toHaveBeenCalledWith('Failed to create todo:', expect.any(Error));
      expect(alertSpy).toHaveBeenCalledWith('Failed to create todo. Please try again.');
    });

    consoleSpy.mockRestore();
    alertSpy.mockRestore();
  });

  test('respects maxLength constraints', async () => {
    const user = userEvent.setup();
    render(<AddTodoForm onTodoAdded={mockOnTodoAdded} />);

    const titleInput = screen.getByTestId('todo-input');
    const descriptionInput = screen.getByTestId('todo-description');

    expect(titleInput).toHaveAttribute('maxLength', '100');
    expect(descriptionInput).toHaveAttribute('maxLength', '500');
  });
});