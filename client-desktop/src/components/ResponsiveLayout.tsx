/**
 * Responsive Layout Components
 *
 * Provides responsive layout utilities for handling different window sizes
 * in the desktop application.
 */

import {
    Component,
    createContext,
    createSignal,
    JSX,
    onCleanup,
    onMount,
    ParentComponent,
    Show,
    useContext,
} from 'solid-js';

/**
 * Breakpoint definitions
 */
export const breakpoints = {
  sm: 640,
  md: 768,
  lg: 1024,
  xl: 1280,
  '2xl': 1536,
} as const;

export type Breakpoint = keyof typeof breakpoints;

/**
 * Window size state
 */
interface WindowSize {
  width: number;
  height: number;
}

/**
 * Responsive context
 */
interface ResponsiveContextType {
  windowSize: () => WindowSize;
  isMobile: () => boolean;
  isTablet: () => boolean;
  isDesktop: () => boolean;
  isLargeDesktop: () => boolean;
  isMinWidth: (breakpoint: Breakpoint) => boolean;
  isMaxWidth: (breakpoint: Breakpoint) => boolean;
  isBetween: (min: Breakpoint, max: Breakpoint) => boolean;
}

const ResponsiveContext = createContext<ResponsiveContextType>();

/**
 * Hook to use responsive context
 */
export function useResponsive() {
  const context = useContext(ResponsiveContext);
  if (!context) {
    throw new Error('useResponsive must be used within ResponsiveProvider');
  }
  return context;
}

/**
 * Responsive Provider Component
 */
export const ResponsiveProvider: ParentComponent = (props) => {
  const [windowSize, setWindowSize] = createSignal<WindowSize>({
    width: window.innerWidth,
    height: window.innerHeight,
  });

  onMount(() => {
    const handleResize = () => {
      setWindowSize({
        width: window.innerWidth,
        height: window.innerHeight,
      });
    };

    window.addEventListener('resize', handleResize);
    onCleanup(() => window.removeEventListener('resize', handleResize));
  });

  const isMinWidth = (breakpoint: Breakpoint) => windowSize().width >= breakpoints[breakpoint];
  const isMaxWidth = (breakpoint: Breakpoint) => windowSize().width < breakpoints[breakpoint];

  const contextValue: ResponsiveContextType = {
    windowSize,
    isMobile: () => windowSize().width < breakpoints.md,
    isTablet: () => windowSize().width >= breakpoints.md && windowSize().width < breakpoints.lg,
    isDesktop: () => windowSize().width >= breakpoints.lg,
    isLargeDesktop: () => windowSize().width >= breakpoints.xl,
    isMinWidth,
    isMaxWidth,
    isBetween: (min, max) => isMinWidth(min) && isMaxWidth(max),
  };

  return (
    <ResponsiveContext.Provider value={contextValue}>
      {props.children}
    </ResponsiveContext.Provider>
  );
};

/**
 * Show component only above certain breakpoint
 */
interface ShowAboveProps {
  breakpoint: Breakpoint;
  children: JSX.Element;
  fallback?: JSX.Element;
}

export const ShowAbove: Component<ShowAboveProps> = (props) => {
  const { isMinWidth } = useResponsive();
  
  return (
    <Show when={isMinWidth(props.breakpoint)} fallback={props.fallback}>
      {props.children}
    </Show>
  );
};

/**
 * Show component only below certain breakpoint
 */
interface ShowBelowProps {
  breakpoint: Breakpoint;
  children: JSX.Element;
  fallback?: JSX.Element;
}

export const ShowBelow: Component<ShowBelowProps> = (props) => {
  const { isMaxWidth } = useResponsive();
  
  return (
    <Show when={isMaxWidth(props.breakpoint)} fallback={props.fallback}>
      {props.children}
    </Show>
  );
};

/**
 * Collapsible sidebar for small screens
 */
interface CollapsibleSidebarProps {
  children: JSX.Element;
  collapsed?: boolean;
  onToggle?: () => void;
  width?: string;
  collapsedWidth?: string;
}

export const CollapsibleSidebar: Component<CollapsibleSidebarProps> = (props) => {
  const width = () => (props.collapsed ? props.collapsedWidth || '64px' : props.width || '280px');

  return (
    <aside
      class="h-full bg-gray-800 border-r border-gray-700 transition-all duration-300 ease-in-out overflow-hidden flex flex-col"
      style={{ width: width(), 'min-width': props.collapsedWidth || '64px' }}
    >
      {props.children}
    </aside>
  );
};

/**
 * Resizable panel component
 */
interface ResizablePanelProps {
  children: JSX.Element;
  defaultWidth?: number;
  minWidth?: number;
  maxWidth?: number;
  resizable?: boolean;
  side?: 'left' | 'right';
}

