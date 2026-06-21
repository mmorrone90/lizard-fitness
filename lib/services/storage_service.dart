import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadAvatar(String uid, File file) async {
    final ref = _storage.ref('avatars/$uid/avatar.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<String> uploadProgressPhoto(String uid, File file, String photoId) async {
    final ref = _storage.ref('progress_photos/$uid/$photoId.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<void> deleteProgressPhoto(String uid, String photoId) async {
    try {
      await _storage.ref('progress_photos/$uid/$photoId.jpg').delete();
    } catch (_) {}
  }
}
