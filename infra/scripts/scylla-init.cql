-- ScyllaDB schema initialization script
-- Run with: cqlsh -f scylla-init.cql

-- Create keyspace with replication factor 3
CREATE KEYSPACE IF NOT EXISTS guardyn
  WITH replication = {
    'class': 'NetworkTopologyStrategy',
    'datacenter1': 3
  }
  AND durable_writes = true;

-- Use the keyspace
USE guardyn;

-- Messages table for 1-on-1 conversations
CREATE TABLE IF NOT EXISTS messages (
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
  AND comment = '1-on-1 encrypted messages'
  AND default_time_to_live = 0
  AND gc_grace_seconds = 864000
  AND compaction = {
    'class': 'SizeTieredCompactionStrategy',
    'min_threshold': 4,
    'max_threshold': 32
  };

-- Index for sender queries
CREATE INDEX IF NOT EXISTS messages_sender_idx ON messages (sender_user_id);

-- Group messages table
CREATE TABLE IF NOT EXISTS group_messages (
  group_id UUID,
  message_id TIMEUUID,
  sender_user_id TEXT,
  sender_device_id TEXT,
  encrypted_content BLOB,
  mls_epoch BIGINT,
  sent_at TIMESTAMP,
  metadata MAP<TEXT, TEXT>,
  PRIMARY KEY (group_id, message_id)
) WITH CLUSTERING ORDER BY (message_id DESC)
  AND comment = 'Group chat messages with MLS encryption';

-- Media metadata table
CREATE TABLE IF NOT EXISTS media_metadata (
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
) WITH comment = 'Metadata for encrypted media files';

-- Index for conversation media queries
CREATE INDEX IF NOT EXISTS media_conversation_idx ON media_metadata (conversation_id);

-- Presence table with TTL
CREATE TABLE IF NOT EXISTS presence (
  user_id TEXT PRIMARY KEY,
  status TEXT,
  last_seen TIMESTAMP,
  device_id TEXT,
  updated_at TIMESTAMP
) WITH default_time_to_live = 86400
  AND comment = 'User presence with 24h TTL';

-- Call history table
CREATE TABLE IF NOT EXISTS call_history (
  user_id TEXT,
  call_id TIMEUUID,
  call_type TEXT,
  participants SET<TEXT>,
  started_at TIMESTAMP,
  ended_at TIMESTAMP,
  duration INT,
  PRIMARY KEY (user_id, call_id)
) WITH CLUSTERING ORDER BY (call_id DESC)
  AND comment = 'Call history per user';

-- Group metadata table
CREATE TABLE IF NOT EXISTS groups (
  group_id UUID PRIMARY KEY,
  group_name TEXT,
  creator_user_id TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  member_count INT,
  mls_group_state BLOB,
  metadata MAP<TEXT, TEXT>
) WITH comment = 'Group chat metadata and MLS state';

-- Group members table
CREATE TABLE IF NOT EXISTS group_members (
  group_id UUID,
  user_id TEXT,
  role TEXT,
  joined_at TIMESTAMP,
  PRIMARY KEY (group_id, user_id)
) WITH comment = 'Group membership';

-- Materialized view for user's groups
CREATE MATERIALIZED VIEW IF NOT EXISTS user_groups AS
  SELECT group_id, user_id, role, joined_at
  FROM group_members
  WHERE group_id IS NOT NULL AND user_id IS NOT NULL
  PRIMARY KEY (user_id, group_id);

-- Notifications table (temporary storage)
CREATE TABLE IF NOT EXISTS notifications (
  user_id TEXT,
  notification_id TIMEUUID,
  notification_type TEXT,
  title TEXT,
  body TEXT,
  data MAP<TEXT, TEXT>,
  created_at TIMESTAMP,
  read_at TIMESTAMP,
  PRIMARY KEY (user_id, notification_id)
) WITH CLUSTERING ORDER BY (notification_id DESC)
  AND default_time_to_live = 604800
  AND comment = 'Notifications with 7-day TTL';

-- Analytics table for usage statistics
CREATE TABLE IF NOT EXISTS analytics_events (
  event_date DATE,
  event_time TIMESTAMP,
  user_id TEXT,
  event_type TEXT,
  event_data MAP<TEXT, TEXT>,
  PRIMARY KEY (event_date, event_time, user_id)
) WITH CLUSTERING ORDER BY (event_time DESC, user_id ASC)
  AND comment = 'Anonymous usage analytics';

-- Display created tables
DESCRIBE TABLES;

-- Show keyspace details
DESCRIBE KEYSPACE guardyn;
