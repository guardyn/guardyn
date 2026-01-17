/**
 * E2E Smoke Test Configuration
 *
 * Playwright configuration for Tauri desktop app testing.
 */

import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 30000,
  retries: 2,
  workers: 1, // Run tests sequentially for stability
  reporter: [['html', { outputFolder: 'e2e-report' }]],

  use: {
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    {
      name: 'tauri',
      use: {
        ...devices['Desktop Chrome'],
        // Tauri uses WebView, similar to Chrome
        launchOptions: {
          // Custom launch options for Tauri
        },
      },
    },
  ],
});
