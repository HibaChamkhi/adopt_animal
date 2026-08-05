import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Uploads images to Firebase Storage and returns their download URLs.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadAnimalPhoto(File file, String uid) async {
    final name = "${DateTime.now().microsecondsSinceEpoch}.jpg";
    final ref = _storage.ref().child("animals/$uid/$name");
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Uploads several files; skips any that fail so one bad file
  /// doesn't block the whole listing.
  Future<List<String>> uploadAnimalPhotos(List<File> files, String uid) async {
    final urls = <String>[];
    for (final f in files) {
      try {
        urls.add(await uploadAnimalPhoto(f, uid));
      } catch (_) {}
    }
    return urls;
  }
}
