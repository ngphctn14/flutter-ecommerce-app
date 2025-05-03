import 'package:flutter/cupertino.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisExtent: 16
      ),
      itemCount: 2,
    );
  }
}
