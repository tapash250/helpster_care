import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings state model.
class SettingsState {
  const SettingsState({
    this.notifyOnApproval = true,
    this.notifyOnFollowup = true,
    this.notifyOnTreatmentUpdate = true,
    this.notifyOnMessage = false,
    this.pushEnabled = true,
    this.emailDigest = false,
    this.appVersion = '1.0.0+1',
  });

  final bool notifyOnApproval;
  final bool notifyOnFollowup;
  final bool notifyOnTreatmentUpdate;
  final bool notifyOnMessage;
  final bool pushEnabled;
  final bool emailDigest;
  final String appVersion;

  SettingsState copyWith({
    bool? notifyOnApproval,
    bool? notifyOnFollowup,
    bool? notifyOnTreatmentUpdate,
    bool? notifyOnMessage,
    bool? pushEnabled,
    bool? emailDigest,
    String? appVersion,
  }) {
    return SettingsState(
      notifyOnApproval: notifyOnApproval ?? this.notifyOnApproval,
      notifyOnFollowup: notifyOnFollowup ?? this.notifyOnFollowup,
      notifyOnTreatmentUpdate:
          notifyOnTreatmentUpdate ?? this.notifyOnTreatmentUpdate,
      notifyOnMessage: notifyOnMessage ?? this.notifyOnMessage,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailDigest: emailDigest ?? this.emailDigest,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

/// Settings notifier.
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void toggleApprovalNotifications() {
    state = state.copyWith(notifyOnApproval: !state.notifyOnApproval);
  }

  void toggleFollowupNotifications() {
    state = state.copyWith(notifyOnFollowup: !state.notifyOnFollowup);
  }

  void toggleTreatmentNotifications() {
    state = state.copyWith(
        notifyOnTreatmentUpdate: !state.notifyOnTreatmentUpdate);
  }

  void toggleMessageNotifications() {
    state = state.copyWith(notifyOnMessage: !state.notifyOnMessage);
  }

  void togglePushEnabled() {
    state = state.copyWith(pushEnabled: !state.pushEnabled);
  }

  void toggleEmailDigest() {
    state = state.copyWith(emailDigest: !state.emailDigest);
  }
}

/// Provider for SettingsNotifier.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
