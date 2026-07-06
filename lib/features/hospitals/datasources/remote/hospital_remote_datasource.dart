import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:helpster_care/core/services/supabase_service.dart';
import 'package:helpster_care/shared/models/hospital.dart';
import 'package:helpster_care/shared/models/department.dart';
import 'package:helpster_care/shared/models/ward.dart';
import 'package:helpster_care/shared/models/bed.dart';
import 'package:helpster_care/features/hospitals/models/hospital_filter.dart';

/// Supabase-backed remote data source for hospitals.
///
/// Handles all CRUD operations and related entity queries.
class HospitalRemoteDataSource {
  HospitalRemoteDataSource({SupabaseService? supabaseService})
      : _supabase = supabaseService ?? SupabaseService.instance;

  final SupabaseService _supabase;

  SupabaseClient get _client => _supabase.client;

  // ---------------------------------------------------------------------------
  // Hospitals
  // ---------------------------------------------------------------------------

  /// Fetch all hospitals (optionally filtered).
  Future<List<Hospital>> fetchHospitals({HospitalFilter? filter}) async {
    var query = _client
        .from('hospitals')
        .select()
        .order(
          filter?.sortBy ?? 'name',
          ascending: filter?.sortAscending ?? true,
        );

    if (filter?.statusFilter != null) {
      query = query.eq('is_active', filter!.statusFilter == 'active');
    }

    if (filter?.searchQuery != null && filter!.searchQuery.isNotEmpty) {
      query = query.or(
        'name.ilike.%${filter.searchQuery}%,'
        'address.ilike.%${filter.searchQuery}%,'
        'phone.ilike.%${filter.searchQuery}%',
      );
    }

    final result = await query;
    return result.map((json) => Hospital.fromJson(json)).toList();
  }

  /// Fetch a single hospital by ID.
  Future<Hospital?> fetchHospitalById(String id) async {
    final result = await _client
        .from('hospitals')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (result == null) return null;
    return Hospital.fromJson(result);
  }

  /// Create a new hospital.
  Future<Hospital> createHospital(Hospital hospital) async {
    final result = await _client
        .from('hospitals')
        .insert(hospital.toJson()..remove('id'))
        .select()
        .single();
    return Hospital.fromJson(result);
  }

  /// Update an existing hospital.
  Future<Hospital> updateHospital(Hospital hospital) async {
    final result = await _client
        .from('hospitals')
        .update(hospital.toJson())
        .eq('id', hospital.id)
        .select()
        .single();
    return Hospital.fromJson(result);
  }

  /// Soft-delete (deactivate) a hospital.
  Future<void> deactivateHospital(String id) async {
    await _client
        .from('hospitals')
        .update({'is_active': false, 'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }

  /// Hard-delete a hospital.
  Future<void> deleteHospital(String id) async {
    await _client.from('hospitals').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Departments
  // ---------------------------------------------------------------------------

  /// Fetch departments for a hospital.
  Future<List<Department>> fetchDepartments(String hospitalId) async {
    final result = await _client
        .from('departments')
        .select()
        .eq('hospital_id', hospitalId)
        .eq('is_active', true)
        .order('name');
    return result.map((json) => Department.fromJson(json)).toList();
  }

  /// Create a department.
  Future<Department> createDepartment(Department dept) async {
    final result = await _client
        .from('departments')
        .insert(dept.toJson()..remove('id'))
        .select()
        .single();
    return Department.fromJson(result);
  }

  /// Update a department.
  Future<Department> updateDepartment(Department dept) async {
    final result = await _client
        .from('departments')
        .update(dept.toJson())
        .eq('id', dept.id)
        .select()
        .single();
    return Department.fromJson(result);
  }

  /// Delete a department.
  Future<void> deleteDepartment(String id) async {
    await _client.from('departments').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Wards
  // ---------------------------------------------------------------------------

  /// Fetch wards for a hospital (optionally filtered by department).
  Future<List<Ward>> fetchWards(String hospitalId, {String? departmentId}) async {
    var query = _client
        .from('wards')
        .select()
        .eq('hospital_id', hospitalId)
        .eq('is_active', true)
        .order('name');

    if (departmentId != null) {
      query = query.eq('department_id', departmentId);
    }

    final result = await query;
    return result.map((json) => Ward.fromJson(json)).toList();
  }

  /// Create a ward.
  Future<Ward> createWard(Ward ward) async {
    final result = await _client
        .from('wards')
        .insert(ward.toJson()..remove('id'))
        .select()
        .single();
    return Ward.fromJson(result);
  }

  /// Update a ward.
  Future<Ward> updateWard(Ward ward) async {
    final result = await _client
        .from('wards')
        .update(ward.toJson())
        .eq('id', ward.id)
        .select()
        .single();
    return Ward.fromJson(result);
  }

  /// Delete a ward.
  Future<void> deleteWard(String id) async {
    await _client.from('wards').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Beds
  // ---------------------------------------------------------------------------

  /// Fetch beds, optionally filtered by ward.
  Future<List<Bed>> fetchBeds({String? wardId, String? hospitalId}) async {
    var query = _client
        .from('beds')
        .select()
        .order('bed_number');

    if (wardId != null) query = query.eq('ward_id', wardId);
    if (hospitalId != null) query = query.eq('hospital_id', hospitalId);

    final result = await query;
    return result.map((json) => Bed.fromJson(json)).toList();
  }

  /// Create a bed.
  Future<Bed> createBed(Bed bed) async {
    final result = await _client
        .from('beds')
        .insert(bed.toJson()..remove('id'))
        .select()
        .single();
    return Bed.fromJson(result);
  }

  /// Update a bed.
  Future<Bed> updateBed(Bed bed) async {
    final result = await _client
        .from('beds')
        .update(bed.toJson())
        .eq('id', bed.id)
        .select()
        .single();
    return Bed.fromJson(result);
  }

  /// Delete a bed.
  Future<void> deleteBed(String id) async {
    await _client.from('beds').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // OT Schedules (Operating Theatres)
  // ---------------------------------------------------------------------------

  /// Fetch OT schedules for a hospital.
  Future<List<Map<String, dynamic>>> fetchOTSchedules(String hospitalId) async {
    final result = await _client
        .from('ot_schedules')
        .select('''
          id,
          theatre_room,
          patient_id,
          procedure,
          scheduled_start,
          scheduled_end,
          status,
          primary_surgeon_name
        ''')
        .eq('hospital_id', hospitalId)
        .order('scheduled_start');
    return result;
  }
}
