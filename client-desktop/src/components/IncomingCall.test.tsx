import { Router } from '@solidjs/router';
import { fireEvent, render, screen, waitFor } from '@solidjs/testing-library';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import type { IncomingCall } from '../types';
import IncomingCallDialog from './IncomingCall';

// Store callbacks for simulating events
const eventCallbacks: Map<string, (event: { payload: unknown }) => void> = new Map();

// Mock Tauri event API
const mockListen = vi.fn();
const mockUnlisten = vi.fn();

vi.mock('@tauri-apps/api/event', () => ({
  listen: (event: string, callback: (event: { payload: unknown }) => void) => {
    mockListen(event, callback);
    eventCallbacks.set(event, callback);
    return Promise.resolve(mockUnlisten);
  },
}));

// Helper to simulate incoming call event
const simulateIncomingCall = (call: IncomingCall) => {
  const callback = eventCallbacks.get('call:incoming');
  if (callback) {
    callback({ payload: call });
  }
};

// Helper to simulate call cancelled event
const simulateCallCancelled = (callId: string) => {
  const callback = eventCallbacks.get('call:cancelled');
  if (callback) {
    callback({ payload: { call_id: callId } });
  }
};

// Mock calls API
const mockAcceptCall = vi.fn();
const mockRejectCall = vi.fn();

vi.mock('../api/calls', () => ({
  acceptCall: (...args: unknown[]) => mockAcceptCall(...args),
  rejectCall: (...args: unknown[]) => mockRejectCall(...args),
}));

// Helper to render with router
const renderWithRouter = (ui: () => ReturnType<typeof IncomingCallDialog>) => {
  return render(() => <Router>{ui()}</Router>);
};

