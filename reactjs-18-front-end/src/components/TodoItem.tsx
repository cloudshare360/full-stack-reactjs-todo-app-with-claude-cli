import React, { useState } from 'react';
import { Todo } from '../types/Todo';

interface TodoItemProps {
  todo: Todo;
  onToggleComplete: (id: string, completed: boolean) => void;
  onDelete: (id: string) => void;
  onUpdate: (id: string, updates: Partial<Todo>) => void;
}

const TodoItem: React.FC<TodoItemProps> = ({
  todo,
  onToggleComplete,
  onDelete,
  onUpdate
}) => {
  const [isEditing, setIsEditing] = useState(false);
  const [editTitle, setEditTitle] = useState(todo.title);
  const [editDescription, setEditDescription] = useState(todo.description || '');

  const handleSave = () => {
    onUpdate(todo._id, {
      title: editTitle,
      description: editDescription
    });
    setIsEditing(false);
  };

  const handleCancel = () => {
    setEditTitle(todo.title);
    setEditDescription(todo.description || '');
    setIsEditing(false);
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high':
        return '#ff4757';
      case 'medium':
        return '#ffa502';
      case 'low':
        return '#26de81';
      default:
        return '#747d8c';
    }
  };

  return (
    <div className={`todo-item ${todo.completed ? 'completed' : ''}`} data-testid="todo-item">
      <div className="todo-content">
        <div className="todo-header">
          <input
            type="checkbox"
            checked={todo.completed}
            onChange={(e) => onToggleComplete(todo._id, e.target.checked)}
            className="todo-checkbox"
            data-testid="todo-checkbox"
          />
          <div
            className="priority-indicator"
            style={{ backgroundColor: getPriorityColor(todo.priority) }}
          />
        </div>

        {isEditing ? (
          <div className="edit-form">
            <input
              type="text"
              value={editTitle}
              onChange={(e) => setEditTitle(e.target.value)}
              className="edit-title-input"
              placeholder="Todo title"
            />
            <textarea
              value={editDescription}
              onChange={(e) => setEditDescription(e.target.value)}
              className="edit-description-input"
              placeholder="Description (optional)"
              rows={2}
            />
            <div className="edit-buttons">
              <button onClick={handleSave} className="save-btn">Save</button>
              <button onClick={handleCancel} className="cancel-btn">Cancel</button>
            </div>
          </div>
        ) : (
          <div className="todo-details">
            <h3 className="todo-title" data-testid="todo-title">{todo.title}</h3>
            {todo.description && (
              <p className="todo-description">{todo.description}</p>
            )}
            <div className="todo-meta">
              <span className="priority">Priority: {todo.priority}</span>
              <span className="created-date">
                Created: {new Date(todo.createdAt).toLocaleDateString()}
              </span>
            </div>
          </div>
        )}

        <div className="todo-actions">
          {!isEditing && (
            <>
              <button onClick={() => setIsEditing(true)} className="edit-btn" data-testid="edit-btn">
                Edit
              </button>
              <button onClick={() => onDelete(todo._id)} className="delete-btn" data-testid="delete-btn">
                Delete
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default TodoItem;