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
  final _searchController = TextEditingController();
  Category? _selectedParentCategory;
  
  int _currentPage = 1;
  int _itemsPerPage = 10;
  bool _isFormExpanded = false;
  String _searchQuery = '';
  final Set<int> _expandedCategoryIds = <int>{}; // Track which categories are expanded
  
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
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
          _nameController.clear();
          _selectedParentCategory = null;
          setState(() {
            _isFormExpanded = false;
          });
        } else if (state is CategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Column(
        children: [
          _buildCompactAddSection(),
          _buildListHeader(),
          Expanded(child: _buildCategoriesList()),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildCompactAddSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        children: [
          if (!_isFormExpanded) 
            _buildCollapsedAddButton()
          else
            _buildExpandedAddForm(),
        ],
      ),
    );
  }

  Widget _buildCollapsedAddButton() {
    return Row(
      children: [
        Icon(Icons.category, size: 20, color: AppColors.accent),
        SizedBox(width: 8),
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Spacer(),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isFormExpanded = true;
            });
          },
          icon: Icon(Icons.add, size: 16),
          label: Text('Add Category'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size(0, 32),
            textStyle: TextStyle(fontSize: 13),
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          onPressed: () {
            context.read<CategoryBloc>().add(RefreshCategories());
          },
          icon: Icon(Icons.refresh, size: 18),
          tooltip: 'Refresh Categories',
          padding: EdgeInsets.all(4),
          constraints: BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildExpandedAddForm() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final isLoading = state is CategoryCreating;
        final parentCategories = _getParentCategoriesFromState(state);
        
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.add_circle_outline, size: 18, color: AppColors.accent),
                  SizedBox(width: 8),
                  Text(
                    'Add New Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: isLoading ? null : () {
                      setState(() {
                        _isFormExpanded = false;
                        _nameController.clear();
                        _selectedParentCategory = null;
                      });
                    },
                    icon: Icon(Icons.close, size: 18),
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _nameController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        hintText: 'Enter name',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: AppColors.accent),
                        ),
                      ),
                      style: TextStyle(fontSize: 14),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (value.trim().length < 2) {
                          return 'Min 2 characters';
                        }
                        if (value.trim().length > 50) {
                          return 'Max 50 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<Category>(
                      initialValue: _selectedParentCategory,
                      decoration: InputDecoration(
                        labelText: 'Parent (Optional)',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: AppColors.accent),
                        ),
                      ),
                      style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      items: [
                        DropdownMenuItem<Category>(
                          value: null,
                          child: Text(
                            'None (Top Level)',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                        ...parentCategories.map((category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.name, style: TextStyle(fontSize: 13)),
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
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _addCategory,
                    icon: isLoading 
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.add, size: 16),
                    label: Text(isLoading ? 'Adding...' : 'Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size(0, 36),
                      textStyle: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          final allCategories = _getCategoriesFromState(state);
          final filteredCategories = _getFilteredCategories(allCategories);
          //final topLevelCategories = _getTopLevelCategories(filteredCategories);
          
          return Row(
            children: [
              Text(
                _searchQuery.isEmpty 
                  ? 'All Categories (${allCategories.length})'
                  : 'Found (${filteredCategories.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              
              // Items per page selector
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<int>(
                  value: _itemsPerPage,
                  underline: SizedBox(),
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  items: [5, 10, 20, 50].map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value per page'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _itemsPerPage = value;
                        _currentPage = 1; // Reset to first page
                      });
                    }
                  },
                ),
              ),
              
              SizedBox(width: 12),
              
              // Search field
              SizedBox(
                width: 200,
                height: 32,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    prefixIcon: Icon(Icons.search, size: 16, color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: _clearSearch,
                          icon: Icon(Icons.clear, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                        )
                      : null,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),
                  style: TextStyle(fontSize: 12),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                      _currentPage = 1; // Reset to first page when searching
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
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
        
        final allCategories = _getCategoriesFromState(state);
        final filteredCategories = _getFilteredCategories(allCategories);
        final topLevelCategories = _getTopLevelCategories(filteredCategories);
        final paginatedTopLevelCategories = _getPaginatedTopLevelCategories(topLevelCategories);
        
        if (allCategories.isEmpty) {
          return _buildEmptyState();
        }
        
        if (filteredCategories.isEmpty && _searchQuery.isNotEmpty) {
          return _buildNoSearchResultsState();
        }
        
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16),
          elevation: 1,
          child: Column(
            children: [
              _buildTableHeader(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _calculateTotalVisibleItems(paginatedTopLevelCategories, allCategories),
                  itemBuilder: (context, index) {
                    return _buildHierarchicalCategoryItem(
                      paginatedTopLevelCategories, 
                      allCategories, 
                      index
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHierarchicalCategoryItem(
    List<Category> topLevelCategories, 
    List<Category> allCategories, 
    int flatIndex
  ) {
    // Calculate which category this flat index corresponds to
    int currentIndex = 0;
    
    for (Category topCategory in topLevelCategories) {
      if (currentIndex == flatIndex) {
        return _buildCategoryRow(topCategory, allCategories, 0);
      }
      currentIndex++;
      
      if (_expandedCategoryIds.contains(topCategory.id)) {
        final subCategories = _getSubCategories(topCategory.id, allCategories);
        for (Category subCategory in subCategories) {
          if (currentIndex == flatIndex) {
            return _buildCategoryRow(subCategory, allCategories, 1);
          }
          currentIndex++;
        }
      }
    }
    
    return SizedBox(); // Fallback
  }

  int _calculateTotalVisibleItems(List<Category> topLevelCategories, List<Category> allCategories) {
    int count = topLevelCategories.length;
    for (Category topCategory in topLevelCategories) {
      if (_expandedCategoryIds.contains(topCategory.id)) {
        count += _getSubCategories(topCategory.id, allCategories).length;
      }
    }
    return count;
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.accent, strokeWidth: 3),
          SizedBox(height: 12),
          Text(
            'Loading categories...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            SizedBox(height: 12),
            Text(
              'Error loading categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CategoryBloc>().add(LoadCategories());
              },
              icon: Icon(Icons.refresh, size: 16),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                textStyle: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              'No Categories Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Add your first category using the form above',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResultsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              'No categories found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try adjusting your search query',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 16),
            TextButton.icon(
              onPressed: _clearSearch,
              icon: Icon(Icons.clear, size: 16),
              label: Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                fontSize: 13,
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
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Sub-cats',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(Category category, List<Category> allCategories, int level) {
    final parentCategory = _getParentCategory(category.parentId, allCategories);
    final subCategories = _getSubCategories(category.id, allCategories);
    final subCategoriesCount = subCategories.length;
    final isExpanded = _expandedCategoryIds.contains(category.id);
    final hasSubCategories = subCategoriesCount > 0;
    
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final isDeleting = state is CategoryDeleting;
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
            color: isDeleting ? AppColors.error.withValues(alpha: 0.1) : null,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    // Indentation for hierarchy
                    SizedBox(width: level * 20.0),
                    
                    // Expand/Collapse button for categories with subcategories
                    if (hasSubCategories && level == 0) ...[
                      GestureDetector(
                        onTap: () => _toggleCategoryExpansion(category.id),
                        child: Icon(
                          isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                          size: 16,
                          color: AppColors.accent,
                        ),
                      ),
                      SizedBox(width: 4),
                    ] else if (level > 0) ...[
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6),
                    ] else if (level == 0) ...[
                      // Empty space for top-level categories without subcategories
                      SizedBox(width: 20),
                    ],
                    
                    // Category icon
                    Icon(
                      level == 0 ? Icons.folder : Icons.label,
                      size: 14,
                      color: level == 0 ? AppColors.accent : AppColors.textSecondary,
                    ),
                    SizedBox(width: 6),
                    
                    // Category name
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: level == 0 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  parentCategory?.name ?? (level == 0 ? '-' : ''),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  level == 0 ? '$subCategoriesCount' : '-',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isDeleting) ...[
                      SizedBox(
                        width: 16,
                        height: 16,
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
                            height: 36,
                            child: Row(
                              children: [
                                Icon(Icons.add, size: 16),
                                SizedBox(width: 8),
                                Text('Add Product', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            height: 36,
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 8),
                                Text('Edit', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          if (subCategoriesCount == 0)
                            PopupMenuItem(
                              value: 'delete',
                              height: 36,
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 16, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: AppColors.error, fontSize: 13)),
                                ],
                              ),
                            ),
                        ],
                        child: Icon(
                          Icons.more_vert,
                          color: AppColors.textSecondary,
                          size: 18,
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
        final allCategories = _getCategoriesFromState(state);
        final filteredCategories = _getFilteredCategories(allCategories);
        final topLevelCategories = _getTopLevelCategories(filteredCategories);
        final totalPages = (topLevelCategories.length / _itemsPerPage).ceil();
        
        if (totalPages <= 1) return SizedBox();
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
                icon: Icon(Icons.chevron_left, size: 20),
                padding: EdgeInsets.all(4),
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              ...List.generate(totalPages, (index) {
                final pageNumber = index + 1;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: TextButton(
                    onPressed: () => _goToPage(pageNumber),
                    style: TextButton.styleFrom(
                      backgroundColor: _currentPage == pageNumber 
                        ? AppColors.accent 
                        : Colors.transparent,
                      foregroundColor: _currentPage == pageNumber 
                        ? Colors.white 
                        : AppColors.textSecondary,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size(32, 28),
                      textStyle: TextStyle(fontSize: 12),
                    ),
                    child: Text('$pageNumber'),
                  ),
                );
              }),
              IconButton(
                onPressed: _currentPage < totalPages ? () => _goToPage(_currentPage + 1) : null,
                icon: Icon(Icons.chevron_right, size: 20),
                padding: EdgeInsets.all(4),
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
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

  List<Category> _getFilteredCategories(List<Category> categories) {
    if (_searchQuery.isEmpty) return categories;
    
    return categories.where((category) {
      final nameMatch = category.name.toLowerCase().contains(_searchQuery);
      // You could add more sophisticated search here, like fuzzy search
      return nameMatch;
    }).toList();
  }

  List<Category> _getTopLevelCategories(List<Category> categories) {
    return categories.where((category) => category.parentId == null).toList();
  }

  List<Category> _getPaginatedTopLevelCategories(List<Category> topLevelCategories) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return topLevelCategories.sublist(
      startIndex, 
      endIndex > topLevelCategories.length ? topLevelCategories.length : endIndex,
    );
  }

  List<Category> _getSubCategories(int parentId, List<Category> categories) {
    return categories.where((category) => category.parentId == parentId).toList();
  }
  
  Category? _getParentCategory(int? parentId, List<Category> categories) {
    if (parentId == null) return null;
    try {
      return categories.firstWhere((c) => c.id == parentId);
    } catch (e) {
      return null;
    }
  }
  
  void _toggleCategoryExpansion(int categoryId) {
    setState(() {
      if (_expandedCategoryIds.contains(categoryId)) {
        _expandedCategoryIds.remove(categoryId);
      } else {
        _expandedCategoryIds.add(categoryId);
      }
    });
  }
  
  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }
  
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _currentPage = 1;
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
        title: Text('Delete Category', style: TextStyle(fontSize: 16)),
        content: Text('Are you sure you want to delete "${category.name}"?', style: TextStyle(fontSize: 14)),
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

        if (_selectedParentCategory == null && widget.category.parentId != null) {
          try {
            _selectedParentCategory = parentCategories.firstWhere(
              (c) => c.id == widget.category.parentId,
            );
          } catch (e) {
            // Parent not found
          }
        }

        return AlertDialog(
          title: Text('Edit Category', style: TextStyle(fontSize: 16)),
          content: SizedBox(
            width: 350,
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    style: TextStyle(fontSize: 14),
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
                  SizedBox(height: 12),
                  DropdownButtonFormField<Category>(
                    initialValue: _selectedParentCategory,
                    decoration: InputDecoration(
                      labelText: 'Parent Category (Optional)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    items: [
                      DropdownMenuItem<Category>(
                        value: null,
                        child: Text(
                          'None (Top Level)',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                      ...parentCategories
                          .where((c) => c.id != widget.category.id)
                          .map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name, style: TextStyle(fontSize: 13)),
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: TextStyle(fontSize: 13),
              ),
              child: isUpdating 
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Update'),
            ),
          ],
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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