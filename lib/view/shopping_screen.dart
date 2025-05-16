import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/models/Product.dart';
import 'package:flutter_ecommerce_app/services/category_service.dart';
import 'package:flutter_ecommerce_app/services/product_service.dart';
import 'package:flutter_ecommerce_app/view/widgets/custom_search_bar.dart';
import 'package:flutter_ecommerce_app/view/widgets/filter_bottom_sheet.dart';
import 'package:flutter_ecommerce_app/view/widgets/product_grid.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  List<Product> products = [];
  int currentPage = 0;
  bool isLoading = false;
  bool hasMore = true;
  String searchQuery = '';
  int selectedBrandId = 0;
  int selectedCategoryId = 0;
  double? minPrice;
  double? maxPrice;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
    loadProducts(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!isLoading &&
        hasMore &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      loadProducts();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = searchController.text.trim();
      });
      loadProducts(reset: true);
    });
  }

  Future<void> loadProducts({bool reset = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (reset) {
        currentPage = 0;
        hasMore = true;
        products.clear();
      }

      final newProducts = await ProductService.fetchPagedProducts(
        page: currentPage,
        size: 10,
        categoryId: selectedCategoryId == 0 ? null : selectedCategoryId,
        brandId: selectedBrandId == 0 ? null : selectedBrandId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        keyword: searchQuery.isEmpty ? null : searchQuery,
      );

      setState(() {
        products.addAll(newProducts);
        currentPage++;
        hasMore = newProducts.isNotEmpty;
      });
    } catch (e) {
      print("Error loading products: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> openFilter() async {
    final categories = await CategoryService.fetchCategories();
    FilterBottomSheet.show(
      context,
      selectedCategoryId: selectedCategoryId,
      selectedBrandId: selectedBrandId,
      onApply: ({
        required int selectedCategoryId,
        required int selectedBrandId,
        double? minPrice,
        double? maxPrice,
      }) {
        setState(() {
          this.selectedCategoryId = selectedCategoryId;
          this.selectedBrandId = selectedBrandId;
          this.minPrice = minPrice;
          this.maxPrice = maxPrice;
        });
        loadProducts(reset: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          SafeArea(
            child: CustomSearchBar(
              controller: searchController,
              onFilterTap: openFilter,
              onChanged: (text) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  setState(() {
                    searchQuery = text.trim();
                  });
                  loadProducts(reset: true);
                });
              },
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                ProductGrid(
                  products: products,
                  scrollController: _scrollController,
                ),
                if (isLoading)
                  const Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
