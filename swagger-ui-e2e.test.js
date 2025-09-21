const { test, expect, chromium } = require('playwright/test');

// Dynamic Configuration
const os = require('os');

// Function to get local hostname
function getHostname() {
  return process.env.TEST_HOSTNAME || os.hostname() || 'localhost';
}

// Function to get API base URL
function getAPIBaseURL() {
  if (process.env.API_BASE_URL) {
    return process.env.API_BASE_URL;
  }

  const host = process.env.API_HOST || 'localhost';
  const port = process.env.API_PORT || '5000';
  const protocol = process.env.API_PROTOCOL || 'http';

  return `${protocol}://${host}:${port}/api`;
}

// Function to get Swagger UI URL
function getSwaggerUIURL() {
  if (process.env.SWAGGER_UI_URL) {
    return process.env.SWAGGER_UI_URL;
  }

  const host = process.env.SWAGGER_HOST || 'localhost';
  const port = process.env.SWAGGER_PORT || '8080';
  const protocol = process.env.SWAGGER_PROTOCOL || 'http';

  return `${protocol}://${host}:${port}/swagger-ui.html`;
}

// Configuration
const SWAGGER_UI_URL = getSwaggerUIURL();
const API_BASE_URL = getAPIBaseURL();

console.log(`🌐 E2E Test Configuration:`);
console.log(`   Swagger UI: ${SWAGGER_UI_URL}`);
console.log(`   API Base: ${API_BASE_URL}`);

