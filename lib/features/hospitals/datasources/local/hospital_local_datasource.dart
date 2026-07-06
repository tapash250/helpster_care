import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:helpster_care/shared/models/hospital.dart';
import 'package:helpster_care/shared/models/department.dart';
import 'package:helpster_care/shared/models/ward.dart';
import 'package:helpster_care/shared/models/bed.dart';

/// Local (secure storage + in-memory) data source for hospitals.
///
/// Provides offline caching for hospital-related entities.
/// Uses [FlutterSecureStorage] for persistent caching and an in-memory
/// map for fast access during the session.
class HospitalLocalDataSource {
  HospitalLocalDataSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  // In-memory cache
  final Map<String, Hospital> _hospitalCache = {};
  final Map<String, List<Department>> _departmentCache = {};
  final Map<String, List<Ward>> _wardCache = {};
  final Map<String, List<Bed>> _bedCache = {};

  static const _hospitalsKey = 'cached_hospitals';
  static const _departmentsPrefix = 'cached_departments_';
  static const _wardsPrefix = 'cached_wards_';
  static const _bedsPrefix = 'cached_beds_';

  // ---------------------------------------------------------------------------
  // Hospitals
  // ---------------------------------------------------------------------------

  /// Cache hospitals in memory and secure storage.
  Future<void> cacheHospitals(List<Hospital> hospitals) async {
    for (final h in hospitals) {
      _hospitalCache[h.id] = h;
    }
    final json = hospitals.map((h) => h.toJson()).toList();
    await _storage.write(key: _hospitalsKey, value: jsonEncode(json));
  }

  /// Retrieve cached hospitals from memory (or secure storage fallback).
  Future<List<Hospital>> getCachedHospitals() async {
    if (_hospitalCache.isNotEmpty) {
      return _hospitalCache.values.toList();
    }
    final stored = await _storage.read(key: _hospitalsKey);
    if (stored == null) return [];
    final list = jsonDecode(stored) as List;
    final hospitals = list.map((e) => Hospital.fromJson(e)).toList();
    for (final h in hospitals) {
      _hospitalCache[h.id] = h;
    }
    return hospitals;
  }

  /// Get a single hospital from cache.
  Hospital? getCachedHospitalById(String id) => _hospitalCache[id];

  // ---------------------------------------------------------------------------
  // Departments
  // ---------------------------------------------------------------------------

  /// Cache departments for a hospital.
  Future<void> cacheDepartments(
      String hospitalId, List<Department> departments) async {
    _departmentCache[hospitalId] = departments;
    final json = departments.map((d) => d.toJson()).toList();
    await _storage.write(
      key: '$_departmentsPrefix$hospitalId',
      value: jsonEncode(json),
    );
  }

  /// Retrieve cached departments for a hospital.
  Future<List<Department>> getCachedDepartments(String hospitalId) async {
    if (_departmentCache.containsKey(hospitalId)) {
      return _departmentCache[hospitalId]!;
    }
    final stored = await _storage.read(key: '$_departmentsPrefix$hospitalId');
    if (stored == null) return [];
    final list = jsonDecode(stored) as List;
    final departments = list.map((e) => Department.fromJson(e)).toList();
    _departmentCache[hospitalId] = departments;
    return departments;
  }

  // ---------------------------------------------------------------------------
  // Wards
  // ---------------------------------------------------------------------------

  /// Cache wards for a hospital.
  Future<void> cacheWards(String hospitalId, List<Ward> wards) async {
    _wardCache[hospitalId] = wards;
    final json = wards.map((w) => w.toJson()).toList();
    await _storage.write(
      key: '$_wardsPrefix$hospitalId',
      value: jsonEncode(json),
    );
  }

  /// Retrieve cached wards for a hospital.
  Future<List<Ward>> getCachedWards(String hospitalId) async {
    if (_wardCache.containsKey(hospitalId)) {
      return _wardCache[hospitalId]!;
    }
    final stored = await _storage.read(key: '$_wardsPrefix$hospitalId');
    if (stored == null) return [];
    final list = jsonDecode(stored) as List;
    final wards = list.map((e) => Ward.fromJson(e)).toList();
    _wardCache[hospitalId] = wards;
    return wards;
  }

  // ---------------------------------------------------------------------------
  // Beds
  // ---------------------------------------------------------------------------

  /// Cache all beds.
  Future<void> cacheBeds(List<Bed> beds) async {
    _bedCache['all'] = beds;
    final json = beds.map((b) => b.toJson()).toList();
    await _storage.write(key: _bedsPrefix, value: jsonEncode(json));
  }

  /// Retrieve cached beds.
  Future<List<Bed>> getCachedBeds({String? wardId}) async {
    List<Bed> beds;
    if (_bedCache.containsKey('all') && _bedCache['all']!.isNotEmpty) {
      beds = _bedCache['all']!;
    } else {
      final stored = await _storage.read(key: _bedsPrefix);
      if (stored == null) return [];
      final list = jsonDecode(stored) as List;
      beds = list.map((e) => Bed.fromJson(e)).toList();
      _bedCache['all'] = beds;
    }

    if (wardId != null) {
      beds = beds.where((b) => b.wardId == wardId).toList();
    }
    return beds;
  }

  /// Clear all cached data.
  Future<void> clearAll() async {
    _hospitalCache.clear();
    _departmentCache.clear();
    _wardCache.clear();
    _bedCache.clear();
    await _storage.delete(key: _hospitalsKey);
    // Prefix deletes not supported by FlutterSecureStorage — keys will
    // be overwritten on next cache. For a full clear, delete all known keys.
    await _storage.deleteAll();
  }
}
