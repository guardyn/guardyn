/**
 * SubmitButton Component Tests
 *
 * Tests for the animated submit button component.
 */

import { fireEvent, render, screen } from '@solidjs/testing-library';
import { describe, expect, it, vi } from 'vitest';
import SubmitButton from './SubmitButton';

describe('SubmitButton', () => {
  it('renders children content', () => {
    render(() => (
      <SubmitButton>Submit</SubmitButton>
    ));

    expect(screen.getByText('Submit')).toBeInTheDocument();
  });

  it('is enabled by default', () => {
    render(() => (
      <SubmitButton>Submit</SubmitButton>
    ));

    const button = screen.getByRole('button');
    expect(button).not.toBeDisabled();
  });

  it('can be disabled', () => {
    render(() => (
      <SubmitButton disabled>Submit</SubmitButton>
    ));

    const button = screen.getByRole('button');
    expect(button).toBeDisabled();
  });

  it('shows loading spinner when loading', () => {
    const { container } = render(() => (
      <SubmitButton loading>Submit</SubmitButton>
    ));

    const spinner = container.querySelector('.animate-spin');
    expect(spinner).toBeInTheDocument();
  });

  it('is disabled when loading', () => {
    render(() => (
      <SubmitButton loading>Submit</SubmitButton>
    ));

    const button = screen.getByRole('button');
    expect(button).toBeDisabled();
  });

  it('calls onClick when clicked', async () => {
    const handleClick = vi.fn();
    render(() => (
      <SubmitButton onClick={handleClick}>Submit</SubmitButton>
    ));

    const button = screen.getByRole('button');
    await fireEvent.click(button);

    expect(handleClick).toHaveBeenCalled();
  });

  it('does not call onClick when disabled', async () => {
    const handleClick = vi.fn();
    render(() => (
      <SubmitButton onClick={handleClick} disabled>Submit</SubmitButton>
    ));

    const button = screen.getByRole('button');
    await fireEvent.click(button);

    expect(handleClick).not.toHaveBeenCalled();
  });

  it('uses submit type by default', () => {
    render(() => (
      <SubmitButton>Submit</SubmitButton>
    ));

    const button = screen.getByRole('button');
    expect(button).toHaveAttribute('type', 'submit');
  });

  it('can be button type', () => {
    render(() => (
      <SubmitButton type="button">Click Me</SubmitButton>
    ));

    const button = screen.getByRole('button');
    expect(button).toHaveAttribute('type', 'button');
  });

  it('uses custom testid when provided', () => {
    render(() => (
      <SubmitButton data-testid="custom-button">Submit</SubmitButton>
    ));

    expect(screen.getByTestId('custom-button')).toBeInTheDocument();
  });

  it('has gradient styling when enabled', () => {
    render(() => (
      <SubmitButton>Submit</SubmitButton>
    ));

    const button = screen.getByRole('button');
    expect(button).toHaveClass('bg-gradient-to-r');
  });

  it('has gray styling when disabled', () => {
    render(() => (
      <SubmitButton disabled>Submit</SubmitButton>
    ));

    const button = screen.getByRole('button');
    expect(button).toHaveClass('bg-gray-700');
  });
});
