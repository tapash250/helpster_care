import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/providers.dart';
import '../repositories/notification_repository.dart';

/// Provider for NotificationRepository.
final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return NotificationRepository(supabaseClient: supabase.client);
});

/// Provider for the notification list.
final notificationListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.listNotifications();
});

/// Provider for unread notification count.
final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getUnreadCount();
});
