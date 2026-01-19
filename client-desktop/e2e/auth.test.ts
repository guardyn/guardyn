/**
 * Authentication E2E Tests
 *
 * End-to-end tests for login and registration flows.
 * These tests run against the actual Tauri desktop application.
 *
 * Prerequisites:
 * - Backend services running (docker compose up -d)
 * - Tauri app built (npm run tauri:build)
 */

import { expect, test, type Page } from '@playwright/test';

// Test configuration
const TEST_CONFIG = {
  // Unique test user credentials (use timestamp to avoid conflicts)
  testUser: {
    username: `testuser_${Date.now()}`,
    displayName: 'Test User E2E',
    password: 'TestPassword123!',
  },
  existingUser: {
    username: 'alice',
    password: 'alice123',
  },
  timeouts: {
    navigation: 10000,
    animation: 500,
    form: 5000,
  },
};

// Page Object: Login Page
class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login');
    await this.page.waitForSelector('[data-testid="login-form"]', {
      timeout: TEST_CONFIG.timeouts.navigation,
    });
  }

  async isVisible() {
    return this.page.isVisible('[data-testid="login-form"]');
  }

  async fillCredentials(username: string, password: string) {
    await this.page.fill('[data-testid="username-input"]', username);
    await this.page.fill('[data-testid="password-input"]', password);
  }

  async submit() {
    await this.page.click('[data-testid="login-button"]');
  }

  async login(username: string, password: string) {
    await this.fillCredentials(username, password);
    await this.submit();
  }

  async getErrorMessage() {
    try {
      await this.page.waitForSelector('[data-testid="error-message"]', {
        timeout: TEST_CONFIG.timeouts.form,
      });
      return this.page.textContent('[data-testid="error-message"]');
    } catch {
      return null;
    }
  }

  async goToRegister() {
    await this.page.click('a[href="/register"]');
  }
}

// Page Object: Register Page
class RegisterPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/register');
    await this.page.waitForSelector('[data-testid="register-form"]', {
      timeout: TEST_CONFIG.timeouts.navigation,
    });
  }

  async isVisible() {
    return this.page.isVisible('[data-testid="register-form"]');
  }

  async fillForm(username: string, password: string, displayName?: string) {
    await this.page.fill('[data-testid="username-input"]', username);
    if (displayName) {
      await this.page.fill('[data-testid="display-name-input"]', displayName);
    }
    await this.page.fill('[data-testid="password-input"]', password);
    await this.page.fill('[data-testid="confirm-password-input"]', password);
  }

  async submit() {
    await this.page.click('[data-testid="register-button"]');
  }

  async register(username: string, password: string, displayName?: string) {
    await this.fillForm(username, password, displayName);
    await this.submit();
  }

  async getErrorMessage() {
    try {
      await this.page.waitForSelector('[data-testid="error-message"]', {
        timeout: TEST_CONFIG.timeouts.form,
      });
      return this.page.textContent('[data-testid="error-message"]');
    } catch {
      return null;
    }
  }

  async goToLogin() {
    await this.page.click('a[href="/login"]');
  }

  async isPasswordStrengthVisible() {
    return this.page.isVisible('.password-strength');
  }
}

// Page Object: Chat Page (post-authentication)
class ChatPage {
  constructor(private page: Page) {}

  async waitForLoad() {
    await this.page.waitForSelector('[data-testid="conversation-list"], .conversations, [data-testid="chat-container"]', {
      timeout: TEST_CONFIG.timeouts.navigation,
    });
  }

  async isAuthenticated() {
    const url = this.page.url();
    return url.includes('/chat') || url === '/';
  }
}

