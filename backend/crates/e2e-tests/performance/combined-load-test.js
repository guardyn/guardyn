// Guardyn Combined Load Test (Auth + Messaging)
// Target: 50 concurrent users, P95 latency < 200ms, 5 min duration
//
// Run: k6 run --vus 50 --duration 5m combined-load-test.js

import { check, sleep } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';
import grpc from 'k6/net/grpc';

// Custom metrics
const registrationLatency = new Trend('registration_latency', true);
const loginLatency = new Trend('login_latency', true);
const sendMessageLatency = new Trend('send_message_latency', true);
const getMessagesLatency = new Trend('get_messages_latency', true);

const registrationSuccess = new Rate('registration_success');
const loginSuccess = new Rate('login_success');
const sendMessageSuccess = new Rate('send_message_success');
const getMessagesSuccess = new Rate('get_messages_success');

const totalRequests = new Counter('total_requests');
const totalErrors = new Counter('total_errors');

// Test configuration
export const options = {
  vus: 50,              // 50 concurrent users
  duration: '5m',       // 5 minutes
  thresholds: {
    'registration_latency': ['p(95)<200'],    // P95 < 200ms
    'login_latency': ['p(95)<200'],           // P95 < 200ms
    'send_message_latency': ['p(95)<200'],    // P95 < 200ms
    'get_messages_latency': ['p(95)<200'],    // P95 < 200ms
    'registration_success': ['rate>0.95'],    // 95% success rate
    'login_success': ['rate>0.95'],           // 95% success rate
    'send_message_success': ['rate>0.95'],    // 95% success rate
    'get_messages_success': ['rate>0.95'],    // 95% success rate
    'total_errors': ['count<50'],             // Less than 50 errors total
  },
  summaryTrendStats: ['avg', 'min', 'med', 'max', 'p(90)', 'p(95)', 'p(99)'],
};

// gRPC clients
const authClient = new grpc.Client();
const messagingClient = new grpc.Client();

authClient.load(['../../proto'], 'auth.proto');
messagingClient.load(['../../proto'], 'messaging.proto');

export function setup() {
  console.log('🚀 Guardyn Combined Load Test');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('⚠️  Prerequisites: Port-forward services:');
  console.log('   kubectl port-forward -n apps svc/auth-service 50051:50051 &');
  console.log('   kubectl port-forward -n apps svc/messaging-service 50052:50052 &');
  console.log('');
  console.log('📊 Test Configuration:');
  console.log('   VUs: 50 concurrent users');
  console.log('   Duration: 5 minutes');
  console.log('   Target P95 latency: < 200ms');
  console.log('   Target success rate: > 95%');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  // Create a shared receiver user for all VUs to send messages to
  const authUrl = 'localhost:50051';
  authClient.connect(authUrl, { plaintext: true });

  const sharedReceiver = `loadtest_receiver_${Date.now()}`;
  const password = 'LoadTest123!';

  const regReceiver = authClient.invoke('guardyn.auth.AuthService/Register', {
    username: sharedReceiver,
    password: password,
    device_name: 'k6-receiver',
  });

  authClient.close();

  if (regReceiver.status !== grpc.StatusOK) {
    throw new Error('Failed to create shared receiver in setup');
  }

  console.log(`✅ Shared receiver created: ${regReceiver.message.user_id}`);
  
  return {
    authUrl: 'localhost:50051',
    messagingUrl: 'localhost:50052',
    receiverUserId: regReceiver.message.user_id,
  };
}

