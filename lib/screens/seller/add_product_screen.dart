import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/product_controller.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_date_picker.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';

/// Add Product Screen
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String? _selectedCategoryId;
  String? _imageBase64; // Legacy support
  String? _imageUrl; // Firebase Storage URL
  File? _imageFile;
  DateTime? _saleEndDate;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    context.read<ProductController>().fetchCategories();
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
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageBase64 = null; // Clear base64 when using Firebase Storage
        _imageUrl = null; // Will be set after upload
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading indicator
    if (!mounted) return;
    Helpers.showSnackBar(context, 'Uploading image...', isSuccess: false);

    String? imageUrl = _imageUrl;

    // Upload image to Firebase Storage if image file is selected
    if (_imageFile != null && imageUrl == null) {
      try {
        imageUrl = await _storageService.uploadProductImage(_imageFile!);
        if (imageUrl == null) {
          if (!mounted) return;
          Helpers.showSnackBar(
            context,
            'Failed to upload image',
            isError: true,
          );
          return;
        }
        setState(() {
          _imageUrl = imageUrl;
        });
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

    // Add product with Firebase Storage URL (preferred) or Base64 (legacy fallback)
    final success = await context.read<ProductController>().addProduct(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          stockQuantity: int.parse(_stockController.text),
          categoryId: _selectedCategoryId,
          imageUrl: imageUrl, // Use Firebase Storage URL
          imageBase64: imageUrl == null ? _imageBase64 : null, // Legacy fallback
          saleEndDate: _saleEndDate,
        );

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(
        context,
        'Product added successfully',
        isSuccess: true,
      );
      Navigator.pop(context);
    } else {
      Helpers.showSnackBar(
        context,
        context.read<ProductController>().error ?? 'Failed to add product',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Add Product'),
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
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add image',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
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
              const SizedBox(height: 16),

              // Sale End Date Picker
              CustomDatePicker(
                selectedDate: _saleEndDate,
                labelText: 'Sale End Date (Optional)',
                hintText: 'Select sale end date',
                prefixIcon: Icons.calendar_today_outlined,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateSelected: (date) {
                  setState(() {
                    _saleEndDate = date;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              Consumer<ProductController>(
                builder: (context, controller, _) => PrimaryButton(
                  text: 'Add Product',
                  icon: Icons.add_box_outlined,
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
}

