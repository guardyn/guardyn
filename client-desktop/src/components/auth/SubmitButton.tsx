/**
 * Submit Button Component
 *
 * Animated button with loading state and hover effects.
 */

import { Component, JSX, Show } from 'solid-js';

interface SubmitButtonProps {
  children: JSX.Element;
  loading?: boolean;
  disabled?: boolean;
  type?: 'submit' | 'button';
  onClick?: () => void;
  'data-testid'?: string;
}

const SubmitButton: Component<SubmitButtonProps> = (props) => {
  return (
    <button
      type={props.type || 'submit'}
      disabled={props.loading || props.disabled}
      onClick={() => props.onClick?.()}
      data-testid={props['data-testid'] || 'submit-button'}
      class="submit-btn relative w-full py-3.5 px-4 rounded-xl font-medium text-white overflow-hidden transition-all duration-300 disabled:cursor-not-allowed group"
      classList={{
        'bg-gradient-to-r from-guardyn-600 to-guardyn-500 hover:from-guardyn-500 hover:to-guardyn-400 hover:shadow-lg hover:shadow-guardyn-500/25': !props.disabled && !props.loading,
        'bg-gray-700 opacity-60': props.disabled || props.loading,
      }}
    >
      {/* Shine effect */}
      <div class="absolute inset-0 -translate-x-full group-hover:translate-x-full transition-transform duration-700 bg-gradient-to-r from-transparent via-white/10 to-transparent" />

      {/* Content */}
      <div class="relative flex items-center justify-center gap-2">
        <Show when={props.loading}>
          <svg class="animate-spin h-5 w-5" viewBox="0 0 24 24">
            <circle
              class="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              stroke-width="4"
              fill="none"
            />
            <path
              class="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            />
          </svg>
        </Show>
        <span classList={{ 'opacity-0': props.loading }}>{props.children}</span>
      </div>
    </button>
  );
};

export default SubmitButton;
