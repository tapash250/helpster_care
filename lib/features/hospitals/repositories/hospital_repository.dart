import 'package:helpster_care/shared/models/hospital.dart';
import 'package:helpster_care/shared/models/department.dart';
import 'package:helpster_care/shared/models/ward.dart';
import 'package:helpster_care/shared/models/bed.dart';
import 'package:helpster_care/features/hospitals/models/hospital_filter.dart';
import 'package:helpster_care/features/hospitals/datasources/remote/hospital_remote_datasource.dart';
import 'package:helpster_care/features/hospitals/datasources/local/hospital_local_datasource.dart';

/// Repository that coordinates remote and local data sources for hospitals.
///
/// Implements an offline-first strategy: fetch from remote on app start,
/// cache locally, and serve from local cache when offline.
class HospitalRepository {
  HospitalRepository({
    HospitalRemoteDataSource? remoteDataSource,
    HospitalLocalDataSource? localDataSource,
  })  : _remote = remoteDataSource ?? HospitalRemoteDataSource(),
        _local = localDataSource ?? HospitalLocalDataSource();

  final HospitalRemoteDataSource _remote;
  final HospitalLocalDataSource _local;

  // ---------------------------------------------------------------------------
  // Hospitals
  // ---------------------------------------------------------------------------

  /// Fetch hospitals — remote first with local cache fallback.
  Future<List<Hospital>> fetchHospitals({HospitalFilter? filter}) async {
    try {
      final hospitals = await _remote.fetchHospitals(filter: filter);
      // Cache asynchronously (fire-and-forget)
      unawaitedCache(_local.cacheHospitals(hospitals));
      return hospitals;
    } catch (_) {
      // Offline fallback: return cached data
      return _local.getCachedHospitals();
    }
  }

  /// Fetch a single hospital by ID.
  Future<Hospital?> fetchHospitalById(String id) async {
    try {
      final hospital = await _remote.fetchHospitalById(id);
      return hospital;
    } catch (_) {
      return _local.getCachedHospitalById(id);
    }
  }

  /// Create a new hospital.
  Future<Hospital> createHospital(Hospital hospital) async {
    final created = await _remote.createHospital(hospital);
    _local.cacheHospitals([created]);
    return created;
  }

  /// Update an existing hospital.
  Future<Hospital> updateHospital(Hospital hospital) async {
    final updated = await _remote.updateHospital(hospital);
    _local.cacheHospitals([updated]);
    return updated;
  }

  /// Deactivate a hospital.
  Future<void> deactivateHospital(String id) async {
    await _remote.deactivateHospital(id);
  }

  /// Delete a hospital permanently.
  Future<void> deleteHospital(String id) async {
    await _remote.deleteHospital(id);
  }

  // ---------------------------------------------------------------------------
  // Departments
  // ---------------------------------------------------------------------------

  /// Fetch departments for a hospital.
  Future<List<Department>> fetchDepartments(String hospitalId) async {
    try {
      final departments = await _remote.fetchDepartments(hospitalId);
      unawaitedCache(_local.cacheDepartments(hospitalId, departments));
      return departments;
    } catch (_) {
      return _local.getCachedDepartments(hospitalId);
    }
  }

  /// Create a department.
  Future<Department> createDepartment(Department dept) async {
    return _remote.createDepartment(dept);
  }

  /// Update a department.
  Future<Department> updateDepartment(Department dept) async {
    return _remote.updateDepartment(dept);
  }

  /// Delete a department.
  Future<void> deleteDepartment(String id) async {
    await _remote.deleteDepartment(id);
  }

  // ---------------------------------------------------------------------------
  // Wards
  // ---------------------------------------------------------------------------

  /// Fetch wards for a hospital.
  Future<List<Ward>> fetchWards(String hospitalId,
      {String? departmentId}) async {
    try {
      final wards =
          await _remote.fetchWards(hospitalId, departmentId: departmentId);
      unawaitedCache(_local.cacheWards(hospitalId, wards));
      return wards;
    } catch (_) {
      return _local.getCachedWards(hospitalId);
    }
  }

  /// Create a ward.
  Future<Ward> createWard(Ward ward) async {
    return _remote.createWard(ward);
  }

  /// Update a ward.
  Future<Ward> updateWard(Ward ward) async {
    return _remote.updateWard(ward);
  }

  /// Delete a ward.
  Future<void> deleteWard(String id) async {
    await _remote.deleteWard(id);
  }

  // ---------------------------------------------------------------------------
  // Beds
  // ---------------------------------------------------------------------------

  /// Fetch beds, optionally filtered.
  Future<List<Bed>> fetchBeds({String? wardId, String? hospitalId}) async {
    try {
      final beds = await _remote.fetchBeds(wardId: wardId, hospitalId: hospitalId);
      unawaitedCache(_local.cacheBeds(beds));
      return beds;
    } catch (_) {
      return _local.getCachedBeds(wardId: wardId);
    }
  }

  /// Create a bed.
  Future<Bed> createBed(Bed bed) async {
    return _remote.createBed(bed);
  }

  /// Update a bed.
  Future<Bed> updateBed(Bed bed) async {
    return _remote.updateBed(bed);
  }

  /// Delete a bed.
  Future<void> deleteBed(String id) async {
    await _remote.deleteBed(id);
  }

  // ---------------------------------------------------------------------------
  // OT Schedules
  // ---------------------------------------------------------------------------

  /// Fetch OT schedules for a hospital.
  Future<List<Map<String, dynamic>>> fetchOTSchedules(String hospitalId) async {
    return _remote.fetchOTSchedules(hospitalId);
  }

  /// Fire-and-forget cache operation (no await).
  void unawaitedCache(Future<void> future) {
    future.ignore();
  }
}
