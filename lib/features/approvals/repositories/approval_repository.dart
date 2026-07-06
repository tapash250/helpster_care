import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/approval_filter.dart';

/// Repository for approval operations via Supabase.
class ApprovalRepository {
  ApprovalRepository({required SupabaseClient supabaseClient})
      : _client = supabaseClient;

  final SupabaseClient _client;

  /// List approvals with optional filter.
  Future<List<Map<String, dynamic>>> listApprovals({
    ApprovalFilter? filter,
  }) async {
    var query = _client
        .from('approvals')
        .select('*, patients!inner(full_name, patient_id)')
        .order('created_at', ascending: false);

    if (filter != null) {
      if (filter.searchQuery.isNotEmpty) {
        query = query.or(
          'patients.full_name.ilike.%${filter.searchQuery}%,'
          'patients.patient_id.ilike.%${filter.searchQuery}%',
        );
      }
      if (filter.states.isNotEmpty) {
        query = query.inFilter('current_state', filter.states);
      }
      if (filter.priority != null) {
        query = query.eq('priority', filter.priority);
      }
      if (filter.patientId != null) {
        query = query.eq('patient_id', filter.patientId);
      }
    }

    final response = await query;
    return response as List<Map<String, dynamic>>;
  }

  /// Get a single approval with history.
  Future<Map<String, dynamic>?> getApproval(String id) async {
    final response = await _client
        .from('approvals')
        .select(
            '*, patients(full_name, patient_id), approval_history(*)')
        .eq('id', id)
        .maybeSingle();
    return response as Map<String, dynamic>?;
  }

  /// Update approval state (approve, reject, submit, etc.).
  Future<void> updateApprovalState({
    required String approvalId,
    required String newState,
    String? notes,
  }) async {
    // Update the approval record
    final data = <String, dynamic>{
      'current_state': newState,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (newState == 'APPROVED' || newState == 'REJECTED') {
      data['reviewed_by'] = _client.auth.currentUser?.id;
      data['decided_at'] = DateTime.now().toIso8601String();
      data['review_notes'] = notes;
    }

    await _client.from('approvals').update(data).eq('id', approvalId);
  }

  /// Get approval history for a specific approval.
  Future<List<Map<String, dynamic>>> getApprovalHistory(
      String approvalId) async {
    final response = await _client
        .from('approval_history')
        .select('*')
        .eq('approval_id', approvalId)
        .order('created_at', ascending: true);
    return response as List<Map<String, dynamic>>;
  }
}
