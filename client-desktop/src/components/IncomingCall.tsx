/**
 * Incoming Call Dialog Component
 *
 * Shows notification when receiving an incoming call.
 */

import { useNavigate } from '@solidjs/router';
import { listen } from '@tauri-apps/api/event';
import { Component, createEffect, createSignal, onCleanup, Show } from 'solid-js';
import { acceptCall, rejectCall } from '../api/calls';
import type { IncomingCall } from '../types';

// Icons
const PhoneIcon = () => (
  <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
  </svg>
);

const VideoIcon = () => (
  <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
  </svg>
);

const IncomingCallDialog: Component = () => {
  const navigate = useNavigate();
  const [incomingCall, setIncomingCall] = createSignal<IncomingCall | null>(null);
  const [isRinging, setIsRinging] = createSignal(false);

  // Listen for incoming call events
  createEffect(() => {
    const unlistenIncoming = listen<IncomingCall>('call:incoming', (event) => {
      setIncomingCall(event.payload);
      setIsRinging(true);

      // Auto-dismiss after 30 seconds
      setTimeout(() => {
        if (isRinging()) {
          handleDecline();
        }
      }, 30000);
    });

    const unlistenCancelled = listen<{ call_id: string }>('call:cancelled', (event) => {
      if (incomingCall()?.call_id === event.payload.call_id) {
        setIncomingCall(null);
        setIsRinging(false);
      }
    });

    onCleanup(() => {
      unlistenIncoming.then(unlisten => unlisten());
      unlistenCancelled.then(unlisten => unlisten());
    });
  });

  const handleAccept = async () => {
    const call = incomingCall();
    if (!call) return;

    try {
      const result = await acceptCall(call.call_id);
      if (result.success) {
        setIncomingCall(null);
        setIsRinging(false);
        navigate(`/call/${call.call_id}`);
      }
    } catch (e) {
      console.error('Failed to accept call:', e);
    }
  };

  const handleDecline = async () => {
    const call = incomingCall();
    if (!call) return;

    try {
      await rejectCall(call.call_id, 'User declined');
    } catch (e) {
      console.error('Failed to reject call:', e);
    } finally {
      setIncomingCall(null);
      setIsRinging(false);
    }
  };

  return (
    <Show when={incomingCall()}>
      <div class="fixed inset-0 bg-black/80 flex items-center justify-center z-50">
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-8 max-w-sm w-full mx-4 text-center shadow-2xl">
          {/* Avatar placeholder */}
          <div class="w-24 h-24 mx-auto mb-4 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center">
            <Show when={incomingCall()?.caller_avatar} fallback={
              <span class="text-4xl text-white font-bold">
                {incomingCall()?.caller_name?.[0]?.toUpperCase() || '?'}
              </span>
            }>
              <img
                src={incomingCall()?.caller_avatar}
                alt={incomingCall()?.caller_name}
                class="w-full h-full rounded-full object-cover"
              />
            </Show>
          </div>

          {/* Caller info */}
          <h2 class="text-2xl font-semibold text-gray-900 dark:text-white mb-2">
            {incomingCall()?.caller_name || 'Unknown'}
          </h2>
          <p class="text-gray-500 dark:text-gray-400 mb-8">
            Incoming {incomingCall()?.call_type} call...
          </p>

          {/* Action buttons */}
          <div class="flex justify-center gap-8">
            {/* Decline button */}
            <button
              onClick={handleDecline}
              class="w-16 h-16 rounded-full bg-red-600 text-white flex items-center justify-center hover:bg-red-700 transition-all transform hover:scale-110 shadow-lg"
              title="Decline"
            >
              <svg class="w-8 h-8 rotate-[135deg]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
              </svg>
            </button>

            {/* Accept button */}
            <button
              onClick={handleAccept}
              class="w-16 h-16 rounded-full bg-green-600 text-white flex items-center justify-center hover:bg-green-700 transition-all transform hover:scale-110 shadow-lg animate-pulse"
              title="Accept"
            >
              <Show when={incomingCall()?.call_type === 'video'} fallback={<PhoneIcon />}>
                <VideoIcon />
              </Show>
            </button>
          </div>
        </div>
      </div>
    </Show>
  );
};

export default IncomingCallDialog;
