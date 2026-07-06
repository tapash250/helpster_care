/// Re-export barrel for patient providers.
///
/// Providers are defined alongside their controllers for cohesion.
/// This barrel re-exports them for convenient single-line imports.
library;

export '../controllers/patient_list_controller.dart'
    show
        patientListControllerProvider,
        patientListConfigProvider,
        patientListProvider,
        patientRepositoryProvider;
export '../controllers/patient_detail_controller.dart'
    show patientDetailControllerProvider, patientDetailProvider, PatientDetailData;
export '../controllers/patient_form_controller.dart'
    show patientFormControllerProvider;
export 'patient_detail_provider.dart';
