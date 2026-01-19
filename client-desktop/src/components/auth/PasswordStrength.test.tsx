/**
 * PasswordStrength Component Tests
 *
 * Tests for the password strength indicator component.
 */

import { render, screen } from '@solidjs/testing-library';
import { describe, expect, it } from 'vitest';
import PasswordStrength from './PasswordStrength';

describe('PasswordStrength', () => {
  it('shows nothing for empty password', () => {
    const { container } = render(() => (
      <PasswordStrength password="" />
    ));

    expect(container.querySelector('.password-strength')).toBeInTheDocument();
    expect(screen.queryByText('Weak')).not.toBeInTheDocument();
  });

  it('shows "Weak" for short passwords', () => {
    render(() => (
      <PasswordStrength password="abc" />
    ));

    expect(screen.getByText('Weak')).toBeInTheDocument();
  });

  it('shows "Fair" for medium strength passwords', () => {
    // Fair = 3 requirements: lowercase, uppercase, number (but not 8 chars and no special)
    render(() => (
      <PasswordStrength password="Abc123" />
    ));

    expect(screen.getByText('Fair')).toBeInTheDocument();
  });

  it('shows "Strong" for good passwords', () => {
    // Strong = 4 requirements: 8+ chars, uppercase, lowercase, number (no special)
    render(() => (
      <PasswordStrength password="Abcd1234" />
    ));

    expect(screen.getByText('Strong')).toBeInTheDocument();
  });

  it('shows "Excellent" for very strong passwords', () => {
    // Excellent = all 5 requirements: 8+ chars, uppercase, lowercase, number, special
    render(() => (
      <PasswordStrength password="Abcd1234!" />
    ));

    expect(screen.getByText('Excellent')).toBeInTheDocument();
  });

  it('shows requirements when showRequirements is true', () => {
    render(() => (
      <PasswordStrength password="test" showRequirements />
    ));

    expect(screen.getByText('At least 8 characters')).toBeInTheDocument();
    expect(screen.getByText('Contains uppercase letter')).toBeInTheDocument();
    expect(screen.getByText('Contains lowercase letter')).toBeInTheDocument();
    expect(screen.getByText('Contains a number')).toBeInTheDocument();
    expect(screen.getByText('Contains special character')).toBeInTheDocument();
  });

  it('highlights passed requirements', () => {
    render(() => (
      <PasswordStrength password="TestPassword123!" showRequirements />
    ));

    // All requirements should be passed
    const requirements = screen.getAllByText(/At least|Contains/);
    expect(requirements.length).toBe(5);
  });

  it('does not show requirements when showRequirements is false', () => {
    render(() => (
      <PasswordStrength password="test" showRequirements={false} />
    ));

    expect(screen.queryByText('At least 8 characters')).not.toBeInTheDocument();
  });

  it('does not show requirements for empty password even with showRequirements', () => {
    render(() => (
      <PasswordStrength password="" showRequirements />
    ));

    // Requirements should only show when password.length > 0
    expect(screen.queryByText('At least 8 characters')).not.toBeInTheDocument();
  });
});
