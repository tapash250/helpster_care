/// Remote persistence for patient data via Supabase REST API.
///
/// Used for remote-only operations such as image upload, cross-device
/// validation, and admin-level operations that bypass the local sync.
library;

import 'package:helpster_care/core/services/supabase_service.dart';
import 'package:helpster_care/shared/models/models.dart';

/// Datasource for remote patient operations via Supabase REST.
class PatientRemoteDatasource {
  PatientRemoteDatasource({required SupabaseService supabase})
      : _client = supabase.client;

  final SupabaseClient _client;

  // ── Patients ────────────────────────────────────────────────────

  /// Upsert a patient to Supabase (bypasses local sync).
  Future<void> upsertPatient(Patient patient) async {
    await _client.from('patients').upsert({
      'id': patient.id,
      'patient_id': patient.patientId,
      'national_id': patient.nationalId,
      'full_name': patient.fullName,
      'date_of_birth': patient.dateOfBirth?.toIso8601String(),
      'gender': patient.gender,
      'blood_group': patient.bloodGroup,
      'religion': patient.religion,
      'occupation': patient.occupation,
      'photo_path': patient.photoPath,
      'status': patient.status,
      'hospital_id': patient.hospitalId,
      'hospital_name': patient.hospitalName,
      'created_at': patient.createdAt.toIso8601String(),
      'updated_at': patient.updatedAt.toIso8601String(),
      'created_by': patient.createdBy,
      'updated_by': patient.updatedBy,
      'is_deleted': patient.isDeleted ? 1 : 0,
      'deleted_at': patient.deletedAt?.toIso8601String(),
      'deleted_by': patient.deletedBy,
    });
  }

  /// Soft-delete a patient on remote.
  Future<void> deletePatient(String id) async {
    final now = DateTime.now().toIso8601String();
    await _client
        .from('patients')
        .update({'is_deleted': 1, 'deleted_at': now})
        .eq('id', id);
  }

  // ── Related data operations ─────────────────────────────────────

  /// Upsert a patient contact.
  Future<void> upsertContact(PatientContact contact) async {
    await _client.from('patient_contacts').upsert({
      'id': contact.id,
      'patient_id': contact.patientId,
      'phone': contact.phone,
      'email': contact.email,
      'is_emergency': contact.isEmergency ? 1 : 0,
    });
  }

  /// Upsert a patient address.
  Future<void> upsertAddress(PatientAddress address) async {
    await _client.from('patient_addresses').upsert({
      'id': address.id,
      'patient_id': address.patientId,
      'address_type': address.addressType,
      'division': address.division,
      'district': address.district,
      'upazila': address.upazila,
      'union_or_city': address.unionOrCity,
      'village_or_ward': address.villageOrWard,
      'street': address.street,
      'post_code': address.postCode,
      'country': address.country,
    });
  }

  /// Upsert a patient guardian.
  Future<void> upsertGuardian(PatientGuardian guardian) async {
    await _client.from('patient_guardians').upsert({
      'id': guardian.id,
      'patient_id': guardian.patientId,
      'full_name': guardian.fullName,
      'relationship': guardian.relationship,
      'phone': guardian.phone,
      'email': guardian.email,
      'address': guardian.address,
      'is_minor': guardian.isMinor ? 1 : 0,
    });
  }

  /// Upload a patient photo and return the public URL.
  Future<String?> uploadPhoto({
    required String patientId,
    required String filePath,
    required String mimeType,
  }) async {
    final bytes = await _client.storage.from('patient-photos').upload(
          '$patientId/${DateTime.now().millisecondsSinceEpoch}',
          _fileToBytes(filePath),
          fileOptions: FileOptions(contentType: mimeType),
        );

    final publicUrl = _client.storage
        .from('patient-photos')
        .getPublicUrl('$patientId/${DateTime.now().millisecondsSinceEpoch}');

    return publicUrl;
  }

  /// Upload raw photo bytes to Supabase storage.
  Future<String> upsertPhotoBytes({
    required String path,
    required List<int> bytes,
    required String mimeType,
  }) async {
    await _client.storage.from('patient-photos').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );
    final publicUrl = _client.storage
        .from('patient-photos')
        .getPublicUrl(path);
    return publicUrl;
  }

  /// Delete a patient photo from storage.
  Future<void> deletePhoto(String path) async {
    await _client.storage.from('patient-photos').remove([path]);
  }
}
