/// Repository for patient data management.
///
/// Coordinates between the local PowerSync datasource and the remote Supabase
/// datasource. The local datasource is the primary source of truth for reads;
/// writes go to local first (offline-first) with remote sync handled by
/// PowerSync's sync engine.
library;

import 'package:helpster_care/features/patients/datasources/local/patient_local_datasource.dart';
import 'package:helpster_care/features/patients/datasources/remote/patient_remote_datasource.dart';
import 'package:helpster_care/features/patients/models/patient_filter.dart';
import 'package:helpster_care/shared/models/models.dart';

/// Exception thrown by the repository on failure.
class PatientRepositoryException implements Exception {
  const PatientRepositoryException(this.message);
  final String message;

  @override
  String toString() => 'PatientRepositoryException: $message';
}

/// Coordinates patient data between local and remote datasources.
class PatientRepository {
  PatientRepository({
    required PatientLocalDatasource local,
    required PatientRemoteDatasource remote,
  })  : _local = local,
        _remote = remote;

  final PatientLocalDatasource _local;
  final PatientRemoteDatasource _remote;

  // ── Patients ────────────────────────────────────────────────────

  /// Fetch patients with optional filtering.
  Future<List<Patient>> getPatients({PatientFilter? filter}) async {
    try {
      return await _local.getPatients(filter: filter);
    } catch (e) {
      throw PatientRepositoryException('Failed to load patients: $e');
    }
  }

  /// Get a single patient by id.
  Future<Patient?> getPatientById(String id) async {
    try {
      return await _local.getPatientById(id);
    } catch (e) {
      throw PatientRepositoryException('Failed to load patient: $e');
    }
  }

  /// Create a new patient with optional related data.
  Future<Patient> createPatient(
    Patient patient, {
    PatientContact? contact,
    PatientAddress? address,
    PatientGuardian? guardian,
    PatientStatusHistory? statusHistory,
  }) async {
    try {
      await _local.insertPatient(patient);

      if (contact != null) {
        await _local.insertContact(contact);
      }
      if (address != null) {
        await _local.insertAddress(address);
      }
      if (guardian != null) {
        await _local.insertGuardian(guardian);
      }
      if (statusHistory != null) {
        await _local.insertStatusHistory(statusHistory);
      }

      // Best-effort remote sync (PowerSync handles automatic sync,
      // but we also push directly for immediate consistency).
      try {
        await _remote.upsertPatient(patient);
        if (contact != null) await _remote.upsertContact(contact);
        if (address != null) await _remote.upsertAddress(address);
        if (guardian != null) await _remote.upsertGuardian(guardian);
      } catch (_) {
        // Remote sync failed — data is safe locally and will sync
        // when connectivity is restored.
      }

      return patient;
    } catch (e) {
      throw PatientRepositoryException('Failed to create patient: $e');
    }
  }

  /// Update an existing patient.
  Future<Patient> updatePatient(
    Patient patient, {
    PatientContact? contact,
    PatientAddress? address,
    PatientGuardian? guardian,
    PatientStatusHistory? statusHistory,
  }) async {
    try {
      await _local.updatePatient(patient);

      if (contact != null) {
        await _local.updateContact(contact);
      }
      if (address != null) {
        await _local.updateAddress(address);
      }
      if (guardian != null) {
        await _local.updateGuardian(guardian);
      }
      if (statusHistory != null) {
        await _local.insertStatusHistory(statusHistory);
      }

      try {
        await _remote.upsertPatient(patient);
        if (contact != null) await _remote.upsertContact(contact);
        if (address != null) await _remote.upsertAddress(address);
        if (guardian != null) await _remote.upsertGuardian(guardian);
      } catch (_) {}

      return patient;
    } catch (e) {
      throw PatientRepositoryException('Failed to update patient: $e');
    }
  }

  /// Delete (soft-delete) a patient.
  Future<void> deletePatient(String id) async {
    try {
      await _local.deletePatient(id);
      try {
        await _remote.deletePatient(id);
      } catch (_) {}
    } catch (e) {
      throw PatientRepositoryException('Failed to delete patient: $e');
    }
  }

  // ── Contacts ────────────────────────────────────────────────────

  Future<List<PatientContact>> getContacts(String patientId) async {
    try {
      return await _local.getContacts(patientId);
    } catch (e) {
      throw PatientRepositoryException('Failed to load contacts: $e');
    }
  }

  // ── Addresses ───────────────────────────────────────────────────

  Future<List<PatientAddress>> getAddresses(String patientId) async {
    try {
      return await _local.getAddresses(patientId);
    } catch (e) {
      throw PatientRepositoryException('Failed to load addresses: $e');
    }
  }

  // ── Guardians ───────────────────────────────────────────────────

  Future<List<PatientGuardian>> getGuardians(String patientId) async {
    try {
      return await _local.getGuardians(patientId);
    } catch (e) {
      throw PatientRepositoryException('Failed to load guardians: $e');
    }
  }

  // ── Assignments ─────────────────────────────────────────────────

  Future<List<PatientAssignment>> getAssignments(String patientId) async {
    try {
      return await _local.getAssignments(patientId);
    } catch (e) {
      throw PatientRepositoryException('Failed to load assignments: $e');
    }
  }

  // ── Status History ──────────────────────────────────────────────

  Future<List<PatientStatusHistory>> getStatusHistory(String patientId) async {
    try {
      return await _local.getStatusHistory(patientId);
    } catch (e) {
      throw PatientRepositoryException('Failed to load status history: $e');
    }
  }

  /// Record a status change.
  Future<void> recordStatusChange(
    String patientId,
    String fromStatus,
    String toStatus, {
    String? changedBy,
    String? reason,
  }) async {
    final entry = PatientStatusHistory(
      id: 'sh_${DateTime.now().microsecondsSinceEpoch}',
      patientId: patientId,
      fromStatus: fromStatus,
      toStatus: toStatus,
      changedBy: changedBy,
      reason: reason,
      changedAt: DateTime.now(),
    );
    await _local.insertStatusHistory(entry);
  }

  // ── Notes ───────────────────────────────────────────────────────

  Future<List<PatientNote>> getNotes(String patientId) async {
    try {
      return await _local.getNotes(patientId);
    } catch (e) {
      throw PatientRepositoryException('Failed to load notes: $e');
    }
  }

  Future<PatientNote> addNote(PatientNote note) async {
    try {
      await _local.insertNote(note);
      return note;
    } catch (e) {
      throw PatientRepositoryException('Failed to add note: $e');
    }
  }
}
