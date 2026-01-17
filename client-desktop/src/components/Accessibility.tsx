/**
 * Accessibility (a11y) Components
 *
 * Provides accessibility utilities for screen readers,
 * focus management, and ARIA support.
 */

import { Component, createEffect, JSX, onCleanup, onMount, ParentComponent } from 'solid-js';

/**
 * VisuallyHidden - Hide content visually but keep it accessible to screen readers
 */
interface VisuallyHiddenProps {
  children: JSX.Element;
  as?: keyof JSX.IntrinsicElements;
}

export const VisuallyHidden: ParentComponent<VisuallyHiddenProps> = (props) => {
  const Tag = (props.as || 'span') as keyof JSX.IntrinsicElements;
  
  return (
    <Tag
      class="absolute w-px h-px p-0 -m-px overflow-hidden whitespace-nowrap border-0"
      style={{ clip: 'rect(0, 0, 0, 0)' }}
    >
      {props.children}
    </Tag>
  );
};

/**
 * SkipLink - Allows keyboard users to skip navigation and jump to main content
 */
interface SkipLinkProps {
  targetId: string;
  children?: JSX.Element;
}

export const SkipLink: Component<SkipLinkProps> = (props) => {
  return (
    <a
      href={`#${props.targetId}`}
      class="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-guardyn-600 focus:text-white focus:rounded-lg focus:outline-none focus:ring-2 focus:ring-guardyn-400"
    >
      {props.children || 'Skip to main content'}
    </a>
  );
};

/**
 * FocusTrap - Traps focus within a container (for modals, dialogs)
 */
interface FocusTrapProps {
  children: JSX.Element;
  active?: boolean;
  restoreFocus?: boolean;
  autoFocus?: boolean;
}

export const FocusTrap: ParentComponent<FocusTrapProps> = (props) => {
  let containerRef: HTMLDivElement | undefined;
  let previousActiveElement: Element | null = null;

  const getFocusableElements = () => {
    if (!containerRef) return [];
    
    const selector = [
      'button:not([disabled])',
      'input:not([disabled])',
      'select:not([disabled])',
      'textarea:not([disabled])',
      'a[href]',
      '[tabindex]:not([tabindex="-1"])',
    ].join(',');
    
    return Array.from(containerRef.querySelectorAll(selector)) as HTMLElement[];
  };

  const handleKeyDown = (e: KeyboardEvent) => {
    if (!props.active || e.key !== 'Tab') return;
    
    const focusableElements = getFocusableElements();
    if (focusableElements.length === 0) return;
    
    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];
    
    if (e.shiftKey) {
      // Shift + Tab: If on first element, move to last
      if (document.activeElement === firstElement) {
        e.preventDefault();
        lastElement.focus();
      }
    } else {
      // Tab: If on last element, move to first
      if (document.activeElement === lastElement) {
        e.preventDefault();
        firstElement.focus();
      }
    }
  };

  createEffect(() => {
    if (props.active !== false) {
      previousActiveElement = document.activeElement;
      
      // Auto-focus first focusable element
      if (props.autoFocus !== false) {
        requestAnimationFrame(() => {
          const focusableElements = getFocusableElements();
          if (focusableElements.length > 0) {
            focusableElements[0].focus();
          }
        });
      }
    }
  });

  onCleanup(() => {
    // Restore focus to previous element
    if (props.restoreFocus !== false && previousActiveElement) {
      (previousActiveElement as HTMLElement).focus?.();
    }
  });

  return (
    <div
      ref={containerRef}
      onKeyDown={handleKeyDown}
    >
      {props.children}
    </div>
  );
};

/**
 * LiveRegion - Announces dynamic content changes to screen readers
 */
interface LiveRegionProps {
  'aria-live'?: 'polite' | 'assertive' | 'off';
  'aria-atomic'?: boolean;
  children: JSX.Element;
  class?: string;
}

export const LiveRegion: ParentComponent<LiveRegionProps> = (props) => {
  return (
    <div
      aria-live={props['aria-live'] || 'polite'}
      aria-atomic={props['aria-atomic'] ?? true}
      class={props.class}
    >
      {props.children}
    </div>
  );
};

/**
 * Announce - Visually hidden live region for announcements
 */
interface AnnounceProps {
  message: string;
  type?: 'polite' | 'assertive';
}

export const Announce: Component<AnnounceProps> = (props) => {
  return (
    <VisuallyHidden>
      <LiveRegion aria-live={props.type || 'polite'}>
        {props.message}
      </LiveRegion>
    </VisuallyHidden>
  );
};

/**
 * useAnnounce - Hook for programmatic announcements
 */
