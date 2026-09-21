import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage;
  
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadCustomerProfilePhoto(String uid, File file) async {
    final ref = _storage.ref('customers/$uid/profile.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<String> uploadCustomerProfilePhotoBytes(String uid, Uint8List bytes, String ext) async {
    final ref = _storage.ref('customers/$uid/profile.$ext');
    await ref.putData(bytes);
    return ref.getDownloadURL();
  }

  Future<String> uploadStylistPhoto(String stylistId, File file) async {
    final ref = _storage.ref('stylists/$stylistId/photo.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<String> uploadBranchImage(String branchId, File file) async {
    final ref = _storage.ref('branches/$branchId/image.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> deleteFile(String path) async {
    await _storage.ref(path).delete();
  }
}
