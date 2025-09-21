import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import TodoItem from '../TodoItem';
import { Todo } from '../../types/Todo';

describe('TodoItem', () => {
  const mockTodo: Todo = {
    _id: '1',
    title: 'Test Todo',
    description: 'Test Description',
    completed: false,
    priority: 'medium',
    createdAt: '2025-01-01T00:00:00.000Z',
    updatedAt: '2025-01-01T00:00:00.000Z'
  };

  const mockProps = {
    todo: mockTodo,
    onToggleComplete: jest.fn(),
    onDelete: jest.fn(),
    onUpdate: jest.fn()
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders todo item correctly', () => {
    render(<TodoItem {...mockProps} />);

    expect(screen.getByTestId('todo-item')).toBeInTheDocument();
    expect(screen.getByTestId('todo-title')).toHaveTextContent('Test Todo');
    expect(screen.getByText('Test Description')).toBeInTheDocument();
    expect(screen.getByTestId('todo-checkbox')).toBeInTheDocument();
    expect(screen.getByTestId('edit-btn')).toBeInTheDocument();
    expect(screen.getByTestId('delete-btn')).toBeInTheDocument();
  });

  test('displays priority correctly', () => {
    render(<TodoItem {...mockProps} />);
    expect(screen.getByText('Priority: medium')).toBeInTheDocument();
  });

  test('displays creation date', () => {
    render(<TodoItem {...mockProps} />);
    expect(screen.getByText(/Created:/)).toBeInTheDocument();
  });

  test('calls onToggleComplete when checkbox is clicked', async () => {
    const user = userEvent.setup();
    render(<TodoItem {...mockProps} />);

    const checkbox = screen.getByTestId('todo-checkbox');
    await user.click(checkbox);

    expect(mockProps.onToggleComplete).toHaveBeenCalledWith('1', true);
  });

  test('calls onDelete when delete button is clicked', async () => {
    const user = userEvent.setup();
    render(<TodoItem {...mockProps} />);

    const deleteButton = screen.getByTestId('delete-btn');
    await user.click(deleteButton);

    expect(mockProps.onDelete).toHaveBeenCalledWith('1');
  });

  test('enters edit mode when edit button is clicked', async () => {
    const user = userEvent.setup();
    render(<TodoItem {...mockProps} />);

    const editButton = screen.getByTestId('edit-btn');
    await user.click(editButton);

    // In edit mode, we should see input fields instead of display text
    expect(screen.getByDisplayValue('Test Todo')).toBeInTheDocument();
    expect(screen.getByDisplayValue('Test Description')).toBeInTheDocument();
    expect(screen.getByText('Save')).toBeInTheDocument();
    expect(screen.getByText('Cancel')).toBeInTheDocument();
  });

  test('saves changes in edit mode', async () => {
    const user = userEvent.setup();
    render(<TodoItem {...mockProps} />);

    // Enter edit mode
    await user.click(screen.getByTestId('edit-btn'));

    // Edit the title
    const titleInput = screen.getByDisplayValue('Test Todo');
    await user.clear(titleInput);
    await user.type(titleInput, 'Updated Todo');

    // Save changes
    await user.click(screen.getByText('Save'));

    expect(mockProps.onUpdate).toHaveBeenCalledWith('1', {
      title: 'Updated Todo',
      description: 'Test Description'
    });
  });

  test('cancels edit mode without saving changes', async () => {
    const user = userEvent.setup();
    render(<TodoItem {...mockProps} />);

    // Enter edit mode
    await user.click(screen.getByTestId('edit-btn'));

    // Edit the title
    const titleInput = screen.getByDisplayValue('Test Todo');
    await user.clear(titleInput);
    await user.type(titleInput, 'Changed Title');

    // Cancel changes
    await user.click(screen.getByText('Cancel'));

    // Should exit edit mode and not call onUpdate
    expect(screen.getByTestId('todo-title')).toHaveTextContent('Test Todo');
    expect(mockProps.onUpdate).not.toHaveBeenCalled();
  });

  test('applies completed styling when todo is completed', () => {
    const completedTodo = { ...mockTodo, completed: true };
    render(<TodoItem {...mockProps} todo={completedTodo} />);

    const todoItem = screen.getByTestId('todo-item');
    expect(todoItem).toHaveClass('completed');

    const checkbox = screen.getByTestId('todo-checkbox');
    expect(checkbox).toBeChecked();
  });

  test('shows correct priority color', () => {
    const { rerender } = render(<TodoItem {...mockProps} />);

    // Test different priorities
    const priorities: Array<'high' | 'medium' | 'low'> = ['high', 'medium', 'low'];
    const expectedColors = ['#ff4757', '#ffa502', '#26de81'];

    priorities.forEach((priority, index) => {
      const todoWithPriority = { ...mockTodo, priority };
      rerender(<TodoItem {...mockProps} todo={todoWithPriority} />);

      const priorityIndicator = document.querySelector('.priority-indicator');
      expect(priorityIndicator).toHaveStyle(`background-color: ${expectedColors[index]}`);
    });
  });

  test('handles todo without description', () => {
    const todoWithoutDescription = { ...mockTodo, description: undefined };
    render(<TodoItem {...mockProps} todo={todoWithoutDescription} />);

    expect(screen.getByTestId('todo-title')).toHaveTextContent('Test Todo');
    expect(screen.queryByText('Test Description')).not.toBeInTheDocument();
  });

  test('checkbox reflects completed state', () => {
    const { rerender } = render(<TodoItem {...mockProps} />);

    // Initially not completed
    let checkbox = screen.getByTestId('todo-checkbox');
    expect(checkbox).not.toBeChecked();

    // Rerender with completed todo
    const completedTodo = { ...mockTodo, completed: true };
    rerender(<TodoItem {...mockProps} todo={completedTodo} />);

    checkbox = screen.getByTestId('todo-checkbox');
    expect(checkbox).toBeChecked();
  });

  test('edit form validation handles empty title', async () => {
    const user = userEvent.setup();
    render(<TodoItem {...mockProps} />);

    // Enter edit mode
    await user.click(screen.getByTestId('edit-btn'));

    // Clear the title
    const titleInput = screen.getByDisplayValue('Test Todo');
    await user.clear(titleInput);

    // Try to save
    await user.click(screen.getByText('Save'));

    // Should still call onUpdate even with empty title (validation should be on server side)
    expect(mockProps.onUpdate).toHaveBeenCalledWith('1', {
      title: '',
      description: 'Test Description'
    });
  });
});