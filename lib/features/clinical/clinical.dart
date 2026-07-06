/// Clinical feature module — treatments, surgeries, OT schedules, follow-ups.
///
/// AGENTS.md §97–§103, §106. Every treatment is a Treatment record with either
/// conservative or surgical extension.
library;

export 'models/treatment_filter.dart';
export 'providers/treatment_providers.dart';
export 'repositories/treatment_repository.dart';
export 'routes/treatment_routes.dart';
export 'screens/treatment_list_screen.dart';
export 'screens/treatment_detail_screen.dart';
export 'screens/treatment_form_screen.dart';
export 'screens/ot_schedule_screen.dart';
export 'screens/followup_list_screen.dart';
export 'controllers/treatment_controller.dart';
export 'controllers/ot_controller.dart';
export 'controllers/followup_controller.dart';
export 'widgets/treatment_card.dart';
export 'widgets/ot_timeline.dart';
export 'widgets/followup_card.dart';
export 'widgets/diagnosis_section.dart';
export 'widgets/prescription_section.dart';
