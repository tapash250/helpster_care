import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for notification operations via Supabase.
class NotificationRepository {
  NotificationRepository({required SupabaseClient supabaseClient})
      : _client = supabaseClient;

  final SupabaseClient _client;

  /// List notifications for the current user.
  Future<List<Map<String, dynamic>>> listNotifications({
    bool? unreadOnly,
    int limit = 50,
    int offset = 0,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    var query = _client
        .from('notifications')
        .select('*')
        .eq('recipient_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    if (unreadOnly == true) {
      query = query.eq('is_read', false);
    }

    final response = await query;
    return response as List<Map<String, dynamic>>;
  }

  /// Get unread count.
  Future<int> getUnreadCount() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _client
        .from('notifications')
        .select('id', CountOption.exact)
        .eq('recipient_id', userId)
        .eq('is_read', false);

    return response.count ?? 0;
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _client.from('notifications').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('id', notificationId);
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('notifications').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('recipient_id', userId).eq('is_read', false);
  }

  /// Delete a notification.
  Future<void> deleteNotification(String notificationId) async {
    await _client
        .from('notifications')
        .delete()
        .eq('id', notificationId);
  }
}
