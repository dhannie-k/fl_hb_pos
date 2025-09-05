import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constans/app_colors.dart';
import '../../../domain/entities/category.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_event.dart';
import '../../bloc/category/category_state.dart';

class EditCategoryDialog extends StatefulWidget {
  final Category category;

  const EditCategoryDialog({super.key, required this.category});

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  Category? _selectedParentCategory;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryOperationSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is CategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final parentCategories = _getParentCategoriesFromState(state);
        final isUpdating = state is CategoryUpdating;

        // Initialize selected parent category once we have the data
        if (!_isInitialized && parentCategories.isNotEmpty) {
          _initializeSelectedParent(parentCategories);
          _isInitialized = true;
        }

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: AppColors.accent),
              SizedBox(width: 8),
              Text('Edit Category'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Name Field
                  TextFormField(
                    controller: _nameController,
                    enabled: !isUpdating,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      prefixIcon: Icon(Icons.category, size: 20),
                      helperText: 'Enter a unique category name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Category name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Category name must be at least 2 characters';
                      }
                      if (value.trim().length > 50) {
                        return 'Category name must be less than 50 characters';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Parent Category Dropdown
                  DropdownButtonFormField<Category>(
                    initialValue: _selectedParentCategory,
                    decoration: InputDecoration(
                      labelText: 'Parent Category',
                      prefixIcon: Icon(Icons.account_tree, size: 20),
                      helperText: 'Optional: Select a parent category',
                    ),
                    items: [
                      DropdownMenuItem<Category>(
                        value: null,
                        child: Row(
                          children: [
                            Icon(Icons.home, size: 16, color: AppColors.textSecondary),
                            SizedBox(width: 8),
                            Text(
                              'None (Top Level)',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ...parentCategories
                          .where((c) => c.id != widget.category.id) // Can't be parent of itself
                          .map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Row(
                            children: [
                              Icon(Icons.folder, size: 16, color: AppColors.accent),
                              SizedBox(width: 8),
                              Expanded(child: Text(category.name)),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: isUpdating ? null : (Category? value) {
                      setState(() {
                        _selectedParentCategory = value;
                      });
                    },
                    isExpanded: true,
                  ),
                  
                  if (isUpdating) ...[
                    SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Updating category...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUpdating ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton.icon(
              onPressed: isUpdating ? null : _updateCategory,
              icon: isUpdating 
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.save),
              label: Text(isUpdating ? 'Updating...' : 'Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        );
      },
    );
  }

  void _initializeSelectedParent(List<Category> parentCategories) {
    if (widget.category.parentId != null) {
      try {
        _selectedParentCategory = parentCategories.firstWhere(
          (c) => c.id == widget.category.parentId,
        );
      } catch (e) {
        // Parent not found, leave as null
        _selectedParentCategory = null;
      }
    }
  }

  List<Category> _getParentCategoriesFromState(CategoryState state) {
    if (state is CategoriesLoaded) return state.parentCategories;
    if (state is CategoryOperationSuccess) return state.parentCategories;
    return [];
  }

  void _updateCategory() {
    if (_formKey.currentState!.validate()) {
      final trimmedName = _nameController.text.trim();
      
      // Check if anything actually changed
      bool hasChanges = trimmedName != widget.category.name ||
                       _selectedParentCategory?.id != widget.category.parentId;
      
      if (!hasChanges) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No changes detected'),
            backgroundColor: AppColors.info,
          ),
        );
        return;
      }

      context.read<CategoryBloc>().add(
        UpdateCategory(
          id: widget.category.id,
          name: trimmedName,
          parentId: _selectedParentCategory?.id,
        ),
      );
    }
  }
}