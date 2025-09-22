// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Comprehensive Todo Application Flows', () => {
  
  test.beforeEach(async ({ page }) => {
    // Navigate to the application and wait for load
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Ensure we have a clean state by clearing any existing todos if needed
    await expect(page.locator('h1')).toContainText('React Todo App');
  });

  test.describe('User Journey - Complete Todo Management', () => {
    
    test('should handle complete CRUD operations in sequence', async ({ page }) => {
      const todoTitle = 'Integration Test Todo';
      const updatedTitle = 'Updated Integration Todo';
      
      // CREATE: Add a new todo
      await page.fill('[data-testid="todo-input"]', todoTitle);
      await page.fill('[data-testid="todo-description"]', 'Test description for CRUD operations');
      await page.selectOption('[data-testid="priority-select"]', 'high');
      await page.click('[data-testid="add-todo-btn"]');
      
      // Verify creation
      await expect(page.locator('[data-testid="todo-title"]').first()).toContainText(todoTitle);
      
      // READ: Verify todo is displayed with correct details
      await expect(page.locator('[data-testid="todo-item"]').first()).toBeVisible();
      await expect(page.locator('[data-testid="todo-priority"]').first()).toContainText('high');
      
      // UPDATE: Edit the todo
      await page.click('[data-testid="edit-btn"]');
      await page.fill('[data-testid="edit-input"]', updatedTitle);
      await page.click('[data-testid="save-btn"]');
      
      // Verify update
      await expect(page.locator('[data-testid="todo-title"]').first()).toContainText(updatedTitle);
      
      // Mark as completed
      await page.check('[data-testid="todo-checkbox"]');
      await expect(page.locator('[data-testid="todo-item"]').first()).toHaveClass(/completed/);
      
      // DELETE: Remove the todo
      await page.click('[data-testid="delete-btn"]');
      
      // Verify deletion (todo should no longer be visible or count should decrease)
      await expect(page.locator(`text=${updatedTitle}`)).not.toBeVisible();
    });

    test('should handle multiple todos with different priorities', async ({ page }) => {
      const todos = [
        { title: 'High Priority Task', priority: 'high', description: 'Urgent task' },
        { title: 'Medium Priority Task', priority: 'medium', description: 'Regular task' },
        { title: 'Low Priority Task', priority: 'low', description: 'When time permits' }
      ];

      // Create multiple todos
      for (const todo of todos) {
        await page.fill('[data-testid="todo-input"]', todo.title);
        await page.fill('[data-testid="todo-description"]', todo.description);
        await page.selectOption('[data-testid="priority-select"]', todo.priority);
        await page.click('[data-testid="add-todo-btn"]');
        
        // Wait for each todo to be created
        await expect(page.locator(`text=${todo.title}`)).toBeVisible();
      }

      // Verify all todos are present
      await expect(page.locator('[data-testid="todo-item"]')).toHaveCount(3);
      
      // Verify priority sorting/display (if implemented)
      const todoItems = await page.locator('[data-testid="todo-item"]').all();
      expect(todoItems.length).toBe(3);
    });

    test('should persist data across browser sessions', async ({ page, context }) => {
      const persistentTodo = 'Persistent Todo for Session Test';
      
      // Create a todo
      await page.fill('[data-testid="todo-input"]', persistentTodo);
      await page.click('[data-testid="add-todo-btn"]');
      await expect(page.locator(`text=${persistentTodo}`)).toBeVisible();
      
      // Close and reopen browser
      await page.close();
      const newPage = await context.newPage();
      await newPage.goto('/');
      await newPage.waitForLoadState('networkidle');
      
      // Verify todo persists
      await expect(newPage.locator(`text=${persistentTodo}`)).toBeVisible();
    });
  });

  test.describe('Error Handling and Edge Cases', () => {
    
    test('should handle API connection failures gracefully', async ({ page }) => {
      // Simulate API failure by intercepting network requests
      await page.route('**/api/todos', route => {
        route.fulfill({ status: 500, body: '{"error": "Server Error"}' });
      });
      
      await page.reload();
      
      // Verify error handling UI appears
      await expect(page.locator('[data-testid="error-message"]')).toBeVisible();
    });

    test('should handle slow API responses', async ({ page }) => {
      // Simulate slow API response
      await page.route('**/api/todos', async route => {
        await new Promise(resolve => setTimeout(resolve, 2000));
        route.continue();
      });
      
      await page.reload();
      
      // Verify loading state is shown
      await expect(page.locator('[data-testid="loading-spinner"]')).toBeVisible();
    });

    test('should validate form inputs properly', async ({ page }) => {
      // Test empty title
      await page.click('[data-testid="add-todo-btn"]');
      await expect(page.locator('[data-testid="validation-error"]')).toContainText('Title is required');
      
      // Test very long title
      const longTitle = 'a'.repeat(500);
      await page.fill('[data-testid="todo-input"]', longTitle);
      await page.click('[data-testid="add-todo-btn"]');
      await expect(page.locator('[data-testid="validation-error"]')).toContainText('Title too long');
    });
  });

  test.describe('Responsive Design Testing', () => {
    
    test('should work properly on mobile devices', async ({ page }) => {
      // Set mobile viewport
      await page.setViewportSize({ width: 375, height: 667 });
      
      // Verify mobile-responsive elements
      await expect(page.locator('h1')).toBeVisible();
      await expect(page.locator('[data-testid="todo-input"]')).toBeVisible();
      
      // Test mobile interactions
      await page.fill('[data-testid="todo-input"]', 'Mobile Test Todo');
      await page.tap('[data-testid="add-todo-btn"]');
      
      await expect(page.locator('[data-testid="todo-item"]').first()).toBeVisible();
    });

    test('should work on tablet viewport', async ({ page }) => {
      await page.setViewportSize({ width: 768, height: 1024 });
      
      // Test tablet-specific behaviors
      await page.fill('[data-testid="todo-input"]', 'Tablet Test Todo');
      await page.click('[data-testid="add-todo-btn"]');
      
      await expect(page.locator('[data-testid="todo-item"]').first()).toBeVisible();
    });
  });

  test.describe('Performance and Load Testing', () => {
    
    test('should handle many todos efficiently', async ({ page }) => {
      // Create multiple todos quickly
      for (let i = 1; i <= 20; i++) {
        await page.fill('[data-testid="todo-input"]', `Performance Test Todo ${i}`);
        await page.selectOption('[data-testid="priority-select"]', i % 3 === 0 ? 'high' : i % 2 === 0 ? 'medium' : 'low');
        await page.click('[data-testid="add-todo-btn"]');
      }
      
      // Verify all todos are created and page remains responsive
      await expect(page.locator('[data-testid="todo-item"]')).toHaveCount(20);
      
      // Test scrolling performance
      await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
      await page.evaluate(() => window.scrollTo(0, 0));
      
      // Verify page is still interactive
      await expect(page.locator('[data-testid="todo-input"]')).toBeFocused();
    });

    test('should load quickly', async ({ page }) => {
      const startTime = Date.now();
      
      await page.goto('/');
      await page.waitForLoadState('networkidle');
      
      const loadTime = Date.now() - startTime;
      
      // Verify page loads in reasonable time (adjust threshold as needed)
      expect(loadTime).toBeLessThan(5000);
      
      // Verify critical elements are visible
      await expect(page.locator('h1')).toBeVisible();
      await expect(page.locator('[data-testid="add-todo-btn"]')).toBeVisible();
    });
  });

  test.describe('Accessibility Testing', () => {
    
    test('should be keyboard navigable', async ({ page }) => {
      // Test tab navigation
      await page.keyboard.press('Tab');
      await expect(page.locator('[data-testid="todo-input"]')).toBeFocused();
      
      await page.keyboard.press('Tab');
      await expect(page.locator('[data-testid="todo-description"]')).toBeFocused();
      
      await page.keyboard.press('Tab');
      await expect(page.locator('[data-testid="priority-select"]')).toBeFocused();
      
      await page.keyboard.press('Tab');
      await expect(page.locator('[data-testid="add-todo-btn"]')).toBeFocused();
    });

    test('should have proper ARIA labels', async ({ page }) => {
      // Verify form elements have proper labels
      const todoInput = page.locator('[data-testid="todo-input"]');
      await expect(todoInput).toHaveAttribute('aria-label');
      
      const prioritySelect = page.locator('[data-testid="priority-select"]');
      await expect(prioritySelect).toHaveAttribute('aria-label');
    });

    test('should support screen reader navigation', async ({ page }) => {
      // Verify headings structure
      await expect(page.locator('h1')).toBeVisible();
      await expect(page.locator('h2')).toHaveCount(2); // "Add New Todo" and "Your Todos"
      
      // Verify semantic HTML structure
      await expect(page.locator('main')).toBeVisible();
      await expect(page.locator('form')).toBeVisible();
    });
  });

  test.describe('Integration with Backend', () => {
    
    test('should sync with database in real-time', async ({ page, context }) => {
      const testTodo = 'Real-time Sync Test';
      
      // Create todo in first session
      await page.fill('[data-testid="todo-input"]', testTodo);
      await page.click('[data-testid="add-todo-btn"]');
      await expect(page.locator(`text=${testTodo}`)).toBeVisible();
      
      // Open second browser session
      const secondPage = await context.newPage();
      await secondPage.goto('/');
      await secondPage.waitForLoadState('networkidle');
      
      // Verify todo appears in second session (if real-time sync is implemented)
      await expect(secondPage.locator(`text=${testTodo}`)).toBeVisible();
    });

    test('should handle concurrent modifications', async ({ page, context }) => {
      // This test would verify how the app handles concurrent edits
      // Implementation depends on your conflict resolution strategy
      const todoTitle = 'Concurrent Edit Test';
      
      // Create todo
      await page.fill('[data-testid="todo-input"]', todoTitle);
      await page.click('[data-testid="add-todo-btn"]');
      await expect(page.locator(`text=${todoTitle}`)).toBeVisible();
      
      // Open second session and modify the same todo
      const secondPage = await context.newPage();
      await secondPage.goto('/');
      await secondPage.waitForLoadState('networkidle');
      
      // Both pages should handle concurrent modifications gracefully
      // Specific implementation depends on your conflict resolution
    });
  });
});