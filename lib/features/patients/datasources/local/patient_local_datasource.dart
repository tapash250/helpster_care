/// Local persistence for patient data via PowerSync.
///
/// All CRUD operations use the local PowerSync SQLite database. Writes are
/// automatically synced to Supabase by the PowerSync sync engine when the
/// device is online.
library;

import 'package:powersync/powersync.dart';
import 'package:helpster_care/shared/models/models.dart';
import 'package:helpster_care/features/patients/models/patient_filter.dart';

/// Datasource for local patient CRUD via PowerSync.
class PatientLocalDatasource {
  PatientLocalDatasource({required PowerSyncDatabase db}) : _db = db;

  final PowerSyncDatabase _db;

  // ── Patients ────────────────────────────────────────────────────

  /// Fetch patients with optional filtering and sorting.
  Future<List<Patient>> getPatients({PatientFilter? filter}) async {
    final conditions = <String>[];
    final params = <dynamic>[];

    if (filter != null) {
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final q = '%${filter.searchQuery}%';
        conditions.add(
          '(full_name LIKE ? OR patient_id LIKE ? OR national_id LIKE ?)',
        );
        params.addAll([q, q, q]);
      }

      if (filter.statusFilter.isNotEmpty) {
        final placeholders = filter.statusFilter.map((_) => '?').join(',');
        conditions.add('status IN ($placeholders)');
        params.addAll(filter.statusFilter);
      }
    }

    // Soft-delete filter
    conditions.add('(is_deleted IS NULL OR is_deleted = 0)');

    final where = conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';
    final orderDir = filter?.ascending == true ? 'ASC' : 'DESC';
    final orderBy = 'ORDER BY ${filter?.sortField ?? 'created_at'} $orderDir';

    final rows = await _db.getAll(
      "SELECT * FROM patients $where $orderBy",
      params,
    );

