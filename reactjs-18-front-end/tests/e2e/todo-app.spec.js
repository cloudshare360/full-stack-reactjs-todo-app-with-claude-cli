// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Todo Application - Complete User Journey', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the application
    await page.goto('/');

    // Wait for the page to load
    await expect(page.locator('h1')).toContainText('React Todo App');
  });

  test('should load the homepage with initial elements', async ({ page }) => {
    // Verify main elements are present
    await expect(page.locator('h1')).toContainText('React Todo App');
    await expect(page.locator('h2').first()).toContainText('Add New Todo');
    await expect(page.locator('h2').last()).toContainText('Your Todos');

    // Verify form elements are present
    await expect(page.locator('[data-testid="todo-input"]')).toBeVisible();
    await expect(page.locator('[data-testid="priority-select"]')).toBeVisible();
    await expect(page.locator('[data-testid="add-todo-btn"]')).toBeVisible();
  });

  test('should create a new todo successfully', async ({ page }) => {
    const todoTitle = 'Automated Test Todo';
    const todoDescription = 'This todo was created by Playwright automation';

    // Fill in the form
    await page.fill('[data-testid="todo-input"]', todoTitle);
    await page.fill('[data-testid="todo-description"]', todoDescription);
    await page.selectOption('[data-testid="priority-select"]', 'high');

    // Submit the form
    await page.click('[data-testid="add-todo-btn"]');

    // Wait for the todo to appear
    await expect(page.locator('[data-testid="todo-item"]').first()).toBeVisible();
    await expect(page.locator('[data-testid="todo-title"]').first()).toContainText(todoTitle);

    // Verify the form is cleared
    await expect(page.locator('[data-testid="todo-input"]')).toHaveValue('');
  });

  test('should mark todo as completed', async ({ page }) => {
    // Create a todo first
    await page.fill('[data-testid="todo-input"]', 'Test Completion');
    await page.click('[data-testid="add-todo-btn"]');

    // Wait for todo to appear
    await expect(page.locator('[data-testid="todo-item"]').first()).toBeVisible();

    // Mark as completed
    await page.check('[data-testid="todo-checkbox"]');

    // Verify visual changes
    await expect(page.locator('[data-testid="todo-item"]').first()).toHaveClass(/completed/);
  });

  test('should edit todo successfully', async ({ page }) => {
    const originalTitle = 'Original Todo Title';
    const editedTitle = 'Edited Todo Title';

    // Create a todo
    await page.fill('[data-testid="todo-input"]', originalTitle);
    await page.click('[data-testid="add-todo-btn"]');

    // Wait for todo to appear
    await expect(page.locator('[data-testid="todo-title"]').first()).toContainText(originalTitle);

    // Click edit button
    await page.click('[data-testid="edit-btn"]');

    // Edit the title (assuming edit mode creates an input field)
    const editInput = page.locator('input').nth(1); // First input is the add form, second should be edit
    await editInput.fill(editedTitle);

    // Save changes (assuming there's a save button)
    await page.click('button:has-text("Save")');

    // Verify changes
    await expect(page.locator('[data-testid="todo-title"]').first()).toContainText(editedTitle);
  });

  test('should delete todo successfully', async ({ page }) => {
    const todoTitle = 'Todo to Delete';

    // Create a todo
    await page.fill('[data-testid="todo-input"]', todoTitle);
    await page.click('[data-testid="add-todo-btn"]');

    // Wait for todo to appear
    await expect(page.locator('[data-testid="todo-title"]').first()).toContainText(todoTitle);

    // Count todos before deletion
    const todosBeforeDeletion = await page.locator('[data-testid="todo-item"]').count();

    // Delete the todo
    await page.click('[data-testid="delete-btn"]');

    // Verify todo is removed
    const todosAfterDeletion = await page.locator('[data-testid="todo-item"]').count();
    expect(todosAfterDeletion).toBe(todosBeforeDeletion - 1);
  });

  test('should handle different priority levels', async ({ page }) => {
    const priorities = ['high', 'medium', 'low'];

    for (const priority of priorities) {
      await page.fill('[data-testid="todo-input"]', `${priority} priority todo`);
      await page.selectOption('[data-testid="priority-select"]', priority);
      await page.click('[data-testid="add-todo-btn"]');

      // Wait for todo to appear
      await expect(page.locator('[data-testid="todo-item"]').first()).toBeVisible();
    }

    // Verify we have 3 todos
    await expect(page.locator('[data-testid="todo-item"]')).toHaveCount(3);
  });

  test('should validate required fields', async ({ page }) => {
    // Try to submit with empty title
    await page.click('[data-testid="add-todo-btn"]');

    // Verify form validation (button should be disabled or form shouldn't submit)
    const isDisabled = await page.locator('[data-testid="add-todo-btn"]').isDisabled();
    expect(isDisabled).toBe(true);
  });

  test('should display existing todos on page load', async ({ page }) => {
    // Should load with existing todos from the database
    const todoItems = page.locator('[data-testid="todo-item"]');
    const count = await todoItems.count();

    // Should have some todos from seed data
    expect(count).toBeGreaterThan(0);
  });

  test('should persist todos across page refreshes', async ({ page }) => {
    const todoTitle = 'Persistent Todo';

    // Create a todo
    await page.fill('[data-testid="todo-input"]', todoTitle);
    await page.click('[data-testid="add-todo-btn"]');

    // Wait for todo to appear
    await expect(page.locator('[data-testid="todo-title"]').first()).toContainText(todoTitle);

    // Refresh the page
    await page.reload();

    // Verify todo is still there
    await expect(page.locator('[data-testid="todo-title"]').first()).toContainText(todoTitle);
  });

  test('should handle mobile viewport', async ({ page }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });

    // Verify page is still functional
    await expect(page.locator('h1')).toContainText('React Todo App');
    await expect(page.locator('[data-testid="todo-input"]')).toBeVisible();

    // Test creating a todo on mobile
    await page.fill('[data-testid="todo-input"]', 'Mobile Todo');
    await page.click('[data-testid="add-todo-btn"]');

    // Verify it works
    await expect(page.locator('[data-testid="todo-title"]').first()).toContainText('Mobile Todo');
  });
});