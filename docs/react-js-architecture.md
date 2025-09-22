# React.js Frontend Architecture Documentation

## Overview
This document provides a comprehensive overview of the React.js frontend architecture for the Todo Application, including detailed sequence diagrams for component interactions, state management, and user flows.

## Architecture Components

### 1. Application Entry Point (`src/index.tsx`)
The main entry point that renders the App component into the DOM.

### 2. App Component (`src/App.tsx`)
The root component that manages the overall application layout and coordinates between child components.

**Key Features:**
- **State Management**: Uses `refreshKey` state to trigger TodoList re-renders
- **Component Coordination**: Manages communication between AddTodoForm and TodoList
- **Layout Structure**: Provides the main application layout with header, main, and footer

### 3. TodoList Component (`src/components/TodoList.tsx`)
Manages the display and operations of the todo list.

**Key Features:**
- **State Management**: Local state for todos, loading, and error states
- **Data Fetching**: Retrieves todos from the API on component mount
- **CRUD Operations**: Handles todo updates and deletions
- **Error Handling**: Displays error messages and loading states

### 4. AddTodoForm Component (`src/components/AddTodoForm.tsx`)
Provides a form interface for creating new todos.

**Key Features:**
- **Form State**: Manages form input states (title, description, priority)
- **Validation**: Client-side validation before submission
- **API Integration**: Calls the API to create new todos
- **Parent Communication**: Notifies parent component when todo is added

### 5. TodoItem Component (`src/components/TodoItem.tsx`)
Individual todo item with inline editing and action capabilities.

**Key Features:**
- **Interactive UI**: Toggle completion, edit in-place, delete actions
- **State Management**: Local editing state for inline updates
- **Event Handling**: Manages user interactions and propagates changes

### 6. API Service Layer (`src/services/todoAPI.ts`)
Centralized API communication layer using the Fetch API.

**Available Methods:**
- `getAllTodos()` - Fetch all todos
- `getTodoById(id)` - Fetch specific todo
- `createTodo(todo)` - Create new todo
- `updateTodo(id, updates)` - Update existing todo
- `deleteTodo(id)` - Delete todo

### 7. Type Definitions (`src/types/Todo.ts`)
TypeScript interfaces for type safety and better development experience.

---

## Component Interaction Sequence Diagrams

### 1. Application Initialization Flow

```mermaid
sequenceDiagram
    participant Browser
    participant Index
    participant App
    participant AddTodoForm
    participant TodoList
    participant TodoAPI
    participant Backend

    Browser->>Index: Load application
    Index->>App: Render App component
    App->>App: Initialize refreshKey state (0)
    
    par Render AddTodoForm
        App->>AddTodoForm: Render with onTodoAdded callback
        AddTodoForm->>AddTodoForm: Initialize form states
        AddTodoForm->>AddTodoForm: title: "", description: "", priority: "medium"
    and Render TodoList
        App->>TodoList: Render with key={refreshKey}
        TodoList->>TodoList: Initialize component state
        TodoList->>TodoList: todos: [], loading: true, error: ""
        
        TodoList->>TodoAPI: getAllTodos()
        TodoAPI->>Backend: GET /api/todos
        Backend-->>TodoAPI: Return todos array
        TodoAPI-->>TodoList: Return parsed todos
        
        TodoList->>TodoList: Update state with fetched todos
        TodoList->>TodoList: Set loading: false
    end
    
    App-->>Browser: Render complete application
```

### 2. Create New Todo Flow

