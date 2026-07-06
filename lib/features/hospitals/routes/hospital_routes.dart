import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:helpster_care/features/hospitals/screens/hospital_list_screen.dart';
import 'package:helpster_care/features/hospitals/screens/hospital_detail_screen.dart';
import 'package:helpster_care/features/hospitals/screens/hospital_form_screen.dart';

/// Route path constants for the hospitals feature.
class HospitalRoutes {
  const HospitalRoutes._();

  /// /hospitals — hospital list.
  static const String list = '/hospitals';

  /// /hospitals/:id — hospital detail.
  static const String detail = '/hospitals/:id';

  /// /hospitals/new — create hospital form.
  static const String create = '/hospitals/new';

  /// /hospitals/:id/edit — edit hospital form.
  static const String edit = '/hospitals/:id/edit';

  /// Build the detail route path for a specific hospital ID.
  static String detailPath(String id) => '/hospitals/$id';

  /// Build the edit route path for a specific hospital ID.
  static String editPath(String id) => '/hospitals/$id/edit';
}

/// Hospital feature routes to be composed into the app router.
///
/// Usage: add these to the main router's routes list.
List<RouteBase> get hospitalFeatureRoutes {
  return [
    GoRoute(
      path: HospitalRoutes.list,
      name: 'hospitals',
      builder: (context, state) => const HospitalListScreen(),
      routes: [
        GoRoute(
          path: 'new',
          name: 'hospital-create',
          builder: (context, state) => const HospitalFormScreen(),
        ),
        GoRoute(
          path: ':id',
          name: 'hospital-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return HospitalDetailScreen(hospitalId: id);
          },
          routes: [
            GoRoute(
              path: 'edit',
              name: 'hospital-edit',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return HospitalFormScreen(hospitalId: id);
              },
            ),
          ],
        ),
      ],
    ),
  ];
}
