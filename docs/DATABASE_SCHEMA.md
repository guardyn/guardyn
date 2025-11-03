# Database Schema Design

## Overview

Guardyn uses a dual-database architecture for optimal performance:

- **TiKV**: ACID-compliant distributed key-value storage for critical data (users, sessions, device keys)
- **ScyllaDB**: High-throughput storage for messages, media metadata, and analytics

## TiKV Schema

### Design Principles

- Strong consistency for authentication and key management
- ACID transactions for user operations
- Low-latency reads for session validation

### Keyspace Structure

#### Users Subspace

```
/users/<user_id>/profile -> UserProfile {
  user_id: String,
  username: String,
  display_name: String,
  created_at: Timestamp,
  updated_at: Timestamp,
}

/users/<user_id>/identity_key -> IdentityKey {
  public_key: Bytes,
  created_at: Timestamp,
}

/users/username/<username> -> user_id
```

#### Devices Subspace

```
/devices/<user_id>/<device_id> -> Device {
  device_id: String,
  device_name: String,
  platform: String (ios|android|web|desktop),
  registration_id: u32,
  created_at: Timestamp,
  last_seen: Timestamp,
}

/devices/<user_id>/<device_id>/pre_keys/<key_id> -> PreKey {
  key_id: u32,
  public_key: Bytes,
  signature: Bytes,
}

/devices/<user_id>/<device_id>/one_time_keys/<key_id> -> OneTimeKey {
  key_id: u32,
  public_key: Bytes,
}
```

#### Sessions Subspace

```
/sessions/<session_token> -> Session {
  user_id: String,
  device_id: String,
  created_at: Timestamp,
  expires_at: Timestamp,
  refresh_token: String,
}

/sessions/user/<user_id>/<session_token> -> SessionReference
```

#### Message Delivery State

```
/delivery/<recipient_user_id>/<message_id> -> DeliveryState {
  message_id: String,
  sender_user_id: String,
  sent_at: Timestamp,
  delivered_at: Option<Timestamp>,
  read_at: Option<Timestamp>,
  status: String (pending|delivered|read|failed),
}
```

### Indexes

- `username` → `user_id` (unique)
- `user_id` → devices (one-to-many)
- `session_token` → session (unique, with TTL)

## ScyllaDB Schema

### Design Principles

- High write throughput for messages
- Time-series data optimization
- Efficient pagination for message history

### Keyspaces

```cql
CREATE KEYSPACE guardyn
  WITH replication = {
    'class': 'NetworkTopologyStrategy',
    'datacenter1': 3
  }
  AND durable_writes = true;
```

### Tables

#### Messages Table

```cql
CREATE TABLE guardyn.messages (
  conversation_id UUID,
  message_id TIMEUUID,
  sender_user_id TEXT,
  sender_device_id TEXT,
  recipient_user_id TEXT,
  encrypted_content BLOB,
  content_type TEXT,
  sent_at TIMESTAMP,
  metadata MAP<TEXT, TEXT>,
  PRIMARY KEY (conversation_id, message_id)
) WITH CLUSTERING ORDER BY (message_id DESC)
  AND default_time_to_live = 0
  AND gc_grace_seconds = 864000;

-- Index for sender queries
CREATE INDEX ON guardyn.messages (sender_user_id);
```

#### Group Messages Table

```cql
CREATE TABLE guardyn.group_messages (
  group_id UUID,
  message_id TIMEUUID,
  sender_user_id TEXT,
  sender_device_id TEXT,
  encrypted_content BLOB,
  mls_epoch BIGINT,
  sent_at TIMESTAMP,
  metadata MAP<TEXT, TEXT>,
  PRIMARY KEY (group_id, message_id)
) WITH CLUSTERING ORDER BY (message_id DESC);
```

#### Media Metadata Table

