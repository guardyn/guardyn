import { Router } from '@solidjs/router';
import { fireEvent, render, screen, waitFor } from '@solidjs/testing-library';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { Conversation, Message } from '../types';

// Create hoisted mock that can be used by vi.mock
const { mockInvoke, mockWs, mockEncryptMessage } = vi.hoisted(() => {
  const ws = {
    connect: vi.fn(async () => {}),
    disconnect: vi.fn(),
    send: vi.fn(),
    sendMessage: vi.fn(),
    sendTyping: vi.fn(),
    on: vi.fn(),
    off: vi.fn(),
    // Chat.tsx registers these in onMount; capture the state callback so a test can bring
    // the socket up and actually exercise the send path.
    onStateChange: vi.fn((cb: (state: string) => void) => {
      ws._stateCb = cb;
    }),
    onMessage: vi.fn(),
    onTyping: vi.fn(),
    isConnected: false,
    _stateCb: undefined as ((state: string) => void) | undefined,
  };
  return {
    mockInvoke: vi.fn(),
    mockWs: ws,
    mockEncryptMessage: vi.fn(),
  };
});

// Mock Tauri API using hoisted mock
vi.mock('@tauri-apps/api/core', () => ({
  invoke: (...args: unknown[]) => mockInvoke(...args),
}));

// Mock WebSocket modules
vi.mock('../api/websocket', () => ({
  MessageType: {
    TEXT_MESSAGE: 'TEXT_MESSAGE',
    TYPING_START: 'TYPING_START',
    TYPING_STOP: 'TYPING_STOP',
    PRESENCE_UPDATE: 'PRESENCE_UPDATE',
  },
  initWebSocket: vi.fn(() => mockWs),
  getWebSocket: vi.fn(() => mockWs),
  destroyWebSocket: vi.fn(),
}));

// The send path now runs through the encryption manager, and must refuse when it throws.
vi.mock('../services/encryption', () => ({
  encryptionManager: {
    encryptMessage: (...args: unknown[]) => mockEncryptMessage(...args),
  },
}));

vi.mock('../api/websocket.mock', () => ({
  startMockGenerator: vi.fn(),
  stopMockGenerator: vi.fn(),
}));

