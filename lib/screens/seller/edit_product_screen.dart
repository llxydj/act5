import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../controllers/product_controller.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../utils/image_compressor.dart';

/// Edit Product Screen
class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String? _selectedCategoryId;
  String? _imageBase64; // For preview
  String? _firestoreImageId; // Firestore document ID
  File? _imageFile;
  bool _isActive = true;
  bool _isLoading = true;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadProduct();
    context.read<ProductController>().fetchCategories();
  }

  Future<void> _loadProduct() async {
    final product = await context
        .read<ProductController>()
        .fetchProductById(widget.productId);

    if (product != null && mounted) {
      setState(() {
        _nameController.text = product.name;
        _descriptionController.text = product.description;
        _priceController.text = product.price.toString();
        _stockController.text = product.stockQuantity.toString();
        _selectedCategoryId = product.categoryId;
        _firestoreImageId = product.firestoreImageId;
        _imageBase64 = product.imageBase64; // Legacy fallback
        _isActive = product.isActive;
        _isLoading = false;
      });
      
      // If we have Firestore image ID, fetch the Base64 for preview
      if (_firestoreImageId != null && _firestoreImageId!.isNotEmpty) {
        try {
          final base64 = await _storageService.getProductImageBase64(_firestoreImageId!);
          if (base64 != null && mounted) {
            setState(() {
              _imageBase64 = base64;
            });
          }
        } catch (e) {
          print('Failed to load image from Firestore: $e');
        }
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      try {
        // Compress image immediately for preview
        final compressedBase64 = await ImageCompressor.compressImageToBase64(
          File(pickedFile.path),
        );
        
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBase64 = compressedBase64; // For preview
          _firestoreImageId = null; // Will be updated after upload
        });
      } catch (e) {
        if (!mounted) return;
        Helpers.showSnackBar(
          context,
          'Failed to process image: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Upload new image to Firestore if image file is selected
    String? firestoreImageId = _firestoreImageId;
    if (_imageFile != null) {
      if (!mounted) return;
      Helpers.showSnackBar(context, 'Uploading image to Firestore...', isSuccess: false);
      
      try {
        if (firestoreImageId != null && firestoreImageId.isNotEmpty) {
          // Update existing image
          await _storageService.updateProductImage(firestoreImageId, _imageFile!);
        } else {
          // Upload new image
          firestoreImageId = await _storageService.uploadProductImage(_imageFile!);
          if (firestoreImageId == null) {
            if (!mounted) return;
            Helpers.showSnackBar(
              context,
              'Failed to upload image',
              isError: true,
            );
            return;
          }
        }
      } catch (e) {
        if (!mounted) return;
        Helpers.showSnackBar(
          context,
          'Failed to upload image: ${e.toString()}',
          isError: true,
        );
        return;
      }
    }

    final success = await context.read<ProductController>().updateProduct(
          productId: widget.productId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          stockQuantity: int.parse(_stockController.text),
          categoryId: _selectedCategoryId,
          firestoreImageId: firestoreImageId,
          isActive: _isActive,
        );

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(
        context,
        'Product updated successfully',
        isSuccess: true,
      );
      Navigator.pop(context);
    } else {
      Helpers.showSnackBar(
        context,
        context.read<ProductController>().error ?? 'Failed to update product',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Edit Product'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const LoadingWidget(message: 'Loading product...'),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              const Text(
                'Product Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: _imageBase64 != null && _imageBase64!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            base64Decode(_imageBase64!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                          ),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
              const SizedBox(height: 24),

              // Active Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Row(
                  children: [
                    Icon(
                      _isActive ? Icons.check_circle : Icons.pause_circle,
                      color:
                          _isActive ? AppTheme.successColor : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _isActive ? 'Active - Visible to buyers' : 'Inactive',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isActive,
                      activeColor: AppTheme.successColor,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Product Name
              CustomTextField(
                controller: _nameController,
                labelText: 'Product Name',
                hintText: 'Enter product name',
                prefixIcon: Icons.shopping_bag_outlined,
                validator: (value) =>
                    Validators.required(value, fieldName: 'Product name'),
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Enter product description',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
                validator: (value) =>
                    Validators.required(value, fieldName: 'Description'),
              ),
              const SizedBox(height: 16),

              // Price and Stock Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      labelText: 'Price (\$)',
                      hintText: '0.00',
                      prefixIcon: Icons.attach_money,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: Validators.price,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      labelText: 'Stock',
                      hintText: '0',
                      prefixIcon: Icons.inventory_outlined,
                      keyboardType: TextInputType.number,
                      validator: Validators.stockQuantity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              Consumer<ProductController>(
                builder: (context, controller, _) => CustomDropdown<String>(
                  value: _selectedCategoryId,
                  labelText: 'Category (Optional)',
                  prefixIcon: Icons.category_outlined,
                  items: controller.categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Consumer<ProductController>(
                builder: (context, controller, _) => PrimaryButton(
                  text: 'Update Product',
                  icon: Icons.save_outlined,
                  isLoading: controller.isLoading,
                  onPressed: _handleSubmit,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to change image',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

