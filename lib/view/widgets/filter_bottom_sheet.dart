import 'package:flutter/material.dart';
import '../../models/Category.dart';
import '../../models/Brand.dart';
import '../../services/category_service.dart';
import '../../services/brand_service.dart';
import '../../utils/app_textstyles.dart';
import 'package:get/get.dart';

class FilterBottomSheet {
  static Future<void> show(
      BuildContext context, {
        required int selectedCategoryId,
        required int selectedBrandId,
        required Function({
        required int selectedCategoryId,
        required int selectedBrandId,
        double? minPrice,
        double? maxPrice,
        }) onApply,
      }) async {

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final minPriceController = TextEditingController();
    final maxPriceController = TextEditingController();
    int categoryId = selectedCategoryId;
    int brandId = selectedBrandId;

    // Fetch categories & brands
    final categories = await CategoryService.fetchCategories();
    final brands = await BrandService.fetchBrands();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Products',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h3,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Price Range', style: AppTextStyle.withColor(
                  AppTextStyle.bodyLarge,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minPriceController,
                        decoration: InputDecoration(
                          labelText: 'Min',
                          suffixText: ' VNĐ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: maxPriceController,
                        decoration: InputDecoration(
                          labelText: 'Max',
                          suffixText: ' VNĐ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Category', style: AppTextStyle.withColor(
                  AppTextStyle.bodyLarge,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                )),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: categoryId == 0,
                      onSelected: (_) => setState(() => categoryId = 0),
                      backgroundColor: Theme.of(context).cardColor,
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                    ...categories.map((c) => FilterChip(
                      label: Text(c.name ?? ''),
                      selected: categoryId == c.id,
                      onSelected: (_) => setState(() => categoryId = c.id!),
                      backgroundColor: Theme.of(context).cardColor,
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    )),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Brand', style: AppTextStyle.withColor(
                  AppTextStyle.bodyLarge,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                )),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: brandId == 0,
                      onSelected: (_) => setState(() => brandId = 0),
                      backgroundColor: Theme.of(context).cardColor,
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                    ...brands.map((b) => FilterChip(
                      label: Text(b.name),
                      selected: brandId == b.id,
                      onSelected: (_) => setState(() => brandId = b.id),
                      backgroundColor: Theme.of(context).cardColor,
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    )),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final min = double.tryParse(minPriceController.text);
                      final max = double.tryParse(maxPriceController.text);
                      onApply(
                        selectedCategoryId: categoryId,
                        selectedBrandId: brandId,
                        minPrice: min,
                        maxPrice: max,
                      );
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Apply Filters', style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium, Colors.white,
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