// Test Suite: Registration Flow
test.describe('Registration Flow', () => {
  let registerPage: RegisterPage;
  let chatPage: ChatPage;

  test.beforeEach(async ({ page }) => {
    registerPage = new RegisterPage(page);
    chatPage = new ChatPage(page);
  });

  test('displays registration form with all fields', async ({ page }) => {
    await registerPage.goto();

    expect(await registerPage.isVisible()).toBeTruthy();
    expect(await page.isVisible('[data-testid="username-input"]')).toBeTruthy();
    expect(await page.isVisible('[data-testid="display-name-input"]')).toBeTruthy();
    expect(await page.isVisible('[data-testid="password-input"]')).toBeTruthy();
    expect(await page.isVisible('[data-testid="confirm-password-input"]')).toBeTruthy();
    expect(await page.isVisible('[data-testid="register-button"]')).toBeTruthy();
  });

  test('shows security badges', async ({ page }) => {
    await registerPage.goto();

    expect(await page.isVisible('text="E2E Encrypted"')).toBeTruthy();
    expect(await page.isVisible('text="Post-Quantum Ready"')).toBeTruthy();
  });

  test('validates username length', async ({ page }) => {
    await registerPage.goto();

    await page.fill('[data-testid="username-input"]', 'ab');
    await page.fill('[data-testid="password-input"]', 'ValidPassword123!');
    await page.fill('[data-testid="confirm-password-input"]', 'ValidPassword123!');
    await page.click('[data-testid="username-input"]'); // trigger blur

    // Wait for validation
    await page.waitForTimeout(TEST_CONFIG.timeouts.animation);
    await registerPage.submit();

    const error = await registerPage.getErrorMessage();
    expect(error).toContain('at least 3 characters');
  });

  test('validates password match', async ({ page }) => {
    await registerPage.goto();

    await page.fill('[data-testid="username-input"]', 'validuser');
    await page.fill('[data-testid="password-input"]', 'Password123!');
    await page.fill('[data-testid="confirm-password-input"]', 'DifferentPassword123!');
    await page.click('[data-testid="confirm-password-input"]');
    await page.waitForTimeout(TEST_CONFIG.timeouts.animation);

    await registerPage.submit();

    const error = await registerPage.getErrorMessage();
    expect(error).toContain('do not match');
  });

  test('validates password length', async ({ page }) => {
    await registerPage.goto();

    await page.fill('[data-testid="username-input"]', 'validuser');
    await page.fill('[data-testid="password-input"]', 'short');
    await page.fill('[data-testid="confirm-password-input"]', 'short');
    await page.click('[data-testid="password-input"]');
    await page.waitForTimeout(TEST_CONFIG.timeouts.animation);

    await registerPage.submit();

    const error = await registerPage.getErrorMessage();
    expect(error).toContain('at least 8 characters');
  });

  test('shows password strength indicator', async ({ page }) => {
    await registerPage.goto();

    await page.fill('[data-testid="password-input"]', 'weak');
    await page.waitForTimeout(TEST_CONFIG.timeouts.animation);

    expect(await registerPage.isPasswordStrengthVisible()).toBeTruthy();
    expect(await page.isVisible('text="Weak"')).toBeTruthy();

    await page.fill('[data-testid="password-input"]', 'StrongPassword123!');
    await page.waitForTimeout(TEST_CONFIG.timeouts.animation);

    // Should show stronger rating
    const strengthText = await page.textContent('.password-strength');
    expect(strengthText).toMatch(/Strong|Excellent/);
  });

  test('navigates to login page via link', async ({ page }) => {
    await registerPage.goto();
    await registerPage.goToLogin();

    const loginPage = new LoginPage(page);
    await page.waitForTimeout(TEST_CONFIG.timeouts.animation);

    expect(await loginPage.isVisible()).toBeTruthy();
  });

  test('successful registration redirects to chat', async ({ page }) => {
    await registerPage.goto();

    const uniqueUser = `e2e_${Date.now()}`;
    await registerPage.register(uniqueUser, 'TestPassword123!', 'E2E Test User');

    await chatPage.waitForLoad();
    expect(await chatPage.isAuthenticated()).toBeTruthy();
  });
});

// Test Suite: Login Flow
test.describe('Login Flow', () => {
  let loginPage: LoginPage;
  let registerPage: RegisterPage;
  let chatPage: ChatPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    registerPage = new RegisterPage(page);
    chatPage = new ChatPage(page);
  });

  test('displays login form with all fields', async ({ page }) => {
    await loginPage.goto();

    expect(await loginPage.isVisible()).toBeTruthy();
    expect(await page.isVisible('[data-testid="username-input"]')).toBeTruthy();
    expect(await page.isVisible('[data-testid="password-input"]')).toBeTruthy();
    expect(await page.isVisible('[data-testid="login-button"]')).toBeTruthy();
  });

  test('shows branding and security info', async ({ page }) => {
    await loginPage.goto();

    expect(await page.isVisible('text="Guardyn"')).toBeTruthy();
    expect(await page.isVisible('text="Secure Communication Platform"')).toBeTruthy();
    expect(await page.isVisible('text="E2E Encrypted"')).toBeTruthy();
  });

  test('validates empty username', async ({ page }) => {
    await loginPage.goto();

    await page.fill('[data-testid="password-input"]', 'somepassword');
    await loginPage.submit();

    const error = await loginPage.getErrorMessage();
    expect(error).toContain('Username is required');
  });

  test('validates empty password', async ({ page }) => {
    await loginPage.goto();

    await page.fill('[data-testid="username-input"]', 'someuser');
    await loginPage.submit();

    const error = await loginPage.getErrorMessage();
    expect(error).toContain('Password is required');
  });

  test('shows error for invalid credentials', async ({ page }) => {
    await loginPage.goto();

    await loginPage.login('nonexistent_user', 'wrongpassword');

    const error = await loginPage.getErrorMessage();
    expect(error).toBeTruthy();
  });

  test('navigates to register page via link', async ({ page }) => {
    await loginPage.goto();
    await loginPage.goToRegister();

    await page.waitForTimeout(TEST_CONFIG.timeouts.animation);
    expect(await registerPage.isVisible()).toBeTruthy();
  });

  test('successful login redirects to chat', async ({ page }) => {
    // First register a new user
    await registerPage.goto();
    const uniqueUser = `login_test_${Date.now()}`;
    await registerPage.register(uniqueUser, 'TestPassword123!');
    await chatPage.waitForLoad();

    // Logout (if there's a logout mechanism in UI)
    // For now, just navigate to login
    await loginPage.goto();

    // Login with the created user
    await loginPage.login(uniqueUser, 'TestPassword123!');
    await chatPage.waitForLoad();

    expect(await chatPage.isAuthenticated()).toBeTruthy();
  });
});

