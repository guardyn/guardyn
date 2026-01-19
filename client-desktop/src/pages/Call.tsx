/**
 * Call Page Component
 *
 * Handles voice and video calls with WebRTC.
 */

import { useNavigate, useParams } from '@solidjs/router';
import { listen } from '@tauri-apps/api/event';
import { Component, createEffect, createSignal, For, onCleanup, Show } from 'solid-js';
import {
  endCall,
  getScreenSources,
  startScreenShare,
  stopScreenShare,
  toggleMute,
  toggleVideo,
  type ScreenSource
} from '../api/calls';
import type { CallInfo } from '../types';

// Icons (inline SVGs for simplicity)
const MicIcon = () => (
  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" />
  </svg>
);

const MicOffIcon = () => (
  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" clip-rule="evenodd" />
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2" />
  </svg>
);

const VideoIcon = () => (
  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
  </svg>
);

const VideoOffIcon = () => (
  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" />
  </svg>
);

const ScreenShareIcon = () => (
  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
  </svg>
);

const EndCallIcon = () => (
  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 8l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2M5 3a2 2 0 00-2 2v1c0 8.284 6.716 15 15 15h1a2 2 0 002-2v-3.28a1 1 0 00-.684-.948l-4.493-1.498a1 1 0 00-1.21.502l-1.13 2.257a11.042 11.042 0 01-5.516-5.517l2.257-1.128a1 1 0 00.502-1.21L9.228 3.683A1 1 0 008.279 3H5z" />
  </svg>
);

