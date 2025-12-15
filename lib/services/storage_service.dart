import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_image_service.dart';
import '../utils/image_compressor.dart';

/// Storage Service for Firestore Base64 image operations
/// Images are compressed to 300-500px and stored as Base64 strings in Firestore
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreImageService _firestoreImageService = FirestoreImageService();

  /// Upload product image to Firestore as Base64
  /// Returns the Firestore document ID
  Future<String?> uploadProductImage(File imageFile, {String? productId}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Compress and convert to Base64
      final base64String = await ImageCompressor.compressImageToBase64(imageFile);

      // Upload to Firestore
      final documentId = await _firestoreImageService.uploadImageBase64(
        base64String,
        productId: productId,
      );

      return documentId;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  /// Upload product image from bytes to Firestore as Base64
  /// Returns the Firestore document ID
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

      // Compress and convert to Base64
      final base64String = await ImageCompressor.compressImageBytesToBase64(
        Uint8List.fromList(imageBytes),
      );

      // Upload to Firestore
      final documentId = await _firestoreImageService.uploadImageBase64(
        base64String,
        productId: productId,
      );

      return documentId;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  /// Get Base64 image string from Firestore by document ID
  Future<String?> getProductImageBase64(String firestoreImageId) async {
    try {
      return await _firestoreImageService.getImageBase64(firestoreImageId);
    } catch (e) {
      throw Exception('Failed to get image: ${e.toString()}');
    }
  }

  /// Update product image in Firestore
  Future<void> updateProductImage(String firestoreImageId, File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Compress and convert to Base64
      final base64String = await ImageCompressor.compressImageToBase64(imageFile);

      // Update in Firestore
      await _firestoreImageService.updateImageBase64(firestoreImageId, base64String);
    } catch (e) {
      throw Exception('Failed to update image: ${e.toString()}');
    }
  }

  /// Delete product image from Firestore
  Future<void> deleteProductImage(String firestoreImageId) async {
    try {
      await _firestoreImageService.deleteImage(firestoreImageId);
    } catch (e) {
      // Log error but don't throw - image might not exist
      print('Failed to delete image: ${e.toString()}');
    }
  }
}

