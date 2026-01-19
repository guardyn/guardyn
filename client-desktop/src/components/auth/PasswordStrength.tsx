/**
 * Password Strength Indicator
 *
 * Visual feedback for password strength with requirements checklist.
 */

import { Component, createMemo, For, Show } from 'solid-js';

interface PasswordStrengthProps {
  password: string;
  showRequirements?: boolean;
}

interface Requirement {
  label: string;
  test: (password: string) => boolean;
}

const requirements: Requirement[] = [
  { label: 'At least 8 characters', test: (p) => p.length >= 8 },
  { label: 'Contains uppercase letter', test: (p) => /[A-Z]/.test(p) },
  { label: 'Contains lowercase letter', test: (p) => /[a-z]/.test(p) },
  { label: 'Contains a number', test: (p) => /\d/.test(p) },
  { label: 'Contains special character', test: (p) => /[!@#$%^&*(),.?":{}|<>]/.test(p) },
];

const PasswordStrength: Component<PasswordStrengthProps> = (props) => {
  const strength = createMemo(() => {
    if (!props.password) return 0;
    return requirements.filter((req) => req.test(props.password)).length;
  });

  const strengthLabel = createMemo(() => {
    const s = strength();
    if (s === 0) return '';
    if (s <= 2) return 'Weak';
    if (s <= 3) return 'Fair';
    if (s <= 4) return 'Strong';
    return 'Excellent';
  });

  const strengthColor = createMemo(() => {
    const s = strength();
    if (s <= 2) return 'bg-red-500';
    if (s <= 3) return 'bg-yellow-500';
    if (s <= 4) return 'bg-guardyn-500';
    return 'bg-guardyn-400';
  });

  return (
    <div class="password-strength">
      {/* Strength bar */}
      <Show when={props.password.length > 0}>
        <div class="flex items-center gap-2 mb-2">
          <div class="flex-1 h-1 bg-white/10 rounded-full overflow-hidden flex gap-0.5">
            <For each={Array(5).fill(0)}>
              {(_, i) => (
                <div
                  class="flex-1 h-full rounded-full transition-all duration-300"
                  classList={{
                    [strengthColor()]: i() < strength(),
                    'bg-transparent': i() >= strength(),
                  }}
                />
              )}
            </For>
          </div>
          <span
            class="text-xs font-medium min-w-16 text-right"
            classList={{
              'text-red-400': strength() <= 2,
              'text-yellow-400': strength() === 3,
              'text-guardyn-400': strength() >= 4,
            }}
          >
            {strengthLabel()}
          </span>
        </div>
      </Show>

      {/* Requirements list */}
      <Show when={props.showRequirements && props.password.length > 0}>
        <div class="mt-3 space-y-1.5 animate-fade-in">
          <For each={requirements}>
            {(req) => {
              const passed = () => req.test(props.password);
              return (
                <div
                  class="flex items-center gap-2 text-xs transition-colors duration-200"
                  classList={{
                    'text-gray-500': !passed(),
                    'text-guardyn-400': passed(),
                  }}
                >
                  <svg
                    class="w-3.5 h-3.5 transition-transform duration-200"
                    classList={{
                      'scale-110': passed(),
                    }}
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <Show
                      when={passed()}
                      fallback={
                        <circle cx="12" cy="12" r="8" stroke-width="2" class="opacity-50" />
                      }
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                      />
                    </Show>
                  </svg>
                  <span>{req.label}</span>
                </div>
              );
            }}
          </For>
        </div>
      </Show>
    </div>
  );
};

export default PasswordStrength;
