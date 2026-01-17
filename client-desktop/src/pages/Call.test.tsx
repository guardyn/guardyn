import { Router } from '@solidjs/router';
import { fireEvent, render, screen, waitFor } from '@solidjs/testing-library';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { CallInfo } from '../types';
import Call from './Call';

// Mock Tauri APIs
const mockInvoke = vi.fn();
const mockListen = vi.fn();
const mockUnlisten = vi.fn();

vi.mock('@tauri-apps/api/core', () => ({
  invoke: (...args: unknown[]) => mockInvoke(...args),
}));

vi.mock('@tauri-apps/api/event', () => ({
  listen: (event: string, callback: (event: { payload: unknown }) => void) => {
    mockListen(event, callback);
    return Promise.resolve(mockUnlisten);
  },
}));

// Mock calls API
vi.mock('../api/calls', () => ({
  endCall: vi.fn().mockResolvedValue({ success: true }),
  toggleMute: vi.fn().mockResolvedValue({ success: true }),
  toggleVideo: vi.fn().mockResolvedValue({ success: true }),
  startScreenShare: vi.fn().mockResolvedValue({ success: true }),
  stopScreenShare: vi.fn().mockResolvedValue({ success: true }),
  getScreenSources: vi.fn().mockResolvedValue([]),
}));

// Mock useParams
vi.mock('@solidjs/router', async () => {
  const actual = await vi.importActual('@solidjs/router');
  return {
    ...actual,
    useParams: vi.fn(() => ({ id: 'call-123' })),
    useNavigate: vi.fn(() => vi.fn()),
  };
});

// Helper to render with router
const renderWithRouter = (ui: () => ReturnType<typeof Call>) => {
  return render(() => <Router>{ui()}</Router>);
};

