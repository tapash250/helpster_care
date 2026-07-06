import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/widgets/widgets.dart';
import 'package:helpster_care/features/notifications/providers/notification_providers.dart';
import 'package:helpster_care/features/notifications/widgets/notification_tile.dart';

/// Screen displaying the notification list with read/unread styling.
class NotificationListScreen extends ConsumerStatefulWidget {
  const NotificationListScreen({super.key});

  @override
  ConsumerState<NotificationListScreen> createState() =>
      _NotificationListScreenState();
}

class _NotificationListScreenState
    extends ConsumerState<NotificationListScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(notificationListProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final unreadAsync = ref.watch(unreadCountProvider);
              return unreadAsync.when(
                data: (count) => count > 0
                    ? TextButton(
                        onPressed: _markAllAsRead,
                        child: const Text('Mark all read'),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Unread summary bar
          Consumer(
            builder: (context, ref, _) {
              final unreadAsync = ref.watch(unreadCountProvider);
              return unreadAsync.when(
                data: (count) {
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    color: theme.colorScheme.primaryContainer
                        .withOpacity(0.15),
                    child: Row(
                      children: [
                        Icon(
                          Icons.markunread,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '$count unread notification${count == 1 ? '' : 's'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),

          // Notification list
          Expanded(
            child: AsyncValueWidget<List<Map<String, dynamic>>>(
              value: notificationsAsync,
              data: (notifications) {
                if (notifications.isEmpty) {
                  return const EmptyState(
                    title: 'No notifications',
                    subtitle:
                        'You\'re all caught up! Notifications will appear here.',
                    icon: Icons.notifications_off_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(notificationListProvider);
                    ref.invalidate(unreadCountProvider);
                  },
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      final id = n['id'] as String? ?? '';
                      final isRead = n['is_read'] as bool? ?? false;
                      final createdAt = n['created_at'] as String?;

                      return NotificationTile(
                        title: n['title'] as String? ?? '',
                        body: n['body'] as String? ?? '',
                        isRead: isRead,
                        createdAt: createdAt != null
                            ? DateTime.tryParse(createdAt)
                            : null,
                        referenceType:
                            n['reference_type'] as String?,
                        onTap: () {
                          if (!isRead) _markAsRead(id);
                          _handleNotificationTap(
                            n['reference_type'] as String?,
                            n['reference_id'] as String?,
                          );
                        },
                        onDismiss: () => _deleteNotification(id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsRead(String id) async {
    await ref.read(notificationRepositoryProvider).markAsRead(id);
    ref.invalidate(notificationListProvider);
    ref.invalidate(unreadCountProvider);
  }

  Future<void> _markAllAsRead() async {
    await ref.read(notificationRepositoryProvider).markAllAsRead();
    ref.invalidate(notificationListProvider);
    ref.invalidate(unreadCountProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteNotification(String id) async {
    await ref.read(notificationRepositoryProvider).deleteNotification(id);
    ref.invalidate(notificationListProvider);
    ref.invalidate(unreadCountProvider);
  }

  void _handleNotificationTap(String? type, String? referenceId) {
    if (type == null || referenceId == null) return;
    // TODO: Navigate to the relevant screen based on type
    // e.g., if type == 'APPROVAL', navigate to approval detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to $type: $referenceId'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
