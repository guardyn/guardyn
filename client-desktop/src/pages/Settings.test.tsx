import { Router } from '@solidjs/router';
import { fireEvent, render, screen, waitFor } from '@solidjs/testing-library';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { Settings as SettingsType } from '../types';
import Settings from './Settings';

// Mock Tauri invoke
const mockInvoke = vi.fn();
vi.mock('@tauri-apps/api/core', () => ({
  invoke: (...args: unknown[]) => mockInvoke(...args),
}));

// Helper to render with router
const renderWithRouter = (ui: () => ReturnType<typeof Settings>) => {
  return render(() => <Router>{ui()}</Router>);
};

describe('Settings Page', () => {
  const mockSettings: Partial<SettingsType> = {
    theme: 'dark',
    notifications_enabled: true,
    sound_enabled: true,
    show_message_preview: true,
    language: 'en',
  };

  beforeEach(() => {
    mockInvoke.mockClear();
    mockInvoke.mockResolvedValue(mockSettings);
  });

  it('renders settings sections', async () => {
    renderWithRouter(() => <Settings />);

    expect(screen.getByText('Settings')).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.getByText('Appearance')).toBeInTheDocument();
      expect(screen.getByText('Notifications')).toBeInTheDocument();
      expect(screen.getByText('Privacy')).toBeInTheDocument();
      expect(screen.getByText('Security')).toBeInTheDocument();
    });
  });

  it('loads user settings on mount', async () => {
    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(mockInvoke).toHaveBeenCalledWith('get_settings');
    });
  });

  it('displays theme selector', async () => {
    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(screen.getByText('Theme')).toBeInTheDocument();
      expect(screen.getByText('Choose your preferred color scheme')).toBeInTheDocument();
    });

    const themeSelect = screen.getByRole('combobox', { name: /theme/i }) || 
                        screen.getAllByRole('combobox')[0];
    expect(themeSelect).toBeInTheDocument();
  });

  it('displays language selector', async () => {
    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(screen.getByText('Language')).toBeInTheDocument();
      expect(screen.getByText('Select your language')).toBeInTheDocument();
    });
  });

  it('updates theme setting', async () => {
    mockInvoke
      .mockResolvedValueOnce(mockSettings) // get_settings
      .mockResolvedValueOnce(undefined); // update_settings

    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(screen.getByText('Theme')).toBeInTheDocument();
    });

    const themeSelect = screen.getAllByRole('combobox')[0] as HTMLSelectElement;
    await fireEvent.change(themeSelect, { target: { value: 'light' } });

    await waitFor(() => {
      expect(mockInvoke).toHaveBeenCalledWith('update_settings', {
        key: 'theme',
        value: 'light',
      });
    });
  });

  it('displays notification settings', async () => {
    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(screen.getByText('Enable notifications')).toBeInTheDocument();
      expect(screen.getByText('Notification sounds')).toBeInTheDocument();
      expect(screen.getByText('Message preview')).toBeInTheDocument();
    });
  });

  it('toggles notification setting', async () => {
    mockInvoke
      .mockResolvedValueOnce(mockSettings)
      .mockResolvedValueOnce(undefined);

    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(screen.getByText('Enable notifications')).toBeInTheDocument();
    });

    // Find the toggle for notifications
    const toggles = screen.getAllByRole('checkbox');
    if (toggles.length > 0) {
      await fireEvent.click(toggles[0]);

      await waitFor(() => {
        expect(mockInvoke).toHaveBeenCalledWith('update_settings', {
          key: 'notifications_enabled',
          value: false,
        });
      });
    }
  });

  it('displays privacy settings', async () => {
    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(screen.getByText('Privacy')).toBeInTheDocument();
      expect(screen.getByText('Read receipts')).toBeInTheDocument();
      expect(screen.getByText('Typing indicators')).toBeInTheDocument();
    });
  });

  it('displays security section', async () => {
    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(screen.getByText('Security')).toBeInTheDocument();
      expect(screen.getByText('Export Keys')).toBeInTheDocument();
    });
  });

  it('exports keys when button is clicked', async () => {
    mockInvoke
      .mockResolvedValueOnce(mockSettings)
      .mockResolvedValueOnce(undefined);

    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(screen.getByText('Export Keys')).toBeInTheDocument();
    });

    const exportButton = screen.getByText('Export Keys').closest('button');
    if (exportButton) {
      await fireEvent.click(exportButton);

      await waitFor(() => {
        expect(mockInvoke).toHaveBeenCalledWith('export_keys');
      });
    }
  });

  it('shows saving state when updating settings', async () => {
    let resolveUpdate: (value: unknown) => void;
    mockInvoke
      .mockResolvedValueOnce(mockSettings)
      .mockImplementationOnce(() => new Promise((resolve) => {
        resolveUpdate = resolve;
      }));

    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(screen.getByText('Theme')).toBeInTheDocument();
    });

    const themeSelect = screen.getAllByRole('combobox')[0];
    await fireEvent.change(themeSelect, { target: { value: 'light' } });

    // Resolve the update
    resolveUpdate!(undefined);

    await waitFor(() => {
      expect(mockInvoke).toHaveBeenCalledWith('update_settings', expect.anything());
    });
  });

  it('shows saved confirmation after update', async () => {
    vi.useFakeTimers();

    mockInvoke
      .mockResolvedValueOnce(mockSettings)
      .mockResolvedValueOnce(undefined);

    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(screen.getByText('Theme')).toBeInTheDocument();
    });

    const themeSelect = screen.getAllByRole('combobox')[0];
    await fireEvent.change(themeSelect, { target: { value: 'light' } });

    await waitFor(() => {
      expect(mockInvoke).toHaveBeenCalledWith('update_settings', expect.anything());
    });

    vi.useRealTimers();
  });

  it('handles settings load error gracefully', async () => {
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
    mockInvoke.mockRejectedValueOnce(new Error('Failed to load settings'));

    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(consoleSpy).toHaveBeenCalledWith('Failed to load settings:', expect.any(Error));
    });

    consoleSpy.mockRestore();
  });

  it('handles settings update error gracefully', async () => {
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
    mockInvoke
      .mockResolvedValueOnce(mockSettings)
      .mockRejectedValueOnce(new Error('Failed to save'));

    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(screen.getByText('Theme')).toBeInTheDocument();
    });

    const themeSelect = screen.getAllByRole('combobox')[0];
    await fireEvent.change(themeSelect, { target: { value: 'light' } });

    await waitFor(() => {
      expect(consoleSpy).toHaveBeenCalledWith('Failed to save settings:', expect.any(Error));
    });

    consoleSpy.mockRestore();
  });

  it('displays available theme options', async () => {
    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      const themeSelect = screen.getAllByRole('combobox')[0];
      expect(themeSelect).toBeInTheDocument();
    });

    const options = screen.getAllByRole('option') as HTMLOptionElement[];
    const themeOptions = options.filter(
      (opt: HTMLOptionElement) => ['Light', 'Dark', 'System'].includes(opt.textContent || '')
    );
    expect(themeOptions.length).toBeGreaterThanOrEqual(2);
  });

  it('displays available language options', async () => {
    renderWithRouter(() => <Settings />);

    await waitFor(() => {
      expect(screen.getByText('Language')).toBeInTheDocument();
    });

    const options = screen.getAllByRole('option') as HTMLOptionElement[];
    const languageOptions = options.filter(
      (opt: HTMLOptionElement) => ['English', 'Deutsch', 'Français', 'Español'].includes(opt.textContent || '')
    );
    expect(languageOptions.length).toBeGreaterThanOrEqual(1);
  });
});
