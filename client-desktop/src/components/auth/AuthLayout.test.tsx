/**
 * AuthLayout Component Tests
 *
 * Tests for the authentication layout wrapper component.
 */

import { render, screen } from '@solidjs/testing-library';
import { describe, expect, it } from 'vitest';
import AuthLayout from './AuthLayout';

describe('AuthLayout', () => {
  it('renders title and subtitle', () => {
    render(() => (
      <AuthLayout title="Test Title" subtitle="Test Subtitle">
        <div>Test content</div>
      </AuthLayout>
    ));

    expect(screen.getByText('Test Title')).toBeInTheDocument();
    expect(screen.getByText('Test Subtitle')).toBeInTheDocument();
  });

  it('renders children content', () => {
    render(() => (
      <AuthLayout title="Title" subtitle="Subtitle">
        <div data-testid="child-content">Child content</div>
      </AuthLayout>
    ));

    expect(screen.getByTestId('child-content')).toBeInTheDocument();
    expect(screen.getByText('Child content')).toBeInTheDocument();
  });

  it('displays security badges', () => {
    render(() => (
      <AuthLayout title="Title" subtitle="Subtitle">
        <div>Content</div>
      </AuthLayout>
    ));

    expect(screen.getByText('E2E Encrypted')).toBeInTheDocument();
    expect(screen.getByText('Post-Quantum Ready')).toBeInTheDocument();
  });

  it('has gradient background elements', () => {
    const { container } = render(() => (
      <AuthLayout title="Title" subtitle="Subtitle">
        <div>Content</div>
      </AuthLayout>
    ));

    // Check for gradient orbs
    expect(container.querySelector('.gradient-orb-1')).toBeInTheDocument();
    expect(container.querySelector('.gradient-orb-2')).toBeInTheDocument();
    expect(container.querySelector('.gradient-orb-3')).toBeInTheDocument();
  });

  it('applies glassmorphism card styling', () => {
    const { container } = render(() => (
      <AuthLayout title="Title" subtitle="Subtitle">
        <div>Content</div>
      </AuthLayout>
    ));

    expect(container.querySelector('.auth-card')).toBeInTheDocument();
  });
});
