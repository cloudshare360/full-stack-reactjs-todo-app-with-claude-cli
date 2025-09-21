const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();

  // Listen to console logs from the browser
  page.on('console', msg => {
    console.log(`BROWSER CONSOLE: ${msg.type()}: ${msg.text()}`);
  });

  // Navigate to the app
  await page.goto('http://localhost:3001');

  // Wait a moment for the page to load
  await page.waitForTimeout(3000);

  console.log('=== Testing Complete CRUD Functionality ===');

  // Test 1: Read - Check if existing todos are displayed
  console.log('\n1. Testing READ functionality...');
  const initialTodoCount = await page.locator('[data-testid="todo-item"]').count();
  console.log(`Initial todo count: ${initialTodoCount}`);

  // Test 2: Create - Add a new todo
  console.log('\n2. Testing CREATE functionality...');
  const testTodoTitle = `Test CRUD Todo - ${Date.now()}`;
  await page.fill('[data-testid="todo-input"]', testTodoTitle);
  await page.fill('[data-testid="todo-description"]', 'Testing CRUD operations');
  await page.selectOption('[data-testid="priority-select"]', 'high');
  await page.click('[data-testid="add-todo-btn"]');

  // Wait for the new todo to appear
  await page.waitForTimeout(2000);
  const newTodoCount = await page.locator('[data-testid="todo-item"]').count();
  console.log(`New todo count after creation: ${newTodoCount}`);
  console.log(`✅ CREATE: ${newTodoCount > initialTodoCount ? 'SUCCESS' : 'FAILED'}`);

  // Test 3: Update - Find the newly created todo and edit it
  console.log('\n3. Testing UPDATE functionality...');
  const newTodo = page.locator('[data-testid="todo-item"]').first();
  await newTodo.locator('[data-testid="edit-btn"]').click();

  // Wait for edit mode
  await page.waitForTimeout(1000);

  // Update the title
  const updatedTitle = `Updated CRUD Todo - ${Date.now()}`;
  await page.fill('input[value*="Test CRUD Todo"]', updatedTitle);
  await page.click('button:has-text("Save")');

  // Wait for update to complete
  await page.waitForTimeout(2000);

  // Verify the title was updated
  const updatedTodoTitle = await newTodo.locator('[data-testid="todo-title"]').textContent();
  console.log(`Updated todo title: ${updatedTodoTitle}`);
  console.log(`✅ UPDATE: ${updatedTodoTitle.includes('Updated CRUD Todo') ? 'SUCCESS' : 'FAILED'}`);

  // Test 4: Update - Toggle completion status
  console.log('\n4. Testing TOGGLE COMPLETE functionality...');
  const checkbox = newTodo.locator('[data-testid="todo-checkbox"]');
  const initialCheckedState = await checkbox.isChecked();
  await checkbox.click();

  // Wait for the toggle to complete
  await page.waitForTimeout(2000);

  const newCheckedState = await checkbox.isChecked();
  console.log(`Initial checked state: ${initialCheckedState}, New checked state: ${newCheckedState}`);
  console.log(`✅ TOGGLE: ${initialCheckedState !== newCheckedState ? 'SUCCESS' : 'FAILED'}`);

  // Test 5: Delete - Remove the test todo
  console.log('\n5. Testing DELETE functionality...');
  await newTodo.locator('[data-testid="delete-btn"]').click();

  // Wait for deletion to complete
  await page.waitForTimeout(2000);

  const finalTodoCount = await page.locator('[data-testid="todo-item"]').count();
  console.log(`Final todo count after deletion: ${finalTodoCount}`);
  console.log(`✅ DELETE: ${finalTodoCount === initialTodoCount ? 'SUCCESS' : 'FAILED'}`);

  // Summary
  console.log('\n=== CRUD Test Summary ===');
  console.log(`Initial todos: ${initialTodoCount}`);
  console.log(`After CREATE: ${newTodoCount}`);
  console.log(`After DELETE: ${finalTodoCount}`);

  const allTestsPassed =
    newTodoCount > initialTodoCount && // CREATE worked
    updatedTodoTitle.includes('Updated CRUD Todo') && // UPDATE worked
    initialCheckedState !== newCheckedState && // TOGGLE worked
    finalTodoCount === initialTodoCount; // DELETE worked

  console.log(`\n🎯 OVERALL RESULT: ${allTestsPassed ? '✅ ALL CRUD OPERATIONS WORKING' : '❌ SOME OPERATIONS FAILED'}`);

  // Take a screenshot for verification
  await page.screenshot({ path: 'crud-test-final.png' });

  await browser.close();
})();