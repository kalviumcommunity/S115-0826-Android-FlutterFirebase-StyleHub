import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exceptions.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage({
    required String uid,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.profileImagesPath)
          .child('$uid.jpg');
      
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );
      
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw FirestoreException('Failed to upload profile image: $e');
    }
  }

  Future<String> uploadServiceImage({
    required String serviceId,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.serviceImagesPath)
          .child('$serviceId.jpg');
      
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );
      
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw FirestoreException('Failed to upload service image: $e');
    }
  }
}