const Call: Component = () => {
  const params = useParams<{ id: string }>();
  const navigate = useNavigate();

  // Call state
  const [callInfo, setCallInfo] = createSignal<CallInfo | null>(null);
  const [isMuted, setIsMuted] = createSignal(false);
  const [isVideoEnabled, setIsVideoEnabled] = createSignal(false);
  const [isScreenSharing, setIsScreenSharing] = createSignal(false);
  const [callDuration, setCallDuration] = createSignal(0);
  const [showScreenPicker, setShowScreenPicker] = createSignal(false);
  const [screenSources, setScreenSources] = createSignal<ScreenSource[]>([]);
  const [error, setError] = createSignal<string | null>(null);

  // Duration timer
  let durationInterval: number | null = null;

  createEffect(() => {
    const info = callInfo();
    if (info?.state === 'connected' && !durationInterval) {
      durationInterval = window.setInterval(() => {
        setCallDuration(d => d + 1);
      }, 1000);
    }
  });

  onCleanup(() => {
    if (durationInterval) {
      clearInterval(durationInterval);
    }
  });

  // Listen for call events
  createEffect(() => {
    const unlistenCallState = listen<CallInfo>('call:state_changed', (event) => {
      setCallInfo(event.payload);
      if (event.payload.state === 'ended') {
        navigate('/');
      }
    });

    onCleanup(() => {
      unlistenCallState.then(unlisten => unlisten());
    });
  });

  const formatDuration = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const handleToggleMute = async () => {
    const callId = params.id;
    if (!callId) return;

    try {
      const newState = !isMuted();
      await toggleMute(callId, newState);
      setIsMuted(newState);
    } catch (e) {
      setError(`Failed to toggle mute: ${e}`);
    }
  };

  const handleToggleVideo = async () => {
    const callId = params.id;
    if (!callId) return;

    try {
      const newState = !isVideoEnabled();
      await toggleVideo(callId, newState);
      setIsVideoEnabled(newState);
    } catch (e) {
      setError(`Failed to toggle video: ${e}`);
    }
  };

  const handleToggleScreenShare = async () => {
    const callId = params.id;
    if (!callId) return;

    if (isScreenSharing()) {
      // Stop screen sharing
      try {
        await stopScreenShare(callId);
        setIsScreenSharing(false);
      } catch (e) {
        setError(`Failed to stop screen share: ${e}`);
      }
    } else {
      // Show screen picker
      try {
        const sources = await getScreenSources();
        setScreenSources(sources);
        setShowScreenPicker(true);
      } catch (e) {
        setError(`Failed to get screen sources: ${e}`);
      }
    }
  };

  const handleSelectScreen = async (source: ScreenSource) => {
    const callId = params.id;
    if (!callId) return;

    try {
      await startScreenShare(callId, { audio: false, cursor: true });
      setIsScreenSharing(true);
      setShowScreenPicker(false);
    } catch (e) {
      setError(`Failed to start screen share: ${e}`);
    }
  };

  const handleEndCall = async () => {
    const callId = params.id;
    if (!callId) return;

    try {
      await endCall(callId);
      navigate('/');
    } catch (e) {
      setError(`Failed to end call: ${e}`);
    }
  };

  return (
    <div class="flex flex-col h-full bg-gray-100 dark:bg-gray-900 transition-colors duration-200">
      {/* Video area */}
      <div class="flex-1 relative bg-gray-200 dark:bg-gray-800">
        {/* Remote video placeholder */}
        <div class="absolute inset-0 flex items-center justify-center">
          <Show
            when={callInfo()?.participants?.length}
            fallback={
              <div class="text-gray-600 dark:text-gray-500 text-xl">
                Connecting...
              </div>
            }
          >
            <div class="text-gray-900 dark:text-white text-2xl">
              {callInfo()?.caller_name || 'Unknown'}
            </div>
          </Show>
        </div>

        {/* Local video preview (picture-in-picture) */}
        <Show when={isVideoEnabled()}>
          <div class="absolute bottom-4 right-4 w-48 h-36 bg-gray-300 dark:bg-gray-700 rounded-lg shadow-lg">
            <div class="flex items-center justify-center h-full text-gray-500 dark:text-gray-400 text-sm">
              Your camera
            </div>
          </div>
        </Show>

        {/* Screen share indicator */}
        <Show when={isScreenSharing()}>
          <div class="absolute top-4 left-4 bg-green-600 text-white px-3 py-1 rounded-full text-sm flex items-center gap-2">
            <ScreenShareIcon />
            Screen sharing
          </div>
        </Show>

        {/* Call duration */}
        <div class="absolute top-4 right-4 bg-black/50 text-white px-3 py-1 rounded-full text-sm">
          {formatDuration(callDuration())}
        </div>
      </div>

      {/* Controls bar */}
      <div class="bg-gray-200 dark:bg-gray-950 p-4">
        <div class="flex items-center justify-center gap-4">
          {/* Mute button */}
          <button
            onClick={handleToggleMute}
            class={`p-4 rounded-full transition-colors ${
              isMuted()
                ? 'bg-red-600 text-white'
                : 'bg-gray-300 dark:bg-gray-700 text-gray-900 dark:text-white hover:bg-gray-400 dark:hover:bg-gray-600'
            }`}
            title={isMuted() ? 'Unmute' : 'Mute'}
          >
            <Show when={isMuted()} fallback={<MicIcon />}>
              <MicOffIcon />
            </Show>
          </button>

          {/* Video button */}
          <button
            onClick={handleToggleVideo}
            class={`p-4 rounded-full transition-colors ${
              !isVideoEnabled()
                ? 'bg-red-600 text-white'
                : 'bg-gray-300 dark:bg-gray-700 text-gray-900 dark:text-white hover:bg-gray-400 dark:hover:bg-gray-600'
            }`}
            title={isVideoEnabled() ? 'Turn off camera' : 'Turn on camera'}
          >
            <Show when={isVideoEnabled()} fallback={<VideoOffIcon />}>
              <VideoIcon />
            </Show>
          </button>

          {/* Screen share button */}
          <button
            onClick={handleToggleScreenShare}
            class={`p-4 rounded-full transition-colors ${
              isScreenSharing()
                ? 'bg-green-600 text-white'
                : 'bg-gray-300 dark:bg-gray-700 text-gray-900 dark:text-white hover:bg-gray-400 dark:hover:bg-gray-600'
            }`}
            title={isScreenSharing() ? 'Stop sharing' : 'Share screen'}
          >
            <ScreenShareIcon />
          </button>

          {/* End call button */}
          <button
            onClick={handleEndCall}
            class="p-4 rounded-full bg-red-600 text-white hover:bg-red-700 transition-colors"
            title="End call"
          >
            <EndCallIcon />
          </button>
        </div>
      </div>

      {/* Screen picker modal */}
      <Show when={showScreenPicker()}>
        <div class="fixed inset-0 bg-black/80 flex items-center justify-center z-50">
          <div class="bg-white dark:bg-gray-800 rounded-lg p-6 max-w-2xl w-full mx-4 shadow-2xl">
            <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">
              Choose what to share
            </h2>

            <div class="grid grid-cols-2 gap-4 max-h-96 overflow-y-auto">
              <For each={screenSources()}>
                {(source) => (
                  <button
                    onClick={() => handleSelectScreen(source)}
                    class="bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 rounded-lg p-4 text-left transition-colors"
                  >
                    <div class="aspect-video bg-gray-200 dark:bg-gray-600 rounded mb-2 flex items-center justify-center">
                      <Show when={source.thumbnail} fallback={
                        <ScreenShareIcon />
                      }>
                        <img
                          src={`data:image/png;base64,${source.thumbnail}`}
                          alt={source.name}
                          class="w-full h-full object-cover rounded"
                        />
                      </Show>
                    </div>
                    <div class="text-gray-900 dark:text-white text-sm truncate">{source.name}</div>
                    <div class="text-gray-500 dark:text-gray-400 text-xs capitalize">{source.source_type}</div>
                  </button>
                )}
              </For>
            </div>

            <div class="flex justify-end mt-4">
              <button
                onClick={() => setShowScreenPicker(false)}
                class="px-4 py-2 bg-gray-200 dark:bg-gray-600 text-gray-900 dark:text-white rounded hover:bg-gray-300 dark:hover:bg-gray-500 transition-colors"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      </Show>

      {/* Error toast */}
      <Show when={error()}>
        <div class="fixed bottom-20 left-1/2 -translate-x-1/2 bg-red-600 text-white px-4 py-2 rounded-lg shadow-lg">
          {error()}
          <button
            onClick={() => setError(null)}
            class="ml-4 text-white/80 hover:text-white"
          >
            ×
          </button>
        </div>
      </Show>
    </div>
  );
};

export default Call;
