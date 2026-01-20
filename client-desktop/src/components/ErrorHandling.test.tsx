import { fireEvent, render, screen, waitFor } from '@solidjs/testing-library';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import {
    clearAllToasts,
    dismissToast,
    EmptyState,
    ErrorBoundary,
    LoadingSpinner,
    showToast,
    ToastContainer,
} from './ErrorHandling';

describe('ErrorBoundary', () => {
  beforeEach(() => {
    vi.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('renders children when no error', () => {
    render(() => (
      <ErrorBoundary>
        <div>Test content</div>
      </ErrorBoundary>
    ));

    expect(screen.getByText('Test content')).toBeInTheDocument();
  });

  it('renders error display when error occurs', async () => {
    const ThrowError = () => {
      throw new Error('Test error message');
    };

    render(() => (
      <ErrorBoundary>
        <ThrowError />
      </ErrorBoundary>
    ));

    await waitFor(() => {
      expect(screen.getByText('Something went wrong')).toBeInTheDocument();
      expect(screen.getByText('Test error message')).toBeInTheDocument();
    });
  });

  it('shows Try Again button', async () => {
    const ThrowError = () => {
      throw new Error('Test error');
    };

    render(() => (
      <ErrorBoundary>
        <ThrowError />
      </ErrorBoundary>
    ));

    await waitFor(() => {
      expect(screen.getByRole('button', { name: /try again/i })).toBeInTheDocument();
    });
  });

  it('uses custom fallback when provided', async () => {
    const ThrowError = () => {
      throw new Error('Test error');
    };

    const customFallback = (error: Error, reset: () => void) => (
      <div>
        <span>Custom error: {error.message}</span>
        <button onClick={reset}>Custom reset</button>
      </div>
    );

    render(() => (
      <ErrorBoundary fallback={customFallback}>
        <ThrowError />
      </ErrorBoundary>
    ));

    await waitFor(() => {
      expect(screen.getByText('Custom error: Test error')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: /custom reset/i })).toBeInTheDocument();
    });
  });
});

describe('ToastContainer', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    clearAllToasts(); // Reset toast state between tests
  });

  afterEach(() => {
    clearAllToasts(); // Cleanup after each test
    vi.useRealTimers();
  });

  it('renders empty container when no toasts', () => {
    const { container } = render(() => <ToastContainer />);

    // Container should exist but be empty or have no toasts
    expect(container.querySelector('.fixed')).toBeInTheDocument();
  });

  it('displays success toast', async () => {
    render(() => <ToastContainer />);

    showToast('success', 'Operation successful');

    await waitFor(() => {
      expect(screen.getByText('Operation successful')).toBeInTheDocument();
    });
  });

  it('displays error toast', async () => {
    render(() => <ToastContainer />);

    showToast('error', 'Something went wrong');

    await waitFor(() => {
      expect(screen.getByText('Something went wrong')).toBeInTheDocument();
    });
  });

  it('displays warning toast', async () => {
    render(() => <ToastContainer />);

    showToast('warning', 'Please be careful');

    await waitFor(() => {
      expect(screen.getByText('Please be careful')).toBeInTheDocument();
    });
  });

  it('displays info toast', async () => {
    render(() => <ToastContainer />);

    showToast('info', 'Here is some information');

    await waitFor(() => {
      expect(screen.getByText('Here is some information')).toBeInTheDocument();
    });
  });

  it('auto-dismisses toast after duration', async () => {
    render(() => <ToastContainer />);

    showToast('success', 'Auto dismiss test', 3000);

    await waitFor(() => {
      expect(screen.getByText('Auto dismiss test')).toBeInTheDocument();
    });

    // Advance time past the duration
    vi.advanceTimersByTime(3500);

    await waitFor(() => {
      expect(screen.queryByText('Auto dismiss test')).not.toBeInTheDocument();
    });
  });

  it('manually dismisses toast', async () => {
    render(() => <ToastContainer />);

    const toastId = showToast('info', 'Manual dismiss test', 0); // 0 = no auto-dismiss

    await waitFor(() => {
      expect(screen.getByText('Manual dismiss test')).toBeInTheDocument();
    });

    dismissToast(toastId);

    await waitFor(() => {
      expect(screen.queryByText('Manual dismiss test')).not.toBeInTheDocument();
    });
  });

  it('dismisses toast when close button clicked', async () => {
    vi.useRealTimers(); // Use real timers for this test to avoid timing issues

    render(() => <ToastContainer />);

    showToast('info', 'Clickable dismiss', 0);

    // Wait for toast to appear
    await waitFor(() => {
      expect(screen.getByText('Clickable dismiss')).toBeInTheDocument();
    });

    // Find and click the close button (the button inside the toast)
    const closeButton = screen.getByRole('button');
    fireEvent.click(closeButton);

    // Wait for toast to be removed
    await waitFor(
      () => {
        expect(screen.queryByText('Clickable dismiss')).not.toBeInTheDocument();
      },
      { timeout: 1000 }
    );
  });

  it('shows multiple toasts', async () => {
    render(() => <ToastContainer />);

    showToast('success', 'First toast', 0);
    showToast('error', 'Second toast', 0);
    showToast('info', 'Third toast', 0);

    await waitFor(() => {
      expect(screen.getByText('First toast')).toBeInTheDocument();
      expect(screen.getByText('Second toast')).toBeInTheDocument();
      expect(screen.getByText('Third toast')).toBeInTheDocument();
    });
  });
});

