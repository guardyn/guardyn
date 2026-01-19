/**
 * ErrorAlert Component Tests
 *
 * Tests for the error alert component.
 */

import { fireEvent, render, screen } from '@solidjs/testing-library';
import { describe, expect, it, vi } from 'vitest';
import ErrorAlert from './ErrorAlert';

describe('ErrorAlert', () => {
  it('renders error message', () => {
    render(() => (
      <ErrorAlert message="Something went wrong" />
    ));

    expect(screen.getByText('Something went wrong')).toBeInTheDocument();
  });

  it('does not render when message is empty', () => {
    const { container } = render(() => (
      <ErrorAlert message="" />
    ));

    expect(container.querySelector('.error-alert')).not.toBeInTheDocument();
  });

  it('has alert role for accessibility', () => {
    render(() => (
      <ErrorAlert message="Error" />
    ));

    expect(screen.getByRole('alert')).toBeInTheDocument();
  });

  it('shows dismiss button when onDismiss is provided', () => {
    render(() => (
      <ErrorAlert message="Error" onDismiss={() => {}} />
    ));

    const dismissButton = screen.getByRole('button');
    expect(dismissButton).toBeInTheDocument();
  });

  it('does not show dismiss button when onDismiss is not provided', () => {
    render(() => (
      <ErrorAlert message="Error" />
    ));

    expect(screen.queryByRole('button')).not.toBeInTheDocument();
  });

  it('calls onDismiss when dismiss button is clicked', async () => {
    const handleDismiss = vi.fn();
    render(() => (
      <ErrorAlert message="Error" onDismiss={handleDismiss} />
    ));

    const dismissButton = screen.getByRole('button');
    await fireEvent.click(dismissButton);

    expect(handleDismiss).toHaveBeenCalled();
  });

  it('has error-message test id', () => {
    render(() => (
      <ErrorAlert message="Error" />
    ));

    expect(screen.getByTestId('error-message')).toBeInTheDocument();
  });

  it('displays error icon', () => {
    const { container } = render(() => (
      <ErrorAlert message="Error" />
    ));

    const svg = container.querySelector('svg');
    expect(svg).toBeInTheDocument();
  });
});
