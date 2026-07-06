import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/providers.dart';
import '../repositories/approval_repository.dart';
import '../models/approval_filter.dart';

/// Provider for ApprovalRepository.
final approvalRepositoryProvider = Provider<ApprovalRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return ApprovalRepository(supabaseClient: supabase.client);
});

/// Provider for the filtered approval list.
final approvalListProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, ApprovalFilter>((ref, filter) async {
  final repo = ref.watch(approvalRepositoryProvider);
  return repo.listApprovals(filter: filter);
});

/// Provider for a single approval by ID.
final approvalDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>?, String>(
        (ref, id) async {
  final repo = ref.watch(approvalRepositoryProvider);
  return repo.getApproval(id);
});
