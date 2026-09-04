import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../core/app_exceptions.dart';
import '../core/constants.dart';

/// Service Layer: Handles Firebase Cloud Storage uploads and downloads.
///
/// Per the Layered Architecture (TRD §1), this is the ONLY class that
/// imports `firebase_storage`. All other layers interact with storage
/// through Repository methods that delegate here.
///
/// Design decisions:
/// - Constructor injection of [FirebaseStorage] for testability.
/// - Provides two upload methods: [uploadFile] for mobile (dart:io File)
///   and [uploadBytes] for web (Uint8List). Both return the download URL.
/// - Path generation uses [StoragePaths] constants to enforce consistent
///   directory structure across the app.
/// - Upload metadata includes content type for proper browser rendering.
/// - [deleteFile] is provided for profile photo replacement flows.
class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  // ---------------------------------------------------------------------------
  // Customer Profile Photos
  // ---------------------------------------------------------------------------

  /// Uploads a customer profile photo from a [File] (mobile).
  ///
  /// Storage path: `profile_photos/{uid}/profile.jpg`
  /// Returns the public download URL for storing in the user's Firestore profile.
  Future<String> uploadCustomerProfilePhoto({
    required String uid,
    required File file,
  }) async {
    final path = StoragePaths.customerProfilePhoto(uid);
    return await _uploadFile(path: path, file: file, contentType: 'image/jpeg');
  }

  /// Uploads a customer profile photo from bytes (web / in-memory).
  Future<String> uploadCustomerProfilePhotoBytes({
    required String uid,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final path = StoragePaths.customerProfilePhoto(uid);
    return await _uploadBytes(
      path: path,
      bytes: bytes,
      contentType: contentType,
    );
  }

  /// Deletes the customer's profile photo from storage.
  Future<void> deleteCustomerProfilePhoto(String uid) async {
    final path = StoragePaths.customerProfilePhoto(uid);
    await _deleteFile(path);
  }

  // ---------------------------------------------------------------------------
  // Stylist Images
  // ---------------------------------------------------------------------------

  /// Uploads a stylist photo from a [File] (mobile).
  ///
  /// Storage path: `stylist_images/{stylistId}/photo.jpg`
  /// Returns the public download URL.
  Future<String> uploadStylistPhoto({
    required String stylistId,
    required File file,
  }) async {
    final path = StoragePaths.stylistPhoto(stylistId);
    return await _uploadFile(path: path, file: file, contentType: 'image/jpeg');
  }

  /// Uploads a stylist photo from bytes (web / in-memory).
  Future<String> uploadStylistPhotoBytes({
    required String stylistId,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final path = StoragePaths.stylistPhoto(stylistId);
    return await _uploadBytes(
      path: path,
      bytes: bytes,
      contentType: contentType,
    );
  }

  /// Deletes a stylist's photo from storage.
  Future<void> deleteStylistPhoto(String stylistId) async {
    final path = StoragePaths.stylistPhoto(stylistId);
    await _deleteFile(path);
  }

  // ---------------------------------------------------------------------------
  // Branch Images
  // ---------------------------------------------------------------------------

  /// Uploads a branch cover image from a [File] (mobile).
  ///
  /// Storage path: `branch_images/{branchId}/cover.jpg`
  /// Returns the public download URL.
  Future<String> uploadBranchImage({
    required String branchId,
    required File file,
  }) async {
    final path = StoragePaths.branchImage(branchId);
    return await _uploadFile(path: path, file: file, contentType: 'image/jpeg');
  }

  /// Deletes a branch's cover image from storage.
  Future<void> deleteBranchImage(String branchId) async {
    final path = StoragePaths.branchImage(branchId);
    await _deleteFile(path);
  }

  // ---------------------------------------------------------------------------
  // Generic Download URL
  // ---------------------------------------------------------------------------

  /// Returns the download URL for a file at the given storage path.
  /// Useful when the URL wasn't cached at upload time.
  Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to retrieve download URL.',
        code: e.code,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Uploads a [File] to the given [path] and returns the download URL.
  Future<String> _uploadFile({
    required String path,
    required File file,
    required String contentType,
  }) async {
    try {
      final ref = _storage.ref(path);
      final metadata = SettableMetadata(contentType: contentType);
      await ref.putFile(file, metadata);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'File upload failed. Please try again.',
        code: e.code,
      );
    }
  }

  /// Uploads raw [bytes] to the given [path] and returns the download URL.
  Future<String> _uploadBytes({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      final ref = _storage.ref(path);
      final metadata = SettableMetadata(contentType: contentType);
      await ref.putData(bytes, metadata);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'File upload failed. Please try again.',
        code: e.code,
      );
    }
  }

  /// Deletes a file at the given [path]. Silently succeeds if not found.
  Future<void> _deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } on FirebaseException catch (e) {
      // object-not-found is expected when deleting a photo that doesn't exist
      if (e.code != 'object-not-found') {
        throw FirestoreException(
          'File deletion failed.',
          code: e.code,
        );
      }
    }
  }
}
