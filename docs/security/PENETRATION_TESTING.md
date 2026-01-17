# Penetration Testing Guide

This guide provides comprehensive penetration testing procedures for Guardyn security assessment.

## Prerequisites

### Required Tools

```bash
# Install via Nix (recommended)
nix develop

# Or install manually:
# - OWASP ZAP: https://www.zaproxy.org/
# - Nuclei: https://nuclei.projectdiscovery.io/
# - Trivy: https://trivy.dev/
# - cargo-audit: cargo install cargo-audit
# - cargo-deny: cargo install cargo-deny
# - grpcurl: https://github.com/fullstorydev/grpcurl
```

### Environment Setup

```bash
# Start local development cluster
just kube-create
just kube-bootstrap

# Deploy all services
just k8s-deploy all

# Port forward services for testing
kubectl port-forward -n apps svc/auth-service 50051:50051 &
kubectl port-forward -n apps svc/messaging-service 50052:50052 &
kubectl port-forward -n apps svc/media-service 50053:50053 &
```

## Automated Security Scans

### 1. Dependency Vulnerability Scanning

#### Rust Dependencies

```bash
# Run cargo-audit for known vulnerabilities
cd backend
cargo audit

# Run cargo-deny for license and security policy
cargo deny check

# Generate SBOM (Software Bill of Materials)
cargo sbom --output-format spdx-json > sbom.json
```

#### Flutter Dependencies

```bash
cd client
flutter pub audit

# Check for outdated packages
flutter pub outdated
```

### 2. Container Image Scanning

```bash
# Scan all service images with Trivy
trivy image guardyn-registry:5000/auth-service:latest
trivy image guardyn-registry:5000/messaging-service:latest
trivy image guardyn-registry:5000/media-service:latest

# Generate reports
trivy image --format sarif \
  guardyn-registry:5000/auth-service:latest > trivy-auth.sarif
```

### 3. Infrastructure Scanning

```bash
# Kubernetes security scanning
trivy k8s --report summary cluster

# Scan Kubernetes manifests
trivy config infra/k8s/

# Check for misconfigurations
kubesec scan infra/k8s/base/*/deployment.yaml
```

### 4. gRPC API Testing

```bash
# List all gRPC services
grpcurl -plaintext localhost:50051 list

# Test authentication endpoints
grpcurl -plaintext -d '{"username":"test","password":"weak"}' \
  localhost:50051 guardyn.auth.AuthService/Register

# Fuzz authentication
grpcurl -plaintext -d '{"username":"' + "A"*10000 + '","password":"x"}' \
  localhost:50051 guardyn.auth.AuthService/Register
```

## Manual Penetration Tests

### Authentication Tests

| Test ID | Description            | Steps                            | Expected Result               |
| ------- | ---------------------- | -------------------------------- | ----------------------------- |
| AUTH-01 | Brute force protection | Send 100 login attempts          | Rate limited after 5 failures |
| AUTH-02 | Password policy        | Try weak passwords               | Rejected                      |
| AUTH-03 | Session hijacking      | Copy session token to new device | Rejected (device binding)     |
| AUTH-04 | Token expiration       | Use expired token                | 401 Unauthorized              |
| AUTH-05 | Credential stuffing    | Use leaked credentials           | Rate limited, account locked  |

### Cryptography Tests

| Test ID   | Description      | Steps                                         | Expected Result               |
| --------- | ---------------- | --------------------------------------------- | ----------------------------- |
| CRYPTO-01 | Key randomness   | Generate 1000 keys, check entropy             | High entropy (>7.9 bits/byte) |
| CRYPTO-02 | Nonce reuse      | Force nonce reuse in encryption               | Implementation prevents reuse |
| CRYPTO-03 | Timing attacks   | Measure response times for valid/invalid MACs | Constant time                 |
| CRYPTO-04 | Downgrade attack | Request weaker cipher                         | Rejected                      |
| CRYPTO-05 | Key leakage      | Memory dump after session                     | Keys zeroized                 |

### Messaging Tests

| Test ID | Description           | Steps                      | Expected Result             |
| ------- | --------------------- | -------------------------- | --------------------------- |
| MSG-01  | Message injection     | Send malformed protobuf    | Proper error handling       |
| MSG-02  | Replay attack         | Resend captured message    | Rejected (message ID check) |
| MSG-03  | Unauthorized access   | Read other user's messages | 403 Forbidden               |
| MSG-04  | Metadata leakage      | Analyze sealed sender      | Sender identity hidden      |
| MSG-05  | DoS via large message | Send 100MB message         | Rate limited, rejected      |

### Infrastructure Tests

| Test ID  | Description         | Steps                        | Expected Result            |
| -------- | ------------------- | ---------------------------- | -------------------------- |
| INFRA-01 | Pod escape          | Attempt container breakout   | Blocked by securityContext |
| INFRA-02 | Network policy      | Pod-to-pod communication     | Only allowed paths         |
| INFRA-03 | Secret exposure     | List secrets without auth    | Denied                     |
| INFRA-04 | Resource exhaustion | Consume all CPU/memory       | Resource limits enforced   |
| INFRA-05 | Log injection       | Send logs with special chars | Properly escaped           |

