/**
 * Button Component
 * 
 * Neumorphic button with multiple variants and sizes.
 */

import { Component, JSX, Show, splitProps } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'ghost';
export type ButtonSize = 'sm' | 'md' | 'lg';

export interface ButtonProps extends JSX.ButtonHTMLAttributes<HTMLButtonElement> {
  /** Button visual variant */
  variant?: ButtonVariant;
  /** Button size */
  size?: ButtonSize;
  /** Whether button is in loading state */
  loading?: boolean;
  /** Icon to display before text */
  leftIcon?: JSX.Element;
  /** Icon to display after text */
  rightIcon?: JSX.Element;
  /** Additional CSS classes */
  class?: string;
  /** Button content */
  children?: JSX.Element;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const VARIANT_CLASSES: Record<ButtonVariant, string> = {
  primary: `
    bg-guardyn-500 text-white
    hover:bg-guardyn-600 active:bg-guardyn-700
    dark:bg-guardyn-600 dark:hover:bg-guardyn-500
    shadow-neumorphic-btn active:shadow-neumorphic-pressed
    dark:shadow-neumorphic-btn-dark dark:active:shadow-neumorphic-pressed-dark
  `,
  secondary: `
    bg-neutral-100 text-neutral-900
    hover:bg-neutral-200 active:bg-neutral-300
    dark:bg-neutral-800 dark:text-neutral-100
    dark:hover:bg-neutral-700 dark:active:bg-neutral-600
    shadow-neumorphic-btn active:shadow-neumorphic-pressed
    dark:shadow-neumorphic-btn-dark dark:active:shadow-neumorphic-pressed-dark
  `,
  danger: `
    bg-red-500 text-white
    hover:bg-red-600 active:bg-red-700
    dark:bg-red-600 dark:hover:bg-red-500
    shadow-neumorphic-btn active:shadow-neumorphic-pressed
    dark:shadow-neumorphic-btn-dark dark:active:shadow-neumorphic-pressed-dark
  `,
  ghost: `
    bg-transparent text-neutral-700
    hover:bg-neutral-100 active:bg-neutral-200
    dark:text-neutral-300
    dark:hover:bg-neutral-800 dark:active:bg-neutral-700
  `,
};

const SIZE_CLASSES: Record<ButtonSize, string> = {
  sm: 'px-3 py-1.5 text-sm rounded-lg gap-1.5',
  md: 'px-4 py-2 text-base rounded-xl gap-2',
  lg: 'px-6 py-3 text-lg rounded-xl gap-2.5',
};

// =============================================================================
// COMPONENT
// =============================================================================

export const Button: Component<ButtonProps> = (props) => {
  const [local, rest] = splitProps(props, [
    'variant',
    'size',
    'loading',
    'leftIcon',
    'rightIcon',
    'class',
    'children',
    'disabled',
  ]);

  const variant = () => local.variant ?? 'primary';
  const size = () => local.size ?? 'md';
  const isDisabled = () => local.disabled || local.loading;

  return (
    <button
      {...rest}
      disabled={isDisabled()}
      class={`
        inline-flex items-center justify-center
        font-medium transition-all duration-200
        focus:outline-none focus:ring-2 focus:ring-guardyn-500/50 focus:ring-offset-2
        dark:focus:ring-offset-neutral-900
        disabled:opacity-50 disabled:cursor-not-allowed disabled:shadow-none
        ${VARIANT_CLASSES[variant()]}
        ${SIZE_CLASSES[size()]}
        ${local.class ?? ''}
      `}
    >
      <Show when={local.loading}>
        <svg class="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
        </svg>
      </Show>
      <Show when={!local.loading && local.leftIcon}>
        {local.leftIcon}
      </Show>
      {local.children}
      <Show when={!local.loading && local.rightIcon}>
        {local.rightIcon}
      </Show>
    </button>
  );
};

export default Button;
