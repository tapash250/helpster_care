/// Service for picking patient photos and uploading them to Supabase storage.
library;

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:helpster_care/features/patients/datasources/remote/patient_remote_datasource.dart';

/// Result of a photo operation.
class PhotoOperationResult {
  const PhotoOperationResult({
    this.localPath,
    this.remoteUrl,
    this.error,
  });

  /// Local file path of the picked photo.
  final String? localPath;

  /// Remote URL after successful upload.
  final String? remoteUrl;

  /// Error message if the operation failed.
  final String? error;

  bool get isSuccess => error == null;
}

/// Handles image picking and uploading for patient photos.
class PatientImageService {
  PatientImageService({
    required PatientRemoteDatasource remoteDatasource,
    ImagePicker? imagePicker,
  })  : _remote = remoteDatasource,
        _picker = imagePicker ?? ImagePicker();

  final PatientRemoteDatasource _remote;
  final ImagePicker _picker;

  /// Pick a photo from the gallery.
  Future<PhotoOperationResult> pickFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) {
        return const PhotoOperationResult(error: 'No photo selected');
      }
      return PhotoOperationResult(localPath: picked.path);
    } catch (e) {
      return PhotoOperationResult(error: 'Failed to pick photo: $e');
    }
  }

  /// Take a photo with the camera.
  Future<PhotoOperationResult> takePhoto() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) {
        return const PhotoOperationResult(error: 'No photo taken');
      }
      return PhotoOperationResult(localPath: picked.path);
    } catch (e) {
      return PhotoOperationResult(error: 'Failed to take photo: $e');
    }
  }

  /// Upload a local photo to Supabase storage for the given patient.
  Future<PhotoOperationResult> uploadPhoto({
    required String patientId,
    required String localPath,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) {
        return const PhotoOperationResult(error: 'Photo file not found');
      }

      final bytes = await file.readAsBytes();
      final extension = localPath.split('.').last.toLowerCase();
      final mimeType = _mimeForExtension(extension);

      final remotePath =
          '$patientId/${DateTime.now().millisecondsSinceEpoch}.$extension';

      await _remote.upsertPhotoBytes(
        path: remotePath,
        bytes: bytes,
        mimeType: mimeType,
      );

      // Return the public URL (constructed from the bucket config)
      final publicUrl =
          'patient-photos/$remotePath'; // Supabase storage URL pattern

      return PhotoOperationResult(
        localPath: localPath,
        remoteUrl: publicUrl,
      );
    } catch (e) {
      return PhotoOperationResult(
        localPath: localPath,
        error: 'Failed to upload photo: $e',
      );
    }
  }

  /// Delete a photo from storage.
  Future<void> deletePhoto(String remotePath) async {
    await _remote.deletePhoto(remotePath);
  }

  /// Determine MIME type from file extension.
  String _mimeForExtension(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