## Security Test Scripts

### Rate Limiting Test

```bash
#!/bin/bash
# Test rate limiting on auth service

ENDPOINT="localhost:50051"
SUCCESS=0
BLOCKED=0

for i in {1..100}; do
  RESULT=$(grpcurl -plaintext -d '{"username":"test","password":"wrong"}' \
    $ENDPOINT guardyn.auth.AuthService/Login 2>&1)

  if echo "$RESULT" | grep -q "rate limit"; then
    ((BLOCKED++))
  else
    ((SUCCESS++))
  fi
done

echo "Successful attempts: $SUCCESS"
echo "Rate limited: $BLOCKED"

if [ $BLOCKED -gt 90 ]; then
  echo "✅ Rate limiting working correctly"
else
  echo "❌ Rate limiting may not be effective"
  exit 1
fi
```

### Sealed Sender Verification

```bash
#!/bin/bash
# Verify server cannot see sender identity

# Capture network traffic during message send
tcpdump -i lo port 50052 -w capture.pcap &
TCPDUMP_PID=$!

# Send test message (using test client)
./test-sealed-sender.sh

# Stop capture
kill $TCPDUMP_PID

# Analyze for sender identity leakage
if tshark -r capture.pcap -Y 'grpc' | grep -q "sender_user_id"; then
  echo "❌ Sender identity visible in traffic!"
  exit 1
else
  echo "✅ Sender identity properly sealed"
fi
```

### Memory Key Zeroization Test

```rust
// backend/crates/e2e-tests/tests/security/key_zeroization.rs

#[test]
fn test_key_zeroization() {
    use guardyn_crypto::x3dh::X3DHKeyBundle;
    use std::ptr;

    // Generate key bundle
    let (bundle, private_keys) = X3DHKeyBundle::generate().unwrap();

    // Get pointer to private key memory
    let key_ptr = private_keys.identity_key.as_ptr() as usize;

    // Drop the private keys (should zeroize)
    drop(private_keys);

    // Read memory at old location (unsafe, for testing only)
    let memory: [u8; 32] = unsafe {
        ptr::read(key_ptr as *const [u8; 32])
    };

    // Verify memory is zeroed
    assert!(memory.iter().all(|&b| b == 0),
        "Private key not zeroized after drop!");
}
```

## Vulnerability Disclosure

### Reporting

Found a vulnerability? Report it responsibly:

1. **Email**: security@guardyn.io (PGP key in SECURITY.md)
2. **DO NOT** create public GitHub issues for security vulnerabilities
3. Allow 90 days for fix before public disclosure

### Response Timeline

| Severity | Initial Response | Fix Target |
| -------- | ---------------- | ---------- |
| Critical | 4 hours          | 24 hours   |
| High     | 24 hours         | 7 days     |
| Medium   | 3 days           | 30 days    |
| Low      | 7 days           | 90 days    |

## Compliance Checklist

### OWASP Mobile Top 10

- [ ] M1: Improper Platform Usage
- [ ] M2: Insecure Data Storage
- [ ] M3: Insecure Communication
- [ ] M4: Insecure Authentication
- [ ] M5: Insufficient Cryptography
- [ ] M6: Insecure Authorization
- [ ] M7: Client Code Quality
- [ ] M8: Code Tampering
- [ ] M9: Reverse Engineering
- [ ] M10: Extraneous Functionality

### CWE Coverage

Key CWEs addressed:

- CWE-256: Plaintext Storage of Password ❌ Not applicable (passwords hashed)
- CWE-311: Missing Encryption ✅ All data encrypted
- CWE-327: Broken Crypto ✅ Modern algorithms only
- CWE-352: CSRF ❌ N/A (no web frontend with sessions)
- CWE-798: Hardcoded Credentials ✅ No hardcoded secrets
- CWE-918: SSRF ✅ Input validation on URLs

## Continuous Security

### CI/CD Integration

```yaml
# .github/workflows/security.yml
name: Security Scans

on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: "0 0 * * *" # Daily

jobs:
  rust-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: rustsec/audit-check@v1.4.1
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

  container-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: aquasecurity/trivy-action@master
        with:
          image-ref: "guardyn-registry:5000/auth-service:latest"
          format: "sarif"
          output: "trivy-results.sarif"

  k8s-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: aquasecurity/trivy-action@master
        with:
          scan-type: "config"
          scan-ref: "infra/k8s/"
```

## Post-Audit Actions

1. **Triage findings** by severity
2. **Create issues** for each finding
3. **Implement fixes** with tests
4. **Verify fixes** with targeted re-tests
5. **Update documentation** with lessons learned
6. **Schedule re-audit** in 6 months
