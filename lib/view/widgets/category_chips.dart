import 'package:flutter/material.dart';

import '../../models/Category.dart';
import '../../services/category_service.dart';
import '../../utils/app_textstyles.dart';

class CategoryChips extends StatefulWidget {
  final Function(int?) onCategorySelected;
  final int selectedCategoryId; // Thêm tham số này

  const CategoryChips({
    super.key,
    required this.onCategorySelected,
    required this.selectedCategoryId,
  });

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    try {
      final fetched = await CategoryService.fetchCategories();
      setState(() {
        categories = [Category(id: -1, name: "All"), ...fetched]; // Giữ nút "All"
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return categories.isEmpty
        ? CircularProgressIndicator()
        : SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(categories.length, (index) {
          final category = categories[index];
          // Chip được chọn khi selectedCategoryId khớp với category.id ("All" là 0)
          final isSelected = widget.selectedCategoryId == (category.id == -1 ? 0 : category.id);
          return Padding(
            padding: EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                category.name,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isDark
                      ? Colors.grey[300]
                      : Colors.grey[600],
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                widget.onCategorySelected(category.id == -1 ? 0 : category.id);
              },
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }),
      ),
    );
  }
}