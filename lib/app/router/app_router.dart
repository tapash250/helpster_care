import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:helpster_care/features/dashboard/screens/dashboard_screen.dart';
import 'package:helpster_care/features/authentication/routes/auth_routes.dart';
import 'package:helpster_care/features/hospitals/routes/hospital_routes.dart';
import 'package:helpster_care/features/patients/routes/patient_routes.dart';
import 'package:helpster_care/features/settings/screens/settings_screen.dart';
import 'package:helpster_care/features/settings/screens/profile_screen.dart';
import 'package:helpster_care/features/notifications/screens/notification_list_screen.dart';
import 'package:helpster_care/features/approvals/screens/approval_list_screen.dart';
import 'package:helpster_care/features/approvals/screens/approval_detail_screen.dart';
import 'package:helpster_care/features/clinical/screens/treatment_list_screen.dart';
import 'package:helpster_care/features/clinical/screens/treatment_detail_screen.dart';
import 'package:helpster_care/features/clinical/screens/treatment_form_screen.dart';
import 'package:helpster_care/features/clinical/screens/ot_schedule_screen.dart';
import 'package:helpster_care/features/clinical/screens/followup_list_screen.dart';

/// Provides the application's [GoRouter] instance.
///
/// Navigation uses Go Router exclusively (AGENTS.md §28). Route strings are
/// declared as constants (§29) and authentication/permission redirects belong
/// in router guards (§30) — never inside widgets.
///
/// Routes are composed from each feature's `routes/` folder.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      // === Dashboard (landing) ===
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // === Authentication ===
      ...authRoutes,

      // === Patient routes ===
      ...patientGoRoutes,

      // === Clinical / Treatment routes ===
      GoRoute(
        path: '/treatments',
        name: 'treatment-list',
        builder: (context, state) => const TreatmentListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'treatment-create',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final patientId = state.uri.queryParameters['patientId'];
              return TreatmentFormScreen(patientId: patientId);
            },
          ),
          GoRoute(
            path: ':id',
            name: 'treatment-detail',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TreatmentDetailScreen(id: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/ot-schedule',
        name: 'ot-schedule',
        builder: (context, state) => const OTScheduleScreen(),
      ),
      GoRoute(
        path: '/followups',
        name: 'followup-list',
        builder: (context, state) {
          final patientId = state.uri.queryParameters['patientId'];
          return FollowupListScreen(patientId: patientId);
        },
      ),

      // === Hospital routes ===
      ...hospitalFeatureRoutes,

      // === Approval routes ===
      GoRoute(
        path: '/approvals',
        name: 'approval-list',
        builder: (context, state) => const ApprovalListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'approval-detail',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ApprovalDetailScreen(id: id);
            },
          ),
        ],
      ),

      // === Notification routes ===
      GoRoute(
        path: '/notifications',
        name: 'notification-list',
        builder: (context, state) => const NotificationListScreen(),
      ),

      // === Settings routes ===
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            name: 'settings-profile',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Navigator key for full-screen routes that cover the bottom nav.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
