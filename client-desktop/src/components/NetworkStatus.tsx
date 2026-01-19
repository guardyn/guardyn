/**
 * Network Status Components
 *
 * Provides offline detection and status indicators for the application.
 * Shows banner when connection is lost and handles reconnection.
 */

import { Component, createSignal, onCleanup, onMount, Show } from 'solid-js';
import { showToast } from './ErrorHandling';

/**
 * Network status state
 */
const [isOnline, setIsOnline] = createSignal(navigator.onLine);
const [isReconnecting, setIsReconnecting] = createSignal(false);
const [lastOnlineTime, setLastOnlineTime] = createSignal<Date | null>(null);

/**
 * Initialize network status listeners
 */
export function initNetworkListeners() {
  const handleOnline = () => {
    setIsOnline(true);
    setIsReconnecting(false);
    showToast('success', 'Connection restored');
  };

  const handleOffline = () => {
    setIsOnline(false);
    setLastOnlineTime(new Date());
    showToast('warning', 'You are offline. Some features may not be available.');
  };

  window.addEventListener('online', handleOnline);
  window.addEventListener('offline', handleOffline);

  return () => {
    window.removeEventListener('online', handleOnline);
    window.removeEventListener('offline', handleOffline);
  };
}

/**
 * Hook to use network status
 */
export function useNetworkStatus() {
  return {
    isOnline,
    isReconnecting,
    lastOnlineTime,
  };
}

/**
 * Offline banner component
 */
export const OfflineBanner: Component = () => {
  onMount(() => {
    const cleanup = initNetworkListeners();
    onCleanup(cleanup);
  });

  const handleRetry = async () => {
    setIsReconnecting(true);
    
    try {
      // Try to fetch a small resource to test connectivity
      const response = await fetch('/api/health', {
        method: 'HEAD',
        cache: 'no-cache',
      });
      
      if (response.ok) {
        setIsOnline(true);
        showToast('success', 'Connection restored');
      }
    } catch {
      showToast('error', 'Still offline. Please check your connection.');
    } finally {
      setIsReconnecting(false);
    }
  };

  const getOfflineDuration = () => {
    const last = lastOnlineTime();
    if (!last) return null;
    
    const diff = Date.now() - last.getTime();
    const minutes = Math.floor(diff / 60000);
    
    if (minutes < 1) return 'just now';
    if (minutes === 1) return '1 minute ago';
    if (minutes < 60) return `${minutes} minutes ago`;
    
    const hours = Math.floor(minutes / 60);
    if (hours === 1) return '1 hour ago';
    return `${hours} hours ago`;
  };

  return (
    <Show when={!isOnline()}>
      <div
        class="fixed top-0 left-0 right-0 z-50 bg-yellow-900/95 border-b border-yellow-700 px-4 py-3"
        role="alert"
        aria-live="polite"
      >
        <div class="flex items-center justify-between max-w-4xl mx-auto">
          <div class="flex items-center gap-3">
            {/* Offline icon */}
            <svg
              class="w-5 h-5 text-yellow-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              aria-hidden="true"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M18.364 5.636a9 9 0 010 12.728m0 0l-2.829-2.829m2.829 2.829L21 21M15.536 8.464a5 5 0 010 7.072m0 0l-2.829-2.829m-4.243 2.829a4.978 4.978 0 01-1.414-2.83m-1.414 5.658a9 9 0 01-2.167-9.238m7.824 2.167a1 1 0 111.414 1.414m-1.414-1.414L3 3m8.293 8.293l1.414 1.414"
              />
            </svg>
            
            <div>
              <p class="text-yellow-100 font-medium">You're offline</p>
              <Show when={lastOnlineTime()}>
                <p class="text-yellow-300/70 text-sm">
                  Lost connection {getOfflineDuration()}
                </p>
              </Show>
            </div>
          </div>

          <button
            onClick={handleRetry}
            disabled={isReconnecting()}
            class="flex items-center gap-2 px-4 py-1.5 bg-yellow-700 hover:bg-yellow-600 disabled:opacity-50 disabled:cursor-not-allowed text-yellow-100 rounded-lg transition-colors text-sm font-medium"
            aria-label="Retry connection"
          >
            <Show when={isReconnecting()} fallback={<span>Retry</span>}>
              <svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
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
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
                />
              </svg>
              <span>Reconnecting...</span>
            </Show>
          </button>
        </div>
      </div>
    </Show>
  );
};

/**
 * Connection status indicator (small)
 */
interface ConnectionStatusProps {
  class?: string;
}

export const ConnectionStatus: Component<ConnectionStatusProps> = (props) => {
  return (
    <div
      class={`flex items-center gap-1.5 ${props.class || ''}`}
      role="status"
      aria-label={isOnline() ? 'Connected' : 'Offline'}
    >
      <span
        class={`w-2 h-2 rounded-full ${
          isOnline() ? 'bg-green-500' : 'bg-yellow-500 animate-pulse'
        }`}
      />
      <span class="text-xs text-gray-400">
        {isOnline() ? 'Connected' : 'Offline'}
      </span>
    </div>
  );
};

/**
 * Retry button component for failed operations
 */
interface RetryButtonProps {
  onRetry: () => void | Promise<void>;
  loading?: boolean;
  class?: string;
  size?: 'sm' | 'md' | 'lg';
}

export const RetryButton: Component<RetryButtonProps> = (props) => {
  const [isRetrying, setIsRetrying] = createSignal(false);

  const handleClick = async () => {
    setIsRetrying(true);
    try {
      await props.onRetry();
    } finally {
      setIsRetrying(false);
    }
  };

  const sizeClasses = {
    sm: 'px-3 py-1 text-sm',
    md: 'px-4 py-2',
    lg: 'px-6 py-3 text-lg',
  };

  const loading = () => props.loading ?? isRetrying();

  return (
    <button
      onClick={handleClick}
      disabled={loading()}
      class={`flex items-center gap-2 bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed text-gray-900 dark:text-white rounded-lg transition-colors ${sizeClasses[props.size || 'md']} ${props.class || ''}`}
      aria-label="Retry"
    >
      <Show
        when={loading()}
        fallback={
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
            />
          </svg>
        }
      >
        <svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
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
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
          />
        </svg>
      </Show>
      <span>{loading() ? 'Retrying...' : 'Retry'}</span>
    </button>
  );
};

/**
 * Error state with retry option
 */
interface ErrorStateProps {
  title?: string;
  message: string;
  onRetry?: () => void | Promise<void>;
  retryLabel?: string;
}

export const ErrorState: Component<ErrorStateProps> = (props) => {
  return (
    <div
      class="flex flex-col items-center justify-center p-8 text-center"
      role="alert"
      aria-live="assertive"
    >
      {/* Error icon */}
      <div class="w-16 h-16 mb-4 rounded-full bg-red-900/20 flex items-center justify-center">
        <svg
          class="w-8 h-8 text-red-500"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
          />
        </svg>
      </div>

      <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
        {props.title || 'Something went wrong'}
      </h3>

      <p class="text-gray-600 dark:text-gray-400 text-sm mb-4 max-w-md">{props.message}</p>

      <Show when={props.onRetry}>
        <RetryButton onRetry={props.onRetry!} />
      </Show>
    </div>
  );
};

export default OfflineBanner;
