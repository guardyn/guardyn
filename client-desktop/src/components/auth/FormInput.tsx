/**
 * Form Input Component
 *
 * Reusable input component with modern styling and validation.
 */

import { Component, createSignal, JSX, Show } from 'solid-js';

interface FormInputProps {
  id: string;
  name: string;
  label: string;
  type?: 'text' | 'password' | 'email';
  value: string;
  placeholder?: string;
  required?: boolean;
  error?: string;
  hint?: string;
  icon?: JSX.Element;
  onInput: (value: string) => void;
  onBlur?: () => void;
  'data-testid'?: string;
}

const FormInput: Component<FormInputProps> = (props) => {
  const [focused, setFocused] = createSignal(false);
  const [showPassword, setShowPassword] = createSignal(false);

  const inputType = () => {
    if (props.type !== 'password') return props.type || 'text';
    return showPassword() ? 'text' : 'password';
  };

  return (
    <div class="form-group">
      <label
        for={props.id}
        class="block text-sm font-medium text-gray-300 mb-1.5 transition-colors"
        classList={{ 'text-guardyn-400': focused() }}
      >
        {props.label}
        {props.required && <span class="text-guardyn-500 ml-1">*</span>}
      </label>

      <div class="relative">
        {/* Left icon */}
        <Show when={props.icon}>
          <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-gray-500">
            {props.icon}
          </div>
        </Show>

        <input
          id={props.id}
          name={props.name}
          type={inputType()}
          required={props.required}
          value={props.value}
          placeholder={props.placeholder}
          data-testid={props['data-testid'] || `${props.name}-input`}
          onInput={(e) => props.onInput(e.currentTarget.value)}
          onFocus={() => setFocused(true)}
          onBlur={() => {
            setFocused(false);
            props.onBlur?.();
          }}
          class="input-field w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 transition-all duration-200"
          classList={{
            'pl-10': !!props.icon,
            'pr-10': props.type === 'password',
            'input-focused': focused(),
            'input-error': !!props.error,
          }}
        />

        {/* Password toggle */}
        <Show when={props.type === 'password'}>
          <button
            type="button"
            onClick={() => setShowPassword(!showPassword())}
            class="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-500 hover:text-gray-300 transition-colors"
            tabIndex={-1}
          >
            <Show
              when={showPassword()}
              fallback={
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                  />
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
                  />
                </svg>
              }
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"
                />
              </svg>
            </Show>
          </button>
        </Show>
      </div>

      {/* Hint or error */}
      <Show when={props.error}>
        <p class="mt-1.5 text-sm text-red-400 animate-shake">{props.error}</p>
      </Show>
      <Show when={!props.error && props.hint}>
        <p class="mt-1.5 text-xs text-gray-500">{props.hint}</p>
      </Show>
    </div>
  );
};

export default FormInput;
