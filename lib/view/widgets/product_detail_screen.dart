import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/Product.dart';
import '../../models/ProductVariant.dart';
import '../../models/Review.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<List<ProductVariant>> futureVariants;
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  int selectedIndex = 0;

  late WebSocketChannel channel;
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    futureVariants = fetchProductVariants(widget.product.id);

    // Kết nối WebSocket
    channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080/ws/reviews/${widget.product.id}'),
    );

    // Lắng nghe dữ liệu đánh giá
    channel.stream.listen((data) {
      final review = Review.fromJson(jsonDecode(data));
      setState(() {
        reviews.insert(0, review);
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  Future<List<ProductVariant>> fetchProductVariants(int productId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/v1/productVariants/$productId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((item) => ProductVariant.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load product variants');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: FutureBuilder<List<ProductVariant>>(
        future: futureVariants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không có phiên bản nào."));
          }

          final variants = snapshot.data!;
          final productVariant = variants[selectedIndex];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh sản phẩm
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    itemCount: productVariant.images.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          productVariant.images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Tên phiên bản
                Text(
                  productVariant.variantName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                // Giá
                Text(
                  currencyFormatter.format(productVariant.priceDiff),
                  style: const TextStyle(fontSize: 20, color: Colors.green),
                ),

                const SizedBox(height: 12),

                // Mô tả
                Text(
                  widget.product.description ?? 'Không có mô tả.',
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 20),

                // Chọn phiên bản
                const Text("Chọn phiên bản:", style: TextStyle(fontSize: 16)),
                DropdownButton<int>(
                  value: selectedIndex,
                  items: List.generate(variants.length, (index) {
                    return DropdownMenuItem(
                      value: index,
                      child: Text(variants[index].variantName),
                    );
                  }),
                  onChanged: (index) {
                    setState(() {
                      selectedIndex = index!;
                    });
                  },
                ),

                const SizedBox(height: 30),

                // Đánh giá
                const Text("Đánh giá sản phẩm:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                if (reviews.isEmpty)
                  const Text("Chưa có đánh giá nào.")
                else
                  Column(
                    children: reviews.map((r) => ReviewCard(review: r)).toList(),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(review.username[0].toUpperCase()),
        ),
        title: Text(review.username),
        subtitle: Text(review.comment),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
                (index) => Icon(
              index < review.rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
