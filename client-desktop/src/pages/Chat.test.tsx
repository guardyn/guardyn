import { Router } from '@solidjs/router';
import { fireEvent, render, screen, waitFor } from '@solidjs/testing-library';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { Conversation, Message } from '../types';
import Chat from './Chat';

// Mock Tauri invoke
const mockInvoke = vi.fn();
vi.mock('@tauri-apps/api/core', () => ({
  invoke: (...args: unknown[]) => mockInvoke(...args),
}));

// Helper to render with router
const renderWithRouter = (ui: () => ReturnType<typeof Chat>) => {
  return render(() => <Router>{ui()}</Router>);
};

describe('Chat Page', () => {
  const mockConversations: Conversation[] = [
    {
      id: 'conv-1',
      name: 'Alice',
      is_group: false,
      participant_ids: ['user-1', 'user-2'],
      last_message: {
        id: 'msg-1',
        content: 'Hello there!',
        sender_id: 'user-2',
        timestamp: Date.now(),
      },
      unread_count: 2,
      updated_at: Date.now(),
    },
    {
      id: 'conv-2',
      name: 'Team Chat',
      is_group: true,
      participant_ids: ['user-1', 'user-2', 'user-3'],
      last_message: {
        id: 'msg-2',
        content: 'Meeting at 3pm',
        sender_id: 'user-3',
        timestamp: Date.now() - 3600000,
      },
      unread_count: 0,
      updated_at: Date.now() - 3600000,
    },
  ];

  const mockMessages: Message[] = [
    {
      id: 'msg-1',
      conversation_id: 'conv-1',
      sender_id: 'user-2',
      content: 'Hello there!',
      timestamp: Date.now() - 60000,
      status: 'Read',
      reactions: [],
    },
    {
      id: 'msg-2',
      conversation_id: 'conv-1',
      sender_id: 'user-1',
      content: 'Hi! How are you?',
      timestamp: Date.now(),
      status: 'Sent',
      reactions: [],
    },
  ];

  beforeEach(() => {
    mockInvoke.mockClear();
  });

  it('renders the chat page with loading state', () => {
    mockInvoke.mockImplementation(() => new Promise(() => {}));

    renderWithRouter(() => <Chat />);

    expect(screen.getByText('Messages')).toBeInTheDocument();
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('loads and displays conversations', async () => {
    mockInvoke.mockResolvedValueOnce(mockConversations);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
      expect(screen.getByText('Team Chat')).toBeInTheDocument();
    });
  });

  it('displays last message preview', async () => {
    mockInvoke.mockResolvedValueOnce(mockConversations);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Hello there!')).toBeInTheDocument();
      expect(screen.getByText('Meeting at 3pm')).toBeInTheDocument();
    });
  });

  it('displays unread count badge', async () => {
    mockInvoke.mockResolvedValueOnce(mockConversations);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('2')).toBeInTheDocument();
    });
  });

  it('shows empty state when no conversations', async () => {
    mockInvoke.mockResolvedValueOnce([]);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('No conversations yet')).toBeInTheDocument();
      expect(screen.getByText('Start a new chat')).toBeInTheDocument();
    });
  });

  it('shows placeholder when no conversation selected', async () => {
    mockInvoke.mockResolvedValueOnce(mockConversations);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Select a conversation to start messaging')).toBeInTheDocument();
    });
  });

  it('loads messages when conversation is selected', async () => {
    mockInvoke
      .mockResolvedValueOnce(mockConversations) // get_conversations
      .mockResolvedValueOnce(mockMessages); // get_messages

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
    });

    const aliceConv = screen.getByText('Alice').closest('button');
    await fireEvent.click(aliceConv!);

    await waitFor(() => {
      expect(mockInvoke).toHaveBeenCalledWith('get_messages', { conversationId: 'conv-1' });
    });
  });

  it('displays messages in conversation', async () => {
    mockInvoke
      .mockResolvedValueOnce(mockConversations)
      .mockResolvedValueOnce(mockMessages);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
    });

    const aliceConv = screen.getByText('Alice').closest('button');
    await fireEvent.click(aliceConv!);

    await waitFor(() => {
      expect(screen.getByText('Hello there!')).toBeInTheDocument();
      expect(screen.getByText('Hi! How are you?')).toBeInTheDocument();
    });
  });

  it('sends a new message', async () => {
    mockInvoke
      .mockResolvedValueOnce(mockConversations)
      .mockResolvedValueOnce(mockMessages)
      .mockResolvedValueOnce(undefined) // send_message
      .mockResolvedValueOnce([...mockMessages, {
        id: 'msg-3',
        conversation_id: 'conv-1',
        sender_id: 'user-1',
        content: 'New message',
        timestamp: Date.now(),
        status: 'Sending',
        reactions: [],
      }]); // get_messages after send

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
    });

    const aliceConv = screen.getByText('Alice').closest('button');
    await fireEvent.click(aliceConv!);

    await waitFor(() => {
      expect(screen.getByPlaceholderText('Type a message...')).toBeInTheDocument();
    });

    const messageInput = screen.getByPlaceholderText('Type a message...') as HTMLInputElement;
    const sendButton = screen.getByRole('button', { name: /send/i });

    await fireEvent.input(messageInput, { target: { value: 'New message' } });
    await fireEvent.click(sendButton);

    await waitFor(() => {
      expect(mockInvoke).toHaveBeenCalledWith('send_message', {
        conversationId: 'conv-1',
        content: 'New message',
      });
    });
  });

  it('clears message input after sending', async () => {
    mockInvoke
      .mockResolvedValueOnce(mockConversations)
      .mockResolvedValueOnce(mockMessages)
      .mockResolvedValueOnce(undefined)
      .mockResolvedValueOnce(mockMessages);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
    });

    const aliceConv = screen.getByText('Alice').closest('button');
    await fireEvent.click(aliceConv!);

    await waitFor(() => {
      expect(screen.getByPlaceholderText('Type a message...')).toBeInTheDocument();
    });

    const messageInput = screen.getByPlaceholderText('Type a message...') as HTMLInputElement;
    const sendButton = screen.getByRole('button', { name: /send/i });

    await fireEvent.input(messageInput, { target: { value: 'Test message' } });
    await fireEvent.click(sendButton);

    await waitFor(() => {
      expect(messageInput.value).toBe('');
    });
  });

  it('does not send empty messages', async () => {
    mockInvoke
      .mockResolvedValueOnce(mockConversations)
      .mockResolvedValueOnce(mockMessages);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
    });

    const aliceConv = screen.getByText('Alice').closest('button');
    await fireEvent.click(aliceConv!);

    await waitFor(() => {
      expect(screen.getByPlaceholderText('Type a message...')).toBeInTheDocument();
    });

    const sendButton = screen.getByRole('button', { name: /send/i });
    await fireEvent.click(sendButton);

    // send_message should not be called
    expect(mockInvoke).not.toHaveBeenCalledWith('send_message', expect.anything());
  });

  it('highlights selected conversation', async () => {
    mockInvoke
      .mockResolvedValueOnce(mockConversations)
      .mockResolvedValueOnce(mockMessages);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
    });

    const aliceConv = screen.getByText('Alice').closest('button');
    await fireEvent.click(aliceConv!);

    await waitFor(() => {
      expect(aliceConv).toHaveClass('bg-gray-700');
    });
  });

  it('handles conversation loading error gracefully', async () => {
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
    mockInvoke.mockRejectedValueOnce(new Error('Failed to load'));

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(consoleSpy).toHaveBeenCalledWith('Failed to load conversations:', expect.any(Error));
    });

    consoleSpy.mockRestore();
  });
});
