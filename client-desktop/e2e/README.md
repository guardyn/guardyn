# E2E Testing for Guardyn Desktop

## Prerequisites

1. Install Playwright:

   ```bash
   npm install -D @playwright/test
   npx playwright install
   ```

2. Start backend services:

   ```bash
   docker compose -f docker-compose.dev.yml up -d
   ```

3. Create test users (if not existing):
   ```bash
   # The test requires two users: testuser1 and testuser2
   # You can create them via the API or registration flow
   ```

## Running E2E Tests

### Run all E2E tests

```bash
npx playwright test
```

### Run smoke test only

```bash
npx playwright test e2e/smoke.test.ts
```

### Run with UI mode (interactive)

```bash
npx playwright test --ui
```

### Run with debug mode

```bash
npx playwright test --debug
```

## Test Coverage

### Smoke Test (`smoke.test.ts`)

- ✅ Login with valid credentials
- ✅ Send message to conversation
- ✅ Logout successfully
- ✅ Login with invalid credentials shows error
- ✅ Session persists after page reload
- ✅ Empty message cannot be sent
- ✅ Keyboard shortcut Ctrl+Enter sends message

## Configuration

Edit `playwright.config.ts` to customize:

- Test timeout
- Retries
- Screenshots/video on failure
- Browser options

## Troubleshooting

### Tests fail to find elements

- Ensure the app uses consistent `data-testid` attributes
- Update selectors in test files if component structure changes

### Backend connection errors

- Verify backend services are running: `docker compose ps`
- Check logs: `docker compose logs -f auth-service`

### Tauri-specific issues

- For Tauri apps, you may need `@playwright/test` with custom WebDriver setup
- Consider using `tauri-driver` for more accurate testing