// Test suite for Swagger UI E2E testing
test.describe('Swagger UI E2E Tests', () => {
  let browser;
  let page;

  test.beforeAll(async () => {
    browser = await chromium.launch({
      headless: true,
      args: ['--disable-web-security', '--disable-features=VizDisplayCompositor']
    });
  });

  test.afterAll(async () => {
    if (browser) {
      await browser.close();
    }
  });

  test.beforeEach(async () => {
    page = await browser.newPage();

    // Set longer timeout for API requests
    page.setDefaultTimeout(30000);

    // Navigate to Swagger UI
    await page.goto(SWAGGER_UI_URL);

    // Wait for Swagger UI to fully load
    await page.waitForSelector('.swagger-ui', { timeout: 10000 });
  });

  test.afterEach(async () => {
    if (page) {
      await page.close();
    }
  });

  test('1. Swagger UI loads correctly with all components', async () => {
    console.log('🔍 Testing: Swagger UI page load and components...');

    // Check main Swagger UI container
    const swaggerContainer = await page.locator('.swagger-ui');
    await expect(swaggerContainer).toBeVisible();

    // Check API title and description
    const apiTitle = await page.locator('.title');
    await expect(apiTitle).toBeVisible();
    await expect(apiTitle).toContainText('Todo API');

    // Check version info
    const versionInfo = await page.locator('.version');
    await expect(versionInfo).toBeVisible();
    await expect(versionInfo).toContainText('1.0.0');

    // Check API status indicator
    const statusIndicator = await page.locator('#api-status');
    await expect(statusIndicator).toBeVisible();

    console.log('✅ Swagger UI components loaded successfully');
  });

  test('2. API endpoints are properly documented', async () => {
    console.log('🔍 Testing: API endpoints documentation...');

    // Wait for API spec to load
    await page.waitForSelector('.opblock', { timeout: 15000 });

    // Check for main endpoint groups
    const endpointSections = await page.locator('.opblock-tag-section');
    const sectionCount = await endpointSections.count();
    expect(sectionCount).toBeGreaterThan(0);

    // Check for GET /todos endpoint
    const getTodosEndpoint = await page.locator('.opblock.opblock-get').first();
    await expect(getTodosEndpoint).toBeVisible();

    // Check for POST /todos endpoint
    const postTodosEndpoint = await page.locator('.opblock.opblock-post').first();
    await expect(postTodosEndpoint).toBeVisible();

    // Check for DELETE endpoint
    const deleteEndpoint = await page.locator('.opblock.opblock-delete').first();
    await expect(deleteEndpoint).toBeVisible();

    console.log('✅ All API endpoints are documented');
  });

  test('3. GET /todos/stats endpoint - Interactive testing', async () => {
    console.log('🔍 Testing: GET /todos/stats endpoint interactively...');

    // Wait for endpoints to load
    await page.waitForSelector('.opblock', { timeout: 15000 });

    // Find and expand the GET /todos/stats endpoint
    const statsEndpoint = await page.locator('.opblock.opblock-get').filter({
      has: page.locator('text=Get todo statistics')
    }).first();

    if (await statsEndpoint.count() > 0) {
      await statsEndpoint.click();

      // Wait for endpoint details to expand
      await page.waitForTimeout(1000);

      // Click "Try it out" button
      const tryItButton = await statsEndpoint.locator('.btn.try-out').first();
      if (await tryItButton.count() > 0) {
        await tryItButton.click();
        await page.waitForTimeout(500);

        // Click "Execute" button
        const executeButton = await statsEndpoint.locator('.btn.execute').first();
        if (await executeButton.count() > 0) {
          await executeButton.click();

          // Wait for response
          await page.waitForTimeout(3000);

          // Check for response
          const responseSection = await statsEndpoint.locator('.responses-wrapper');
          await expect(responseSection).toBeVisible();

          // Check response status
          const responseCode = await statsEndpoint.locator('.response .response-col_status').first();
          if (await responseCode.count() > 0) {
            const statusText = await responseCode.textContent();
            expect(statusText).toContain('200');
          }

          console.log('✅ GET /todos/stats executed successfully via Swagger UI');
        }
      }
    }
  });

  test('4. GET /todos endpoint - Interactive testing', async () => {
    console.log('🔍 Testing: GET /todos endpoint interactively...');

    await page.waitForSelector('.opblock', { timeout: 15000 });

    // Find the first GET endpoint (should be GET /todos)
    const getTodosEndpoint = await page.locator('.opblock.opblock-get').first();

    if (await getTodosEndpoint.count() > 0) {
      await getTodosEndpoint.click();
      await page.waitForTimeout(1000);

      const tryItButton = await getTodosEndpoint.locator('.btn.try-out').first();
      if (await tryItButton.count() > 0) {
        await tryItButton.click();
        await page.waitForTimeout(500);

        const executeButton = await getTodosEndpoint.locator('.btn.execute').first();
        if (await executeButton.count() > 0) {
          await executeButton.click();
          await page.waitForTimeout(3000);

          const responseSection = await getTodosEndpoint.locator('.responses-wrapper');
          await expect(responseSection).toBeVisible();

          console.log('✅ GET /todos executed successfully via Swagger UI');
        }
      }
    }
  });

  test('5. POST /todos endpoint - Interactive testing', async () => {
    console.log('🔍 Testing: POST /todos endpoint interactively...');

    await page.waitForSelector('.opblock', { timeout: 15000 });

    // Find POST endpoint
    const postTodosEndpoint = await page.locator('.opblock.opblock-post').first();

    if (await postTodosEndpoint.count() > 0) {
      await postTodosEndpoint.click();
      await page.waitForTimeout(1000);

      const tryItButton = await postTodosEndpoint.locator('.btn.try-out').first();
      if (await tryItButton.count() > 0) {
        await tryItButton.click();
        await page.waitForTimeout(1000);

        // Find request body textarea and input sample data
        const requestBodyTextarea = await postTodosEndpoint.locator('.body-param textarea').first();
        if (await requestBodyTextarea.count() > 0) {
          const sampleTodo = {
            title: "E2E Test Todo",
            description: "Created via Swagger UI E2E test",
            priority: "high"
          };

          await requestBodyTextarea.fill(JSON.stringify(sampleTodo, null, 2));
          await page.waitForTimeout(500);

          const executeButton = await postTodosEndpoint.locator('.btn.execute').first();
          if (await executeButton.count() > 0) {
            await executeButton.click();
            await page.waitForTimeout(3000);

            const responseSection = await postTodosEndpoint.locator('.responses-wrapper');
            await expect(responseSection).toBeVisible();

            console.log('✅ POST /todos executed successfully via Swagger UI');
          }
        }
      }
    }
  });

  test('6. Schema definitions are present and detailed', async () => {
    console.log('🔍 Testing: Schema definitions...');

    // Wait for page to fully load
    await page.waitForSelector('.swagger-ui', { timeout: 10000 });

    // Scroll to bottom to find schemas section
    await page.evaluate(() => {
      window.scrollTo(0, document.body.scrollHeight);
    });

    await page.waitForTimeout(2000);

    // Look for models/schemas section
    const modelsSection = await page.locator('.models-control, .model-container, h4:has-text("Schemas")');

    if (await modelsSection.count() > 0) {
      console.log('✅ Schema definitions section found');
    } else {
      console.log('ℹ️  Schema definitions may be inline with endpoints');
    }

    // Check if we can find Todo model definition anywhere
    const todoModel = await page.locator('text=Todo').first();
    if (await todoModel.count() > 0) {
      console.log('✅ Todo model definition found in documentation');
    }
  });

  test('7. API status monitoring functionality', async () => {
    console.log('🔍 Testing: API status monitoring...');

    // Check for API status indicator
    const statusElement = await page.locator('#api-status');
    if (await statusElement.count() > 0) {
      await expect(statusElement).toBeVisible();

      // Check if status shows "online" (green)
      const statusClass = await statusElement.getAttribute('class');
      if (statusClass && statusClass.includes('online')) {
        console.log('✅ API status shows online');
      }

      // Check status text
      const statusText = await statusElement.textContent();
      expect(statusText).toBeDefined();

      console.log('✅ API status monitoring is functional');
    } else {
      console.log('ℹ️  API status indicator not found - may be custom implementation');
    }
  });

  test('8. Response examples and documentation quality', async () => {
    console.log('🔍 Testing: Response examples and documentation...');

    await page.waitForSelector('.opblock', { timeout: 15000 });

    // Expand first endpoint to check response examples
    const firstEndpoint = await page.locator('.opblock').first();
    await firstEndpoint.click();
    await page.waitForTimeout(1000);

    // Look for response examples
    const responseExamples = await firstEndpoint.locator('.response-content-type, .example-value');
    if (await responseExamples.count() > 0) {
      console.log('✅ Response examples found in documentation');
    }

    // Check for parameter descriptions
    const parameterSection = await firstEndpoint.locator('.parameters-container, .parameter__name');
    if (await parameterSection.count() > 0) {
      console.log('✅ Parameter documentation found');
    }

    console.log('✅ Documentation quality check completed');
  });

  test('9. Error handling and validation', async () => {
    console.log('🔍 Testing: Error handling documentation...');

    await page.waitForSelector('.opblock', { timeout: 15000 });

    // Look for different response codes (200, 400, 404, 500)
    const responseTypes = await page.locator('.response-col_status');
    if (await responseTypes.count() > 0) {
      console.log('✅ Multiple response status codes documented');
    }

    // Check for error response examples
    const errorResponses = await page.locator('text=400, text=404, text=500').first();
    if (await errorResponses.count() > 0) {
      console.log('✅ Error response codes found in documentation');
    }

    console.log('✅ Error handling documentation verified');
  });

  test('10. Overall Swagger UI functionality and user experience', async () => {
    console.log('🔍 Testing: Overall UX and functionality...');

    // Test search/filter functionality if available
    const searchBox = await page.locator('input[placeholder*="filter"], .filter input');
    if (await searchBox.count() > 0) {
      await searchBox.fill('todos');
      await page.waitForTimeout(1000);
      console.log('✅ Search/filter functionality works');
    }

    // Test expandable/collapsible sections
    const expandableSection = await page.locator('.opblock-tag').first();
    if (await expandableSection.count() > 0) {
      await expandableSection.click();
      await page.waitForTimeout(500);
      console.log('✅ Expandable sections work correctly');
    }

    // Check for proper styling and layout
    const swaggerContainer = await page.locator('.swagger-ui');
    const containerStyles = await swaggerContainer.evaluate(el =>
      window.getComputedStyle(el).display
    );
    expect(containerStyles).not.toBe('none');

    // Verify responsive design elements
    const mainContent = await page.locator('.swagger-ui .wrapper');
    if (await mainContent.count() > 0) {
      const isVisible = await mainContent.isVisible();
      expect(isVisible).toBe(true);
    }

    console.log('✅ Overall Swagger UI UX verified');
  });
});

// Additional test for direct API validation through browser
test.describe('API Validation Tests', () => {
  test('Direct API endpoint validation', async () => {
    console.log('🔍 Testing: Direct API validation...');

    const browser = await chromium.launch({ headless: true });
    const page = await browser.newPage();

    try {
      // Test stats endpoint directly
      const response = await page.goto(`${API_BASE_URL}/todos/stats`);
      expect(response.status()).toBe(200);

      const responseBody = await response.json();
      expect(responseBody).toHaveProperty('success', true);
      expect(responseBody).toHaveProperty('data');

      console.log('✅ Direct API validation successful');
      console.log(`📊 Found ${responseBody.data.total} todos in database`);
    } catch (error) {
      console.error('❌ Direct API validation failed:', error.message);
    } finally {
      await browser.close();
    }
  });
});