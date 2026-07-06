/// Supabase service Riverpod provider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_service.dart';

/// Singleton provider for the Supabase service.
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});
