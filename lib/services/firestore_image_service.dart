import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore Image Service for storing Base64 compressed images
/// Images are stored as Base64 strings in Firestore documents
class FirestoreImageService {
  static final FirestoreImageService _instance = FirestoreImageService._internal();
  factory FirestoreImageService() => _instance;
  FirestoreImageService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collectionName = 'images';

  /// Upload compressed Base64 image to Firestore
  /// Returns the document ID
  Future<String?> uploadImageBase64(String base64String, {String? productId}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check size (Firestore has 1MB limit per document)
      final base64Bytes = utf8.encode(base64String);
      if (base64Bytes.length > 900000) { // ~900KB to leave room for metadata
        throw Exception('Image too large. Please use a smaller image (max ~900KB when compressed)');
      }

      final imageData = {
        'base64': base64String,
        'created_at': FieldValue.serverTimestamp(),
        'user_id': user.uid,
        if (productId != null) 'product_id': productId,
      };

      final docRef = await _firestore.collection(_collectionName).add(imageData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to upload image to Firestore: ${e.toString()}');
    }
  }

  /// Get Base64 image string from Firestore by document ID
  Future<String?> getImageBase64(String documentId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(documentId).get();
      
      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      return data?['base64'] as String?;
    } catch (e) {
      throw Exception('Failed to get image from Firestore: ${e.toString()}');
    }
  }

  /// Update existing image document in Firestore
  Future<void> updateImageBase64(String documentId, String base64String) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check size
      final base64Bytes = utf8.encode(base64String);
      if (base64Bytes.length > 900000) {
        throw Exception('Image too large. Please use a smaller image (max ~900KB when compressed)');
      }

      await _firestore.collection(_collectionName).doc(documentId).update({
        'base64': base64String,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update image in Firestore: ${e.toString()}');
    }
  }

  /// Delete image document from Firestore
  Future<void> deleteImage(String documentId) async {
    try {
      await _firestore.collection(_collectionName).doc(documentId).delete();
    } catch (e) {
      // Log error but don't throw - image might not exist
      print('Failed to delete image from Firestore: ${e.toString()}');
    }
  }

  /// Get image document reference (for batch operations)
  DocumentReference getImageDocumentRef(String documentId) {
    return _firestore.collection(_collectionName).doc(documentId);
  }
}