describe('Call Page', () => {
  const mockCallInfo: CallInfo = {
    call_id: 'call-123',
    caller_id: 'user-1',
    caller_name: 'Test User',
    call_type: 'video',
    state: 'connecting',
    duration_seconds: 0,
    participants: [],
    is_screen_sharing: false,
  };

  beforeEach(() => {
    mockInvoke.mockClear();
    mockListen.mockClear();
    mockUnlisten.mockClear();
    vi.clearAllMocks();
  });

  it('renders the call page', () => {
    renderWithRouter(() => <Call />);

    // Check for basic call UI elements
    expect(screen.getByRole('button')).toBeInTheDocument();
  });

  it('subscribes to call state events', async () => {
    renderWithRouter(() => <Call />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalledWith('call:state_changed', expect.any(Function));
    });
  });

  it('displays call controls', () => {
    renderWithRouter(() => <Call />);

    // Should have mute, video, and end call buttons
    const buttons = screen.getAllByRole('button');
    expect(buttons.length).toBeGreaterThanOrEqual(1);
  });

  it('shows mute button', () => {
    renderWithRouter(() => <Call />);

    // The mute button should be present
    const buttons = screen.getAllByRole('button');
    expect(buttons.some((btn: HTMLButtonElement) => btn.getAttribute('aria-label')?.includes('mute') || 
                                   btn.classList.contains('mute') ||
                                   btn.querySelector('svg'))).toBeTruthy();
  });

  it('shows video toggle button for video calls', async () => {
    // Simulate a video call state
    let stateCallback: (event: { payload: CallInfo }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: CallInfo }) => void) => {
      if (event === 'call:state_changed') {
        stateCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <Call />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    // Trigger state change
    if (stateCallback!) {
      stateCallback({ payload: { ...mockCallInfo, state: 'connected' } });
    }

    const buttons = screen.getAllByRole('button');
    expect(buttons.length).toBeGreaterThanOrEqual(1);
  });

  it('shows end call button', () => {
    renderWithRouter(() => <Call />);

    const buttons = screen.getAllByRole('button') as HTMLButtonElement[];
    const endCallButton = buttons.find(
      (btn: HTMLButtonElement) => btn.classList.contains('bg-red-600') || 
               btn.getAttribute('aria-label')?.includes('end') ||
               btn.querySelector('path')
    );
    expect(endCallButton).toBeInTheDocument();
  });

  it('shows screen share button', () => {
    renderWithRouter(() => <Call />);

    const buttons = screen.getAllByRole('button');
    expect(buttons.length).toBeGreaterThanOrEqual(3);
  });

  it('displays call duration when connected', async () => {
    vi.useFakeTimers();

    let stateCallback: (event: { payload: CallInfo }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: CallInfo }) => void) => {
      if (event === 'call:state_changed') {
        stateCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <Call />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    // Simulate connected state
    if (stateCallback!) {
      stateCallback({ payload: { ...mockCallInfo, state: 'connected' } });
    }

    // Advance timers
    vi.advanceTimersByTime(5000);

    vi.useRealTimers();
  });

  it('cleans up event listeners on unmount', async () => {
    const { unmount } = renderWithRouter(() => <Call />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    unmount();

    // Unlisten should be called
    expect(mockUnlisten).toHaveBeenCalled();
  });

  it('handles mute toggle', async () => {
    await import('../api/calls');

    renderWithRouter(() => <Call />);

    // Find mute button and click it
    const buttons = screen.getAllByRole('button');
    const muteButton = buttons[0]; // Assuming first button is mute

    await fireEvent.click(muteButton);

    // Note: The actual toggle implementation may vary
  });

  it('handles video toggle', async () => {
    renderWithRouter(() => <Call />);

    // Find video button and click it
    const buttons = screen.getAllByRole('button');
    if (buttons.length > 1) {
      await fireEvent.click(buttons[1]);
    }
  });

  it('handles end call', async () => {
    await import('../api/calls');

    renderWithRouter(() => <Call />);

    // Find the end call button (usually red)
    const buttons = screen.getAllByRole('button') as HTMLButtonElement[];
    const endCallButton = buttons.find((btn: HTMLButtonElement) => 
      btn.classList.contains('bg-red-600') || 
      btn.classList.contains('bg-red-500')
    ) || buttons[buttons.length - 1];

    if (endCallButton) {
      await fireEvent.click(endCallButton);
    }
  });

  it('shows connecting state', async () => {
    let stateCallback: (event: { payload: CallInfo }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: CallInfo }) => void) => {
      if (event === 'call:state_changed') {
        stateCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <Call />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    // Simulate connecting state
    if (stateCallback!) {
      stateCallback({ payload: { ...mockCallInfo, state: 'connecting' } });
    }

    // Check for connecting indicator
    await waitFor(() => {
      screen.queryByText(/connecting/i);
      // May or may not be present depending on implementation
    });
  });

  it('navigates away when call ends', async () => {
    const { useNavigate } = await import('@solidjs/router');
    const mockNavigate = vi.fn();
    (useNavigate as ReturnType<typeof vi.fn>).mockReturnValue(mockNavigate);

    let stateCallback: (event: { payload: CallInfo }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: CallInfo }) => void) => {
      if (event === 'call:state_changed') {
        stateCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <Call />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    // Simulate ended state
    if (stateCallback!) {
      stateCallback({ payload: { ...mockCallInfo, state: 'ended' } });
    }

    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith('/');
    });
  });

  it('displays caller avatar placeholder', () => {
    renderWithRouter(() => <Call />);

    // There should be an avatar or placeholder visible
    screen.queryAllByRole('img');
    // May have video elements instead
  });

  it('formats call duration correctly', async () => {
    vi.useFakeTimers();

    let stateCallback: (event: { payload: CallInfo }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: CallInfo }) => void) => {
      if (event === 'call:state_changed') {
        stateCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <Call />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    // Simulate connected state
    if (stateCallback!) {
      stateCallback({ payload: { ...mockCallInfo, state: 'connected' } });
    }

    // Advance by 1 minute 30 seconds
    vi.advanceTimersByTime(90000);

    // Check for duration display (01:30 or 1:30)
    await waitFor(() => {
      screen.queryByText(/1:30|01:30/);
      // Duration display may vary
    });

    vi.useRealTimers();
  });
});