// Test Suite: Complete Auth Flow
test.describe('Complete Authentication Flow', () => {
  test('register → logout → login flow', async ({ page }) => {
    const registerPage = new RegisterPage(page);
    const loginPage = new LoginPage(page);
    const chatPage = new ChatPage(page);

    // Step 1: Register new user
    const uniqueUser = `flow_test_${Date.now()}`;
    await registerPage.goto();
    await registerPage.register(uniqueUser, 'SecurePass123!', 'Flow Test');
    await chatPage.waitForLoad();

    expect(await chatPage.isAuthenticated()).toBeTruthy();

    // Step 2: Navigate to login (simulating logout)
    await loginPage.goto();

    // Step 3: Login with same credentials
    await loginPage.login(uniqueUser, 'SecurePass123!');
    await chatPage.waitForLoad();

    expect(await chatPage.isAuthenticated()).toBeTruthy();
  });

  test('session persists after page reload', async ({ page }) => {
    const registerPage = new RegisterPage(page);
    const chatPage = new ChatPage(page);

    // Register and authenticate
    const uniqueUser = `session_test_${Date.now()}`;
    await registerPage.goto();
    await registerPage.register(uniqueUser, 'SessionPass123!');
    await chatPage.waitForLoad();

    // Reload page
    await page.reload();

    // Should still be authenticated
    await chatPage.waitForLoad();
    expect(await chatPage.isAuthenticated()).toBeTruthy();
  });
});

// Test Suite: Error Handling
test.describe('Error Handling', () => {
  test('dismisses error alert', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();

    // Trigger an error
    await loginPage.login('invalid', 'invalid');
    await page.waitForSelector('[data-testid="error-message"]', {
      timeout: TEST_CONFIG.timeouts.form,
    });

    // Find and click dismiss button
    const dismissButton = page.locator('[data-testid="error-message"] button');
    if (await dismissButton.isVisible()) {
      await dismissButton.click();
      await page.waitForTimeout(TEST_CONFIG.timeouts.animation);

      expect(await page.isVisible('[data-testid="error-message"]')).toBeFalsy();
    }
  });

  test('handles network timeout gracefully', async ({ page }) => {
    // Simulate slow network by setting timeout
    await page.route('**/api/**', async (route) => {
      await new Promise((resolve) => setTimeout(resolve, 15000));
      await route.abort();
    });

    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('testuser', 'testpass');

    // Should show connection error
    const error = await loginPage.getErrorMessage();
    expect(error).toBeTruthy();
  });
});

// Test Suite: Accessibility
test.describe('Accessibility', () => {
  test('login form is keyboard navigable', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();

    // Tab through form elements
    await page.keyboard.press('Tab');
    const activeElement1 = await page.evaluate(() => document.activeElement?.getAttribute('data-testid'));
    expect(activeElement1).toBe('username-input');

    await page.keyboard.press('Tab');
    const activeElement2 = await page.evaluate(() => document.activeElement?.getAttribute('data-testid'));
    expect(activeElement2).toBe('password-input');
  });

  test('form can be submitted with Enter key', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();

    await page.fill('[data-testid="username-input"]', 'testuser');
    await page.fill('[data-testid="password-input"]', 'testpass');
    await page.keyboard.press('Enter');

    // Should attempt login (will show error for invalid creds)
    await page.waitForTimeout(TEST_CONFIG.timeouts.form);
    const error = await loginPage.getErrorMessage();
    expect(error).toBeTruthy(); // Error means form was submitted
  });

  test('error messages have proper ARIA attributes', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();

    await loginPage.login('invalid', 'invalid');
    await page.waitForSelector('[data-testid="error-message"]', {
      timeout: TEST_CONFIG.timeouts.form,
    });

    const role = await page.getAttribute('[data-testid="error-message"]', 'role');
    expect(role).toBe('alert');
  });
});
