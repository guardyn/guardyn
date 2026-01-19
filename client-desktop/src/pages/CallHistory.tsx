/**
 * Call History Page
 *
 * Shows list of recent calls with ability to call back.
 */

import { useNavigate } from '@solidjs/router';
import { Component, createEffect, createSignal, For, Show } from 'solid-js';
import { getCallHistory, initiateCall } from '../api/calls';
import type { CallHistoryEntry } from '../types';

// Icons
const PhoneOutgoingIcon = () => (
  <svg class="w-5 h-5 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 7l-5-5m0 0l-5 5m5-5v12" transform="translate(10, 0) rotate(45, 12, 12)" />
  </svg>
);

const PhoneIncomingIcon = () => (
  <svg class="w-5 h-5 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
  </svg>
);

const PhoneMissedIcon = () => (
  <svg class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6" />
  </svg>
);

const VideoIcon = () => (
  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
  </svg>
);

const CallIcon = () => (
  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
  </svg>
);

const CallHistory: Component = () => {
  const navigate = useNavigate();
  const [calls, setCalls] = createSignal<CallHistoryEntry[]>([]);
  const [loading, setLoading] = createSignal(true);
  const [error, setError] = createSignal<string | null>(null);

  createEffect(() => {
    loadCallHistory();
  });

  const loadCallHistory = async () => {
    try {
      setLoading(true);
      const history = await getCallHistory(100);
      setCalls(history);
    } catch (e) {
      setError(`Failed to load call history: ${e}`);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (timestamp: number): string => {
    const date = new Date(timestamp * 1000);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));

    if (days === 0) {
      return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    } else if (days === 1) {
      return 'Yesterday';
    } else if (days < 7) {
      return date.toLocaleDateString([], { weekday: 'long' });
    } else {
      return date.toLocaleDateString([], { month: 'short', day: 'numeric' });
    }
  };

  const formatDuration = (seconds: number): string => {
    if (seconds === 0) return '';
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    if (mins === 0) return `${secs}s`;
    return `${mins}m ${secs}s`;
  };

  const getCallIcon = (call: CallHistoryEntry) => {
    if (call.end_reason === 'missed' || call.end_reason === 'declined') {
      return <PhoneMissedIcon />;
    }
    return call.is_outgoing ? <PhoneOutgoingIcon /> : <PhoneIncomingIcon />;
  };

  const handleCallBack = async (call: CallHistoryEntry) => {
    try {
      const result = await initiateCall({
        callee_user_id: call.other_user_id,
        call_type: call.call_type,
      });
      if (result.success && result.call_id) {
        navigate(`/call/${result.call_id}`);
      }
    } catch (e) {
      setError(`Failed to initiate call: ${e}`);
    }
  };

  return (
    <div class="h-full flex flex-col bg-gray-100 dark:bg-gray-900 transition-colors duration-200">
      {/* Header */}
      <div class="p-4 border-b border-gray-200 dark:border-gray-700">
        <h1 class="text-xl font-semibold text-gray-900 dark:text-white">Call History</h1>
      </div>

      {/* Content */}
      <div class="flex-1 overflow-y-auto">
        <Show when={loading()}>
          <div class="flex items-center justify-center h-32">
            <div class="text-gray-500 dark:text-gray-400">Loading...</div>
          </div>
        </Show>

        <Show when={error()}>
          <div class="p-4 text-red-400">{error()}</div>
        </Show>

        <Show when={!loading() && !error()}>
          <Show
            when={calls().length > 0}
            fallback={
              <div class="flex flex-col items-center justify-center h-64 text-gray-500 dark:text-gray-400">
                <CallIcon />
                <p class="mt-2">No call history</p>
              </div>
            }
          >
            <div class="divide-y divide-gray-200 dark:divide-gray-800">
              <For each={calls()}>
                {(call) => (
                  <div class="p-4 hover:bg-gray-200 dark:hover:bg-gray-800 transition-colors flex items-center gap-4">
                    {/* Call type icon */}
                    <div class="flex-shrink-0">
                      {getCallIcon(call)}
                    </div>

                    {/* Call info */}
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center gap-2">
                        <span class="text-gray-900 dark:text-white font-medium truncate">
                          {call.other_user_name || 'Unknown'}
                        </span>
                        <Show when={call.call_type === 'video'}>
                          <span class="text-gray-500 dark:text-gray-500">
                            <VideoIcon />
                          </span>
                        </Show>
                      </div>
                      <div class="text-sm text-gray-500 dark:text-gray-400 flex items-center gap-2">
                        <span>{call.is_outgoing ? 'Outgoing' : 'Incoming'}</span>
                        <Show when={call.duration_seconds > 0}>
                          <span>•</span>
                          <span>{formatDuration(call.duration_seconds)}</span>
                        </Show>
                        <Show when={call.end_reason === 'missed'}>
                          <span class="text-red-400">• Missed</span>
                        </Show>
                      </div>
                    </div>

                    {/* Time */}
                    <div class="text-sm text-gray-500 dark:text-gray-400 flex-shrink-0">
                      {formatDate(call.started_at)}
                    </div>

                    {/* Call back button */}
                    <button
                      onClick={() => handleCallBack(call)}
                      class="flex-shrink-0 p-2 rounded-full bg-green-600 text-white hover:bg-green-700 transition-colors"
                      title="Call back"
                    >
                      <Show when={call.call_type === 'video'} fallback={<CallIcon />}>
                        <VideoIcon />
                      </Show>
                    </button>
                  </div>
                )}
              </For>
            </div>
          </Show>
        </Show>
      </div>
    </div>
  );
};

export default CallHistory;
