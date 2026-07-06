/// Patients feature — core patient management module.
///
/// This barrel exports all public types and providers for the feature.
library;

export 'controllers/patient_list_controller.dart'
    show
        patientListControllerProvider,
        patientListConfigProvider,
        patientListProvider,
        patientRepositoryProvider;
export 'controllers/patient_detail_controller.dart'
    show
        patientDetailControllerProvider,
        patientDetailProvider,
        PatientDetailData;
export 'controllers/patient_form_controller.dart'
    show patientFormControllerProvider;
export 'models/patient_filter.dart' show PatientFilter;
export 'providers/patient_detail_provider.dart';
export 'routes/patient_routes.dart' show PatientRoutes, patientGoRoutes;
export 'screens/patient_list_screen.dart' show PatientListScreen;
export 'screens/patient_create_screen.dart' show PatientCreateScreen;
export 'screens/patient_detail_screen.dart' show PatientDetailScreen;
export 'screens/patient_edit_screen.dart' show PatientEditScreen;
export 'states/patient_list_state.dart' show PatientListConfig, PatientStatusOption;
export 'states/patient_form_state.dart' show PatientFormState;
export 'validators/patient_validators.dart' show PatientValidators;
export 'widgets/patient_card.dart' show PatientCard;
export 'widgets/patient_info_section.dart' show PatientInfoSection;
export 'widgets/patient_status_timeline.dart' show PatientStatusTimeline;
export 'widgets/patient_assignment_section.dart' show PatientAssignmentSection;
export 'widgets/patient_notes_section.dart' show PatientNotesSection;
