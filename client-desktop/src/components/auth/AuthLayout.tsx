/**
 * Auth Layout Component
 *
 * Modern glassmorphism design for authentication pages.
 * Features animated gradient background and floating elements.
 */

import { Component, JSX } from 'solid-js';

interface AuthLayoutProps {
  children: JSX.Element;
  title: string;
  subtitle: string;
}

const AuthLayout: Component<AuthLayoutProps> = (props) => {
  return (
    <div class="auth-layout min-h-screen w-full flex items-center justify-center p-4 overflow-hidden relative">
      {/* Animated gradient background */}
      <div class="auth-bg absolute inset-0 -z-10">
        <div class="gradient-orb gradient-orb-1" />
        <div class="gradient-orb gradient-orb-2" />
        <div class="gradient-orb gradient-orb-3" />
      </div>

      {/* Grid pattern overlay */}
      <div class="absolute inset-0 -z-5 bg-grid-pattern opacity-5" />

      {/* Main content card */}
      <div class="auth-card w-full max-w-md animate-scale-in">
        {/* Logo section */}
        <div class="text-center mb-8">
          <div class="logo-container inline-flex items-center justify-center mb-4">
            <svg
              class="w-12 h-12 text-guardyn-500 animate-pulse-slow"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="1.5"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z"
              />
            </svg>
          </div>
          <h1 class="text-3xl font-bold bg-gradient-to-r from-guardyn-400 to-guardyn-600 bg-clip-text text-transparent">
            {props.title}
          </h1>
          <p class="mt-2 text-gray-400 text-sm">{props.subtitle}</p>
        </div>

        {/* Form container */}
        <div class="space-y-6">{props.children}</div>

        {/* Security badge */}
        <div class="mt-8 pt-6 border-t border-white/5">
          <div class="flex items-center justify-center gap-4 text-xs text-gray-500">
            <div class="flex items-center gap-1">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                />
              </svg>
              <span>E2E Encrypted</span>
            </div>
            <div class="w-1 h-1 rounded-full bg-gray-600" />
            <div class="flex items-center gap-1">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                />
              </svg>
              <span>Post-Quantum Ready</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AuthLayout;