    return rows.map(_patientFromRow).toList();
  }

  /// Get a single patient by uuid.
  Future<Patient?> getPatientById(String id) async {
    final rows = await _db.getAll(
      'SELECT * FROM patients WHERE id = ? AND (is_deleted IS NULL OR is_deleted = 0) LIMIT 1',
      [id],
    );
    if (rows.isEmpty) return null;
    return _patientFromRow(rows.first);
  }

  /// Insert a new patient record.
  Future<void> insertPatient(Patient patient) async {
    await _db.execute(
      '''INSERT INTO patients (
        id, patient_id, national_id, full_name, date_of_birth,
        gender, blood_group, religion, occupation, photo_path,
        status, hospital_id, hospital_name,
        created_at, updated_at, created_by, updated_by
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        patient.id,
        patient.patientId,
        patient.nationalId,
        patient.fullName,
        patient.dateOfBirth?.toIso8601String(),
        patient.gender,
        patient.bloodGroup,
        patient.religion,
        patient.occupation,
        patient.photoPath,
        patient.status,
        patient.hospitalId,
        patient.hospitalName,
        patient.createdAt.toIso8601String(),
        patient.updatedAt.toIso8601String(),
        patient.createdBy,
        patient.updatedBy,
      ],
    );
  }

  /// Update an existing patient record.
  Future<void> updatePatient(Patient patient) async {
    await _db.execute(
      '''UPDATE patients SET
        patient_id = ?, national_id = ?, full_name = ?, date_of_birth = ?,
        gender = ?, blood_group = ?, religion = ?, occupation = ?,
        photo_path = ?, status = ?, hospital_id = ?, hospital_name = ?,
        updated_at = ?, updated_by = ?
      WHERE id = ?''',
      [
        patient.patientId,
        patient.nationalId,
        patient.fullName,
        patient.dateOfBirth?.toIso8601String(),
        patient.gender,
        patient.bloodGroup,
        patient.religion,
        patient.occupation,
        patient.photoPath,
        patient.status,
        patient.hospitalId,
        patient.hospitalName,
        patient.updatedAt.toIso8601String(),
        patient.updatedBy,
        patient.id,
      ],
    );
  }

  /// Soft-delete a patient by id.
  Future<void> deletePatient(String id) async {
    final now = DateTime.now().toIso8601String();
    await _db.execute(
      'UPDATE patients SET is_deleted = 1, deleted_at = ? WHERE id = ?',
      [now, id],
    );
  }

  // ── Contacts ────────────────────────────────────────────────────

  Future<List<PatientContact>> getContacts(String patientId) async {
    final rows = await _db.getAll(
      'SELECT * FROM patient_contacts WHERE patient_id = ?',
      [patientId],
    );
    return rows.map(_contactFromRow).toList();
  }

  Future<void> insertContact(PatientContact contact) async {
    await _db.execute(
      '''INSERT INTO patient_contacts (id, patient_id, phone, email, is_emergency)
        VALUES (?, ?, ?, ?, ?)''',
      [contact.id, contact.patientId, contact.phone, contact.email,
       contact.isEmergency ? 1 : 0],
    );
  }

  Future<void> updateContact(PatientContact contact) async {
    await _db.execute(
      'UPDATE patient_contacts SET phone = ?, email = ?, is_emergency = ? WHERE id = ?',
      [contact.phone, contact.email, contact.isEmergency ? 1 : 0, contact.id],
    );
  }

  Future<void> deleteContact(String id) async {
    await _db.execute('DELETE FROM patient_contacts WHERE id = ?', [id]);
  }

  // ── Addresses ───────────────────────────────────────────────────

  Future<List<PatientAddress>> getAddresses(String patientId) async {
    final rows = await _db.getAll(
      'SELECT * FROM patient_addresses WHERE patient_id = ?',
      [patientId],
    );
    return rows.map(_addressFromRow).toList();
  }

  Future<void> insertAddress(PatientAddress address) async {
    await _db.execute(
      '''INSERT INTO patient_addresses (
        id, patient_id, address_type, division, district, upazila,
        union_or_city, village_or_ward, street, post_code, country
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        address.id, address.patientId, address.addressType,
        address.division, address.district, address.upazila,
        address.unionOrCity, address.villageOrWard, address.street,
        address.postCode, address.country,
      ],
    );
  }

  Future<void> updateAddress(PatientAddress address) async {
    await _db.execute(
      '''UPDATE patient_addresses SET address_type = ?, division = ?, district = ?,
        upazila = ?, union_or_city = ?, village_or_ward = ?, street = ?,
        post_code = ?, country = ? WHERE id = ?''',
      [
        address.addressType, address.division, address.district,
        address.upazila, address.unionOrCity, address.villageOrWard,
        address.street, address.postCode, address.country, address.id,
      ],
    );
  }

  Future<void> deleteAddress(String id) async {
    await _db.execute('DELETE FROM patient_addresses WHERE id = ?', [id]);
  }

  // ── Guardians ───────────────────────────────────────────────────

  Future<List<PatientGuardian>> getGuardians(String patientId) async {
    final rows = await _db.getAll(
      'SELECT * FROM patient_guardians WHERE patient_id = ?',
      [patientId],
    );
    return rows.map(_guardianFromRow).toList();
  }

  Future<void> insertGuardian(PatientGuardian guardian) async {
    await _db.execute(
      '''INSERT INTO patient_guardians (
        id, patient_id, full_name, relationship, phone, email, address, is_minor
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        guardian.id, guardian.patientId, guardian.fullName,
        guardian.relationship, guardian.phone, guardian.email,
        guardian.address, guardian.isMinor ? 1 : 0,
      ],
    );
  }

  Future<void> updateGuardian(PatientGuardian guardian) async {
    await _db.execute(
      '''UPDATE patient_guardians SET full_name = ?, relationship = ?,
        phone = ?, email = ?, address = ?, is_minor = ? WHERE id = ?''',
      [
        guardian.fullName, guardian.relationship, guardian.phone,
        guardian.email, guardian.address, guardian.isMinor ? 1 : 0,
        guardian.id,
      ],
    );
  }

  Future<void> deleteGuardian(String id) async {
    await _db.execute('DELETE FROM patient_guardians WHERE id = ?', [id]);
  }

  // ── Assignments ─────────────────────────────────────────────────

  Future<List<PatientAssignment>> getAssignments(String patientId) async {
    final rows = await _db.getAll(
      'SELECT * FROM patient_assignments WHERE patient_id = ?',
      [patientId],
    );
    return rows.map(_assignmentFromRow).toList();
  }

  Future<void> insertAssignment(PatientAssignment assignment) async {
    await _db.execute(
      '''INSERT INTO patient_assignments (
        id, patient_id, user_id, assignment_type, user_name,
        is_active, assigned_by, assigned_at, unassigned_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        assignment.id, assignment.patientId, assignment.userId,
        assignment.assignmentType, assignment.userName,
        assignment.isActive ? 1 : 0, assignment.assignedBy,
        assignment.assignedAt.toIso8601String(),
        assignment.unassignedAt?.toIso8601String(),
      ],
    );
  }

  // ── Status History ──────────────────────────────────────────────

  Future<List<PatientStatusHistory>> getStatusHistory(String patientId) async {
    final rows = await _db.getAll(
      'SELECT * FROM patient_status_history WHERE patient_id = ? ORDER BY changed_at DESC',
      [patientId],
    );
    return rows.map(_statusHistoryFromRow).toList();
  }

  Future<void> insertStatusHistory(PatientStatusHistory entry) async {
    await _db.execute(
      '''INSERT INTO patient_status_history (
        id, patient_id, from_status, to_status, changed_by, reason, changed_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [
        entry.id, entry.patientId, entry.fromStatus, entry.toStatus,
        entry.changedBy, entry.reason, entry.changedAt.toIso8601String(),
      ],
    );
  }

  // ── Notes ───────────────────────────────────────────────────────

  Future<List<PatientNote>> getNotes(String patientId) async {
    final rows = await _db.getAll(
      'SELECT * FROM patient_notes WHERE patient_id = ? ORDER BY created_at DESC',
      [patientId],
    );
    return rows.map(_noteFromRow).toList();
  }

  Future<void> insertNote(PatientNote note) async {
    await _db.execute(
      '''INSERT INTO patient_notes (id, patient_id, note, note_type, author_id, author_name, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [
        note.id, note.patientId, note.note, note.noteType,
        note.authorId, note.authorName, note.createdAt.toIso8601String(),
      ],
    );
  }

  // ── Row mappers ─────────────────────────────────────────────────

  Patient _patientFromRow(Map<String, dynamic> row) => Patient(
        id: row['id'] as String,
        patientId: row['patient_id'] as String? ?? '',
        nationalId: row['national_id'] as String?,
        fullName: row['full_name'] as String? ?? '',
        dateOfBirth: _parseDate(row['date_of_birth'] as String?),
        gender: row['gender'] as String?,
        bloodGroup: row['blood_group'] as String?,
        religion: row['religion'] as String?,
        occupation: row['occupation'] as String?,
        photoPath: row['photo_path'] as String?,
        status: row['status'] as String? ?? 'DRAFT',
        hospitalId: row['hospital_id'] as String?,
        hospitalName: row['hospital_name'] as String?,
        createdAt: _parseDateTime(row['created_at'] as String?),
        updatedAt: _parseDateTime(row['updated_at'] as String?),
        createdBy: row['created_by'] as String?,
        updatedBy: row['updated_by'] as String?,
        deletedAt: _parseDateTime(row['deleted_at'] as String?),
        deletedBy: row['deleted_by'] as String?,
        isDeleted: (row['is_deleted'] as int?) == 1,
      );

  PatientContact _contactFromRow(Map<String, dynamic> row) => PatientContact(
        id: row['id'] as String,
        patientId: row['patient_id'] as String? ?? '',
        phone: row['phone'] as String?,
        email: row['email'] as String?,
        isEmergency: (row['is_emergency'] as int?) == 1,
      );

  PatientAddress _addressFromRow(Map<String, dynamic> row) => PatientAddress(
        id: row['id'] as String,
        patientId: row['patient_id'] as String? ?? '',
        addressType: row['address_type'] as String? ?? 'PRESENT',
        division: row['division'] as String?,
        district: row['district'] as String?,
        upazila: row['upazila'] as String?,
        unionOrCity: row['union_or_city'] as String?,
        villageOrWard: row['village_or_ward'] as String?,
        street: row['street'] as String?,
        postCode: row['post_code'] as String?,
        country: row['country'] as String? ?? 'Bangladesh',
      );

  PatientGuardian _guardianFromRow(Map<String, dynamic> row) => PatientGuardian(
        id: row['id'] as String,
        patientId: row['patient_id'] as String? ?? '',
        fullName: row['full_name'] as String? ?? '',
        relationship: row['relationship'] as String?,
        phone: row['phone'] as String?,
        email: row['email'] as String?,
        address: row['address'] as String?,
        isMinor: (row['is_minor'] as int?) == 1,
      );

  PatientAssignment _assignmentFromRow(Map<String, dynamic> row) =>
      PatientAssignment(
        id: row['id'] as String,
        patientId: row['patient_id'] as String? ?? '',
        userId: row['user_id'] as String? ?? '',
        assignmentType: row['assignment_type'] as String? ?? '',
        userName: row['user_name'] as String?,
        isActive: (row['is_active'] as int?) == 1,
        assignedBy: row['assigned_by'] as String?,
        assignedAt: _parseDateTime(row['assigned_at'] as String?) ?? DateTime.now(),
        unassignedAt: _parseDateTime(row['unassigned_at'] as String?),
      );

  PatientStatusHistory _statusHistoryFromRow(Map<String, dynamic> row) =>
      PatientStatusHistory(
        id: row['id'] as String,
        patientId: row['patient_id'] as String? ?? '',
        fromStatus: row['from_status'] as String?,
        toStatus: row['to_status'] as String? ?? '',
        changedBy: row['changed_by'] as String?,
        reason: row['reason'] as String?,
        changedAt: _parseDateTime(row['changed_at'] as String?) ?? DateTime.now(),
      );

  PatientNote _noteFromRow(Map<String, dynamic> row) => PatientNote(
        id: row['id'] as String,
        patientId: row['patient_id'] as String? ?? '',
        note: row['note'] as String? ?? '',
        noteType: row['note_type'] as String? ?? 'GENERAL',
        authorId: row['author_id'] as String?,
        authorName: row['author_name'] as String?,
        createdAt: _parseDateTime(row['created_at'] as String?) ?? DateTime.now(),
      );

  DateTime? _parseDate(String? iso) {
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }

  DateTime? _parseDateTime(String? iso) {
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }
}
