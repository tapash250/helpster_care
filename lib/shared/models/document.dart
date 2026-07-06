import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

/// Document category.
@freezed
class DocumentCategory with _$DocumentCategory {
  const factory DocumentCategory({
    required String code,
    required String label,
    String? description,
    @Default(0) int sortOrder,
  }) = _DocumentCategory;

  factory DocumentCategory.fromJson(Map<String, dynamic> json) =>
      _$DocumentCategoryFromJson(json);
}

/// Document metadata (binary files in Supabase Storage).
@freezed
class Document with _$Document {
  const factory Document({
    required String id,
    required String patientId,
    String? categoryId,
    String? categoryLabel,
    required String title,
    String? description,
    required String storagePath,
    String? checksum,
    @Default(0) int sizeBytes,
    String? mimeType,
    @Default(false) bool isVerified,
    String? verifiedBy,
    DateTime? verifiedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? createdBy,
    @Default(false) bool isDeleted,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);
}

/// Document version.
@freezed
class DocumentVersion with _$DocumentVersion {
  const factory DocumentVersion({
    required String id,
    required String documentId,
    required int versionNum,
    required String storagePath,
    String? checksum,
    @Default(0) int sizeBytes,
    String? uploadedBy,
    required DateTime createdAt,
  }) = _DocumentVersion;

  factory DocumentVersion.fromJson(Map<String, dynamic> json) =>
      _$DocumentVersionFromJson(json);
}
