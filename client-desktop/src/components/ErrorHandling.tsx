/**
 * Error Boundary Component
 *
 * Catches JavaScript errors anywhere in the child component tree,
 * logs those errors, and displays a fallback UI.
 */

import { Component, createSignal, For, JSX, Show, ErrorBoundary as SolidErrorBoundary } from 'solid-js';

interface ErrorDisplayProps {
  error: Error;
  reset: () => void;
}

/**
 * Error display component with retry option
 */
const ErrorDisplay: Component<ErrorDisplayProps> = (props) => {
  return (
    <div class="flex flex-col items-center justify-center min-h-[200px] p-6 text-center">
      <div class="w-16 h-16 mb-4 rounded-full bg-red-900/20 flex items-center justify-center">
        <svg
          class="w-8 h-8 text-red-500"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
          />
        </svg>
      </div>

      <h3 class="text-lg font-semibold text-white mb-2">Something went wrong</h3>

      <p class="text-gray-400 text-sm mb-4 max-w-md">{props.error.message}</p>

      <button
        onClick={props.reset}
        class="px-4 py-2 bg-guardyn-600 hover:bg-guardyn-700 text-white rounded-lg transition-colors"
      >
        Try Again
      </button>

      {/* Show stack trace in development */}
      {import.meta.env.DEV && (
        <details class="mt-4 text-left w-full max-w-lg">
          <summary class="text-gray-500 text-sm cursor-pointer hover:text-gray-400">
            Error details
          </summary>
          <pre class="mt-2 p-3 bg-gray-800 rounded-lg text-xs text-gray-400 overflow-auto max-h-48">
            {props.error.stack}
          </pre>
        </details>
      )}
    </div>
  );
};

interface ErrorBoundaryProps {
  children: JSX.Element;
  fallback?: (error: Error, reset: () => void) => JSX.Element;
}

/**
 * Error Boundary wrapper component
 */
export const ErrorBoundary: Component<ErrorBoundaryProps> = (props) => {
  return (
    <SolidErrorBoundary
      fallback={(error, reset) => {
        console.error('Error caught by boundary:', error);

        if (props.fallback) {
          return props.fallback(error, reset);
        }

        return <ErrorDisplay error={error} reset={reset} />;
      }}
    >
      {props.children}
    </SolidErrorBoundary>
  );
};

/**
 * Toast notification types
 */
export type ToastType = 'success' | 'error' | 'warning' | 'info';

interface Toast {
  id: string;
  type: ToastType;
  message: string;
  duration?: number;
}

/**
 * Toast notification state and methods
 */
const [toasts, setToasts] = createSignal<Toast[]>([]);

export function showToast(type: ToastType, message: string, duration = 5000) {
  const id = Math.random().toString(36).substring(2, 9);
  const toast: Toast = { id, type, message, duration };

  setToasts((prev) => [...prev, toast]);

  if (duration > 0) {
    setTimeout(() => {
      dismissToast(id);
    }, duration);
  }

  return id;
}

export function dismissToast(id: string) {
  setToasts((prev) => prev.filter((t) => t.id !== id));
}

/**
 * Toast container component
 */
export const ToastContainer: Component = () => {
  const getToastStyles = (type: ToastType): string => {
    const base = 'flex items-center p-4 rounded-lg shadow-lg transition-all';
    switch (type) {
      case 'success':
        return `${base} bg-green-900/90 text-green-100 border border-green-700`;
      case 'error':
        return `${base} bg-red-900/90 text-red-100 border border-red-700`;
      case 'warning':
        return `${base} bg-yellow-900/90 text-yellow-100 border border-yellow-700`;
      case 'info':
        return `${base} bg-blue-900/90 text-blue-100 border border-blue-700`;
    }
  };

  const getIcon = (type: ToastType) => {
    switch (type) {
      case 'success':
        return (
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        );
      case 'error':
        return (
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        );
      case 'warning':
        return (
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        );
      case 'info':
        return (
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        );
    }
  };

  return (
    <div class="fixed bottom-4 right-4 z-50 space-y-2">
      <For each={toasts()}>
        {(toast) => (
          <div class={getToastStyles(toast.type)}>
            {getIcon(toast.type)}
            <span class="flex-1">{toast.message}</span>
            <button
              onClick={() => dismissToast(toast.id)}
              class="ml-3 opacity-70 hover:opacity-100"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        )}
      </For>
    </div>
  );
};

/**
 * Loading spinner component
 */
interface LoadingSpinnerProps {
  size?: 'sm' | 'md' | 'lg';
  class?: string;
}

export const LoadingSpinner: Component<LoadingSpinnerProps> = (props) => {
  const sizeClasses = {
    sm: 'w-4 h-4',
    md: 'w-8 h-8',
    lg: 'w-12 h-12',
  };

  return (
    <svg
      class={`animate-spin ${sizeClasses[props.size || 'md']} ${props.class || ''}`}
      fill="none"
      viewBox="0 0 24 24"
    >
      <circle
        class="opacity-25"
        cx="12"
        cy="12"
        r="10"
        stroke="currentColor"
        stroke-width="4"
      />
      <path
        class="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      />
    </svg>
  );
};

/**
 * Empty state component
 */
interface EmptyStateProps {
  icon?: JSX.Element;
  title: string;
  description?: string;
  action?: {
    label: string;
    onClick: () => void;
  };
}

export const EmptyState: Component<EmptyStateProps> = (props) => {
  return (
    <div class="flex flex-col items-center justify-center p-8 text-center">
      <Show when={props.icon}>
        <div class="w-16 h-16 mb-4 rounded-full bg-gray-800 flex items-center justify-center text-gray-500">
          {props.icon}
        </div>
      </Show>

      <h3 class="text-lg font-medium text-white mb-1">{props.title}</h3>

      <Show when={props.description}>
        <p class="text-gray-400 text-sm mb-4 max-w-sm">{props.description}</p>
      </Show>

      <Show when={props.action}>
        <button
          onClick={props.action!.onClick}
          class="px-4 py-2 bg-guardyn-600 hover:bg-guardyn-700 text-white rounded-lg transition-colors"
        >
          {props.action!.label}
        </button>
      </Show>
    </div>
  );
};

export default ErrorBoundary;
