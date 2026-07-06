import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget of the Helpster Care application.
///
/// Wires together the Go Router configuration and the Material 3 theme.
/// It renders state only — no business logic lives here (AGENTS.md §20).
class HelpsterCareApp extends ConsumerWidget {
  /// Creates the root application widget.
  const HelpsterCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Helpster Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