import { resetMessageStore } from '../stores/messageStore';
import Chat from './Chat';

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

  // Default WebSocket config mock response
  const mockWsConfig = {
    url: 'ws://localhost:8080/ws',
    token: 'mock-token-for-testing',
    device_id: 'test-device',
    user_id: 'user-1',
  };

  beforeEach(() => {
    mockInvoke.mockReset();
    mockWs.sendMessage.mockClear();
    mockWs._stateCb = undefined;
    mockEncryptMessage.mockReset();
    resetMessageStore();
  });

  // Helper: set up mockInvoke to return ws config first, then data
  const setupMockInvoke = (...responses: unknown[]) => {
    mockInvoke
      .mockResolvedValueOnce(mockWsConfig); // get_ws_config (always first)
    for (const response of responses) {
      mockInvoke.mockResolvedValueOnce(response);
    }
  };

  it('renders the chat page with loading state', () => {
    mockInvoke.mockImplementation(() => new Promise(() => {}));

    renderWithRouter(() => <Chat />);

    expect(screen.getByText('Messages')).toBeInTheDocument();
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('loads and displays conversations', async () => {
    setupMockInvoke(mockConversations);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
      expect(screen.getByText('Team Chat')).toBeInTheDocument();
    });
  });

  it('displays last message preview', async () => {
    setupMockInvoke(mockConversations);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Hello there!')).toBeInTheDocument();
      expect(screen.getByText('Meeting at 3pm')).toBeInTheDocument();
    });
  });

  it('displays unread count badge', async () => {
    setupMockInvoke(mockConversations);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('2')).toBeInTheDocument();
    });
  });

  it('shows empty state when no conversations', async () => {
    setupMockInvoke([]);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('No conversations yet')).toBeInTheDocument();
      expect(screen.getByText('Start a new chat')).toBeInTheDocument();
    });
  });

  it('shows placeholder when no conversation selected', async () => {
    setupMockInvoke(mockConversations);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Select a conversation to start messaging')).toBeInTheDocument();
    });
  });

  it('loads messages when conversation is selected', async () => {
    setupMockInvoke(mockConversations, mockMessages);

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
    setupMockInvoke(mockConversations, mockMessages);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
    });

    const aliceConv = screen.getByText('Alice').closest('button');
    await fireEvent.click(aliceConv!);

    await waitFor(() => {
      // Hello there! appears twice - in conversation preview and in message
      const helloMessages = screen.getAllByText('Hello there!');
      expect(helloMessages.length).toBeGreaterThanOrEqual(1);
      expect(screen.getByText('Hi! How are you?')).toBeInTheDocument();
    });
  });

  // These two replace a test named "sends a new message", which asserted
  //
  //     expect(mockInvoke).toHaveBeenCalledWith('send_message', {
  //       conversationId: 'conv-1', recipientId: 'user-1', content: 'New message', ...
  //     })
  //
  // - that is, it pinned #163: it required the plaintext to be handed to the transport, and
  // would have failed had the client started encrypting. A test that enforces the defect has
  // to be corrected rather than kept, the same way #227 corrected the mobile equivalent.

  const openAliceAndType = async (text: string) => {
    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
    });

    await fireEvent.click(screen.getByText('Alice').closest('button')!);

    await waitFor(() => {
      expect(screen.getByPlaceholderText('Type a message...')).toBeInTheDocument();
    });

    // Bring the socket up, as onStateChange would at runtime.
    mockWs._stateCb?.('connected');

    const messageInput = screen.getByPlaceholderText('Type a message...') as HTMLInputElement;
    await fireEvent.input(messageInput, { target: { value: text } });
    await fireEvent.click(screen.getByRole('button', { name: /send message/i }));
  };

  it('sends ciphertext, never the plaintext', async () => {
    setupMockInvoke(mockConversations, mockMessages, undefined, mockMessages);
    mockEncryptMessage.mockResolvedValue({ ciphertext: 'AQIDBA==', nonce: '', header: '' });

    await openAliceAndType('New message');

    await waitFor(() => {
      expect(mockWs.sendMessage).toHaveBeenCalled();
    });

    const [recipientId, payload, options] = mockWs.sendMessage.mock.calls[0];
    expect(recipientId).toBe('user-1');
    expect(payload).toBe('AQIDBA==');
    expect(payload).not.toBe('New message');
    expect(options.encrypted).toBe(true);

    // The plaintext must not reach the transport by any route, including the gRPC command
    // that used to be invoked alongside the socket.
    expect(mockInvoke).not.toHaveBeenCalledWith('send_message', expect.anything());
    expect(JSON.stringify(mockWs.sendMessage.mock.calls)).not.toContain('New message');
  });

  it('refuses to send when encryption is unavailable', async () => {
    setupMockInvoke(mockConversations, mockMessages, undefined, mockMessages);
    mockEncryptMessage.mockRejectedValue(
      new Error('No established session with peer: user-1')
    );

    await openAliceAndType('New message');

    // Fail closed: nothing leaves the client at all.
    await waitFor(() => {
      expect(mockEncryptMessage).toHaveBeenCalled();
    });
    expect(mockWs.sendMessage).not.toHaveBeenCalled();
    expect(mockInvoke).not.toHaveBeenCalledWith('send_message', expect.anything());
  });

  // TODO: Fix these tests after WebSocket integration stabilizes
  it.skip('clears message input after sending', async () => {
    setupMockInvoke(mockConversations, mockMessages, undefined, mockMessages);

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
    const sendButton = screen.getByRole('button', { name: /send message/i });

    await fireEvent.input(messageInput, { target: { value: 'Test message' } });
    await fireEvent.click(sendButton);

    await waitFor(() => {
      expect(messageInput.value).toBe('');
    });
  });

  // TODO: Fix this test after WebSocket integration stabilizes
  it.skip('does not send empty messages', async () => {
    setupMockInvoke(mockConversations, mockMessages);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
    });

    const aliceConv = screen.getByText('Alice').closest('button');
    await fireEvent.click(aliceConv!);

    await waitFor(() => {
      expect(screen.getByPlaceholderText('Type a message...')).toBeInTheDocument();
    });

    const sendButton = screen.getByRole('button', { name: /send message/i });
    await fireEvent.click(sendButton);

    // send_message should not be called
    expect(mockInvoke).not.toHaveBeenCalledWith('send_message', expect.anything());
  });

  // TODO: Fix this test after WebSocket integration stabilizes
  it.skip('highlights selected conversation', async () => {
    setupMockInvoke(mockConversations, mockMessages);

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
    });

    const aliceConv = screen.getByText('Alice').closest('button');
    await fireEvent.click(aliceConv!);

    await waitFor(() => {
      // Check for selected state - in light mode it's bg-gray-100, in dark mode bg-gray-700
      expect(aliceConv).toHaveClass('bg-gray-100');
    });
  });

  // TODO: Fix this test - need to ensure error path is hit with new WebSocket code
  it.skip('handles conversation loading error gracefully', async () => {
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
    mockInvoke
      .mockRejectedValueOnce(new Error('Failed to load'));

    renderWithRouter(() => <Chat />);

    await waitFor(() => {
      // Check that an error was logged (could be conversations or other)
      expect(consoleSpy).toHaveBeenCalled();
    });

    consoleSpy.mockRestore();
  });
});
