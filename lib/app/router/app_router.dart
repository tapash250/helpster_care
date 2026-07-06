import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Provides the application's [GoRouter] instance.
///
/// Navigation uses Go Router exclusively (AGENTS.md §28). Route strings are
/// declared as constants (§29) and authentication/permission redirects belong
/// in router guards (§30) — never inside widgets.
///
/// This skeleton exposes a single placeholder route; feature routes are
/// composed from each feature's `routes/` folder as they are implemented.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) => const _PlaceholderScreen(),
      ),
    ],
  );
});

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Helpster Care')),
    );
  }
}
