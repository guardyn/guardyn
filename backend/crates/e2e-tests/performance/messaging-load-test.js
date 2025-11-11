// Guardyn Messaging Service Load Test
// Target: 50 concurrent users, P95 latency < 200ms
//
// Run: k6 run --vus 50 --duration 5m messaging-load-test.js

import { check, sleep } from 'k6';
import encoding from 'k6/encoding';
import { Counter, Rate, Trend } from 'k6/metrics';
import grpc from 'k6/net/grpc';

// Custom metrics
const sendMessageLatency = new Trend('send_message_latency', true);
const getMessagesLatency = new Trend('get_messages_latency', true);
const sendMessageSuccess = new Rate('send_message_success');
const getMessagesSuccess = new Rate('get_messages_success');
const totalRequests = new Counter('total_requests');

// Test configuration
export const options = {
  vus: 50,              // 50 concurrent users
  duration: '5m',       // 5 minutes
  thresholds: {
    'send_message_latency': ['p(95)<200'],    // P95 < 200ms
    'get_messages_latency': ['p(95)<200'],    // P95 < 200ms
    'send_message_success': ['rate>0.95'],    // 95% success rate
    'get_messages_success': ['rate>0.95'],    // 95% success rate
  },
};

// gRPC clients
const authClient = new grpc.Client();
const messagingClient = new grpc.Client();

authClient.load(['../../../../backend/proto'], 'auth.proto');
messagingClient.load(['../../../../backend/proto'], 'messaging.proto');

export function setup() {
  // Port-forward services:
  // kubectl port-forward -n apps svc/auth-service 50051:50051
  // kubectl port-forward -n apps svc/messaging-service 50052:50052
  console.log('⚠️  Make sure services are port-forwarded:');
  console.log('   kubectl port-forward -n apps svc/auth-service 50051:50051');
  console.log('   kubectl port-forward -n apps svc/messaging-service 50052:50052');

  // Create 2 test users for messaging
  const authUrl = 'localhost:50051';
  authClient.connect(authUrl, { plaintext: true });

  const user1 = `sender_${Date.now()}`;
  const user2 = `receiver_${Date.now()}`;
  const password = 'LoadTest123!';

  const reg1 = authClient.invoke('guardyn.auth.AuthService/Register', {
    username: user1,
    password: password,
    device_name: 'k6-sender',
  });

  const reg2 = authClient.invoke('guardyn.auth.AuthService/Register', {
    username: user2,
    password: password,
    device_name: 'k6-receiver',
  });

  authClient.close();

  if (reg1.status !== grpc.StatusOK || !reg1.message.success ||
      reg2.status !== grpc.StatusOK || !reg2.message.success) {
    console.error('Failed to create test users in setup');
    console.error('User1:', JSON.stringify(reg1));
    console.error('User2:', JSON.stringify(reg2));
    throw new Error('Failed to create test users in setup');
  }

  return {
    authUrl: 'localhost:50051',
    messagingUrl: 'localhost:50052',
    user1: {
      userId: reg1.message.success.userId,
      deviceId: reg1.message.success.deviceId,
      token: reg1.message.success.accessToken,
    },
    user2: {
      userId: reg2.message.success.userId,
      deviceId: reg2.message.success.deviceId,
      token: reg2.message.success.accessToken,
    },
  };
}

export default function (data) {
  const messagingUrl = data.messagingUrl;
  const sender = data.user1;
  const receiver = data.user2;

  // Connect to messaging service
  messagingClient.connect(messagingUrl, {
    plaintext: true,
  });

  const messageContent = `Load test message ${__VU}_${__ITER} at ${Date.now()}`;

  // Encode message content to base64 (required for bytes field)
  const encodedContent = encoding.b64encode(messageContent);

  // Test 1: Send Message
  const sendStart = Date.now();
  const sendResponse = messagingClient.invoke('guardyn.messaging.MessagingService/SendMessage', {
    access_token: sender.token,
    recipient_user_id: receiver.userId,
    recipient_device_id: '',  // Empty = all devices
    encrypted_content: encodedContent,
    message_type: 0,  // TEXT
    client_message_id: `${__VU}-${__ITER}-${Date.now()}`,
    client_timestamp: {
      seconds: Math.floor(Date.now() / 1000),
      nanos: (Date.now() % 1000) * 1000000,
    },
    media_id: '',  // No media
  });
  const sendDuration = Date.now() - sendStart;

  sendMessageLatency.add(sendDuration);
  totalRequests.add(1);

  const sendOk = check(sendResponse, {
    'send message successful': (r) => r && r.status === grpc.StatusOK,
    'got message_id': (r) => r && r.message && r.message.message_id && r.message.message_id.length > 0,
    'got timestamp': (r) => r && r.message && r.message.timestamp !== undefined,
  });

  sendMessageSuccess.add(sendOk);

  if (!sendOk) {
    console.error(`Send message failed:`, JSON.stringify(sendResponse));
    messagingClient.close();
    sleep(1);
    return;
  }

  const messageId = sendResponse.message.message_id;

  // Wait a bit before fetching
  sleep(0.5);

  // Test 2: Get Messages
  const getStart = Date.now();
  const getResponse = messagingClient.invoke('guardyn.messaging.MessagingService/GetMessages', {
    access_token: receiver.token,
    conversation_user_id: sender.userId,
    limit: 10,
  });
  const getDuration = Date.now() - getStart;

  getMessagesLatency.add(getDuration);
  totalRequests.add(1);

  const getOk = check(getResponse, {
    'get messages successful': (r) => r && r.status === grpc.StatusOK,
    'got messages array': (r) => r && r.message && r.message.messages && Array.isArray(r.message.messages),
    'message exists': (r) => {
      if (!r || !r.message || !r.message.messages) return false;
      return r.message.messages.some(m => m.message_id === messageId);
    },
  });

  getMessagesSuccess.add(getOk);

  if (!getOk) {
    console.error(`Get messages failed:`, JSON.stringify(getResponse));
  }

  messagingClient.close();
  sleep(1); // Think time between iterations
}

export function teardown(data) {
  console.log('✅ Load test completed');
}