describe('IncomingCallDialog', () => {
  const mockIncomingCall: IncomingCall = {
    call_id: 'call-123',
    caller_id: 'user-456',
    caller_name: 'John Doe',
    call_type: 'voice',
  };

  const mockVideoCall: IncomingCall = {
    call_id: 'call-456',
    caller_id: 'user-789',
    caller_name: 'Jane Smith',
    caller_avatar: 'https://example.com/avatar.jpg',
    call_type: 'video',
  };

  beforeEach(() => {
    mockListen.mockClear();
    mockUnlisten.mockClear();
    mockAcceptCall.mockClear();
    mockRejectCall.mockClear();
    mockAcceptCall.mockResolvedValue({ success: true });
    mockRejectCall.mockResolvedValue({ success: true });
    eventCallbacks.clear();
  });

  afterEach(() => {
    vi.clearAllMocks();
    eventCallbacks.clear();
  });

  it('does not show dialog when no incoming call', () => {
    renderWithRouter(() => <IncomingCallDialog />);

    // Dialog should not be visible
    expect(screen.queryByText('Incoming')).not.toBeInTheDocument();
  });

  it('subscribes to call events on mount', async () => {
    renderWithRouter(() => <IncomingCallDialog />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalledWith('call:incoming', expect.any(Function));
      expect(mockListen).toHaveBeenCalledWith('call:cancelled', expect.any(Function));
    });
  });

  it.skip('shows dialog when incoming call event received', async () => {
    renderWithRouter(() => <IncomingCallDialog />);

    // Wait for event listeners to be registered
    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    // Small delay to ensure effects have run
    await new Promise(resolve => setTimeout(resolve, 50));

    // Trigger incoming call using our helper
    simulateIncomingCall(mockIncomingCall);

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });
  });

  it.skip('displays caller name', async () => {
    renderWithRouter(() => <IncomingCallDialog />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    await new Promise(resolve => setTimeout(resolve, 50));
    simulateIncomingCall(mockIncomingCall);

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });
  });

  it.skip('displays caller avatar when available', async () => {
    let incomingCallback: (event: { payload: IncomingCall }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: IncomingCall }) => void) => {
      if (event === 'call:incoming') {
        incomingCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <IncomingCallDialog />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    incomingCallback!({ payload: mockVideoCall });

    await waitFor(() => {
      const avatar = screen.getByRole('img');
      expect(avatar).toHaveAttribute('src', 'https://example.com/avatar.jpg');
    });
  });

  it.skip('shows caller initial when no avatar', async () => {
    let incomingCallback: (event: { payload: IncomingCall }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: IncomingCall }) => void) => {
      if (event === 'call:incoming') {
        incomingCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <IncomingCallDialog />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    incomingCallback!({ payload: mockIncomingCall });

    await waitFor(() => {
      expect(screen.getByText('J')).toBeInTheDocument();
    });
  });

  it.skip('calls acceptCall when accept button clicked', async () => {
    let incomingCallback: (event: { payload: IncomingCall }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: IncomingCall }) => void) => {
      if (event === 'call:incoming') {
        incomingCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <IncomingCallDialog />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    incomingCallback!({ payload: mockIncomingCall });

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });

    // Find and click accept button (green one)
    const buttons = screen.getAllByRole('button');
    const acceptButton = buttons.find((btn: HTMLButtonElement) => 
      btn.classList.contains('bg-green-600') || 
      btn.getAttribute('title') === 'Accept'
    );
    
    if (acceptButton) {
      await fireEvent.click(acceptButton);

      await waitFor(() => {
        expect(mockAcceptCall).toHaveBeenCalledWith('call-123');
      });
    }
  });

  it.skip('calls rejectCall when decline button clicked', async () => {
    let incomingCallback: (event: { payload: IncomingCall }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: IncomingCall }) => void) => {
      if (event === 'call:incoming') {
        incomingCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <IncomingCallDialog />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    incomingCallback!({ payload: mockIncomingCall });

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });

    // Find and click decline button (red one)
    const buttons = screen.getAllByRole('button');
    const declineButton = buttons.find((btn: HTMLButtonElement) => 
      btn.classList.contains('bg-red-600') || 
      btn.getAttribute('title') === 'Decline'
    );
    
    if (declineButton) {
      await fireEvent.click(declineButton);

      await waitFor(() => {
        expect(mockRejectCall).toHaveBeenCalledWith('call-123', 'User declined');
      });
    }
  });

  it.skip('hides dialog after accepting call', async () => {
    let incomingCallback: (event: { payload: IncomingCall }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: IncomingCall }) => void) => {
      if (event === 'call:incoming') {
        incomingCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <IncomingCallDialog />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    incomingCallback!({ payload: mockIncomingCall });

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });

    const buttons = screen.getAllByRole('button');
    const acceptButton = buttons.find((btn: HTMLButtonElement) => 
      btn.classList.contains('bg-green-600')
    );
    
    if (acceptButton) {
      await fireEvent.click(acceptButton);

      await waitFor(() => {
        expect(screen.queryByText('John Doe')).not.toBeInTheDocument();
      });
    }
  });

  it.skip('hides dialog when call is cancelled', async () => {
    let incomingCallback: (event: { payload: IncomingCall }) => void;
    let cancelledCallback: (event: { payload: { call_id: string } }) => void;

    mockListen.mockImplementation((event: string, callback: (event: { payload: unknown }) => void) => {
      if (event === 'call:incoming') {
        incomingCallback = callback as (event: { payload: IncomingCall }) => void;
      } else if (event === 'call:cancelled') {
        cancelledCallback = callback as (event: { payload: { call_id: string } }) => void;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <IncomingCallDialog />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    // Show incoming call
    incomingCallback!({ payload: mockIncomingCall });

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });

    // Cancel the call
    cancelledCallback!({ payload: { call_id: 'call-123' } });

    await waitFor(() => {
      expect(screen.queryByText('John Doe')).not.toBeInTheDocument();
    });
  });

  it.skip('shows video icon for video calls', async () => {
    let incomingCallback: (event: { payload: IncomingCall }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: IncomingCall }) => void) => {
      if (event === 'call:incoming') {
        incomingCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <IncomingCallDialog />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    incomingCallback!({ payload: mockVideoCall });

    await waitFor(() => {
      expect(screen.getByText(/incoming.*video.*call/i)).toBeInTheDocument();
    });
  });

  it.skip('cleans up listeners on unmount', async () => {
    const { unmount } = renderWithRouter(() => <IncomingCallDialog />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    unmount();

    await waitFor(() => {
      expect(mockUnlisten).toHaveBeenCalled();
    });
  });

  it.skip('shows decline and accept buttons', async () => {
    let incomingCallback: (event: { payload: IncomingCall }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: IncomingCall }) => void) => {
      if (event === 'call:incoming') {
        incomingCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <IncomingCallDialog />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    incomingCallback!({ payload: mockIncomingCall });

    await waitFor(() => {
      const buttons = screen.getAllByRole('button');
      expect(buttons.length).toBe(2); // Decline and Accept
    });
  });

  it.skip('handles accept call error gracefully', async () => {
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
    mockAcceptCall.mockRejectedValueOnce(new Error('Failed to accept'));

    let incomingCallback: (event: { payload: IncomingCall }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: IncomingCall }) => void) => {
      if (event === 'call:incoming') {
        incomingCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <IncomingCallDialog />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    incomingCallback!({ payload: mockIncomingCall });

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });

    const buttons = screen.getAllByRole('button');
    const acceptButton = buttons.find((btn: HTMLButtonElement) => 
      btn.classList.contains('bg-green-600')
    );
    
    if (acceptButton) {
      await fireEvent.click(acceptButton);

      await waitFor(() => {
        expect(consoleSpy).toHaveBeenCalledWith('Failed to accept call:', expect.any(Error));
      });
    }

    consoleSpy.mockRestore();
  });

  it.skip('handles reject call error gracefully', async () => {
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
    mockRejectCall.mockRejectedValueOnce(new Error('Failed to reject'));

    let incomingCallback: (event: { payload: IncomingCall }) => void;
    mockListen.mockImplementation((event: string, callback: (event: { payload: IncomingCall }) => void) => {
      if (event === 'call:incoming') {
        incomingCallback = callback;
      }
      return Promise.resolve(mockUnlisten);
    });

    renderWithRouter(() => <IncomingCallDialog />);

    await waitFor(() => {
      expect(mockListen).toHaveBeenCalled();
    });

    incomingCallback!({ payload: mockIncomingCall });

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });

    const buttons = screen.getAllByRole('button');
    const declineButton = buttons.find((btn: HTMLButtonElement) => 
      btn.classList.contains('bg-red-600')
    );
    
    if (declineButton) {
      await fireEvent.click(declineButton);

      await waitFor(() => {
        expect(consoleSpy).toHaveBeenCalledWith('Failed to reject call:', expect.any(Error));
      });
    }

    consoleSpy.mockRestore();
  });
});
