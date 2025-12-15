import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image/image.dart' as img;

/// Image Compressor Utility
/// Resizes and compresses images to 300-500px width for Base64 storage in Firestore
class ImageCompressor {
  /// Target width for compression (300-500px)
  static const int targetWidth = 400;
  
  /// Maximum width allowed
  static const int maxWidth = 500;
  
  /// Minimum width allowed
  static const int minWidth = 300;
  
  /// JPEG quality (0-100, lower = smaller file size)
  static const int jpegQuality = 75;

  /// Compress and resize image file to Base64 string
  /// Returns Base64 encoded string of compressed image
  static Future<String> compressImageToBase64(File imageFile) async {
    try {
      // Read image file
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate new dimensions maintaining aspect ratio
      final aspectRatio = originalImage.width / originalImage.height;
      int newWidth = targetWidth;
      int newHeight = (targetWidth / aspectRatio).round();

      // Ensure dimensions are within limits
      if (newWidth > maxWidth) {
        newWidth = maxWidth;
        newHeight = (maxWidth / aspectRatio).round();
      } else if (newWidth < minWidth) {
        newWidth = minWidth;
        newHeight = (minWidth / aspectRatio).round();
      }

      // Resize image
      final resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Convert to JPEG and compress
      final jpegBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: jpegQuality),
      );

      // Encode to Base64
      final base64String = base64Encode(jpegBytes);

      // Verify size (Firestore has 1MB limit, we'll use ~900KB as safety margin)
      if (base64String.length > 900000) {
        // If still too large, compress more aggressively
        final moreCompressed = img.encodeJpg(resizedImage, quality: 50);
        final compressedBase64 = base64Encode(moreCompressed);
        
        if (compressedBase64.length > 900000) {
          // Last resort: reduce quality further
          final finalCompressed = img.encodeJpg(resizedImage, quality: 30);
          return base64Encode(finalCompressed);
        }
        
        return compressedBase64;
      }

      return base64String;
    } catch (e) {
      throw Exception('Failed to compress image: ${e.toString()}');
    }
  }

  /// Compress image from bytes to Base64 string
  static Future<String> compressImageBytesToBase64(Uint8List imageBytes) async {
    try {
      final originalImage = img.decodeImage(imageBytes);
      
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate new dimensions maintaining aspect ratio
      final aspectRatio = originalImage.width / originalImage.height;
      int newWidth = targetWidth;
      int newHeight = (targetWidth / aspectRatio).round();

      // Ensure dimensions are within limits
      if (newWidth > maxWidth) {
        newWidth = maxWidth;
        newHeight = (maxWidth / aspectRatio).round();
      } else if (newWidth < minWidth) {
        newWidth = minWidth;
        newHeight = (minWidth / aspectRatio).round();
      }

      // Resize image
      final resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Convert to JPEG and compress
      final jpegBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: jpegQuality),
      );

      // Encode to Base64
      final base64String = base64Encode(jpegBytes);

      // Verify size
      if (base64String.length > 900000) {
        final moreCompressed = img.encodeJpg(resizedImage, quality: 50);
        final compressedBase64 = base64Encode(moreCompressed);
        
        if (compressedBase64.length > 900000) {
          final finalCompressed = img.encodeJpg(resizedImage, quality: 30);
          return base64Encode(finalCompressed);
        }
        
        return compressedBase64;
      }

      return base64String;
    } catch (e) {
      throw Exception('Failed to compress image: ${e.toString()}');
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

