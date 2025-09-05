import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constans/app_colors.dart';
import '../../../domain/entities/category.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_event.dart';
import '../../bloc/category/category_state.dart';

class CategoryTab extends StatefulWidget {
  const CategoryTab({super.key});

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Category? _selectedParentCategory;
  
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  
  @override
  void initState() {
    super.initState();
    // Load categories when widget initializes
    context.read<CategoryBloc>().add(LoadCategories());
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          // Clear form after successful operation
          _nameController.clear();
          _selectedParentCategory = null;
        } else if (state is CategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Category Form
            _buildAddCategoryForm(),
            SizedBox(height: 32),
            
            // Categories List Header
            _buildListHeader(),
            SizedBox(height: 16),
            
            // Categories List
            Expanded(
              child: _buildCategoriesList(),
            ),
            
            // Pagination
            _buildPagination(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddCategoryForm() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final isLoading = state is CategoryCreating;
        final parentCategories = _getParentCategoriesFromState(state);
        
        return Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  Row(
                    children: [
                      // Category Name Field
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _nameController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            labelText: 'Category Name',
                            hintText: 'Enter category name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.accent),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.error),
                            ),
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
                        ),
                      ),
                      
                      SizedBox(width: 16),
                      
                      // Parent Category Dropdown
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<Category>(
                          initialValue: _selectedParentCategory,
                          decoration: InputDecoration(
                            labelText: 'Parent Category (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.accent),
                            ),
                          ),
                          items: [
                            DropdownMenuItem<Category>(
                              value: null,
                              child: Text(
                                'None (Top Level)',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                            ...parentCategories.map((category) {
                              return DropdownMenuItem<Category>(
                                value: category,
                                child: Text(category.name),
                              );
                            }),
                          ],
                          onChanged: isLoading ? null : (Category? value) {
                            setState(() {
                              _selectedParentCategory = value;
                            });
                          },
                        ),
                      ),
                      
                      SizedBox(width: 16),
                      
                      // Add Button
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _addCategory,
                        icon: isLoading 
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.add),
                        label: Text(isLoading ? 'Adding...' : 'Add Category'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListHeader() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = _getCategoriesFromState(state);
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                Text(
                  'Total: ${categories.length}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    context.read<CategoryBloc>().add(RefreshCategories());
                  },
                  icon: Icon(Icons.refresh),
                  tooltip: 'Refresh Categories',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildCategoriesList() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return _buildLoadingState();
        }
        
        if (state is CategoryError) {
          return _buildErrorState(state.message);
        }
        
        final categories = _getCategoriesFromState(state);
        final paginatedCategories = _getPaginatedCategories(categories);
        
        if (categories.isEmpty) {
          return _buildEmptyState();
        }
        
