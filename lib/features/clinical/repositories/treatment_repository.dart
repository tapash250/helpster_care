import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/treatment_filter.dart';

/// Repository for all clinical operations (treatments, OT, follow-ups).
class TreatmentRepository {
  TreatmentRepository({required SupabaseClient supabaseClient})
      : _client = supabaseClient;

  final SupabaseClient _client;

  // ---- Treatments ----

  /// List treatments with optional filter.
  Future<List<Map<String, dynamic>>> listTreatments({
    TreatmentFilter? filter,
  }) async {
    var query = _client
        .from('treatments')
        .select('*, patients!inner(full_name, patient_id), hospitals!left(name)')
        .order('created_at', ascending: false);

    if (filter != null) {
      if (filter.searchQuery.isNotEmpty) {
        query = query.or(
          'diagnosis.ilike.%${filter.searchQuery}%,'
          'expected_outcome.ilike.%${filter.searchQuery}%',
        );
      }
      if (filter.status.isNotEmpty) {
        query = query.inFilter('status', filter.status);
      }
      if (filter.treatmentType != null) {
        query = query.eq('treatment_type', filter.treatmentType);
      }
      if (filter.patientId != null) {
        query = query.eq('patient_id', filter.patientId);
      }
    }

    final response = await query;
    return response as List<Map<String, dynamic>>;
  }

  /// Get a single treatment with all relations.
  Future<Map<String, dynamic>?> getTreatment(String id) async {
    final response = await _client
        .from('treatments')
        .select('*, patients(*), hospitals(*), '
            'conservative_treatments(*), '
            'surgical_treatments(*), '
            'diagnoses(*), '
            'prescriptions(*)')
        .eq('id', id)
        .single()
        .maybeSingle();
    return response as Map<String, dynamic>?;
  }

  /// Create a new treatment.
  Future<Map<String, dynamic>> createTreatment(
      Map<String, dynamic> data) async {
    final response =
        await _client.from('treatments').insert(data).select().single();
    return response as Map<String, dynamic>;
  }

  /// Update an existing treatment.
  Future<Map<String, dynamic>> updateTreatment(
      String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('treatments')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response as Map<String, dynamic>;
  }

  // ---- Conservative Treatment ----

  /// Create conservative treatment details.
  Future<Map<String, dynamic>> createConservativeTreatment(
      Map<String, dynamic> data) async {
    final response = await _client
        .from('conservative_treatments')
        .insert(data)
        .select()
        .single();
    return response as Map<String, dynamic>;
  }

  // ---- Surgical Treatment ----

  /// Create surgical treatment details.
  Future<Map<String, dynamic>> createSurgicalTreatment(
      Map<String, dynamic> data) async {
    final response = await _client
        .from('surgical_treatments')
        .insert(data)
        .select()
        .single();
    return response as Map<String, dynamic>;
  }

  // ---- OT Schedules ----

  /// List OT schedules (today and future).
  Future<List<Map<String, dynamic>>> listOTSchedules({
    String? hospitalId,
    String? status,
  }) async {
    final now = DateTime.now().toIso8601String();
    var query = _client
        .from('ot_schedules')
        .select(
            '*, patients(full_name, patient_id), operating_theatres!left(theatre_room)')
        .gte('scheduled_end', now)
        .order('scheduled_start', ascending: true);

    if (hospitalId != null) {
      query = query.eq('operating_theatres.hospital_id', hospitalId);
    }
    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query;
    return response as List<Map<String, dynamic>>;
  }

  /// Create an OT schedule.
  Future<Map<String, dynamic>> createOTSchedule(
      Map<String, dynamic> data) async {
    final response =
        await _client.from('ot_schedules').insert(data).select().single();
    return response as Map<String, dynamic>;
  }

  /// Update OT schedule status (confirm, cancel, complete).
  Future<void> updateOTScheduleStatus(
      String id, String status, Map<String, dynamic>? extra) async {
    final data = <String, dynamic>{'status': status};
    if (status == 'IN_PROGRESS') {
      data['actual_start'] = DateTime.now().toIso8601String();
    } else if (status == 'COMPLETED') {
      data['actual_end'] = DateTime.now().toIso8601String();
    }
    if (extra != null) data.addAll(extra);
    await _client.from('ot_schedules').update(data).eq('id', id);
  }

  // ---- Follow-ups ----

  /// List follow-ups for a patient.
  Future<List<Map<String, dynamic>>> listFollowups(String patientId) async {
    final response = await _client
        .from('followups')
        .select('*, hospitals!left(name)')
        .eq('patient_id', patientId)
        .order('followup_date', ascending: true);
    return response as List<Map<String, dynamic>>;
  }

  /// Create a follow-up.
  Future<Map<String, dynamic>> createFollowup(
      Map<String, dynamic> data) async {
    final response =
        await _client.from('followups').insert(data).select().single();
    return response as Map<String, dynamic>;
  }

  /// Mark follow-up as completed.
  Future<void> completeFollowup(
      String id, String outcome, DateTime? nextVisit) async {
    final data = <String, dynamic>{
      'status': 'COMPLETED',
      'outcome': outcome,
    };
    if (nextVisit != null) data['next_visit'] = nextVisit.toIso8601String();
    await _client.from('followups').update(data).eq('id', id);
  }

  // ---- Diagnoses ----

  /// List diagnoses for a patient.
  Future<List<Map<String, dynamic>>> listDiagnoses(String patientId) async {
    final response = await _client
        .from('diagnoses')
        .select('*')
        .eq('patient_id', patientId)
        .order('diagnosed_at', ascending: false);
    return response as List<Map<String, dynamic>>;
  }

  /// Add a diagnosis.
  Future<Map<String, dynamic>> addDiagnosis(
      Map<String, dynamic> data) async {
    final response =
        await _client.from('diagnoses').insert(data).select().single();
    return response as Map<String, dynamic>;
  }

  // ---- Prescriptions ----

  /// List prescriptions for a patient.
  Future<List<Map<String, dynamic>>> listPrescriptions(
      String patientId) async {
    final response = await _client
        .from('prescriptions')
        .select('*')
        .eq('patient_id', patientId)
        .eq('is_active', true)
        .order('prescribed_at', ascending: false);
    return response as List<Map<String, dynamic>>;
  }

  /// Add a prescription.
  Future<Map<String, dynamic>> addPrescription(
      Map<String, dynamic> data) async {
    final response =
        await _client.from('prescriptions').insert(data).select().single();
    return response as Map<String, dynamic>;
  }
}