export const ResizablePanel: Component<ResizablePanelProps> = (props) => {
  const [width, setWidth] = createSignal(props.defaultWidth || 300);
  const [isResizing, setIsResizing] = createSignal(false);

  const minWidth = () => props.minWidth || 200;
  const maxWidth = () => props.maxWidth || 600;
  const side = () => props.side || 'left';

  const handleMouseDown = (e: MouseEvent) => {
    if (!props.resizable) return;
    e.preventDefault();
    setIsResizing(true);

    const startX = e.clientX;
    const startWidth = width();

    const handleMouseMove = (moveEvent: MouseEvent) => {
      const delta = side() === 'left'
        ? moveEvent.clientX - startX
        : startX - moveEvent.clientX;
      
      const newWidth = Math.max(minWidth(), Math.min(maxWidth(), startWidth + delta));
      setWidth(newWidth);
    };

    const handleMouseUp = () => {
      setIsResizing(false);
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };

    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('mouseup', handleMouseUp);
  };

  return (
    <div
      class="relative flex-shrink-0"
      style={{ width: `${width()}px` }}
    >
      {props.children}

      {/* Resize handle */}
      <Show when={props.resizable}>
        <div
          class={`absolute top-0 bottom-0 w-1 cursor-col-resize hover:bg-guardyn-500 transition-colors ${
            side() === 'left' ? 'right-0' : 'left-0'
          } ${isResizing() ? 'bg-guardyn-500' : 'bg-transparent'}`}
          onMouseDown={handleMouseDown}
          role="separator"
          aria-orientation="vertical"
          aria-valuenow={width()}
          aria-valuemin={minWidth()}
          aria-valuemax={maxWidth()}
        />
      </Show>
    </div>
  );
};

/**
 * Adaptive container that changes layout based on screen size
 */
interface AdaptiveContainerProps {
  children: JSX.Element;
  mobileClass?: string;
  tabletClass?: string;
  desktopClass?: string;
  class?: string;
}

export const AdaptiveContainer: Component<AdaptiveContainerProps> = (props) => {
  const { isMobile, isTablet, isDesktop } = useResponsive();

  const containerClass = () => {
    let classes = props.class || '';
    
    if (isMobile() && props.mobileClass) {
      classes += ` ${props.mobileClass}`;
    } else if (isTablet() && props.tabletClass) {
      classes += ` ${props.tabletClass}`;
    } else if (isDesktop() && props.desktopClass) {
      classes += ` ${props.desktopClass}`;
    }
    
    return classes.trim();
  };

  return <div class={containerClass()}>{props.children}</div>;
};

/**
 * Split view component for desktop with stacked view on mobile
 */
interface SplitViewProps {
  left: JSX.Element;
  right: JSX.Element;
  leftWidth?: string;
  showLeftOnMobile?: boolean;
  showRightOnMobile?: boolean;
}

export const SplitView: Component<SplitViewProps> = (props) => {
  const { isMobile } = useResponsive();
  const [activePane, setActivePane] = createSignal<'left' | 'right'>(
    props.showRightOnMobile ? 'right' : 'left'
  );

  return (
    <div class="flex h-full">
      <Show
        when={!isMobile()}
        fallback={
          // Mobile: Show one pane at a time
          <div class="flex-1 flex flex-col">
            <Show when={activePane() === 'left'}>
              {props.left}
            </Show>
            <Show when={activePane() === 'right'}>
              <button
                onClick={() => setActivePane('left')}
                class="p-2 text-gray-400 hover:text-white"
                aria-label="Go back"
              >
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                </svg>
              </button>
              {props.right}
            </Show>
          </div>
        }
      >
        {/* Desktop: Side by side */}
        <div
          class="border-r border-gray-700"
          style={{ width: props.leftWidth || '320px' }}
        >
          {props.left}
        </div>
        <div class="flex-1">{props.right}</div>
      </Show>
    </div>
  );
};

/**
 * Window minimum size constraint component
 */
interface WindowConstraintProps {
  minWidth?: number;
  minHeight?: number;
  children: JSX.Element;
  fallback?: JSX.Element;
}

export const WindowConstraint: Component<WindowConstraintProps> = (props) => {
  const { windowSize } = useResponsive();

  const isTooSmall = () => {
    const size = windowSize();
    return (
      (props.minWidth && size.width < props.minWidth) ||
      (props.minHeight && size.height < props.minHeight)
    );
  };

  const defaultFallback = (
    <div class="flex items-center justify-center h-full p-8 text-center">
      <div>
        <svg
          class="w-12 h-12 mx-auto text-gray-500 mb-4"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4"
          />
        </svg>
        <h3 class="text-lg font-medium text-gray-300">Window too small</h3>
        <p class="text-gray-500 text-sm mt-1">
          Please resize the window to at least {props.minWidth}×{props.minHeight} pixels
        </p>
      </div>
    </div>
  );

  return (
    <Show when={!isTooSmall()} fallback={props.fallback || defaultFallback}>
      {props.children}
    </Show>
  );
};

export default {
  ResponsiveProvider,
  useResponsive,
  ShowAbove,
  ShowBelow,
  CollapsibleSidebar,
  ResizablePanel,
  AdaptiveContainer,
  SplitView,
  WindowConstraint,
};
