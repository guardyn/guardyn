/// <reference types="vitest" />
import '@testing-library/jest-dom/vitest';

// Mock Tauri API for testing
const mockInvoke = vi.fn();

vi.mock('@tauri-apps/api/core', () => ({
  invoke: mockInvoke,
}));

// Reset mocks before each test
beforeEach(() => {
  mockInvoke.mockClear();
});

// Expose mock for tests
export { mockInvoke };
