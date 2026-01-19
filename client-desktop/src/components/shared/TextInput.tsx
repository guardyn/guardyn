/**
 * TextInput Component
 * 
 * Styled text input with glassmorphism effects.
 */

import { Component, JSX, Show, splitProps } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export type TextInputSize = 'sm' | 'md' | 'lg';

export interface TextInputProps extends Omit<JSX.InputHTMLAttributes<HTMLInputElement>, 'size'> {
  /** Input size variant */
  size?: TextInputSize;
  /** Label text */
  label?: string;
  /** Error message */
  error?: string;
  /** Helper text */
  helper?: string;
  /** Icon to display on the left */
  leftIcon?: JSX.Element;
  /** Icon to display on the right */
  rightIcon?: JSX.Element;
  /** Additional CSS classes for the wrapper */
  wrapperClass?: string;
  /** Additional CSS classes for the input */
  class?: string;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const SIZE_CLASSES: Record<TextInputSize, { input: string; icon: string }> = {
  sm: {
    input: 'px-3 py-2 text-sm rounded-lg',
    icon: 'px-2.5',
  },
  md: {
    input: 'px-4 py-2.5 text-base rounded-xl',
    icon: 'px-3',
  },
  lg: {
    input: 'px-5 py-3 text-lg rounded-xl',
    icon: 'px-4',
  },
};

// =============================================================================
// COMPONENT
// =============================================================================

export const TextInput: Component<TextInputProps> = (props) => {
  const [local, rest] = splitProps(props, [
    'size',
    'label',
    'error',
    'helper',
    'leftIcon',
    'rightIcon',
    'wrapperClass',
    'class',
  ]);

  const size = () => local.size ?? 'md';
  const hasError = () => !!local.error;

  return (
    <div class={`flex flex-col gap-1.5 ${local.wrapperClass ?? ''}`}>
      <Show when={local.label}>
        <label class="text-sm font-medium text-neutral-700 dark:text-neutral-300">
          {local.label}
        </label>
      </Show>

      <div class="relative">
        <Show when={local.leftIcon}>
          <div class={`absolute left-0 top-0 bottom-0 flex items-center ${SIZE_CLASSES[size()].icon} text-neutral-400`}>
            {local.leftIcon}
          </div>
        </Show>

        <input
          {...rest}
          class={`
            w-full
            bg-white dark:bg-neutral-800
            border transition-all duration-200
            ${hasError()
              ? 'border-red-500 focus:border-red-500 focus:ring-red-500/30'
              : 'border-neutral-200 dark:border-neutral-700 focus:border-guardyn-500 focus:ring-guardyn-500/30'
            }
            focus:outline-none focus:ring-2
            text-neutral-900 dark:text-white
            placeholder:text-neutral-400 dark:placeholder:text-neutral-500
            disabled:opacity-50 disabled:cursor-not-allowed disabled:bg-neutral-100 dark:disabled:bg-neutral-900
            ${SIZE_CLASSES[size()].input}
            ${local.leftIcon ? 'pl-10' : ''}
            ${local.rightIcon ? 'pr-10' : ''}
            ${local.class ?? ''}
          `}
        />

        <Show when={local.rightIcon}>
          <div class={`absolute right-0 top-0 bottom-0 flex items-center ${SIZE_CLASSES[size()].icon} text-neutral-400`}>
            {local.rightIcon}
          </div>
        </Show>
      </div>

      <Show when={local.error}>
        <p class="text-sm text-red-500 dark:text-red-400">{local.error}</p>
      </Show>

      <Show when={local.helper && !local.error}>
        <p class="text-sm text-neutral-500 dark:text-neutral-400">{local.helper}</p>
      </Show>
    </div>
  );
};

export default TextInput;
