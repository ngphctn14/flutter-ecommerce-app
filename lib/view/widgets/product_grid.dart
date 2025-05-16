import 'package:flutter/material.dart';
import '../../models/Product.dart';
import '../product_detail_screen.dart';

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
      return const Center(child: Text("No products found."));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2; // Mặc định cho điện thoại
        if (constraints.maxWidth >= 900) {
          crossAxisCount = 4; // Web hoặc máy tính bảng lớn
        }

        return GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(context, product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
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
            const SizedBox(height: 8),
            Text(
              product.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text('${product.price} VND'),
          ],
        ),
      ),
    );
  }
}
