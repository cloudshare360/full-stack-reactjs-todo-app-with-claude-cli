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
  await page.waitForTimeout(5000);

  // Try to create a todo
  console.log('Filling todo form...');
  await page.fill('[data-testid="todo-input"]', 'Test Manual Todo');
  await page.click('[data-testid="add-todo-btn"]');

  // Wait to see if todo appears
  await page.waitForTimeout(3000);

  // Check if todos are visible
  const todoCount = await page.locator('[data-testid="todo-item"]').count();
  console.log(`Todo items found: ${todoCount}`);

  // Take a screenshot for debugging
  await page.screenshot({ path: 'debug-screenshot.png' });

  await browser.close();
})();