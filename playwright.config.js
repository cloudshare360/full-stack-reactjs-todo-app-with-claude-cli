// @ts-check
const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './',
  testMatch: '**/swagger-ui-e2e.test.js',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 1,
  workers: process.env.CI ? 1 : 1,
  reporter: [
    ['html', { outputFolder: 'e2e-test-results' }],
    ['json', { outputFile: 'e2e-test-results.json' }],
    ['list']
  ],
  use: {
    baseURL: 'http://localhost:8080',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 30000,
    navigationTimeout: 30000,
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],

  webServer: [
    {
      command: 'cd swagger-ui && python3 -m http.server 8080',
      port: 8080,
      timeout: 120 * 1000,
      reuseExistingServer: !process.env.CI,
    }
  ],
});