        return Card(
          elevation: 2,
          child: Column(
            children: [
              // Table Header
              _buildTableHeader(),
              
              // Table Body
              Expanded(
                child: ListView.builder(
                  itemCount: paginatedCategories.length,
                  itemBuilder: (context, index) {
                    final category = paginatedCategories[index];
                    return _buildCategoryRow(category, categories);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.accent),
          SizedBox(height: 16),
          Text(
            'Loading categories...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          SizedBox(height: 16),
          Text(
            'Error loading categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<CategoryBloc>().add(LoadCategories());
            },
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 16),
          Text(
            'No Categories Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first category using the form above',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Category Name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Parent Category',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Sub-categories',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 100), // Space for actions
        ],
      ),
    );
  }

  Widget _buildCategoryRow(Category category, List<Category> allCategories) {
    final parentCategory = _getParentCategory(category.parentId, allCategories);
    final subCategoriesCount = _getSubCategoriesCount(category.id, allCategories);
    
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final isDeleting = state is CategoryDeleting;
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 1),
            ),
            color: isDeleting ? AppColors.error.withValues(alpha: 0.1) : null,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    if (category.parentId != null) ...[
                      SizedBox(width: 20),
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: category.parentId == null 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  parentCategory?.name ?? '-',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '$subCategoriesCount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isDeleting) ...[
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ] else ...[
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          _handleCategoryAction(value, category);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'add_product',
                            child: Row(
                              children: [
                                Icon(Icons.add, size: 18),
                                SizedBox(width: 8),
                                Text('Add Product'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          if (subCategoriesCount == 0) // Only allow delete if no subcategories
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                        ],
                        child: Icon(
                          Icons.more_vert,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPagination() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = _getCategoriesFromState(state);
        final totalPages = (categories.length / _itemsPerPage).ceil();
        
        if (totalPages <= 1) return SizedBox();
        
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
                icon: Icon(Icons.chevron_left),
              ),
              ...List.generate(totalPages, (index) {
                final pageNumber = index + 1;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: TextButton(
                    onPressed: () => _goToPage(pageNumber),
                    style: TextButton.styleFrom(
                      backgroundColor: _currentPage == pageNumber 
                        ? AppColors.accent 
                        : Colors.transparent,
                      foregroundColor: _currentPage == pageNumber 
                        ? Colors.white 
                        : AppColors.textSecondary,
                    ),
                    child: Text('$pageNumber'),
                  ),
                );
              }),
              IconButton(
                onPressed: _currentPage < totalPages ? () => _goToPage(_currentPage + 1) : null,
                icon: Icon(Icons.chevron_right),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Helper methods
  List<Category> _getCategoriesFromState(CategoryState state) {
    if (state is CategoriesLoaded) return state.categories;
    if (state is CategoryOperationSuccess) return state.categories;
    return [];
  }

  List<Category> _getParentCategoriesFromState(CategoryState state) {
    if (state is CategoriesLoaded) return state.parentCategories;
    if (state is CategoryOperationSuccess) return state.parentCategories;
    return [];
  }
  
  Category? _getParentCategory(int? parentId, List<Category> categories) {
    if (parentId == null) return null;
    try {
      return categories.firstWhere((c) => c.id == parentId);
    } catch (e) {
      return null;
    }
  }
  
  int _getSubCategoriesCount(int categoryId, List<Category> categories) {
    return categories.where((c) => c.parentId == categoryId).length;
  }
  
  List<Category> _getPaginatedCategories(List<Category> categories) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return categories.sublist(
      startIndex, 
      endIndex > categories.length ? categories.length : endIndex,
    );
  }
  
  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }
  
  void _addCategory() {
    if (_formKey.currentState!.validate()) {
      context.read<CategoryBloc>().add(
        CreateCategory(
          name: _nameController.text.trim(),
          parentId: _selectedParentCategory?.id,
        ),
      );
    }
  }
  
  void _handleCategoryAction(String action, Category category) {
    switch (action) {
      case 'add_product':
        // TODO: Navigate to add product form with category pre-selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigate to Add Product for ${category.name}')),
        );
        break;
      case 'edit':
        _showEditCategoryDialog(category);
        break;
      case 'delete':
        _showDeleteConfirmation(category);
        break;
    }
  }
  
  void _showEditCategoryDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => EditCategoryDialog(category: category),
    );
  }
  
  void _showDeleteConfirmation(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CategoryBloc>().add(DeleteCategory(category.id));
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// Edit Category Dialog Widget
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    // We'll set the selected parent after we get the parent categories from BLoC
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final parentCategories = _getParentCategoriesFromState(state);
        final isUpdating = state is CategoryUpdating;

        // Set initial parent category if not set yet
        if (_selectedParentCategory == null && widget.category.parentId != null) {
          try {
            _selectedParentCategory = parentCategories.firstWhere(
              (c) => c.id == widget.category.parentId,
            );
          } catch (e) {
            // Parent not found, leave as null
          }
        }

        return AlertDialog(
          title: Text('Edit Category'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    enabled: !isUpdating,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<Category>(
                    initialValue: _selectedParentCategory,
                    decoration: InputDecoration(
                      labelText: 'Parent Category (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      DropdownMenuItem<Category>(
                        value: null,
                        child: Text(
                          'None (Top Level)',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      ...parentCategories
                          .where((c) => c.id != widget.category.id) // Can't be parent of itself
                          .map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }),
                    ],
                    onChanged: isUpdating ? null : (Category? value) {
                      setState(() {
                        _selectedParentCategory = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUpdating ? null : () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUpdating ? null : _updateCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: isUpdating 
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Update'),
            ),
          ],
        );
      },
    );
  }

  List<Category> _getParentCategoriesFromState(CategoryState state) {
    if (state is CategoriesLoaded) return state.parentCategories;
    if (state is CategoryOperationSuccess) return state.parentCategories;
    return [];
  }

  void _updateCategory() {
    if (_formKey.currentState!.validate()) {
      context.read<CategoryBloc>().add(
        UpdateCategory(
          id: widget.category.id,
          name: _nameController.text.trim(),
          parentId: _selectedParentCategory?.id,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}