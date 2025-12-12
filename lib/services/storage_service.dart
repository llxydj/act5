import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Storage Service for Firebase Storage operations
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload product image to Firebase Storage
  /// Returns the download URL
  Future<String?> uploadProductImage(File imageFile, {String? productId}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = productId != null
          ? 'products/$productId/${timestamp}_${imageFile.path.split('/').last}'
          : 'products/${user.uid}/${timestamp}_${imageFile.path.split('/').last}';

      // Create reference
      final ref = _storage.ref().child(fileName);

      // Upload file
      final uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  /// Upload product image from bytes
  /// Returns the download URL
  Future<String?> uploadProductImageFromBytes(
    List<int> imageBytes,
    String fileName, {
    String? productId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageFileName = productId != null
          ? 'products/$productId/${timestamp}_$fileName'
          : 'products/${user.uid}/${timestamp}_$fileName';

      // Create reference
      final ref = _storage.ref().child(storageFileName);

      // Upload file
      final uploadTask = ref.putData(
        Uint8List.fromList(imageBytes),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  /// Delete product image from Firebase Storage
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments.last;
      
      // Get reference and delete
      final ref = _storage.ref().child('products/$path');
      await ref.delete();
    } catch (e) {
      // Log error but don't throw - image might not exist
      print('Failed to delete image: ${e.toString()}');
    }
  }
}