export function createAnnouncer() {
  let announceElement: HTMLDivElement | null = null;

  onMount(() => {
    announceElement = document.createElement('div');
    announceElement.setAttribute('aria-live', 'polite');
    announceElement.setAttribute('aria-atomic', 'true');
    announceElement.className = 'absolute w-px h-px p-0 -m-px overflow-hidden whitespace-nowrap border-0';
    announceElement.style.clip = 'rect(0, 0, 0, 0)';
    document.body.appendChild(announceElement);
  });

  onCleanup(() => {
    if (announceElement) {
      document.body.removeChild(announceElement);
    }
  });

  return {
    announce: (message: string, type: 'polite' | 'assertive' = 'polite') => {
      if (announceElement) {
        announceElement.setAttribute('aria-live', type);
        // Clear first to ensure re-announcement
        announceElement.textContent = '';
        requestAnimationFrame(() => {
          if (announceElement) {
            announceElement.textContent = message;
          }
        });
      }
    },
  };
}

/**
 * A11yButton - Accessible button with proper ARIA attributes
 */
interface A11yButtonProps {
  onClick: () => void;
  children: JSX.Element;
  disabled?: boolean;
  loading?: boolean;
  ariaLabel?: string;
  ariaDescribedBy?: string;
  ariaExpanded?: boolean;
  ariaPressed?: boolean;
  ariaHaspopup?: boolean | 'menu' | 'listbox' | 'tree' | 'grid' | 'dialog';
  class?: string;
  type?: 'button' | 'submit' | 'reset';
}

export const A11yButton: Component<A11yButtonProps> = (props) => {
  return (
    <button
      type={props.type || 'button'}
      onClick={props.onClick}
      disabled={props.disabled || props.loading}
      aria-label={props.ariaLabel}
      aria-describedby={props.ariaDescribedBy}
      aria-expanded={props.ariaExpanded}
      aria-pressed={props.ariaPressed}
      aria-haspopup={props.ariaHaspopup}
      aria-busy={props.loading}
      aria-disabled={props.disabled || props.loading}
      class={props.class}
    >
      {props.children}
    </button>
  );
};

/**
 * FormField - Accessible form field with label and error handling
 */
interface FormFieldProps {
  id: string;
  label: string;
  error?: string;
  required?: boolean;
  hint?: string;
  children: JSX.Element;
}

export const FormField: ParentComponent<FormFieldProps> = (props) => {
  const errorId = `${props.id}-error`;
  const hintId = `${props.id}-hint`;
  
  const describedBy = () => {
    const parts: string[] = [];
    if (props.error) parts.push(errorId);
    if (props.hint) parts.push(hintId);
    return parts.length > 0 ? parts.join(' ') : undefined;
  };

  return (
    <div class="space-y-1">
      <label
        for={props.id}
        class="block text-sm font-medium text-gray-200"
      >
        {props.label}
        {props.required && (
          <span class="text-red-400 ml-1" aria-hidden="true">*</span>
        )}
        {props.required && (
          <VisuallyHidden> (required)</VisuallyHidden>
        )}
      </label>
      
      <div
        aria-describedby={describedBy()}
      >
        {props.children}
      </div>
      
      {props.hint && !props.error && (
        <p id={hintId} class="text-sm text-gray-400">
          {props.hint}
        </p>
      )}
      
      {props.error && (
        <p id={errorId} class="text-sm text-red-400" role="alert">
          {props.error}
        </p>
      )}
    </div>
  );
};

/**
 * useReducedMotion - Detect user preference for reduced motion
 */
export function useReducedMotion() {
  const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
  const [prefersReduced, setPrefersReduced] = createSignal(mediaQuery.matches);

  onMount(() => {
    const handler = (e: MediaQueryListEvent) => setPrefersReduced(e.matches);
    mediaQuery.addEventListener('change', handler);
    onCleanup(() => mediaQuery.removeEventListener('change', handler));
  });

  return prefersReduced;
}

import { createSignal } from 'solid-js';

/**
 * useHighContrast - Detect user preference for high contrast
 */
export function useHighContrast() {
  const mediaQuery = window.matchMedia('(prefers-contrast: more)');
  const [prefersHighContrast, setPrefersHighContrast] = createSignal(mediaQuery.matches);

  onMount(() => {
    const handler = (e: MediaQueryListEvent) => setPrefersHighContrast(e.matches);
    mediaQuery.addEventListener('change', handler);
    onCleanup(() => mediaQuery.removeEventListener('change', handler));
  });

  return prefersHighContrast;
}

export default {
  VisuallyHidden,
  SkipLink,
  FocusTrap,
  LiveRegion,
  Announce,
  A11yButton,
  FormField,
};
