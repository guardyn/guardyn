/**
 * E2E Smoke Test: Login → Send Message → Logout
 *
 * This test verifies the core user flow in the desktop application:
 * 1. User logs in with credentials
 * 2. User sends a message to a conversation
 * 3. User logs out successfully
 *
 * Prerequisites:
 * - Backend services must be running (docker compose up -d)
 * - Test user must exist in the system
 */

import { expect, test, type Page } from '@playwright/test';

// Test configuration
const TEST_CONFIG = {
  // Test user credentials (use test-specific accounts)
  user1: {
    username: 'testuser1',
    password: 'TestPassword123!',
  },
  user2: {
    username: 'testuser2',
    password: 'TestPassword123!',
  },
  // Test message content
  testMessage: 'Hello from E2E smoke test! ' + Date.now(),
  // Timeouts
  loginTimeout: 10000,
  messageTimeout: 5000,
};

// Page Object helpers
class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login');
  }

  async login(username: string, password: string) {
    await this.page.fill('[data-testid="username-input"], input[name="username"]', username);
    await this.page.fill('[data-testid="password-input"], input[name="password"]', password);
    await this.page.click('[data-testid="login-button"], button[type="submit"]');
  }

  async isVisible() {
    return this.page.isVisible('[data-testid="login-form"], form');
  }
}

class ChatPage {
  constructor(private page: Page) {}

  async waitForLoad() {
    await this.page.waitForSelector('[data-testid="conversation-list"], .conversations', {
      timeout: TEST_CONFIG.loginTimeout,
    });
  }

  async selectConversation(conversationName: string) {
    await this.page.click(`[data-testid="conversation-${conversationName}"], text="${conversationName}"`);
  }

  async sendMessage(content: string) {
    await this.page.fill('[data-testid="message-input"], input[name="message"], textarea', content);
    await this.page.click('[data-testid="send-button"], button:has-text("Send")');
  }

  async isMessageVisible(content: string) {
    return this.page.isVisible(`text="${content}"`);
  }

  async getLastMessage() {
    const messages = await this.page.locator('[data-testid="message"], .message').all();
    if (messages.length === 0) return null;
    return messages[messages.length - 1].textContent();
  }
}

class SettingsPage {
  constructor(private page: Page) {}

  async openSettings() {
    await this.page.click('[data-testid="settings-button"], a[href="/settings"]');
  }

  async logout() {
    await this.page.click('[data-testid="logout-button"], button:has-text("Logout"), button:has-text("Sign Out")');
  }
}

// Test Suite
test.describe('Smoke Test: Core User Flow', () => {
  let loginPage: LoginPage;
  let chatPage: ChatPage;
  let settingsPage: SettingsPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    chatPage = new ChatPage(page);
    settingsPage = new SettingsPage(page);
  });

  test('complete user flow: login → send message → logout', async ({ page }) => {
    // Step 1: Navigate to login page
    await test.step('Navigate to login', async () => {
      await loginPage.goto();
      expect(await loginPage.isVisible()).toBeTruthy();
    });

    // Step 2: Login with test credentials
    await test.step('Login with credentials', async () => {
      await loginPage.login(TEST_CONFIG.user1.username, TEST_CONFIG.user1.password);
      await chatPage.waitForLoad();
      
      // Verify we're on the chat page
      const url = page.url();
      expect(url).toContain('/chat');
    });

    // Step 3: Send a message
    await test.step('Send a test message', async () => {
      // Select first conversation or create new one
      const conversations = await page.locator('[data-testid="conversation-item"], .conversation').all();
      
      if (conversations.length > 0) {
        await conversations[0].click();
      } else {
        // If no conversations, start a new one
        await page.click('[data-testid="new-chat-button"], button:has-text("New")');
        await page.fill('[data-testid="search-users-input"]', TEST_CONFIG.user2.username);
        await page.click(`text="${TEST_CONFIG.user2.username}"`);
      }

      // Send message
      await chatPage.sendMessage(TEST_CONFIG.testMessage);

      // Wait for message to appear
      await page.waitForSelector(`text="${TEST_CONFIG.testMessage}"`, {
        timeout: TEST_CONFIG.messageTimeout,
      });
      
      expect(await chatPage.isMessageVisible(TEST_CONFIG.testMessage)).toBeTruthy();
    });

    // Step 4: Logout
    await test.step('Logout', async () => {
      await settingsPage.openSettings();
      await settingsPage.logout();

      // Verify we're back on login page
      await page.waitForSelector('[data-testid="login-form"], form', {
        timeout: TEST_CONFIG.loginTimeout,
      });
      
      expect(await loginPage.isVisible()).toBeTruthy();
    });
  });

  test('login with invalid credentials shows error', async ({ page }) => {
    await loginPage.goto();
    await loginPage.login('invaliduser', 'wrongpassword');

    // Should show error message
    await page.waitForSelector('[data-testid="error-message"], .error, [role="alert"]', {
      timeout: 5000,
    });

    const errorText = await page.textContent('[data-testid="error-message"], .error, [role="alert"]');
    expect(errorText).toBeTruthy();
  });

  test('session persists after page reload', async ({ page }) => {
    // Login
    await loginPage.goto();
    await loginPage.login(TEST_CONFIG.user1.username, TEST_CONFIG.user1.password);
    await chatPage.waitForLoad();

    // Reload page
    await page.reload();

    // Should still be on chat page (session persisted)
    await chatPage.waitForLoad();
    const url = page.url();
    expect(url).toContain('/chat');
  });

  test('empty message cannot be sent', async ({ page }) => {
    // Login first
    await loginPage.goto();
    await loginPage.login(TEST_CONFIG.user1.username, TEST_CONFIG.user1.password);
    await chatPage.waitForLoad();

    // Select a conversation
    const conversations = await page.locator('[data-testid="conversation-item"], .conversation').all();
    if (conversations.length > 0) {
      await conversations[0].click();
    }

    // Try to send empty message
    const sendButton = page.locator('[data-testid="send-button"], button:has-text("Send")');
    
    // Button should be disabled for empty input
    await expect(sendButton).toBeDisabled();
  });

  test('keyboard shortcut Cmd/Ctrl+Enter sends message', async ({ page }) => {
    // Login first
    await loginPage.goto();
    await loginPage.login(TEST_CONFIG.user1.username, TEST_CONFIG.user1.password);
    await chatPage.waitForLoad();

    // Select a conversation
    const conversations = await page.locator('[data-testid="conversation-item"], .conversation').all();
    if (conversations.length > 0) {
      await conversations[0].click();
    }

    // Type message and press Ctrl+Enter
    const testMsg = 'Keyboard shortcut test ' + Date.now();
    await page.fill('[data-testid="message-input"], input[name="message"], textarea', testMsg);
    await page.keyboard.press('Control+Enter');

    // Message should be sent
    await page.waitForSelector(`text="${testMsg}"`, {
      timeout: TEST_CONFIG.messageTimeout,
    });
  });
});
