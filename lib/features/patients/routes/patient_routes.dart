/// Routes for the Patients feature.
///
/// Declares path constants and [GoRoute] definitions for all patient screens.
/// Routes follow the convention: `/patients`, `/patients/create`, `/patients/:id`,
/// `/patients/:id/edit`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpster_care/features/patients/screens/patient_list_screen.dart';
import 'package:helpster_care/features/patients/screens/patient_create_screen.dart';
import 'package:helpster_care/features/patients/screens/patient_detail_screen.dart';
import 'package:helpster_care/features/patients/screens/patient_edit_screen.dart';

/// Route path constants for patient screens.
abstract class PatientRoutes {
  PatientRoutes._();

  /// /patients — list screen
  static const String list = '/patients';

  /// /patients/create — create screen
  static const String create = '/patients/create';

  /// /patients/:id — detail screen (template)
  static const String detail = '/patients/:id';

  /// /patients/:id/edit — edit screen (template)
  static const String edit = '/patients/:id/edit';

  /// Build a detail route path for a given patient id.
  static String detailPath(String patientId) => '/patients/$patientId';

  /// Build an edit route path for a given patient id.
  static String editPath(String patientId) => '/patients/$patientId/edit';
}

/// List of [GoRoute] definitions for the patients feature.
///
/// Add this to your app router's route list:
/// ```dart
/// routes: [...PatientRoutes.routes, ...otherRoutes]
/// ```
List<RouteBase> get patientGoRoutes => [
      GoRoute(
        path: '/patients',
        name: 'patient-list',
        builder: (context, state) => const PatientListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'patient-create',
            parentNavigatorKey: patientRootNavigatorKey,
            builder: (context, state) => const PatientCreateScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'patient-detail',
            parentNavigatorKey: patientRootNavigatorKey,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return PatientDetailScreen(patientId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'patient-edit',
                parentNavigatorKey: patientRootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PatientEditScreen(patientId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ];

/// A navigator key for full-screen patient routes.
/// Note: The root navigator key is owned by app_router.dart.
final GlobalKey<NavigatorState> patientRootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'patientRoot');
