import 'package:flutter/material.dart';
import '../../../app/theme/spacing.dart';
import '../../../shared/widgets/widgets.dart';

/// Route constants for the clinical feature.
class ClinicalRoutes {
  ClinicalRoutes._();

  static const treatmentList = '/treatments';
  static const treatmentCreate = '/treatments/create';
  static String treatmentDetail(String id) => '/treatments/$id';
  static const otSchedule = '/treatments/ot';
  static const followups = '/treatments/followups';
  static String patientTreatments(String patientId) =>
      '/patients/$patientId/treatments';
}

/// Route definitions for GoRouter.
class ClinicalRoutePages {
  ClinicalRoutePages._();

  // These will be added to the main router in app_router.dart
}
