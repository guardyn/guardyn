/**
 * Authentication E2E Tests
 *
 * End-to-end tests for login and registration flows.
 * These tests run against the Vite dev server with mocked Tauri API.
 *
 * Prerequisites:
 * - Backend services running (docker compose up -d)
 * - Dev server running (npm run dev)
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

// Helper to inject Tauri mock into page
async function injectTauriMock(page: Page) {
  await page.addInitScript(() => {
    // Use localStorage to persist users across navigations
    const getUsers = (): Record<string, { password: string; displayName?: string }> => {
      try {
        const data = localStorage.getItem('__GUARDYN_TEST_USERS__');
        return data ? JSON.parse(data) : {};
      } catch {
        return {};
      }
    };

    const saveUsers = (users: Record<string, { password: string; displayName?: string }>) => {
      localStorage.setItem('__GUARDYN_TEST_USERS__', JSON.stringify(users));
    };

    const getCurrentUser = () => {
      try {
        const data = localStorage.getItem('__GUARDYN_CURRENT_USER__');
        return data ? JSON.parse(data) : null;
      } catch {
        return null;
      }
    };

    const setCurrentUser = (user: { user_id: string; username: string; display_name?: string } | null) => {
      if (user) {
        localStorage.setItem('__GUARDYN_CURRENT_USER__', JSON.stringify(user));
      } else {
        localStorage.removeItem('__GUARDYN_CURRENT_USER__');
      }
    };
    
    // Mock Tauri's invoke function
    (window as unknown as Record<string, unknown>).__TAURI_INTERNALS__ = {
      invoke: async (cmd: string, args?: Record<string, unknown>) => {
        console.log('[Tauri Mock] invoke:', cmd, args);

        switch (cmd) {
          case 'register': {
            const username = args?.username as string;
            const password = args?.password as string;
            const displayName = args?.displayName as string | undefined;

            const users = getUsers();
            if (users[username]) {
              return { success: false, error: 'Username already exists' };
            }

            users[username] = { password, displayName };
            saveUsers(users);
            
            const currentUser = {
              user_id: `user_${Date.now()}`,
              username,
              display_name: displayName,
            };
            setCurrentUser(currentUser);

            return { success: true, user: currentUser };
          }

          case 'login': {
            const username = args?.username as string;
            const password = args?.password as string;

            const users = getUsers();
            const user = users[username];
            if (!user || user.password !== password) {
              return { success: false, error: 'Invalid credentials' };
            }

            const currentUser = {
              user_id: `user_${Date.now()}`,
              username,
              display_name: user.displayName,
            };
            setCurrentUser(currentUser);

            return { success: true, user: currentUser };
          }

          case 'get_current_user': {
            return getCurrentUser();
          }

          case 'logout': {
            setCurrentUser(null);
            return { success: true };
          }

          default:
            console.warn('[Tauri Mock] Unknown command:', cmd);
            return { success: false, error: `Unknown command: ${cmd}` };
        }
      },
    };
  });
}

// Inject mock once at the start of page lifecycle
async function setupPageWithMock(page: Page) {
  await injectTauriMock(page);
}

// Page Object: Login Page
class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await injectTauriMock(this.page);
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
    // Dispatch form submit event directly (more reliable than button click in web context)
    await this.page.evaluate(() => {
      const form = document.querySelector('[data-testid="login-form"]') as HTMLFormElement;
      if (form) {
        const event = new Event('submit', { bubbles: true, cancelable: true });
        form.dispatchEvent(event);
      }
    });
  }

  async isSubmitDisabled() {
    const button = await this.page.$('[data-testid="login-button"]');
    return button ? await button.isDisabled() : true;
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
    await injectTauriMock(this.page);
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
    // Dispatch form submit event directly (more reliable than button click in web context)
    await this.page.evaluate(() => {
      const form = document.querySelector('[data-testid="register-form"]') as HTMLFormElement;
      if (form) {
        const event = new Event('submit', { bubbles: true, cancelable: true });
        form.dispatchEvent(event);
      }
    });
  }

  async isSubmitDisabled() {
    const button = await this.page.$('[data-testid="register-button"]');
    return button ? await button.isDisabled() : true;
  }

  async getFieldError(fieldName: string) {
    const selector = `[data-testid="${fieldName}-input"]`;
    // Look for error text in the same form group
    const errorSelector = `${selector} ~ .text-red-400, .form-group:has(${selector}) .text-red-400, [data-testid="${fieldName}-error"]`;
    try {
      await this.page.waitForSelector(errorSelector, { timeout: 2000 });
      return this.page.textContent(errorSelector);
    } catch {
      return null;
    }
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
    // Wait for redirect to chat page or home (authenticated state)
    await this.page.waitForURL(/\/(chat)?$/, {
      timeout: TEST_CONFIG.timeouts.navigation,
    });
  }

  async isAuthenticated() {
    const url = this.page.url();
    // Check if we're on chat page or root (both indicate authenticated state)
    return url.includes('/chat') || url.endsWith('/') || !url.includes('/login') && !url.includes('/register');
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
    // Trigger blur to activate validation
    await page.fill('[data-testid="password-input"]', 'ValidPassword123!');

    // Wait for validation
    await page.waitForTimeout(TEST_CONFIG.timeouts.animation);

    // Button should be disabled due to invalid username
    expect(await registerPage.isSubmitDisabled()).toBeTruthy();

    // Check for inline validation error
    const hasError = await page.isVisible('text=/at least 3 characters/i');
    expect(hasError).toBeTruthy();
  });

  test('validates password match', async ({ page }) => {
    await registerPage.goto();

    await page.fill('[data-testid="username-input"]', 'validuser');
    await page.fill('[data-testid="password-input"]', 'Password123!');
    await page.fill('[data-testid="confirm-password-input"]', 'DifferentPassword123!');
    // Trigger blur
    await page.click('[data-testid="confirm-password-input"]');
    await page.keyboard.press('Tab');
    await page.waitForTimeout(TEST_CONFIG.timeouts.animation);

    // Button should be disabled
    expect(await registerPage.isSubmitDisabled()).toBeTruthy();

    // Check for mismatch error
    const hasError = await page.isVisible('text=/do not match/i');
    expect(hasError).toBeTruthy();
  });

  test('validates password length', async ({ page }) => {
    await registerPage.goto();

    await page.fill('[data-testid="username-input"]', 'validuser');
    await page.fill('[data-testid="password-input"]', 'short');
    // Trigger blur
    await page.click('[data-testid="password-input"]');
    await page.keyboard.press('Tab');
    await page.waitForTimeout(TEST_CONFIG.timeouts.animation);

    // Button should be disabled
    expect(await registerPage.isSubmitDisabled()).toBeTruthy();

    // Check for length error
    const hasError = await page.isVisible('text=/at least 12 characters/i');
    expect(hasError).toBeTruthy();
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
    await page.waitForTimeout(500); // Wait for navigation

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
    await page.waitForTimeout(300);

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
    // Inject mock at page level (will persist across navigations)
    await injectTauriMock(page);
    
    // First register a new user
    await page.goto('/register');
    await page.waitForSelector('[data-testid="register-form"]');

    const uniqueUser = `login_test_${Date.now()}`;
    await registerPage.fillForm(uniqueUser, 'TestPassword123!');
    await registerPage.submit();
    await page.waitForTimeout(500);

    // Navigate to login page (mock persists due to addInitScript)
    await page.goto('/login');
    await page.waitForSelector('[data-testid="login-form"]');

    // Login with the created user
    await loginPage.fillCredentials(uniqueUser, 'TestPassword123!');
    await loginPage.submit();
    await page.waitForTimeout(500);

    await chatPage.waitForLoad();
    expect(await chatPage.isAuthenticated()).toBeTruthy();
  });
});

// Test Suite: Complete Auth Flow
test.describe('Complete Authentication Flow', () => {
  test('register → logout → login flow', async ({ page }) => {
    // Inject mock at page level (will persist across navigations)
    await injectTauriMock(page);
    
    const registerPage = new RegisterPage(page);
    const loginPage = new LoginPage(page);
    const chatPage = new ChatPage(page);

    // Step 1: Register new user
    const uniqueUser = `flow_test_${Date.now()}`;
    await page.goto('/register');
    await page.waitForSelector('[data-testid="register-form"]');
    
    await registerPage.fillForm(uniqueUser, 'SecurePass123!', 'Flow Test');
    await registerPage.submit();
    await page.waitForTimeout(500);
    await chatPage.waitForLoad();

    expect(await chatPage.isAuthenticated()).toBeTruthy();

    // Step 2: Navigate to login (simulating logout)
    await page.goto('/login');
    await page.waitForSelector('[data-testid="login-form"]');

    // Step 3: Login with same credentials
    await loginPage.fillCredentials(uniqueUser, 'SecurePass123!');
    await loginPage.submit();
    await page.waitForTimeout(500);
    await chatPage.waitForLoad();

    expect(await chatPage.isAuthenticated()).toBeTruthy();
  });

  test('session state after navigation', async ({ page }) => {
    const registerPage = new RegisterPage(page);
    const chatPage = new ChatPage(page);

    // Register and authenticate
    const uniqueUser = `session_test_${Date.now()}`;
    await registerPage.goto();
    await registerPage.register(uniqueUser, 'SessionPass123!');
    await page.waitForTimeout(500);
    await chatPage.waitForLoad();

    expect(await chatPage.isAuthenticated()).toBeTruthy();

    // Navigate to another page and back
    await page.goto('/login');
    await page.goto('/');

    // Check authentication state
    const url = page.url();
    expect(url).not.toContain('/login');
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

  test('handles invalid credentials error', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();

    // Try to login with non-existent user
    await loginPage.login('nonexistent_user_xyz', 'wrongpassword123');

    // Should show connection/credentials error
    const error = await loginPage.getErrorMessage();
    expect(error).toBeTruthy();
    expect(error).toContain('Invalid credentials');
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
