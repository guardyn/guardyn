// Guardyn gRPC Load Test via grpcurl
// This script uses shell commands as k6's native gRPC has proto loading issues
//
// Alternative: Run this with hey/ghz for gRPC testing:
// ghz --insecure --proto backend/proto/auth.proto \
//     --call guardyn.auth.AuthService/Register \
//     -d '{"username":"loadtest_{{.RequestNumber}}","password":"Test123!","device_name":"ghz"}' \
//     -c 50 -z 5m localhost:50051
//
// For k6, use HTTP tests against Envoy gateway:

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';

// Custom metrics
const registrationLatency = new Trend('registration_latency', true);
const sendMessageLatency = new Trend('send_message_latency', true);
const registrationSuccess = new Rate('registration_success');
const sendMessageSuccess = new Rate('send_message_success');
const totalRequests = new Counter('total_requests');
const totalErrors = new Counter('total_errors');

// Test configuration
export const options = {
  scenarios: {
    smoke: {
      executor: 'constant-vus',
      vus: 10,
      duration: '1m',
      gracefulStop: '10s',
    },
    load: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '30s', target: 20 },  // Ramp up
        { duration: '2m', target: 50 },   // Stay at 50
        { duration: '30s', target: 0 },   // Ramp down
      ],
      gracefulRampDown: '10s',
      startTime: '1m',  // Start after smoke test
    },
  },
  thresholds: {
    'registration_latency': ['p(95)<500'],    // P95 < 500ms
    'send_message_latency': ['p(95)<300'],    // P95 < 300ms
    'registration_success': ['rate>0.90'],    // 90% success rate
    'send_message_success': ['rate>0.90'],    // 90% success rate
    'total_errors': ['count<100'],            // Less than 100 errors
    'http_req_duration': ['p(95)<1000'],      // Overall P95 < 1s
  },
  summaryTrendStats: ['avg', 'min', 'med', 'max', 'p(90)', 'p(95)', 'p(99)'],
};

const BASE_URL = __ENV.ENVOY_URL || 'http://localhost:8080';

export function setup() {
  console.log('🚀 Guardyn Load Test Starting');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`📍 Target: ${BASE_URL}`);
  console.log('');
  console.log('📊 Test Scenarios:');
  console.log('   1. Smoke Test: 10 VUs for 1 minute');
  console.log('   2. Load Test: Ramp up to 50 VUs over 3 minutes');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  // Pre-create a shared receiver for message tests
  const sharedReceiver = {
    username: `loadtest_receiver_${Date.now()}`,
    password: 'LoadTest123!',
  };

  // Try to register shared receiver (may fail if already exists, that's ok)
  const regPayload = JSON.stringify({
    username: sharedReceiver.username,
    password: sharedReceiver.password,
    device_name: 'k6-receiver',
    device_type: 'test',
  });

  try {
    const res = http.post(`${BASE_URL}/guardyn.auth.AuthService/Register`, regPayload, {
      headers: { 'Content-Type': 'application/json' },
      timeout: '30s',
    });
    if (res.status === 200 && res.json('success')) {
      sharedReceiver.userId = res.json('success.userId');
      sharedReceiver.token = res.json('success.accessToken');
      console.log(`✅ Shared receiver created: ${sharedReceiver.userId}`);
    }
  } catch (e) {
    console.log('⚠️ Could not create shared receiver (may already exist)');
  }

  return { baseUrl: BASE_URL, receiver: sharedReceiver };
}

export default function (data) {
  const baseUrl = data.baseUrl;
  const vu = __VU;
  const iter = __ITER;
  const timestamp = Date.now();

  // Generate unique credentials for this VU/iteration
  const username = `loadtest_${vu}_${iter}_${timestamp}`;
  const password = 'LoadTest123!';

  // ============================================
  // TEST 1: User Registration
  // ============================================
  const regPayload = JSON.stringify({
    username: username,
    password: password,
    device_name: `k6-device-${vu}`,
    device_type: 'test',
    email: `${username}@test.local`,
    key_bundle: {
      identity_key: Array(32).fill(0),
      signed_pre_key: Array(32).fill(0),
      signed_pre_key_signature: Array(64).fill(0),
      one_time_pre_keys: [Array(32).fill(0)],
    },
  });

  const regStart = Date.now();
  let regRes;
  
  try {
    regRes = http.post(`${baseUrl}/guardyn.auth.AuthService/Register`, regPayload, {
      headers: { 'Content-Type': 'application/json' },
      timeout: '10s',
    });
  } catch (e) {
    totalErrors.add(1);
    registrationSuccess.add(false);
    console.error(`Registration request failed: ${e}`);
    sleep(1);
    return;
  }

  const regDuration = Date.now() - regStart;
  registrationLatency.add(regDuration);
  totalRequests.add(1);

  let userId = null;
  let token = null;

  const regOk = check(regRes, {
    'registration returns 200': (r) => r.status === 200,
    'registration has success': (r) => {
      try {
        const json = r.json();
        if (json && json.success) {
          userId = json.success.userId;
          token = json.success.accessToken;
          return true;
        }
        return false;
      } catch (e) {
        return false;
      }
    },
  });

  registrationSuccess.add(regOk);

  if (!regOk) {
    totalErrors.add(1);
    sleep(0.5);
    return;
  }

  // ============================================
  // TEST 2: Send Message (if we have a receiver)
  // ============================================
  if (token && data.receiver && data.receiver.userId) {
    const msgPayload = JSON.stringify({
      access_token: token,
      recipient_user_id: data.receiver.userId,
      recipient_device_id: '',
      encrypted_content: Buffer.from(`Test message from ${username}`).toString('base64'),
      client_message_id: `${vu}_${iter}_${timestamp}`,
      message_type: 0,  // TEXT
      recipient_username: data.receiver.username,
    });

    const msgStart = Date.now();
    let msgRes;

    try {
      msgRes = http.post(`${baseUrl}/guardyn.messaging.MessagingService/SendMessage`, msgPayload, {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        timeout: '10s',
      });
    } catch (e) {
      totalErrors.add(1);
      sendMessageSuccess.add(false);
    }

    if (msgRes) {
      const msgDuration = Date.now() - msgStart;
      sendMessageLatency.add(msgDuration);
      totalRequests.add(1);

      const msgOk = check(msgRes, {
        'send message returns 200': (r) => r.status === 200,
        'send message has success': (r) => {
          try {
            const json = r.json();
            return json && (json.success || json.messageId);
          } catch (e) {
            return false;
          }
        },
      });

      sendMessageSuccess.add(msgOk);
      if (!msgOk) {
        totalErrors.add(1);
      }
    }
  }

  // Small delay between iterations
  sleep(0.2);
}

export function teardown(data) {
  console.log('');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('🏁 Load Test Complete');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
