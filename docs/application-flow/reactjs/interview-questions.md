# React.js Interview Questions - Todo Application

## Basic React Concepts

### 1. Component Architecture & Design

**Q: Explain the component hierarchy in this Todo application. Why is it structured this way?**
**A:** The application follows a hierarchical structure:
- **App (Root)**: Manages global state (refreshKey) and coordinates child components
- **AddTodoForm**: Handles todo creation with form state management
- **TodoList**: Manages todo display, fetching, and CRUD operations
- **TodoItem**: Individual todo with inline editing capabilities

This structure follows single responsibility principle where each component has a specific purpose and promotes reusability.

**Q: How does the App component coordinate between AddTodoForm and TodoList?**
**A:** The App component uses a callback pattern:
```typescript
const handleTodoAdded = useCallback((newTodo: Todo) => {
  setRefreshKey(prev => prev + 1);
}, []);
```
When a todo is added, it increments `refreshKey`, which forces TodoList to remount and fetch fresh data.

### 2. State Management

**Q: Why does the application use local state instead of Context API or Redux?**
**A:** The application requirements are simple with minimal state sharing:
- Form state is local to AddTodoForm
- Todo list state is local to TodoList
- Only coordination needed is refresh trigger (handled by callback)
- This follows the principle of "start simple and add complexity when needed"

**Q: Explain the refreshKey pattern. Why not just call a refresh function directly?**
**A:** The refreshKey pattern offers several advantages:
```typescript
// Force component remount and fresh data fetch
<TodoList key={refreshKey} />
```
- **Clean separation**: No need to pass refresh functions down
- **React lifecycle**: Leverages React's natural mounting behavior
- **Consistent state**: Ensures TodoList starts with clean state
- **Error recovery**: Clears any error states from previous renders

### 3. Hooks Usage

**Q: How is useEffect used in the TodoList component? What are the dependencies?**
**A:** 
```typescript
useEffect(() => {
  fetchTodos();
}, []); // Empty dependency array
```
- Runs once on component mount (due to empty deps)
- When key changes, component remounts, so useEffect runs again
- This pattern ensures fresh data on both initial load and after todo creation

**Q: Why use useCallback for handleTodoAdded in App component?**
**A:**
```typescript
const handleTodoAdded = useCallback((newTodo: Todo) => {
  setRefreshKey(prev => prev + 1);
}, []);
```
- Prevents unnecessary re-renders of AddTodoForm
- Maintains referential equality across App re-renders
- Good practice for callback props to child components

### 4. Form Handling

**Q: Explain the controlled component pattern used in AddTodoForm.**
**A:** All form inputs are controlled by component state:
```typescript
const [title, setTitle] = useState('');
const [description, setDescription] = useState('');

<input
  value={title}
  onChange={(e) => setTitle(e.target.value)}
/>
```
- Single source of truth for form data
- Real-time validation possible
- Easy to reset form after submission

**Q: How does form validation work in this application?**
**A:** Multi-layered validation:
- **Client-side**: `!title.trim()` prevents empty submissions
- **Visual feedback**: Button disabled when invalid
- **Server-side**: Express-validator provides backend validation
- **Error handling**: API errors displayed to user

## Intermediate React Concepts

### 5. Component Lifecycle & Effects

**Q: Describe the lifecycle of TodoList component from mount to unmount.**
**A:**
1. **Mount**: Component mounts with initial state
2. **Effect**: useEffect triggers fetchTodos()
3. **Loading**: Shows loading spinner while API call in progress
4. **Update**: State updated with fetched todos
5. **Render**: Displays todo items
6. **User interactions**: Local state updates for CRUD operations
7. **Key change**: Component unmounts when refreshKey changes
8. **Remount**: New instance mounts with fresh state