```mermaid
sequenceDiagram
    participant User
    participant AddTodoForm
    participant TodoAPI
    participant Backend
    participant App
    participant TodoList

    User->>AddTodoForm: Fill form (title, description, priority)
    AddTodoForm->>AddTodoForm: Update local state on each input
    
    User->>AddTodoForm: Submit form
    AddTodoForm->>AddTodoForm: Prevent default & validate input
    AddTodoForm->>AddTodoForm: Set isSubmitting: true
    
    alt Valid Input
        AddTodoForm->>TodoAPI: createTodo({ title, description, priority, completed: false })
        TodoAPI->>Backend: POST /api/todos
        Backend-->>TodoAPI: Return created todo with _id
        TodoAPI-->>AddTodoForm: Return new todo object
        
        AddTodoForm->>AddTodoForm: Reset form fields
        AddTodoForm->>AddTodoForm: Set isSubmitting: false
        AddTodoForm->>App: Call onTodoAdded(newTodo)
        
        App->>App: Increment refreshKey (prev => prev + 1)
        App->>TodoList: Re-render with new key
        
        TodoList->>TodoAPI: getAllTodos() [useEffect triggered by key change]
        TodoAPI->>Backend: GET /api/todos
        Backend-->>TodoAPI: Return updated todos array
        TodoAPI-->>TodoList: Return todos including new one
        
        TodoList->>TodoList: Update todos state
        TodoList-->>User: Display updated todo list
        
    else Invalid Input
        AddTodoForm->>AddTodoForm: Show validation errors
        AddTodoForm->>AddTodoForm: Set isSubmitting: false
    end
```

### 3. Toggle Todo Completion Flow

```mermaid
sequenceDiagram
    participant User
    participant TodoItem
    participant TodoList
    participant TodoAPI
    participant Backend

    User->>TodoItem: Click completion checkbox
    TodoItem->>TodoList: Call onToggleComplete(id, !completed)
    
    TodoList->>TodoAPI: updateTodo(id, { completed: newCompletedState })
    TodoAPI->>Backend: PUT /api/todos/:id
    Backend-->>TodoAPI: Return updated todo
    TodoAPI-->>TodoList: Return updated todo object
    
    alt Update Successful
        TodoList->>TodoList: Update local todos state
        Note over TodoList: todos.map(todo => todo._id === id ? updatedTodo : todo)
        TodoList->>TodoItem: Re-render with updated todo
        TodoItem-->>User: Show updated completion state
        
    else Update Failed
        TodoAPI-->>TodoList: Throw error
        TodoList->>TodoList: Set error state
        TodoList-->>User: Display error message
        Note over User: Todo remains in original state
    end
```

### 4. Edit Todo Flow

```mermaid
sequenceDiagram
    participant User
    participant TodoItem
    participant TodoList
    participant TodoAPI
    participant Backend

    User->>TodoItem: Click edit button
    TodoItem->>TodoItem: Set editing: true
    TodoItem->>TodoItem: Set editTitle: todo.title, editDescription: todo.description
    TodoItem-->>User: Show edit form

    User->>TodoItem: Modify title/description
    TodoItem->>TodoItem: Update editTitle/editDescription state

    User->>TodoItem: Click save button
    TodoItem->>TodoItem: Validate changes
    
    alt Changes Valid
        TodoItem->>TodoList: Call onUpdate(id, { title: editTitle, description: editDescription })
        TodoList->>TodoAPI: updateTodo(id, updates)
        TodoAPI->>Backend: PUT /api/todos/:id
        Backend-->>TodoAPI: Return updated todo
        TodoAPI-->>TodoList: Return updated todo
        
        TodoList->>TodoList: Update todos state
        TodoList->>TodoItem: Re-render with updated data
        TodoItem->>TodoItem: Set editing: false
        TodoItem-->>User: Show updated todo in view mode
        
    else Validation Failed
        TodoItem-->>User: Show validation error
        Note over User: Remain in edit mode
    end

    Note over User: User can also click cancel to exit edit mode without saving
```

### 5. Delete Todo Flow

