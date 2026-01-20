import { Component, createEffect, createSignal, onCleanup, Show } from 'solid-js';

interface LazyImageProps {
  src: string;
  alt: string;
  class?: string;
  placeholderClass?: string;
  width?: number;
  height?: number;
  onClick?: () => void;
  /** Root margin for intersection observer (e.g., "100px") */
  rootMargin?: string;
  /** Threshold for intersection observer (0-1) */
  threshold?: number;
}

/**
 * LazyImage - Image component with lazy loading and placeholder
 * 
 * Features:
 * - Loads image only when visible in viewport
 * - Shows shimmer placeholder while loading
 * - Smooth fade-in transition on load
 * - Configurable intersection observer settings
 */
export const LazyImage: Component<LazyImageProps> = (props) => {
  let containerRef: HTMLDivElement | undefined;
  
  const [isInView, setIsInView] = createSignal(false);
  const [isLoaded, setIsLoaded] = createSignal(false);
  const [hasError, setHasError] = createSignal(false);
  
  createEffect(() => {
    if (!containerRef) return;
    
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setIsInView(true);
            observer.disconnect();
          }
        });
      },
      {
        rootMargin: props.rootMargin ?? '100px',
        threshold: props.threshold ?? 0,
      }
    );
    
    observer.observe(containerRef);
    
    onCleanup(() => observer.disconnect());
  });
  
  const handleLoad = () => {
    setIsLoaded(true);
  };
  
  const handleError = () => {
    setHasError(true);
    setIsLoaded(true);
  };
  
  return (
    <div
      ref={containerRef}
      class={`relative overflow-hidden ${props.class ?? ''}`}
      style={{
        width: props.width ? `${props.width}px` : undefined,
        height: props.height ? `${props.height}px` : undefined,
      }}
      onClick={() => props.onClick?.()}
    >
      {/* Shimmer placeholder */}
      <Show when={!isLoaded()}>
        <div 
          class={`absolute inset-0 bg-gradient-to-r from-gray-200 via-gray-300 to-gray-200 dark:from-gray-700 dark:via-gray-600 dark:to-gray-700 animate-shimmer ${props.placeholderClass ?? ''}`}
          style={{
            'background-size': '200% 100%',
          }}
        />
      </Show>
      
      {/* Actual image */}
      <Show when={isInView()}>
        <Show
          when={!hasError()}
          fallback={
            <div class="absolute inset-0 flex items-center justify-center bg-gray-200 dark:bg-gray-700">
              <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
            </div>
          }
        >
          <img
            src={props.src}
            alt={props.alt}
            class={`w-full h-full object-cover transition-opacity duration-300 ${isLoaded() ? 'opacity-100' : 'opacity-0'}`}
            onLoad={handleLoad}
            onError={handleError}
            loading="lazy"
          />
        </Show>
      </Show>
    </div>
  );
};

export default LazyImage;
