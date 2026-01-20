/**
 * LazyRoute - Component for lazy loading routes with Suspense
 *
 * Provides code splitting support for route components with:
 * - Dynamic imports for reduced initial bundle size
 * - Loading skeleton during component load
 * - Error boundary for failed imports
 *
 * @module components/shared/LazyRoute
 */

import {
  Component,
  JSX,
  Suspense,
  ErrorBoundary,
  For,
  lazy,
} from 'solid-js';
import Shimmer from './Shimmer';

// =============================================================================
// SKELETON DATA
// =============================================================================

const LIST_SKELETON_ITEMS = [0, 1, 2, 3, 4, 5, 6, 7];
const FORM_SKELETON_ITEMS = [0, 1, 2, 3, 4];

// =============================================================================
// LOADING SKELETON
// =============================================================================

/**
 * Full-page loading skeleton for route transitions
 */
export const RouteLoadingSkeleton: Component = () => {
  return (
    <div class="flex-1 flex flex-col h-full animate-pulse">
      {/* Header skeleton */}
      <div class="h-16 border-b border-gray-200 dark:border-gray-700 flex items-center px-6">
        <Shimmer class="w-10 h-10 rounded-full" />
        <div class="ml-4 space-y-2">
          <Shimmer class="w-32 h-4 rounded" />
          <Shimmer class="w-20 h-3 rounded" />
        </div>
      </div>

      {/* Content skeleton */}
      <div class="flex-1 p-6 space-y-4">
        <div class="flex items-start gap-3">
          <Shimmer class="w-8 h-8 rounded-full flex-shrink-0" />
          <div class="space-y-2">
            <Shimmer class="w-48 h-16 rounded-lg" />
            <Shimmer class="w-20 h-3 rounded" />
          </div>
        </div>
        <div class="flex items-start gap-3 justify-end">
          <div class="space-y-2 text-right">
            <Shimmer class="w-64 h-12 rounded-lg" />
            <Shimmer class="w-16 h-3 rounded ml-auto" />
          </div>
        </div>
        <div class="flex items-start gap-3">
          <Shimmer class="w-8 h-8 rounded-full flex-shrink-0" />
          <div class="space-y-2">
            <Shimmer class="w-56 h-20 rounded-lg" />
            <Shimmer class="w-24 h-3 rounded" />
          </div>
        </div>
      </div>

      {/* Input skeleton */}
      <div class="h-20 border-t border-gray-200 dark:border-gray-700 flex items-center px-4 gap-3">
        <Shimmer class="w-10 h-10 rounded-full" />
        <Shimmer class="flex-1 h-12 rounded-xl" />
        <Shimmer class="w-10 h-10 rounded-full" />
      </div>
    </div>
  );
};

/**
 * Sidebar/List loading skeleton
 */
export const ListLoadingSkeleton: Component = () => {
  return (
    <div class="flex flex-col h-full animate-pulse p-4 space-y-3">
      {/* Search skeleton */}
      <Shimmer class="w-full h-10 rounded-lg" />

      {/* List items */}
      <For each={LIST_SKELETON_ITEMS}>
        {() => (
          <div class="flex items-center gap-3 p-3 rounded-lg">
            <Shimmer class="w-12 h-12 rounded-full flex-shrink-0" />
            <div class="flex-1 space-y-2">
              <Shimmer class="w-3/4 h-4 rounded" />
              <Shimmer class="w-1/2 h-3 rounded" />
            </div>
            <Shimmer class="w-8 h-3 rounded" />
          </div>
        )}
      </For>
    </div>
  );
};

/**
 * Form/Settings loading skeleton
 */
export const FormLoadingSkeleton: Component = () => {
  return (
    <div class="flex flex-col h-full animate-pulse p-8 space-y-6 max-w-2xl mx-auto">
      {/* Title */}
      <Shimmer class="w-48 h-8 rounded" />

      {/* Form fields */}
      <For each={FORM_SKELETON_ITEMS}>
        {() => (
          <div class="space-y-2">
            <Shimmer class="w-24 h-4 rounded" />
            <Shimmer class="w-full h-12 rounded-lg" />
          </div>
        )}
      </For>

      {/* Button */}
      <Shimmer class="w-32 h-12 rounded-lg mt-4" />
    </div>
  );
};

// =============================================================================
// ERROR FALLBACK
// =============================================================================

interface ErrorFallbackProps {
  error: Error;
  reset: () => void;
}

const ErrorFallback: Component<ErrorFallbackProps> = (props) => {
  return (
    <div class="flex-1 flex flex-col items-center justify-center p-8 text-center">
      <div class="w-16 h-16 rounded-full bg-red-100 dark:bg-red-900/30 flex items-center justify-center mb-4">
        <svg
          class="w-8 h-8 text-red-600 dark:text-red-400"
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
      <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">
        Failed to load page
      </h2>
      <p class="text-gray-600 dark:text-gray-400 mb-6 max-w-md">
        {props.error.message || 'An unexpected error occurred while loading this page.'}
      </p>
      <button
        onClick={() => props.reset()}
        class="px-6 py-3 bg-guardyn-500 hover:bg-guardyn-600 text-white rounded-lg font-medium transition-colors"
      >
        Try Again
      </button>
    </div>
  );
};

// =============================================================================
// LAZY ROUTE WRAPPER
// =============================================================================

export interface LazyRouteProps {
  /** The lazy-loaded component */
  children: JSX.Element;
  /** Custom loading skeleton */
  fallback?: JSX.Element;
}

/**
 * Wrapper component for lazy-loaded routes
 * Provides Suspense boundary with loading skeleton and error handling
 */
export const LazyRoute: Component<LazyRouteProps> = (props) => {
  return (
    <ErrorBoundary
      fallback={(err, reset) => <ErrorFallback error={err} reset={reset} />}
    >
      <Suspense fallback={props.fallback || <RouteLoadingSkeleton />}>
        {props.children}
      </Suspense>
    </ErrorBoundary>
  );
};

// =============================================================================
// LAZY COMPONENT CREATOR
// =============================================================================

type ComponentProps = Record<string, unknown>;

/**
 * Creates a lazy-loaded component wrapper with automatic code splitting
 *
 * Uses SolidJS's built-in `lazy()` for optimal code splitting with Vite.
 * Each lazy component creates a separate chunk in the build output.
 *
 * @param importFn - Dynamic import function
 * @param fallback - Optional custom loading fallback
 * @returns Lazy-loaded component
 *
 * @example
 * // In routes file:
 * const LazySettings = createLazyComponent(() => import('./pages/Settings'));
 * const LazyChat = createLazyComponent(() => import('./pages/Chat'));
 *
 * // In router:
 * <Route path="/settings" component={LazySettings} />
 */
export function createLazyComponent<T extends Component<ComponentProps>>(
  importFn: () => Promise<{ default: T }>,
  fallback?: JSX.Element
): Component<ComponentProps> {
  const LazyComp = lazy(importFn);

  return (props: ComponentProps) => {
    return (
      <ErrorBoundary
        fallback={(err, reset) => <ErrorFallback error={err} reset={reset} />}
      >
        <Suspense fallback={fallback || <RouteLoadingSkeleton />}>
          <LazyComp {...props} />
        </Suspense>
      </ErrorBoundary>
    );
  };
}

export default LazyRoute;
