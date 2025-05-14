import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/Product.dart';
import '../../models/ProductVariant.dart';
import '../../models/Review.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../services/rating_service.dart';
import '../../models/Rating.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<List<ProductVariant>> futureVariants;
  late Future<List<Rating>> futureRatings;
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  int selectedIndex = 0;

  late WebSocketChannel channel;
  List<Review> reviews = [];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    futureVariants = fetchProductVariants(widget.product.id);
    futureRatings = RatingService.fetchRatings(widget.product.id);
    // WebSocket kết nối nhận đánh giá
    channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080/ws/reviews/${widget.product.id}'),
    );

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
    _timer?.cancel();
    _pageController.dispose();
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

  void startImageAutoScroll(int imageCount) {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % imageCount;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
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

          // Bắt đầu tự cuộn ảnh
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_timer == null || !_timer!.isActive) {
              startImageAutoScroll(productVariant.images.length);
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh sản phẩm
                SizedBox(
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: productVariant.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          productVariant.images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tên phiên bản
                Text(
                  productVariant.variantName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

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
                const Text("Chọn phiên bản:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
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
                      _currentPage = 0;
                      _timer?.cancel();
                      _pageController.jumpToPage(0);
                      startImageAutoScroll(variants[index].images.length);
                    });
                  },
                ),
                FutureBuilder<List<Rating>>(
                  future: futureRatings,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("Chưa có đánh giá sao nào.");
                    }

                    final ratings = snapshot.data!;
                    final double avg = ratings.map((r) => r.stars).reduce((a, b) => a + b) / ratings.length;

                    return Row(
                      children: [
                        const Text("Đánh giá trung bình:", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(
                            5,
                                (index) => Icon(
                              index < avg.round() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(avg.toStringAsFixed(1)),
                      ],
                    );
                  },
                ),
                // Phần đánh giá sao của người dùng
                StarRating(onRated: (stars) async {
                  final response = await http.post(
                    Uri.parse('http://localhost:8080/api/v1/ratings'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'productId': widget.product.id,
                      'stars': stars,
                    }),
                  );
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đánh giá $stars sao thành công!')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đánh giá thất bại!')));
                  }
                }),
                const SizedBox(height: 30),

                const Divider(),

                // Đánh giá
                const Text("Đánh giá sản phẩm:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                if (reviews.isEmpty)
                  const Text("Chưa có đánh giá nào.")
                else
                  Column(
                    children: reviews.map((r) => ReviewCard(review: r)).toList(),
                  ),

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
          backgroundColor: Colors.blueAccent,
          child: Text(
            review.username[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(review.username, style: const TextStyle(fontWeight: FontWeight.w600)),
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
class StarRating extends StatefulWidget {
  final Function(int) onRated;

  const StarRating({super.key, required this.onRated});

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  int _hoveredStar = 0;
  int _selectedStar = 0;

  void _rate(int stars) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận'),
        content: Text('Bạn có muốn đánh giá $stars sao cho sản phẩm này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Không')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Đồng ý')),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onRated(stars); // Gọi callback để fetch API
      setState(() => _selectedStar = stars);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isActive = starIndex <= (_hoveredStar > 0 ? _hoveredStar : _selectedStar);

        return MouseRegion(
          onEnter: (_) {
            if (!isMobile) setState(() => _hoveredStar = starIndex);
          },
          onExit: (_) {
            if (!isMobile) setState(() => _hoveredStar = 0);
          },
          child: GestureDetector(
            onTap: () => _rate(starIndex),
            child: Icon(
              Icons.star,
              color: isActive ? Colors.amber : Colors.grey,
              size: 32,
            ),
          ),
        );
      }),
    );
  }
}
