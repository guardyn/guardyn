/// <reference types="vitest" />
import '@testing-library/jest-dom/vitest';
import { Component, JSX } from 'solid-js';

// Mock browser APIs for jsdom that are needed by solid-router and theme detection
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

// Note: @tauri-apps/api/core mock is defined in each test file that needs it
// using vi.hoisted() for proper module mocking

// Mock WebSocket modules to prevent actual connections during tests
vi.mock('../api/websocket', () => ({
  MessageType: {
    TEXT_MESSAGE: 'TEXT_MESSAGE',
    TYPING_START: 'TYPING_START',
    TYPING_STOP: 'TYPING_STOP',
    PRESENCE_UPDATE: 'PRESENCE_UPDATE',
    READ_RECEIPT: 'READ_RECEIPT',
    DELIVERED_RECEIPT: 'DELIVERED_RECEIPT',
    MESSAGE_DELETED: 'MESSAGE_DELETED',
    MESSAGE_EDITED: 'MESSAGE_EDITED',
    REACTION_ADDED: 'REACTION_ADDED',
    REACTION_REMOVED: 'REACTION_REMOVED',
  },
  initWebSocket: vi.fn(),
  getWebSocket: vi.fn(() => ({
    connect: vi.fn(),
    disconnect: vi.fn(),
    send: vi.fn(),
    on: vi.fn(),
    off: vi.fn(),
    isConnected: false,
  })),
  destroyWebSocket: vi.fn(),
}));

vi.mock('../api/websocket.mock', () => ({
  startMockGenerator: vi.fn(),
  stopMockGenerator: vi.fn(),
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

