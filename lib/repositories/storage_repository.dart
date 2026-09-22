import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String uid, dynamic fileBytesOrFile) async {
    final ref = _storage.ref().child('customers/$uid/profile.jpg');
    
    UploadTask uploadTask;

    if (kIsWeb) {
      uploadTask = ref.putData(fileBytesOrFile as Uint8List, SettableMetadata(contentType: 'image/jpeg'));
    } else {
      uploadTask = ref.putFile(fileBytesOrFile as File, SettableMetadata(contentType: 'image/jpeg'));
    }

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
