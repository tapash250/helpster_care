/// Riverpod providers for the authentication feature.
///
/// Wires together the data source and repository layers so controllers and
/// screens can depend on them without concrete references (AGENTS.md §23).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/providers.dart';
import '../../core/services/auth_service.dart';
import '../datasources/remote/auth_datasource.dart';
import '../repositories/auth_repository.dart';

/// Provider for [AuthRemoteDataSource].
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRemoteDataSource(authService: authService);
});

/// Provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepository(dataSource: dataSource);
});
