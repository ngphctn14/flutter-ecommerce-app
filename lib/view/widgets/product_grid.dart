import 'package:flutter/material.dart';
import '../../models/Product.dart';
import 'product_detail_screen.dart'; // Đảm bảo bạn có màn hình chi tiết sản phẩm

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final ScrollController? scrollController;

  const ProductGrid({
    Key? key,
    required this.products,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(child: Text("No products found."));
    }

    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(context, product); // Chuyển context vào
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        // Điều hướng đến màn hình chi tiết sản phẩm khi nhấn
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: Image.network(product.image, fit: BoxFit.cover),
            ),
            Text(product.name),
            Text('${product.price} VND'),
          ],
        ),
      ),
    );
  }
}