```cql
CREATE TABLE guardyn.media_metadata (
  media_id UUID PRIMARY KEY,
  uploader_user_id TEXT,
  conversation_id UUID,
  message_id TIMEUUID,
  file_name TEXT,
  mime_type TEXT,
  file_size BIGINT,
  encryption_key BLOB,
  encryption_iv BLOB,
  storage_path TEXT,
  thumbnail_path TEXT,
  uploaded_at TIMESTAMP,
  expires_at TIMESTAMP
);

-- Index for conversation media queries
CREATE INDEX ON guardyn.media_metadata (conversation_id);
```

#### Presence Table

```cql
CREATE TABLE guardyn.presence (
  user_id TEXT PRIMARY KEY,
  status TEXT,
  last_seen TIMESTAMP,
  device_id TEXT,
  updated_at TIMESTAMP
) WITH default_time_to_live = 86400;
```

#### Call History Table

```cql
CREATE TABLE guardyn.call_history (
  user_id TEXT,
  call_id TIMEUUID,
  call_type TEXT,
  participants SET<TEXT>,
  started_at TIMESTAMP,
  ended_at TIMESTAMP,
  duration INT,
  PRIMARY KEY (user_id, call_id)
) WITH CLUSTERING ORDER BY (call_id DESC);
```

#### Group Metadata Table

```cql
CREATE TABLE guardyn.groups (
  group_id UUID PRIMARY KEY,
  group_name TEXT,
  creator_user_id TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  member_count INT,
  mls_group_state BLOB,
  metadata MAP<TEXT, TEXT>
);
```

#### Group Members Table

```cql
CREATE TABLE guardyn.group_members (
  group_id UUID,
  user_id TEXT,
  role TEXT,
  joined_at TIMESTAMP,
  PRIMARY KEY (group_id, user_id)
);

-- Reverse index for user's groups
CREATE MATERIALIZED VIEW guardyn.user_groups AS
  SELECT group_id, user_id, role, joined_at
  FROM guardyn.group_members
  WHERE group_id IS NOT NULL AND user_id IS NOT NULL
  PRIMARY KEY (user_id, group_id);
```

## Data Migration Strategy

### Phase 1: Schema Creation

1. Deploy TiKV key-value schema (via application code)
2. Execute ScyllaDB CQL scripts via `cqlsh`
3. Verify schema integrity

### Phase 2: Initial Data

1. Create system users (admin, health-check bot)
2. Initialize default groups
3. Seed test data for development

### Phase 3: Migration Scripts

```bash
# TiKV schema initialization (via application bootstrap)
infra/scripts/verify-tikv.sh

# ScyllaDB schema creation
infra/scripts/scylla-init.cql
```

## Performance Considerations

### TiKV

- **Read latency**: < 5ms (p99)
- **Write latency**: < 10ms (p99)
- **Transactions**: ACID with snapshot isolation
- **Scaling**: Add TiKV nodes for capacity, PD for cluster management

### ScyllaDB

- **Write throughput**: > 100,000 ops/sec per node
- **Read latency**: < 5ms (p95)
- **Compaction**: Size-tiered for time-series data
- **TTL**: Automatic expiration for presence data

## Backup & Recovery

### TiKV

- Continuous backup to S3-compatible storage via BR (Backup & Restore)
- Point-in-time recovery (PITR)
- Backup retention: 30 days

### ScyllaDB

- Incremental snapshots every 6 hours
- Full snapshots daily
- Retention: 7 days (incremental), 30 days (full)

## Security

### Encryption at Rest

- TiKV: Transparent encryption at storage layer
- ScyllaDB: Encryption with ScyllaDB Enterprise or LUKS

### Access Control

- Service accounts with minimal privileges
- TLS/mTLS for all database connections
- Audit logging for schema changes

## Monitoring

### Key Metrics

- **TiKV**: Transaction rate, commit latency, region count, store capacity
- **ScyllaDB**: Write/read ops, compaction stats, disk usage
- **Alerts**: High latency, failed transactions, disk capacity

## Future Enhancements

- [ ] TiKV: Implement tenant isolation via key prefixes
- [ ] ScyllaDB: Add secondary indexes for analytics
- [ ] Time-series aggregation for usage statistics
- [ ] Cross-datacenter replication setup
- [ ] Automated schema migration framework