**Q: How does the application handle component cleanup?**
**A:** 
- Components use local state, so cleanup is automatic
- No manual cleanup needed for API calls (they're not cancelled)
- Could be improved with AbortController for cancelling in-flight requests

### 6. Performance Optimization

**Q: What performance optimizations are implemented in this React application?**
**A:**
- **useCallback**: Prevents unnecessary AddTodoForm re-renders
- **Local state updates**: Immediate UI feedback without API calls
- **Strategic re-mounting**: Only fetch fresh data when actually needed
- **Key prop optimization**: Efficient way to trigger data refresh

**Q: How would you optimize this application further?**
**A:** Potential improvements:
```typescript
// React.memo for TodoItem
const TodoItem = React.memo(({ todo, onToggle, onDelete, onUpdate }) => {
  // Component implementation
});

// useMemo for expensive computations
const sortedTodos = useMemo(() => 
  todos.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)),
  [todos]
);

// AbortController for request cancellation
const controller = new AbortController();
fetch(url, { signal: controller.signal });
```

### 7. Error Handling

**Q: How does error handling work in this React application?**
**A:** Multi-level error handling:
```typescript
// Component level
try {
  const result = await todoAPI.createTodo(todo);
  // Success handling
} catch (error) {
  console.error('Failed to create todo:', error);
  alert('Failed to create todo. Please try again.');
}

// Service level
if (!response.ok) {
  throw new Error('Failed to create todo');
}

// State level
const [error, setError] = useState<string>('');
```

**Q: What improvements could be made to error handling?**
**A:**
- Error boundaries for unhandled errors
- Global error state management
- Retry mechanisms for failed requests
- Better user feedback with toast notifications
- Network status detection

## Advanced React Concepts

### 8. TypeScript Integration

**Q: How does TypeScript improve this React application?**
**A:** TypeScript provides:
```typescript
interface Todo {
  _id: string;
  title: string;
  description?: string;
  completed: boolean;
  priority: 'low' | 'medium' | 'high';
  createdAt: string;
  updatedAt: string;
}

interface AddTodoFormProps {
  onTodoAdded: (todo: Todo) => void;
}
```
- **Type safety**: Catches errors at compile time
- **Better IDE support**: Autocomplete and refactoring
- **API contract**: Ensures frontend matches backend types
- **Documentation**: Types serve as inline documentation

### 9. API Integration

**Q: Explain the service layer pattern used for API calls.**
**A:**
```typescript
class TodoAPI {
  async getAllTodos(): Promise<Todo[]> {
    const response = await fetch(`${API_BASE_URL}/todos`);
    if (!response.ok) {
      throw new Error('Failed to fetch todos');
    }
    const result = await response.json();
    return result.data;
  }
}
```
- **Separation of concerns**: API logic separate from components
- **Reusability**: Service methods used by multiple components
- **Consistency**: Standardized error handling
- **Testing**: Easier to mock service layer

**Q: How would you implement request caching in this application?**
**A:**
```typescript
class TodoAPI {
  private cache = new Map<string, { data: any, timestamp: number }>();
  private CACHE_DURATION = 5 * 60 * 1000; // 5 minutes

  async getAllTodos(): Promise<Todo[]> {
    const cacheKey = 'todos';
    const cached = this.cache.get(cacheKey);
    
    if (cached && Date.now() - cached.timestamp < this.CACHE_DURATION) {
      return cached.data;
    }
    
    const data = await this.fetchFromAPI();
    this.cache.set(cacheKey, { data, timestamp: Date.now() });
    return data;
  }
}
```

### 10. Testing Considerations

**Q: How would you test the TodoList component?**
**A:**
```typescript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import TodoList from './TodoList';

// Mock the API
jest.mock('../services/todoAPI', () => ({
  todoAPI: {
    getAllTodos: jest.fn(),
    updateTodo: jest.fn(),
    deleteTodo: jest.fn(),
  }
}));

test('displays loading state initially', () => {
  render(<TodoList />);
  expect(screen.getByText('Loading todos...')).toBeInTheDocument();
});

test('displays todos after loading', async () => {
  const mockTodos = [{ _id: '1', title: 'Test Todo', completed: false }];
  (todoAPI.getAllTodos as jest.Mock).mockResolvedValue(mockTodos);
  
  render(<TodoList />);
  
  await waitFor(() => {
    expect(screen.getByText('Test Todo')).toBeInTheDocument();
  });
});
```

## Practical Scenarios

### 11. Real-world Implementation Questions

**Q: How would you implement optimistic updates for better UX?**
**A:**
```typescript
const handleToggleComplete = async (id: string, completed: boolean) => {
  // Optimistic update
  setTodos(todos.map(todo =>
    todo._id === id ? { ...todo, completed } : todo
  ));

  try {
    const updatedTodo = await todoAPI.updateTodo(id, { completed });
    // Confirm with server response
    setTodos(todos.map(todo =>
      todo._id === id ? updatedTodo : todo
    ));
  } catch (error) {
    // Revert optimistic update
    setTodos(todos.map(todo =>
      todo._id === id ? { ...todo, completed: !completed } : todo
    ));
    setError('Failed to update todo');
  }
};
```

**Q: How would you implement real-time updates using WebSockets?**
**A:**
```typescript
useEffect(() => {
  const ws = new WebSocket('ws://localhost:5000');
  
  ws.onmessage = (event) => {
    const { type, todo } = JSON.parse(event.data);
    
    switch (type) {
      case 'TODO_ADDED':
        setTodos(prev => [...prev, todo]);
        break;
      case 'TODO_UPDATED':
        setTodos(prev => prev.map(t => t._id === todo._id ? todo : t));
        break;
      case 'TODO_DELETED':
        setTodos(prev => prev.filter(t => t._id !== todo._id));
        break;
    }
  };
  
  return () => ws.close();
}, []);
```

### 12. Architecture & Scalability

**Q: How would you scale this application for larger datasets?**
**A:** Scaling strategies:
- **Pagination**: Implement server-side pagination
- **Virtual scrolling**: For large lists in memory
- **Search/filtering**: Server-side filtering capabilities
- **Infinite scrolling**: Load more data as user scrolls
- **State management**: Consider Redux for complex state

**Q: How would you implement offline support?**
**A:**
```typescript
// Service Worker for caching
// IndexedDB for offline storage
// Sync queue for offline actions

const useOfflineSync = () => {
  const [isOnline, setIsOnline] = useState(navigator.onLine);
  const [pendingActions, setPendingActions] = useState([]);

  useEffect(() => {
    const handleOnline = () => {
      setIsOnline(true);
      // Sync pending actions
      syncPendingActions();
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', () => setIsOnline(false));
    
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', () => setIsOnline(false));
    };
  }, []);
};
```

These questions cover the full spectrum from basic React concepts to advanced architectural decisions, helping prepare for interviews ranging from junior to senior React developer positions.