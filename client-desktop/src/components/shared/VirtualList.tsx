import { Accessor, Component, createEffect, createSignal, For, onCleanup, onMount } from 'solid-js';

interface VirtualListProps<T> {
  items: Accessor<T[]>;
  itemHeight: number | ((item: T, index: number) => number);
  containerHeight: number;
  overscan?: number;
  renderItem: (item: T, index: number) => ReturnType<Component>;
  class?: string;
  onScrollToBottom?: () => void;
  scrollThreshold?: number;
}

interface VirtualItem<T> {
  item: T;
  index: number;
  offset: number;
}

/**
 * VirtualList - Virtualized list for rendering large datasets efficiently
 * 
 * Features:
 * - Only renders visible items + overscan
 * - Supports fixed and variable item heights
 * - Scroll to bottom detection
 * - Smooth scrolling
 */
export function VirtualList<T>(props: VirtualListProps<T>): ReturnType<Component> {
  let containerRef: HTMLDivElement | undefined;
  
  const [scrollTop, setScrollTop] = createSignal(0);
  const [containerHeightSignal, setContainerHeight] = createSignal(0);
  
  // Initialize container height from props
  createEffect(() => {
    if (props.containerHeight > 0) {
      setContainerHeight(props.containerHeight);
    }
  });
  
  const overscan = () => props.overscan ?? 3;
  const scrollThreshold = () => props.scrollThreshold ?? 100;
  
  // Calculate item heights
  const getItemHeight = (item: T, index: number): number => {
    if (typeof props.itemHeight === 'function') {
      return props.itemHeight(item, index);
    }
    return props.itemHeight;
  };
  
  // Calculate total height and item positions
  const itemPositions = () => {
    const items = props.items();
    let totalHeight = 0;
    const positions: { offset: number; height: number }[] = [];
    
    for (let i = 0; i < items.length; i++) {
      const height = getItemHeight(items[i], i);
      positions.push({ offset: totalHeight, height });
      totalHeight += height;
    }
    
    return { positions, totalHeight };
  };
  
  // Calculate visible range
  const visibleRange = () => {
    const items = props.items();
    const { positions } = itemPositions();
    const viewTop = scrollTop();
    const viewBottom = viewTop + containerHeightSignal();
    
    let startIndex = 0;
    let endIndex = items.length - 1;
    
    // Binary search for start index
    let low = 0;
    let high = items.length - 1;
    while (low <= high) {
      const mid = Math.floor((low + high) / 2);
      if (positions[mid].offset + positions[mid].height < viewTop) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    startIndex = Math.max(0, low - overscan());
    
    // Find end index
    for (let i = startIndex; i < items.length; i++) {
      if (positions[i].offset > viewBottom) {
        endIndex = Math.min(items.length - 1, i + overscan());
        break;
      }
    }
    
    return { startIndex, endIndex };
  };
  
  // Get visible items with positions
  const visibleItems = (): VirtualItem<T>[] => {
    const items = props.items();
    const { positions } = itemPositions();
    const { startIndex, endIndex } = visibleRange();
    
    const visible: VirtualItem<T>[] = [];
    for (let i = startIndex; i <= endIndex && i < items.length; i++) {
      visible.push({
        item: items[i],
        index: i,
        offset: positions[i].offset,
      });
    }
    
    return visible;
  };
  
  // Handle scroll
  const handleScroll = (e: Event) => {
    const target = e.target as HTMLDivElement;
    setScrollTop(target.scrollTop);
    
    // Check if scrolled to bottom
    const isNearBottom = 
      target.scrollHeight - target.scrollTop - target.clientHeight < scrollThreshold();
    
    if (isNearBottom && props.onScrollToBottom) {
      props.onScrollToBottom();
    }
  };
  
  // Update container height on resize
  onMount(() => {
    if (containerRef) {
      const resizeObserver = new ResizeObserver((entries) => {
        for (const entry of entries) {
          setContainerHeight(entry.contentRect.height);
        }
      });
      resizeObserver.observe(containerRef);
      
      onCleanup(() => resizeObserver.disconnect());
    }
  });
  
  // Scroll to bottom when new items added
  createEffect(() => {
    const items = props.items();
    if (items.length > 0 && containerRef) {
      // Auto-scroll if already near bottom
      const isNearBottom = 
        containerRef.scrollHeight - containerRef.scrollTop - containerRef.clientHeight < 100;
      
      if (isNearBottom) {
        containerRef.scrollTop = containerRef.scrollHeight;
      }
    }
  });
  
  return (
    <div
      ref={containerRef}
      class={`overflow-y-auto ${props.class ?? ''}`}
      style={{ height: `${containerHeightSignal()}px` }}
      onScroll={handleScroll}
    >
      <div 
        style={{ 
          height: `${itemPositions().totalHeight}px`,
          position: 'relative',
        }}
      >
        <For each={visibleItems()}>
          {(virtualItem) => (
            <div
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                transform: `translateY(${virtualItem.offset}px)`,
              }}
            >
              {props.renderItem(virtualItem.item, virtualItem.index)}
            </div>
          )}
        </For>
      </div>
    </div>
  );
}

export default VirtualList;
