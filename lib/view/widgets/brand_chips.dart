import 'package:flutter/material.dart';
import '../../models/Brand.dart';
import '../../services/brand_service.dart';  // Dịch vụ Brand
import '../../utils/app_textstyles.dart';

class BrandChips extends StatefulWidget {
  final Function(int?) onBrandSelected;
  final int selectedBrandId;  // Thêm tham số này để biết brand nào đang được chọn

  const BrandChips({
    super.key,
    required this.onBrandSelected,
    required this.selectedBrandId,
  });

  @override
  State<BrandChips> createState() => _BrandChipsState();
}

class _BrandChipsState extends State<BrandChips> {
  List<Brand> brands = [];

  @override
  void initState() {
    super.initState();
    loadBrands();
  }

  void loadBrands() async {
    try {
      final fetched = await BrandService.fetchBrands();  // Gọi dịch vụ để lấy danh sách brand
      setState(() {
        brands = [Brand(id: -1, name: "All"), ...fetched];  // Giữ nút "All" để chọn tất cả
      });
    } catch (e) {
      print('Error loading brands: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return brands.isEmpty
        ? CircularProgressIndicator()  // Nếu chưa có dữ liệu, hiển thị loading
        : SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(brands.length, (index) {
          final brand = brands[index];
          // Chip được chọn khi selectedBrandId khớp với brand.id ("All" là 0)
          final isSelected = widget.selectedBrandId == (brand.id == -1 ? 0 : brand.id);
          return Padding(
            padding: EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                brand.name,
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
                widget.onBrandSelected(brand.id == -1 ? 0 : brand.id);  // Truyền brand.id về hàm callback
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
