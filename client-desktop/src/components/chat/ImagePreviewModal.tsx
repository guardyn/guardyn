import { Component, createSignal, Show } from 'solid-js';

interface ImagePreviewModalProps {
  isOpen: boolean;
  imageUrl: string;
  imageName?: string;
  onClose: () => void;
  onDownload?: () => void;
  onShare?: () => void;
}

/**
 * ImagePreviewModal - Full-screen image preview with zoom and actions
 * 
 * Features:
 * - Full-screen display
 * - Click-and-drag pan (when zoomed)
 * - Zoom controls (+/- buttons and scroll wheel)
 * - Download and share buttons
 * - Keyboard navigation (Escape to close, +/- to zoom)
 */
export const ImagePreviewModal: Component<ImagePreviewModalProps> = (props) => {
  const [scale, setScale] = createSignal(1);
  const [position, setPosition] = createSignal({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = createSignal(false);
  const [dragStart, setDragStart] = createSignal({ x: 0, y: 0 });
  
  const MIN_SCALE = 0.5;
  const MAX_SCALE = 4;
  
  // Zoom in
  const zoomIn = () => {
    setScale(prev => Math.min(prev + 0.25, MAX_SCALE));
  };
  
  // Zoom out
  const zoomOut = () => {
    setScale(prev => Math.max(prev - 0.25, MIN_SCALE));
    // Reset position when zooming out to 1x
    if (scale() <= 1.25) {
      setPosition({ x: 0, y: 0 });
    }
  };
  
  // Reset zoom
  const resetZoom = () => {
    setScale(1);
    setPosition({ x: 0, y: 0 });
  };
  
  // Handle wheel zoom
  const handleWheel = (e: WheelEvent) => {
    e.preventDefault();
    if (e.deltaY < 0) {
      zoomIn();
    } else {
      zoomOut();
    }
  };
  
  // Handle mouse down for drag
  const handleMouseDown = (e: MouseEvent) => {
    if (scale() > 1) {
      setIsDragging(true);
      setDragStart({ x: e.clientX - position().x, y: e.clientY - position().y });
    }
  };
  
  // Handle mouse move for drag
  const handleMouseMove = (e: MouseEvent) => {
    if (isDragging() && scale() > 1) {
      setPosition({
        x: e.clientX - dragStart().x,
        y: e.clientY - dragStart().y,
      });
    }
  };
  
  // Handle mouse up
  const handleMouseUp = () => {
    setIsDragging(false);
  };
  
  // Handle keyboard
  const handleKeyDown = (e: KeyboardEvent) => {
    switch (e.key) {
      case 'Escape':
        props.onClose();
        break;
      case '+':
      case '=':
        zoomIn();
        break;
      case '-':
        zoomOut();
        break;
      case '0':
        resetZoom();
        break;
    }
  };
  
  // Handle download
  const handleDownload = () => {
    if (props.onDownload) {
      props.onDownload();
    } else {
      // Default download behavior
      const link = document.createElement('a');
      link.href = props.imageUrl;
      link.download = props.imageName || 'image';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
  };
  
  // Handle backdrop click
  const handleBackdropClick = (e: MouseEvent) => {
    if (e.target === e.currentTarget) {
      props.onClose();
    }
  };
  
  return (
    <Show when={props.isOpen}>
      <div
        class="fixed inset-0 z-50 bg-black/90 flex items-center justify-center"
        onClick={handleBackdropClick}
        onKeyDown={handleKeyDown}
        onWheel={handleWheel}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseUp}
        tabIndex={0}
        ref={(el) => el?.focus()}
      >
        {/* Top bar */}
        <div class="absolute top-0 left-0 right-0 h-16 bg-gradient-to-b from-black/50 to-transparent flex items-center justify-between px-4 z-10">
          {/* File name */}
          <div class="flex items-center gap-3">
            <span class="text-white font-medium truncate max-w-md">
              {props.imageName || 'Image Preview'}
            </span>
            <span class="text-white/60 text-sm">
              {Math.round(scale() * 100)}%
            </span>
          </div>
          
          {/* Close button */}
          <button
            onClick={() => props.onClose()}
            class="p-2 rounded-lg bg-white/10 hover:bg-white/20 transition-colors"
            aria-label="Close"
          >
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        
        {/* Image container */}
        <div
          class={`select-none ${scale() > 1 ? 'cursor-grab' : 'cursor-default'} ${isDragging() ? 'cursor-grabbing' : ''}`}
          onMouseDown={handleMouseDown}
        >
          <img
            src={props.imageUrl}
            alt={props.imageName || 'Preview'}
            class="max-h-[85vh] max-w-[90vw] object-contain transition-transform duration-200"
            style={{
              transform: `scale(${scale()}) translate(${position().x / scale()}px, ${position().y / scale()}px)`,
            }}
            draggable={false}
          />
        </div>
        
        {/* Bottom bar */}
        <div class="absolute bottom-0 left-0 right-0 h-20 bg-gradient-to-t from-black/50 to-transparent flex items-center justify-center gap-4 z-10">
          {/* Zoom controls */}
          <div class="flex items-center gap-2 bg-white/10 rounded-lg p-1">
            <button
              onClick={zoomOut}
              disabled={scale() <= MIN_SCALE}
              class="p-2 rounded hover:bg-white/10 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              aria-label="Zoom out"
            >
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4" />
              </svg>
            </button>
            
            <button
              onClick={resetZoom}
              class="px-3 py-1 text-white text-sm hover:bg-white/10 rounded transition-colors"
            >
              {Math.round(scale() * 100)}%
            </button>
            
            <button
              onClick={zoomIn}
              disabled={scale() >= MAX_SCALE}
              class="p-2 rounded hover:bg-white/10 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              aria-label="Zoom in"
            >
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
              </svg>
            </button>
          </div>
          
          <div class="h-8 w-px bg-white/20" />
          
          {/* Action buttons */}
          <div class="flex items-center gap-2">
            <button
              onClick={handleDownload}
              class="p-2 rounded-lg bg-white/10 hover:bg-white/20 transition-colors"
              aria-label="Download"
            >
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
              </svg>
            </button>
            
            <Show when={props.onShare}>
              <button
                onClick={() => props.onShare?.()}
                class="p-2 rounded-lg bg-white/10 hover:bg-white/20 transition-colors"
                aria-label="Share"
              >
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
                </svg>
              </button>
            </Show>
          </div>
        </div>
        
        {/* Keyboard hints */}
        <div class="absolute bottom-24 left-1/2 -translate-x-1/2 text-white/40 text-xs flex gap-4">
          <span>ESC to close</span>
          <span>+/- to zoom</span>
          <span>Scroll to zoom</span>
          <span>Drag to pan</span>
        </div>
      </div>
    </Show>
  );
};

export default ImagePreviewModal;