```mermaid
sequenceDiagram
    participant User
    participant TodoItem
    participant TodoList
    participant TodoAPI
    participant Backend

    User->>TodoItem: Click delete button
    TodoItem->>User: Show confirmation dialog (optional)
    
    alt User Confirms Deletion
        TodoItem->>TodoList: Call onDelete(id)
        TodoList->>TodoAPI: deleteTodo(id)
        TodoAPI->>Backend: DELETE /api/todos/:id
        Backend-->>TodoAPI: Return success response
        TodoAPI-->>TodoList: Confirm deletion
        
        TodoList->>TodoList: Update local state
        Note over TodoList: todos.filter(todo => todo._id !== id)
        TodoList-->>User: Remove todo from display
        
    else Deletion Failed
        TodoAPI-->>TodoList: Throw error
        TodoList->>TodoList: Set error state
        TodoList-->>User: Display error message
        Note over User: Todo remains in list
    end
```

### 6. Error Handling Flow

```mermaid
sequenceDiagram
    participant User
    participant Component
    participant TodoAPI
    participant Backend

    Component->>TodoAPI: API call (any operation)
    TodoAPI->>Backend: HTTP request
    
    alt Network Error
        Backend-->>TodoAPI: Network failure / timeout
        TodoAPI->>TodoAPI: Catch network error
        TodoAPI-->>Component: Throw "Network error" message
        Component->>Component: Update error state
        Component-->>User: Display error notification
        
    else API Error (4xx/5xx)
        Backend-->>TodoAPI: Error response (400, 404, 500, etc.)
        TodoAPI->>TodoAPI: Check response.ok === false
        TodoAPI-->>Component: Throw specific error message
        Component->>Component: Update error state
        Component-->>User: Display error notification
        
    else Success
        Backend-->>TodoAPI: Success response (200, 201)
        TodoAPI->>TodoAPI: Parse JSON response
        TodoAPI-->>Component: Return data
        Component->>Component: Update state with data
        Component-->>User: Display updated UI
    end
```

---

## State Management Flow

### 1. App Level State Management

```mermaid
sequenceDiagram
    participant AddTodoForm
    participant App
    participant TodoList

    Note over App: State: { refreshKey: number }
    
    AddTodoForm->>App: onTodoAdded callback triggered
    App->>App: setRefreshKey(prev => prev + 1)
    App->>TodoList: Re-render with new key prop
    
    Note over TodoList: useEffect dependency on component mount/key change
    TodoList->>TodoList: Detect key change via useEffect
    TodoList->>TodoList: Trigger fetchTodos()
```

### 2. TodoList State Management

```mermaid
sequenceDiagram
    participant TodoList
    participant TodoAPI

    Note over TodoList: State: { todos: Todo[], loading: boolean, error: string }
    
    TodoList->>TodoList: Component mounts or key changes
    TodoList->>TodoList: setLoading(true)
    TodoList->>TodoAPI: getAllTodos()
    
    alt API Success
        TodoAPI-->>TodoList: Return todos array
        TodoList->>TodoList: setTodos(data)
        TodoList->>TodoList: setLoading(false)
        TodoList->>TodoList: setError("")
        
    else API Error
        TodoAPI-->>TodoList: Throw error
        TodoList->>TodoList: setError("Failed to fetch todos")
        TodoList->>TodoList: setLoading(false)
    end
```

### 3. AddTodoForm State Management

```mermaid
sequenceDiagram
    participant AddTodoForm

    Note over AddTodoForm: State: { title: string, description: string, priority: Priority, isSubmitting: boolean }
    
    AddTodoForm->>AddTodoForm: User types in input
    AddTodoForm->>AddTodoForm: setTitle(e.target.value)
    
    AddTodoForm->>AddTodoForm: User submits form
    AddTodoForm->>AddTodoForm: setIsSubmitting(true)
    
    alt Todo Created Successfully
        AddTodoForm->>AddTodoForm: Reset all form fields
        AddTodoForm->>AddTodoForm: setTitle(""), setDescription(""), setPriority("medium")
        AddTodoForm->>AddTodoForm: setIsSubmitting(false)
        
    else Creation Failed
        AddTodoForm->>AddTodoForm: setIsSubmitting(false)
        AddTodoForm->>AddTodoForm: Keep form data for retry
    end
```

---

