/**
 * Calls API Integration Tests
 *
 * Tests for the calls API module with mocked Tauri invoke.
 */

import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { CallInfo } from '../types';
import {
    acceptCall,
    endCall,
    getCallInfo,
    getScreenSources,
    initiateCall,
    rejectCall,
    startScreenShare,
    stopScreenShare,
    toggleMute,
    toggleVideo,
} from './calls';

// Mock Tauri invoke
const mockInvoke = vi.fn();
vi.mock('@tauri-apps/api/core', () => ({
  invoke: (...args: unknown[]) => mockInvoke(...args),
}));

describe('Calls API', () => {
  beforeEach(() => {
    mockInvoke.mockClear();
  });

  const mockCallInfo: CallInfo = {
    call_id: 'call-123',
    call_type: 'video',
    caller_id: 'user-1',
    caller_name: 'Test User',
    state: 'connected',
    duration_seconds: 120,
    participants: [
      {
        user_id: 'user-1',
        display_name: 'User 1',
        is_muted: false,
        has_video: true,
        is_screen_sharing: false,
        is_speaking: true,
      },
      {
        user_id: 'user-2',
        display_name: 'User 2',
        is_muted: true,
        has_video: false,
        is_screen_sharing: false,
        is_speaking: false,
      },
    ],
    is_screen_sharing: false,
  };

  describe('initiateCall', () => {
    it('initiates voice call', async () => {
      mockInvoke.mockResolvedValueOnce({ success: true, call_id: 'call-123' });

      const result = await initiateCall({
        callee_user_id: 'user-456',
        call_type: 'voice',
      });

      expect(mockInvoke).toHaveBeenCalledWith('initiate_call', {
        request: { callee_user_id: 'user-456', call_type: 'voice' },
      });
      expect(result.success).toBe(true);
      expect(result.call_id).toBe('call-123');
    });

    it('initiates video call', async () => {
      mockInvoke.mockResolvedValueOnce({ success: true, call_id: 'call-456' });

      const result = await initiateCall({
        callee_user_id: 'user-789',
        call_type: 'video',
      });

      expect(mockInvoke).toHaveBeenCalledWith('initiate_call', {
        request: { callee_user_id: 'user-789', call_type: 'video' },
      });
      expect(result.call_id).toBe('call-456');
    });

    it('handles call failure', async () => {
      mockInvoke.mockResolvedValueOnce({
        success: false,
        error: 'User is offline',
      });

      const result = await initiateCall({
        callee_user_id: 'user-offline',
        call_type: 'voice',
      });

      expect(result.success).toBe(false);
      expect(result.error).toBe('User is offline');
    });
  });

  describe('acceptCall', () => {
    it('accepts incoming call', async () => {
      mockInvoke.mockResolvedValueOnce({ success: true, call_id: 'call-123' });

      const result = await acceptCall('call-123');

      expect(mockInvoke).toHaveBeenCalledWith('accept_call', {
        callId: 'call-123',
      });
      expect(result.success).toBe(true);
    });

    it('handles acceptance failure', async () => {
      mockInvoke.mockResolvedValueOnce({
        success: false,
        error: 'Call already ended',
      });

      const result = await acceptCall('call-expired');

      expect(result.success).toBe(false);
      expect(result.error).toBe('Call already ended');
    });
  });

  describe('rejectCall', () => {
    it('rejects call without reason', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await rejectCall('call-123');

      expect(mockInvoke).toHaveBeenCalledWith('reject_call', {
        callId: 'call-123',
        reason: undefined,
      });
    });

    it('rejects call with reason', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await rejectCall('call-123', 'User is busy');

      expect(mockInvoke).toHaveBeenCalledWith('reject_call', {
        callId: 'call-123',
        reason: 'User is busy',
      });
    });
  });

  describe('endCall', () => {
    it('ends active call', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await endCall('call-123');

      expect(mockInvoke).toHaveBeenCalledWith('end_call', {
        callId: 'call-123',
      });
    });
  });

  describe('toggleMute', () => {
    it('mutes audio', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await toggleMute('call-123', true);

      expect(mockInvoke).toHaveBeenCalledWith('toggle_mute', {
        callId: 'call-123',
        muted: true,
      });
    });

    it('unmutes audio', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await toggleMute('call-123', false);

      expect(mockInvoke).toHaveBeenCalledWith('toggle_mute', {
        callId: 'call-123',
        muted: false,
      });
    });
  });

  describe('toggleVideo', () => {
    it('enables video', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await toggleVideo('call-123', true);

      expect(mockInvoke).toHaveBeenCalledWith('toggle_video', {
        callId: 'call-123',
        enabled: true,
      });
    });

    it('disables video', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await toggleVideo('call-123', false);

      expect(mockInvoke).toHaveBeenCalledWith('toggle_video', {
        callId: 'call-123',
        enabled: false,
      });
    });
  });

  describe('startScreenShare', () => {
    it('starts screen share with default options', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await startScreenShare('call-123');

      expect(mockInvoke).toHaveBeenCalledWith('start_screen_share', {
        callId: 'call-123',
        options: { audio: false, cursor: true },
      });
    });

    it('starts screen share with custom options', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await startScreenShare('call-123', { audio: true, cursor: false });

      expect(mockInvoke).toHaveBeenCalledWith('start_screen_share', {
        callId: 'call-123',
        options: { audio: true, cursor: false },
      });
    });
  });

  describe('stopScreenShare', () => {
    it('stops screen share', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await stopScreenShare('call-123');

      expect(mockInvoke).toHaveBeenCalledWith('stop_screen_share', {
        callId: 'call-123',
      });
    });
  });

  describe('getScreenSources', () => {
    it('returns available screen sources', async () => {
      mockInvoke.mockResolvedValueOnce([
        { id: 'screen-1', name: 'Primary Display', type: 'screen' },
        { id: 'window-1', name: 'Browser Window', type: 'window' },
      ]);

      const sources = await getScreenSources();

      expect(mockInvoke).toHaveBeenCalledWith('get_screen_sources');
      expect(sources).toHaveLength(2);
      expect(sources[0].name).toBe('Primary Display');
    });

    it('returns empty array when no sources', async () => {
      mockInvoke.mockResolvedValueOnce([]);

      const sources = await getScreenSources();

      expect(sources).toHaveLength(0);
    });
  });

  describe('getCallInfo', () => {
    it('returns call info for active call', async () => {
      mockInvoke.mockResolvedValueOnce(mockCallInfo);

      const info = await getCallInfo('call-123');

      expect(mockInvoke).toHaveBeenCalledWith('get_call_info', {
        callId: 'call-123',
      });
      expect(info?.call_id).toBe('call-123');
      expect(info?.state).toBe('connected');
      expect(info?.participants).toHaveLength(2);
    });

    it('returns null for non-existent call', async () => {
      mockInvoke.mockResolvedValueOnce(null);

      const info = await getCallInfo('call-nonexistent');

      expect(info).toBeNull();
    });

    it('returns call duration', async () => {
      mockInvoke.mockResolvedValueOnce(mockCallInfo);

      const info = await getCallInfo('call-123');

      expect(info?.duration_seconds).toBe(120);
    });
  });
});
