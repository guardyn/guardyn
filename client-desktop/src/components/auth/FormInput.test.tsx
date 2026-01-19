/**
 * FormInput Component Tests
 *
 * Tests for the reusable form input component.
 */

import { fireEvent, render, screen } from '@solidjs/testing-library';
import { describe, expect, it, vi } from 'vitest';
import FormInput from './FormInput';

describe('FormInput', () => {
  it('renders label and input', () => {
    render(() => (
      <FormInput
        id="test-input"
        name="test"
        label="Test Label"
        value=""
        onInput={() => {}}
      />
    ));

    expect(screen.getByLabelText(/test label/i)).toBeInTheDocument();
  });

  it('shows required indicator when required', () => {
    render(() => (
      <FormInput
        id="test"
        name="test"
        label="Required Field"
        value=""
        required
        onInput={() => {}}
      />
    ));

    expect(screen.getByText('*')).toBeInTheDocument();
  });

  it('handles text input', async () => {
    const handleInput = vi.fn();
    render(() => (
      <FormInput
        id="test"
        name="test"
        label="Test"
        value=""
        onInput={handleInput}
      />
    ));

    const input = screen.getByLabelText(/test/i);
    await fireEvent.input(input, { target: { value: 'Hello' } });

    expect(handleInput).toHaveBeenCalledWith('Hello');
  });

  it('shows error message when provided', () => {
    render(() => (
      <FormInput
        id="test"
        name="test"
        label="Test"
        value=""
        error="This field is required"
        onInput={() => {}}
      />
    ));

    expect(screen.getByText('This field is required')).toBeInTheDocument();
  });

  it('shows hint when no error', () => {
    render(() => (
      <FormInput
        id="test"
        name="test"
        label="Test"
        value=""
        hint="Helpful hint"
        onInput={() => {}}
      />
    ));

    expect(screen.getByText('Helpful hint')).toBeInTheDocument();
  });

  it('toggles password visibility', async () => {
    render(() => (
      <FormInput
        id="password"
        name="password"
        label="Password"
        type="password"
        value="secret"
        onInput={() => {}}
      />
    ));

    const input = screen.getByLabelText(/password/i) as HTMLInputElement;
    expect(input.type).toBe('password');

    // Find and click the toggle button
    const toggleButton = input.parentElement?.querySelector('button');
    expect(toggleButton).toBeInTheDocument();
    
    if (toggleButton) {
      await fireEvent.click(toggleButton);
      expect(input.type).toBe('text');

      await fireEvent.click(toggleButton);
      expect(input.type).toBe('password');
    }
  });

  it('renders with icon', () => {
    render(() => (
      <FormInput
        id="test"
        name="test"
        label="With Icon"
        value=""
        onInput={() => {}}
        icon={<svg data-testid="test-icon" />}
      />
    ));

    expect(screen.getByTestId('test-icon')).toBeInTheDocument();
  });

  it('applies focused state on focus', async () => {
    render(() => (
      <FormInput
        id="test"
        name="test"
        label="Test"
        value=""
        onInput={() => {}}
      />
    ));

    const input = screen.getByLabelText(/test/i);
    await fireEvent.focus(input);

    expect(input).toHaveClass('input-focused');
  });

  it('calls onBlur when input loses focus', async () => {
    const handleBlur = vi.fn();
    render(() => (
      <FormInput
        id="test"
        name="test"
        label="Test"
        value=""
        onInput={() => {}}
        onBlur={handleBlur}
      />
    ));

    const input = screen.getByLabelText(/test/i);
    await fireEvent.focus(input);
    await fireEvent.blur(input);

    expect(handleBlur).toHaveBeenCalled();
  });

  it('uses correct test id', () => {
    render(() => (
      <FormInput
        id="email"
        name="email"
        label="Email"
        value=""
        onInput={() => {}}
        data-testid="custom-email-input"
      />
    ));

    expect(screen.getByTestId('custom-email-input')).toBeInTheDocument();
  });

  it('uses default test id based on name', () => {
    render(() => (
      <FormInput
        id="username"
        name="username"
        label="Username"
        value=""
        onInput={() => {}}
      />
    ));

    expect(screen.getByTestId('username-input')).toBeInTheDocument();
  });
});