export default function (data) {
  const authUrl = data.authUrl;
  const messagingUrl = data.messagingUrl;
  const receiverUserId = data.receiverUserId;
  
  // Unique user for this VU and iteration
  const username = `loadtest_${__VU}_${__ITER}_${Date.now()}`;
  const password = 'LoadTest123!';
  const deviceName = `k6-device-${__VU}`;

  // ============================
  // AUTH FLOW
  // ============================
  
  authClient.connect(authUrl, { plaintext: true });

  // Step 1: Register
  const regStart = Date.now();
  const regResponse = authClient.invoke('guardyn.auth.AuthService/Register', {
    username: username,
    password: password,
    device_name: deviceName,
  });
  const regDuration = Date.now() - regStart;
  
  registrationLatency.add(regDuration);
  totalRequests.add(1);
  
  const regOk = check(regResponse, {
    'registration successful': (r) => r && r.status === grpc.StatusOK,
    'got user_id': (r) => r && r.message && r.message.user_id && r.message.user_id.length > 0,
    'got access_token': (r) => r && r.message && r.message.access_token && r.message.access_token.length > 0,
  });
  
  registrationSuccess.add(regOk);

  if (!regOk) {
    console.error(`❌ Registration failed for ${username}`);
    totalErrors.add(1);
    authClient.close();
    sleep(1);
    return;
  }

  const userId = regResponse.message.user_id;
  const accessToken = regResponse.message.access_token;

  sleep(0.2); // Brief pause

  // Step 2: Login
  const loginStart = Date.now();
  const loginResponse = authClient.invoke('guardyn.auth.AuthService/Login', {
    username: username,
    password: password,
    device_name: deviceName,
  });
  const loginDuration = Date.now() - loginStart;
  
  loginLatency.add(loginDuration);
  totalRequests.add(1);
  
  const loginOk = check(loginResponse, {
    'login successful': (r) => r && r.status === grpc.StatusOK,
    'user_id matches': (r) => r && r.message && r.message.user_id === userId,
  });
  
  loginSuccess.add(loginOk);

  if (!loginOk) {
    console.error(`❌ Login failed for ${username}`);
    totalErrors.add(1);
  }

  authClient.close();
  sleep(0.3);

  // ============================
  // MESSAGING FLOW
  // ============================
  
  messagingClient.connect(messagingUrl, { plaintext: true });

  const messageContent = `Load test message from VU ${__VU} iteration ${__ITER}`;

  // Step 3: Send Message
  const sendStart = Date.now();
  const sendResponse = messagingClient.invoke('guardyn.messaging.MessagingService/SendMessage', {
    recipient_user_id: receiverUserId,
    encrypted_content: messageContent,
    content_type: 'text/plain',
  }, {
    metadata: {
      'authorization': `Bearer ${accessToken}`,
    },
  });
  const sendDuration = Date.now() - sendStart;
  
  sendMessageLatency.add(sendDuration);
  totalRequests.add(1);
  
  const sendOk = check(sendResponse, {
    'send message successful': (r) => r && r.status === grpc.StatusOK,
    'got message_id': (r) => r && r.message && r.message.message_id && r.message.message_id.length > 0,
  });
  
  sendMessageSuccess.add(sendOk);

  if (!sendOk) {
    console.error(`❌ Send message failed for ${username}`);
    totalErrors.add(1);
  }

  sleep(0.3);

  // Step 4: Get Messages (check own messages)
  const getStart = Date.now();
  const getResponse = messagingClient.invoke('guardyn.messaging.MessagingService/GetMessages', {
    other_user_id: receiverUserId,
    limit: 10,
  }, {
    metadata: {
      'authorization': `Bearer ${accessToken}`,
    },
  });
  const getDuration = Date.now() - getStart;
  
  getMessagesLatency.add(getDuration);
  totalRequests.add(1);
  
  const getOk = check(getResponse, {
    'get messages successful': (r) => r && r.status === grpc.StatusOK,
    'got messages array': (r) => r && r.message && r.message.messages && Array.isArray(r.message.messages),
  });
  
  getMessagesSuccess.add(getOk);

  if (!getOk) {
    console.error(`❌ Get messages failed for ${username}`);
    totalErrors.add(1);
  }

  messagingClient.close();
  sleep(1); // Think time between iterations
}

export function teardown(data) {
  console.log('');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('✅ Load test completed');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}

export function handleSummary(data) {
  return {
    'stdout': textSummary(data, { indent: ' ', enableColors: true }),
    'performance-results.json': JSON.stringify(data),
  };
}

function textSummary(data, options) {
  // Custom summary formatting (basic implementation)
  return `
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 GUARDYN PERFORMANCE TEST SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Metrics:
  Registration: ${data.metrics.registration_latency ? data.metrics.registration_latency.values['p(95)'].toFixed(2) + 'ms (P95)' : 'N/A'}
  Login:        ${data.metrics.login_latency ? data.metrics.login_latency.values['p(95)'].toFixed(2) + 'ms (P95)' : 'N/A'}
  Send Message: ${data.metrics.send_message_latency ? data.metrics.send_message_latency.values['p(95)'].toFixed(2) + 'ms (P95)' : 'N/A'}
  Get Messages: ${data.metrics.get_messages_latency ? data.metrics.get_messages_latency.values['p(95)'].toFixed(2) + 'ms (P95)' : 'N/A'}

✅ Success Rates:
  Registration: ${data.metrics.registration_success ? (data.metrics.registration_success.values.rate * 100).toFixed(2) + '%' : 'N/A'}
  Login:        ${data.metrics.login_success ? (data.metrics.login_success.values.rate * 100).toFixed(2) + '%' : 'N/A'}
  Send Message: ${data.metrics.send_message_success ? (data.metrics.send_message_success.values.rate * 100).toFixed(2) + '%' : 'N/A'}
  Get Messages: ${data.metrics.get_messages_success ? (data.metrics.get_messages_success.values.rate * 100).toFixed(2) + '%' : 'N/A'}

📈 Total Requests: ${data.metrics.total_requests ? data.metrics.total_requests.values.count : 'N/A'}
❌ Total Errors:   ${data.metrics.total_errors ? data.metrics.total_errors.values.count : '0'}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
`;
}
