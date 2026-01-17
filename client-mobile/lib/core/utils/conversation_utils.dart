import 'package:uuid/uuid.dart';

/// Utility class for conversation-related operations.
/// Generates deterministic conversation IDs matching backend implementation.
class ConversationUtils {
  /// Namespace UUID for conversation ID generation (same as backend).
  /// Backend uses: Uuid::parse_str("00000000-0000-0000-0000-000000000000")
  static const String _namespaceUuid = '00000000-0000-0000-0000-000000000000';

  /// Generate a deterministic conversation ID from two user IDs.
  /// 
  /// This matches the backend implementation in Rust:
  /// ```rust
  /// fn generate_conversation_id(user1: &str, user2: &str) -> String {
  ///     let mut users = vec![user1, user2];
  ///     users.sort();
  ///     let namespace = Uuid::parse_str("00000000-0000-0000-0000-000000000000").unwrap();
  ///     let data = format!("{}:{}", users[0], users[1]);
  ///     Uuid::new_v5(&namespace, data.as_bytes()).to_string()
  /// }
  /// ```
  static String generateConversationId(String userId1, String userId2) {
    // Sort user IDs to ensure consistency regardless of sender/recipient order
    final users = [userId1, userId2]..sort();
    
    // Generate data string in same format as backend
    final data = '${users[0]}:${users[1]}';
    
    // Use UUID v5 with the same namespace as backend
    final uuid = const Uuid();
    return uuid.v5(_namespaceUuid, data);
  }
}
