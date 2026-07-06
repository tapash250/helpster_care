/// Domain-specific exception hierarchy for Helpster Care.
///
/// Generic `Exception` is discouraged (AGENTS.md §164). Throw the most specific
/// type so callers can handle, log, recover, and notify intentionally (§162).
library;

/// Base type for all Helpster Care domain exceptions.
sealed class AppException implements Exception {
  /// Creates an [AppException] with a human-readable [message] and optional
  /// machine-readable [code].
  const AppException(this.message, {this.code});

  /// Human-readable description (must never contain PHI — §80, §163).
  final String message;

  /// Optional stable error code (see API Error Catalogue, Appendix J).
  final String? code;

  @override
  String toString() => '$runtimeType(${code ?? '-'}): $message';
}

/// Thrown when a requested patient cannot be found.
class PatientNotFoundException extends AppException {
  /// Creates a [PatientNotFoundException].
  const PatientNotFoundException([String message = 'Patient not found'])
      : super(message, code: 'PATIENT_NOT_FOUND');
}

/// Thrown when a user is not assigned to the required hospital.
class HospitalNotAssignedException extends AppException {
  /// Creates a [HospitalNotAssignedException].
  const HospitalNotAssignedException([String message = 'Hospital not assigned'])
      : super(message, code: 'HOSPITAL_NOT_ASSIGNED');
}

/// Thrown when the caller lacks a required permission.
class PermissionDeniedException extends AppException {
  /// Creates a [PermissionDeniedException].
  const PermissionDeniedException([String message = 'Permission denied'])
      : super(message, code: 'PERMISSION_DENIED');
}

/// Thrown when offline synchronization fails or conflicts.
class SynchronizationException extends AppException {
  /// Creates a [SynchronizationException].
  const SynchronizationException([String message = 'Synchronization failed'])
      : super(message, code: 'SYNC_CONFLICT');
}

/// Thrown when input validation fails.
class ValidationException extends AppException {
  /// Creates a [ValidationException].
  const ValidationException([String message = 'Validation failed'])
      : super(message, code: 'VALIDATION_FAILED');
}

/// Thrown when a document upload fails.
class DocumentUploadException extends AppException {
  /// Creates a [DocumentUploadException].
  const DocumentUploadException([String message = 'Document upload failed'])
      : super(message, code: 'DOCUMENT_UPLOAD_FAILED');
}
