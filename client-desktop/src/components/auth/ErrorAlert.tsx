/**
 * Error Alert Component
 *
 * Animated error message display with dismiss capability.
 */

import { Component, Show } from 'solid-js';

interface ErrorAlertProps {
  message: string;
  onDismiss?: () => void;
}

const ErrorAlert: Component<ErrorAlertProps> = (props) => {
  return (
    <Show when={props.message}>
      <div
        class="error-alert relative bg-red-500/10 border border-red-500/30 backdrop-blur-sm rounded-xl px-4 py-3 animate-shake"
        role="alert"
        data-testid="error-message"
      >
        <div class="flex items-start gap-3">
          {/* Icon */}
          <div class="flex-shrink-0 mt-0.5">
            <svg
              class="w-5 h-5 text-red-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>

          {/* Message */}
          <p class="flex-1 text-sm text-red-300">{props.message}</p>

          {/* Dismiss button */}
          <Show when={props.onDismiss}>
            <button
              type="button"
              onClick={() => props.onDismiss?.()}
              class="flex-shrink-0 text-red-400 hover:text-red-300 transition-colors"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </Show>
        </div>
      </div>
    </Show>
  );
};

export default ErrorAlert;
