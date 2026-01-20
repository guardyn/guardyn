/**
 * Shimmer - Loading placeholder with shimmer animation
 *
 * A simple shimmer/skeleton component for loading states.
 * Uses CSS animation for smooth, performant shimmer effect.
 *
 * @module components/shared/Shimmer
 */

import { Component, JSX, mergeProps, splitProps } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export interface ShimmerProps extends JSX.HTMLAttributes<HTMLDivElement> {
  /** Additional class names */
  class?: string;
  /** Width (CSS value or Tailwind class handled via class prop) */
  width?: string;
  /** Height (CSS value or Tailwind class handled via class prop) */
  height?: string;
  /** Border radius (CSS value) */
  rounded?: string;
}

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * Shimmer placeholder component
 *
 * @example
 * <Shimmer class="w-32 h-4 rounded" />
 * <Shimmer class="w-full h-12 rounded-lg" />
 * <Shimmer class="w-10 h-10 rounded-full" />
 */
const Shimmer: Component<ShimmerProps> = (props) => {
  const merged = mergeProps(
    {
      class: '',
      width: undefined,
      height: undefined,
      rounded: undefined,
    },
    props
  );

  const [local, others] = splitProps(merged, ['class', 'width', 'height', 'rounded']);

  return (
    <div
      class={`shimmer bg-gray-200 dark:bg-gray-700 ${local.class}`}
      style={{
        width: local.width,
        height: local.height,
        'border-radius': local.rounded,
      }}
      {...others}
    />
  );
};

export default Shimmer;