## Component Lifecycle and Hooks Usage

### 1. TodoList Component Lifecycle

```mermaid
sequenceDiagram
    participant React
    participant TodoList
    participant TodoAPI

    React->>TodoList: Component Mount
    TodoList->>TodoList: useState initialization
    TodoList->>TodoList: useEffect(() => { fetchTodos() }, [])
    TodoList->>TodoAPI: getAllTodos()
    
    Note over React: Component receives new key prop
    React->>TodoList: Component Re-mount (key changed)
    TodoList->>TodoList: useEffect triggered again
    TodoList->>TodoAPI: getAllTodos() [Fresh data fetch]
    
    Note over React: Component Unmount
    React->>TodoList: Cleanup (if any async operations)
```

### 2. Form Component Lifecycle

```mermaid
sequenceDiagram
    participant React
    participant AddTodoForm

    React->>AddTodoForm: Component Mount
    AddTodoForm->>AddTodoForm: Initialize form state
    
    Note over React: User interactions
    React->>AddTodoForm: Re-render on state changes
    AddTodoForm->>AddTodoForm: Update individual field states
    
    Note over React: Form submission
    AddTodoForm->>AddTodoForm: Handle async submission
    AddTodoForm->>AddTodoForm: Reset form on success
```

---

## API Integration Patterns

### 1. Service Layer Pattern

The application uses a centralized service layer (`todoAPI.ts`) that:
- Encapsulates all HTTP communication
- Provides consistent error handling
- Handles request/response transformation
- Uses modern Fetch API with proper error checking

### 2. Error Propagation Pattern

```mermaid
sequenceDiagram
    participant TodoAPI
    participant Component
    participant User

    TodoAPI->>TodoAPI: response.ok check fails
    TodoAPI->>TodoAPI: throw new Error(message)
    TodoAPI-->>Component: Promise rejection
    Component->>Component: try/catch block
    Component->>Component: Update error state
    Component-->>User: Display error UI
```

---

## Key Features

### 1. **Type Safety**
- Full TypeScript implementation
- Strongly typed interfaces for Todo objects
- Type-safe API service methods
- Props and state typing for all components

### 2. **State Management**
- Local component state using React hooks
- Minimal prop drilling through callback functions
- Strategic re-rendering using key prop pattern
- Optimistic UI updates where appropriate

### 3. **User Experience**
- Loading states during API operations
- Error handling with user-friendly messages
- Form validation with immediate feedback
- Responsive design for mobile compatibility

### 4. **Performance**
- Efficient re-rendering using React keys
- Minimal API calls with strategic data fetching
- Local state updates for immediate UI feedback
- Component memoization opportunities (can be added)

### 5. **Maintainability**
- Separation of concerns with service layer
- Reusable component architecture
- Consistent error handling patterns
- Clear component responsibilities

### 6. **Accessibility**
- Semantic HTML elements
- Proper form labels and ARIA attributes
- Keyboard navigation support
- Screen reader compatibility

---

## Component Props and State Summary

### App Component
**State:** `{ refreshKey: number }`
**Props:** None
**Callbacks:** `handleTodoAdded`

### TodoList Component
**State:** `{ todos: Todo[], loading: boolean, error: string }`
**Props:** `{ key: number }` (from App)
**Methods:** `fetchTodos`, `handleToggleComplete`, `handleDeleteTodo`, `handleUpdateTodo`

### AddTodoForm Component
**State:** `{ title: string, description: string, priority: Priority, isSubmitting: boolean }`
**Props:** `{ onTodoAdded: (todo: Todo) => void }`
**Methods:** `handleSubmit`

### TodoItem Component
**State:** `{ editing: boolean, editTitle: string, editDescription: string }`
**Props:** `{ todo: Todo, onToggleComplete, onDelete, onUpdate }`
**Methods:** `handleEdit`, `handleSave`, `handleCancel`

This React.js architecture provides a clean, maintainable, and scalable frontend solution with proper component separation, state management, and user experience considerations.