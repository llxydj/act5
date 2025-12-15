import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

/// Image Compressor Utility
/// Converts images to Base64 strings for storage in Firestore
/// Since images are typically small (~150KB), we skip compression to avoid errors
class ImageCompressor {
  /// Maximum Base64 string length (Firestore has 1MB limit, we use ~900KB as safety margin)
  static const int maxBase64Length = 900000;

  /// Convert image file to Base64 string
  /// Returns Base64 encoded string of image
  /// Note: No compression is applied since images are typically small
  static Future<String> compressImageToBase64(File imageFile) async {
    try {
      // Read image file directly
      final imageBytes = await imageFile.readAsBytes();
      
      // Check file size before encoding (Base64 increases size by ~33%)
      final estimatedBase64Size = (imageBytes.length * 1.33).round();
      if (estimatedBase64Size > maxBase64Length) {
        throw Exception('Image file is too large. Maximum size is approximately ${(maxBase64Length / 1.33 / 1024).round()}KB');
      }

      // Encode to Base64 directly without compression
      final base64String = base64Encode(imageBytes);
      
      // Final size check
      if (base64String.length > maxBase64Length) {
        throw Exception('Encoded image is too large for Firestore. Please use a smaller image.');
      }

      return base64String;
    } catch (e) {
      // Re-throw with more context if it's already our custom exception
      if (e.toString().contains('too large')) {
        rethrow;
      }
      throw Exception('Failed to process image: ${e.toString()}');
    }
  }

  /// Convert image from bytes to Base64 string
  /// Returns Base64 encoded string of image
  /// Note: No compression is applied since images are typically small
  static Future<String> compressImageBytesToBase64(Uint8List imageBytes) async {
    try {
      // Check file size before encoding (Base64 increases size by ~33%)
      final estimatedBase64Size = (imageBytes.length * 1.33).round();
      if (estimatedBase64Size > maxBase64Length) {
        throw Exception('Image file is too large. Maximum size is approximately ${(maxBase64Length / 1.33 / 1024).round()}KB');
      }

      // Encode to Base64 directly without compression
      final base64String = base64Encode(imageBytes);
      
      // Final size check
      if (base64String.length > maxBase64Length) {
        throw Exception('Encoded image is too large for Firestore. Please use a smaller image.');
      }

      return base64String;
    } catch (e) {
      // Re-throw with more context if it's already our custom exception
      if (e.toString().contains('too large')) {
        rethrow;
      }
      throw Exception('Failed to process image: ${e.toString()}');
    }
  }

  /// Get estimated size of Base64 string in bytes
  static int getBase64Size(String base64String) {
    return utf8.encode(base64String).length;
  }

  /// Check if Base64 string is within Firestore limits
  static bool isWithinFirestoreLimit(String base64String) {
    return getBase64Size(base64String) <= 900000; // ~900KB safety margin
  }
}

