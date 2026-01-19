/// <reference types="vitest" />
import '@testing-library/jest-dom/vitest';

// Mock browser APIs for jsdom that are needed by solid-router
if (typeof window !== 'undefined') {
  // Mock history API if needed
  Object.defineProperty(window, 'scrollTo', {
    value: vi.fn(),
    writable: true,
  });

  // Mock matchMedia for theme detection
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: vi.fn().mockImplementation((query: string) => ({
      matches: query === '(prefers-color-scheme: dark)',
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  });
}

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
