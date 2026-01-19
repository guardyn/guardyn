/// <reference types="vitest" />
import '@testing-library/jest-dom/vitest';
import { Component, JSX } from 'solid-js';

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

// Mock @solidjs/router to avoid client-only API issues
vi.mock('@solidjs/router', () => {
  // Create mock Router component that just renders children
  const MockRouter: Component<{ children?: JSX.Element }> = (props) => props.children;
  const MockRoute: Component<{ path: string; component?: Component }> = () => null;
  const MockA: Component<{ href: string; children?: JSX.Element; class?: string }> = (props) => {
    // Return a span that renders children - this ensures text content is accessible
    return <span data-href={props.href} class={props.class}>{props.children}</span>;
  };
  
  return {
    Router: MockRouter,
    Route: MockRoute,
    A: MockA,
    useNavigate: () => vi.fn(),
    useLocation: () => ({ pathname: '/', search: '', hash: '', state: null }),
    useParams: () => ({}),
    useSearchParams: () => [{}, vi.fn()],
  };
});

// Reset mocks before each test
beforeEach(() => {
  mockInvoke.mockClear();
});

// Expose mock for tests
export { mockInvoke };
