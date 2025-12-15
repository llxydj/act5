import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../config/theme.dart';

/// Widget to display images from Firestore Base64 storage
/// Handles fetching from Firestore and decoding Base64
class FirestoreImageWidget extends StatefulWidget {
  final String? firestoreImageId;
  final String? imageBase64; // Legacy fallback
  final String? imageUrl; // Legacy fallback (Firebase Storage)
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const FirestoreImageWidget({
    super.key,
    this.firestoreImageId,
    this.imageBase64,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<FirestoreImageWidget> createState() => _FirestoreImageWidgetState();
}

class _FirestoreImageWidgetState extends State<FirestoreImageWidget> {
  String? _loadedBase64;
  bool _isLoading = false;
  bool _hasError = false;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(FirestoreImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firestoreImageId != widget.firestoreImageId) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    // Priority 1: Use legacy Base64 if available (for immediate display)
    if (widget.imageBase64 != null && widget.imageBase64!.isNotEmpty) {
      setState(() {
        _loadedBase64 = widget.imageBase64;
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    // Priority 2: Fetch from Firestore if firestoreImageId is provided
    if (widget.firestoreImageId != null && widget.firestoreImageId!.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      try {
        final base64 = await _storageService.getProductImageBase64(widget.firestoreImageId!);
        if (mounted) {
          setState(() {
            _loadedBase64 = base64;
            _isLoading = false;
            _hasError = base64 == null;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } else {
      // No image available
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ?? _buildDefaultPlaceholder();
    }

    if (_hasError || _loadedBase64 == null || _loadedBase64!.isEmpty) {
      return widget.errorWidget ?? _buildDefaultError();
    }

    try {
      return Image.memory(
        base64Decode(_loadedBase64!),
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? _buildDefaultError();
        },
      );
    } catch (e) {
      return widget.errorWidget ?? _buildDefaultError();
    }
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade100,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: widget.width != null && widget.width! < 100 ? 32 : 48,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}