describe('LoadingSpinner', () => {
  it('renders with default size', () => {
    const { container } = render(() => <LoadingSpinner />);

    const svg = container.querySelector('svg');
    expect(svg).toBeInTheDocument();
    expect(svg).toHaveClass('animate-spin');
    expect(svg).toHaveClass('w-8');
    expect(svg).toHaveClass('h-8');
  });

  it('renders with small size', () => {
    const { container } = render(() => <LoadingSpinner size="sm" />);

    const svg = container.querySelector('svg');
    expect(svg).toHaveClass('w-4');
    expect(svg).toHaveClass('h-4');
  });

  it('renders with large size', () => {
    const { container } = render(() => <LoadingSpinner size="lg" />);

    const svg = container.querySelector('svg');
    expect(svg).toHaveClass('w-12');
    expect(svg).toHaveClass('h-12');
  });

  it('applies custom class', () => {
    const { container } = render(() => <LoadingSpinner class="text-blue-500" />);

    const svg = container.querySelector('svg');
    expect(svg).toHaveClass('text-blue-500');
  });
});

describe('EmptyState', () => {
  it('renders title', () => {
    render(() => <EmptyState title="No items found" />);

    expect(screen.getByText('No items found')).toBeInTheDocument();
  });

  it('renders description when provided', () => {
    render(() => (
      <EmptyState
        title="No messages"
        description="Start a conversation to see messages here"
      />
    ));

    expect(screen.getByText('No messages')).toBeInTheDocument();
    expect(screen.getByText('Start a conversation to see messages here')).toBeInTheDocument();
  });

  it('renders action button when provided', () => {
    const mockOnClick = vi.fn();

    render(() => (
      <EmptyState
        title="No items"
        action={{ label: 'Add Item', onClick: mockOnClick }}
      />
    ));

    expect(screen.getByRole('button', { name: /add item/i })).toBeInTheDocument();
  });

  it('calls action onClick when button clicked', async () => {
    const mockOnClick = vi.fn();

    render(() => (
      <EmptyState
        title="No items"
        action={{ label: 'Add Item', onClick: mockOnClick }}
      />
    ));

    const button = screen.getByRole('button', { name: /add item/i });
    await fireEvent.click(button);

    expect(mockOnClick).toHaveBeenCalledTimes(1);
  });

  it('renders custom icon when provided', () => {
    render(() => (
      <EmptyState
        title="No items"
        icon={<span data-testid="custom-icon">📦</span>}
      />
    ));

    expect(screen.getByTestId('custom-icon')).toBeInTheDocument();
  });

  it('does not render description when not provided', () => {
    const { container } = render(() => <EmptyState title="No items" />);

    const description = container.querySelector('.text-gray-400.text-sm');
    expect(description).not.toBeInTheDocument();
  });

  it('does not render action when not provided', () => {
    render(() => <EmptyState title="No items" />);

    expect(screen.queryByRole('button')).not.toBeInTheDocument();
  });
});
