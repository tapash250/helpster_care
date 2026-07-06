/// Authentication route definitions.
///
/// Route paths are declared as constants so callers never hardcode strings
/// (AGENTS.md §29). The [authRoutes] list is composed into the app router.
library;

import 'package:go_router/go_router.dart';

import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/forgot_password_screen.dart';

/// Route path for the login screen.
const String loginRoutePath = '/login';

/// Route path for the sign-up screen.
const String signUpRoutePath = '/sign-up';

/// Route path for the forgot-password screen.
const String forgotPasswordRoutePath = '/forgot-password';

/// Route definitions for authentication flows.
///
/// Add this list to the parent GoRouter's [routes] parameter.
List<RouteBase> get authRoutes => [
      GoRoute(
        path: loginRoutePath,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: signUpRoutePath,
        name: 'sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: forgotPasswordRoutePath,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ];
