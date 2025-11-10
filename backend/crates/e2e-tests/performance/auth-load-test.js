// Guardyn Auth Service Load Test
// Target: 50 concurrent users, P95 latency < 200ms
//
// Run: k6 run --vus 50 --duration 5m auth-load-test.js

import { check, sleep } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';
import grpc from 'k6/net/grpc';

// Custom metrics
const registrationLatency = new Trend('registration_latency', true);
const loginLatency = new Trend('login_latency', true);
const registrationSuccess = new Rate('registration_success');
const loginSuccess = new Rate('login_success');
const totalRequests = new Counter('total_requests');

// Test configuration
export const options = {
  vus: 50,              // 50 concurrent users
  duration: '5m',       // 5 minutes
  thresholds: {
    'registration_latency': ['p(95)<200'],  // P95 < 200ms
    'login_latency': ['p(95)<200'],         // P95 < 200ms
    'registration_success': ['rate>0.95'],  // 95% success rate
    'login_success': ['rate>0.95'],         // 95% success rate
  },
};

// gRPC client setup
const client = new grpc.Client();
client.load(['../../proto'], 'auth.proto');

export function setup() {
  // Port-forward auth service: kubectl port-forward -n apps svc/auth-service 50051:50051
  console.log('⚠️  Make sure auth service is port-forwarded: kubectl port-forward -n apps svc/auth-service 50051:50051');
  return { authUrl: 'localhost:50051' };
}

export default function (data) {
  const authUrl = data.authUrl;
  
  // Connect to auth service
  client.connect(authUrl, {
    plaintext: true,
  });

  const username = `loadtest_${__VU}_${__ITER}_${Date.now()}`;
  const password = 'LoadTest123!';
  const deviceName = `k6-device-${__VU}`;

  // Test 1: User Registration
  const regStart = Date.now();
  const regResponse = client.invoke('guardyn.auth.AuthService/Register', {
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
    'got device_id': (r) => r && r.message && r.message.device_id && r.message.device_id.length > 0,
    'got access_token': (r) => r && r.message && r.message.access_token && r.message.access_token.length > 0,
  });
  
  registrationSuccess.add(regOk);

  if (!regOk) {
    console.error(`Registration failed for ${username}:`, JSON.stringify(regResponse));
    client.close();
    sleep(1);
    return;
  }

  const userId = regResponse.message.user_id;
  const deviceId = regResponse.message.device_id;

  // Wait a bit before login
  sleep(0.5);

  // Test 2: User Login
  const loginStart = Date.now();
  const loginResponse = client.invoke('guardyn.auth.AuthService/Login', {
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
    'device_id matches': (r) => r && r.message && r.message.device_id === deviceId,
    'got access_token': (r) => r && r.message && r.message.access_token && r.message.access_token.length > 0,
    'got refresh_token': (r) => r && r.message && r.message.refresh_token && r.message.refresh_token.length > 0,
  });
  
  loginSuccess.add(loginOk);

  if (!loginOk) {
    console.error(`Login failed for ${username}:`, JSON.stringify(loginResponse));
  }

  client.close();
  sleep(1); // Think time between iterations
}

export function teardown(data) {
  console.log('✅ Load test completed');
}
