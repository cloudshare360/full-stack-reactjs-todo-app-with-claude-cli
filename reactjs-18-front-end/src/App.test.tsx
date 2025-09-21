import React from 'react';
import { render, screen } from '@testing-library/react';
import App from './App';

test('renders todo app correctly', () => {
  render(<App />);
  const appTitle = screen.getByText(/React Todo App/i);
  expect(appTitle).toBeInTheDocument();

  const addTodoSection = screen.getByText(/Add New Todo/i);
  expect(addTodoSection).toBeInTheDocument();

  const todosSection = screen.getByText(/Your Todos/i);
  expect(todosSection).toBeInTheDocument();
});
