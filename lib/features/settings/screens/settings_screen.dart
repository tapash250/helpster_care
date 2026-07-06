import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/widgets/confirm_dialog.dart';
import 'package:helpster_care/core/services/auth_service.dart';
import 'package:helpster_care/features/settings/providers/settings_providers.dart';

/// Settings screen — profile, notification preferences, app info, logout.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authStateProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          // Profile section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _SectionTitle(title: 'Account'),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () => context.go('/settings/profile'),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?.fullName ??
                              'User',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (currentUser?.email != null)
                          Text(
                            currentUser!.email!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const Divider(),

          // Notification preferences
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _SectionTitle(title: 'Notifications'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingsSwitch(
            icon: Icons.push_pin_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive push notifications on your device',
            value: settings.pushEnabled,
            onChanged: (_) =>
                ref.read(settingsProvider.notifier).togglePushEnabled(),
          ),
          _SettingsSwitch(
            icon: Icons.approval_outlined,
            title: 'Approval Updates',
            subtitle: 'When approvals are submitted or reviewed',
            value: settings.notifyOnApproval,
            onChanged: (_) => ref
                .read(settingsProvider.notifier)
                .toggleApprovalNotifications(),
          ),
          _SettingsSwitch(
            icon: Icons.follow_the_signs_outlined,
            title: 'Follow-up Reminders',
            subtitle: 'When follow-ups are due or rescheduled',
            value: settings.notifyOnFollowup,
            onChanged: (_) => ref
                .read(settingsProvider.notifier)
                .toggleFollowupNotifications(),
          ),
          _SettingsSwitch(
            icon: Icons.medical_services_outlined,
            title: 'Treatment Updates',
            subtitle: 'When treatment status changes',
            value: settings.notifyOnTreatmentUpdate,
            onChanged: (_) => ref
                .read(settingsProvider.notifier)
                .toggleTreatmentNotifications(),
          ),
          _SettingsSwitch(
            icon: Icons.message_outlined,
            title: 'Messages',
            subtitle: 'New messages from team members',
            value: settings.notifyOnMessage,
            onChanged: (_) => ref
                .read(settingsProvider.notifier)
                .toggleMessageNotifications(),
          ),
          _SettingsSwitch(
            icon: Icons.email_outlined,
            title: 'Email Digest',
            subtitle: 'Receive a daily email summary',
            value: settings.emailDigest,
            onChanged: (_) =>
                ref.read(settingsProvider.notifier).toggleEmailDigest(),
          ),
          const Divider(),

          // App info
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _SectionTitle(title: 'About'),
          ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            trailing: Text(
              settings.appVersion,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: Icon(
              Icons.open_in_new,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onTap: () {
              // TODO: Open terms of service
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: Icon(
              Icons.open_in_new,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          const Divider(),

          // Logout
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: OutlinedButton.icon(
              onPressed: () => _handleLogout(context, ref),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Future<void> _handleLogout(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmLabel: 'Sign Out',
      isDestructive: true,
    );
    if (confirmed == true) {
      await ref.read(authServiceProvider).signOut();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
