import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/environment/environment.dart';

/// Application entry point for Helpster Care.
///
/// Responsibilities:
/// - Ensure Flutter bindings are ready.
/// - Load environment configuration.
/// - Initialize the Riverpod [ProviderScope] container.
///
/// All heavy initialization (Supabase, PowerSync, secure storage) is performed
/// lazily inside the appropriate providers/services — never here — to keep the
/// entry point thin and testable.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Environment.load();

  runApp(
    const ProviderScope(
      child: HelpsterCareApp(),
    ),
  );
}
