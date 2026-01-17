# Security Hardening Guide

## Overview

This document describes security hardening measures implemented in Guardyn for protection against abuse, attacks, and unauthorized access. All security measures are designed to meet audit requirements and industry best practices.

## Rate Limiting

### Architecture

Guardyn implements multi-layer rate limiting using a sliding window algorithm with burst allowance:

```
┌─────────────────────────────────────────────────────────────┐
│                      Request Flow                            │
├─────────────────────────────────────────────────────────────┤
│  Client → [IP Extraction] → [Rate Limiter] → gRPC Service   │
│                                    │                         │
│                                    ▼                         │
│                         ┌──────────────────┐                │
│                         │  RateLimiters    │                │
│                         ├──────────────────┤                │
│                         │ • auth (strict)  │                │
│                         │ • messaging      │                │
│                         │ • media          │                │
│                         │ • search         │                │
│                         │ • general        │                │
│                         └──────────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

### Configuration Presets

| Endpoint Type          | Max Requests | Window | Burst | Per-IP | Per-User |
| ---------------------- | ------------ | ------ | ----- | ------ | -------- |
| Auth (login, register) | 5            | 60s    | 2     | ✅     | ❌       |
| Messaging              | 60           | 60s    | 10    | ✅     | ✅       |
| Media upload           | 20           | 60s    | 5     | ✅     | ✅       |
| Search                 | 30           | 60s    | 10    | ✅     | ✅       |
| General API            | 300          | 60s    | 50    | ✅     | ✅       |

### Implementation Details

**Sliding Window Algorithm:**

- Tracks timestamps of recent requests
- Automatically cleans expired entries
- O(1) check operations with periodic cleanup

**IP Extraction:**

- Supports `X-Forwarded-For` header (first IP)
- Supports `X-Real-IP` header
- Handles proxy chains correctly

**Blocking Mechanisms:**

- Temporary blocks (rate limit exceeded)
- Persistent IP blocks (abuse detection)
- Persistent user blocks (account suspension)

### Usage in Services

```rust
use guardyn_common::{RateLimitConfig, RateLimiter, RateLimitLayer};

// Create rate limiter for auth endpoints
let auth_limiter = RateLimiter::new(RateLimitConfig::strict());

// Create Tower layer for Tonic service
let layer = RateLimitLayer::new(auth_limiter);

// Apply to gRPC server
Server::builder()
    .layer(layer)
    .add_service(auth_service)
    .serve(addr)
    .await?;
```

## Abuse Prevention Rules

### Authentication Abuse

| Attack               | Detection                               | Mitigation              |
| -------------------- | --------------------------------------- | ----------------------- |
| Brute force login    | >5 failed attempts in 60s               | IP block for 15 minutes |
| Registration spam    | >3 registrations from same IP in 1 hour | CAPTCHA required        |
| Password reset abuse | >3 reset requests in 1 hour             | Temporary block         |

### Messaging Abuse

| Attack                | Detection                | Mitigation               |
| --------------------- | ------------------------ | ------------------------ |
| Message flooding      | >60 messages/minute      | Rate limit + warning     |
| Large attachment spam | >20 uploads/minute       | Upload limit             |
| Group message bomb    | >100 group messages/hour | Throttle + notify admins |

### API Abuse

| Attack           | Detection               | Mitigation                |
| ---------------- | ----------------------- | ------------------------- |
| API scraping     | >300 requests/minute    | Progressive rate limiting |
| Search abuse     | >30 searches/minute     | Throttle + CAPTCHA        |
| Connection storm | >100 connections/minute | Connection limit          |

## Response Headers

All API responses include rate limit information:

```
X-RateLimit-Remaining: 45
X-RateLimit-Limit: 60
X-RateLimit-Reset: 1640000000
Retry-After: 30  (only when limited)
```

## Error Responses

### Rate Limited (429)

```json
{
  "error": "rate_limit_exceeded",
  "message": "Rate limit exceeded: 60 requests per 60s",
  "retry_after_seconds": 30
}
```

### Blocked (403)

```json
{
  "error": "ip_blocked",
  "message": "Your IP address has been temporarily blocked",
  "contact": "abuse@yourdomain.com"
}
```

## Monitoring and Alerts

### Metrics

All rate limiting events are tracked in Prometheus:

```
# Rate limit checks
guardyn_rate_limit_checks_total{endpoint="auth",result="allowed"}
guardyn_rate_limit_checks_total{endpoint="auth",result="blocked"}

# Active blocks
guardyn_blocked_ips_total
guardyn_blocked_users_total

# Rate limit events
guardyn_rate_limit_exceeded_total{endpoint="messaging",reason="ip_limit"}
```

### Alerts

| Alert                  | Condition                | Severity |
| ---------------------- | ------------------------ | -------- |
| High Rate Limit Blocks | >100 blocks/minute       | Warning  |
| IP Blocking Surge      | >50 IPs blocked/hour     | Critical |
| Auth Attack Detected   | >1000 auth failures/hour | Critical |

## Security Audit Checklist

### Rate Limiting

- [ ] Rate limits are enforced on all public endpoints
- [ ] Rate limit headers are included in responses
- [ ] Sliding window prevents burst abuse
- [ ] IP extraction handles proxy chains correctly
- [ ] User ID extraction is secure and verified

### Blocking

- [ ] Blocked IPs receive 403 response
- [ ] Blocked users receive 403 response
- [ ] Block durations are configurable
- [ ] Blocks can be manually removed

### Monitoring

- [ ] All rate limit events are logged
- [ ] Metrics are exported to Prometheus
- [ ] Alerts are configured for abuse patterns
- [ ] Dashboard shows real-time rate limit status

## Configuration

### Environment Variables

```bash
# Rate limiting configuration
RATE_LIMIT_AUTH_MAX=5
RATE_LIMIT_AUTH_WINDOW_SECS=60
RATE_LIMIT_AUTH_BURST=2

RATE_LIMIT_MESSAGING_MAX=60
RATE_LIMIT_MESSAGING_WINDOW_SECS=60
RATE_LIMIT_MESSAGING_BURST=10

# Blocking configuration
BLOCK_DURATION_SECS=900  # 15 minutes default
AUTO_BLOCK_THRESHOLD=10  # Block after 10 limit hits
```

### Kubernetes ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: rate-limit-config
  namespace: apps
data:
  config.yaml: |
    rate_limits:
      auth:
        max_requests: 5
        window_secs: 60
        burst_size: 2
      messaging:
        max_requests: 60
        window_secs: 60
        burst_size: 10
    blocking:
      default_duration_secs: 900
      auto_block_threshold: 10
```

## Future Enhancements

### Planned Features

1. **Distributed Rate Limiting** - Redis-backed for multi-instance deployment
2. **Adaptive Rate Limiting** - Automatic adjustment based on server load
3. **IP Reputation** - Integration with IP reputation databases
4. **Machine Learning** - Anomaly detection for abuse patterns
5. **Geographic Rate Limiting** - Per-region limits

### Integration Points

- **WAF Integration** - Export blocked IPs to web application firewall
- **SIEM Integration** - Forward security events to SIEM
- **Incident Response** - Automatic escalation for critical events
