import React, { useState, useCallback } from 'react';
import TodoList from './components/TodoList';
import AddTodoForm from './components/AddTodoForm';
import { Todo } from './types/Todo';
import './App.css';

function App() {
  const [refreshKey, setRefreshKey] = useState(0);

  const handleTodoAdded = useCallback((newTodo: Todo) => {
    // Trigger a refresh of the TodoList component
    setRefreshKey(prev => prev + 1);
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>React Todo App</h1>
        <p>Manage your tasks efficiently with this modern todo application</p>
      </header>

      <main className="App-main">
        <div className="container">
          <div className="add-todo-section">
            <AddTodoForm onTodoAdded={handleTodoAdded} />
          </div>

          <div className="todos-section">
            <h2>Your Todos</h2>
            <TodoList key={refreshKey} />
          </div>
        </div>
      </main>

      <footer className="App-footer">
        <p>Built with React 18, Express.js, and MongoDB</p>
      </footer>
    </div>
  );
}

export default App;
