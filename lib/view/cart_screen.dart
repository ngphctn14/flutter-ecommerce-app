import 'package:flutter/material.dart';
import '../models/Coupon.dart';
import '../services/cart_service.dart';
import '../models/CartResponse.dart';
import '../services/coupon_service.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<CartResponse?> _futureCart;
  List<Coupon> _coupons = [];
  Coupon? _selectedCoupon;
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _loadCart();
    _loadCoupons();

  }

  void _loadCart() {
    _futureCart = CartService.getCart();
  }
  void _loadCoupons() async {
    try {
      final coupons = await CouponService.getCoupons();
      setState(() {
        _coupons = coupons;
      });
    } catch (e) {
      print('Load coupons error: $e');
    }
  }
  void _updateQuantity(int cartItemId, int newQuantity) async {
    if (newQuantity == 0) {
      await CartService.deleteItem(cartItemId);
    } else {
      await CartService.updateQuantity(cartItemId, newQuantity);
    }
    setState(() => _loadCart());
  }
  double _calculateDiscountedTotal(double total) {
    if (_selectedCoupon != null) {
      return (total - _selectedCoupon!.discountPrice).clamp(0, double.infinity);
    }
    return total;
  }

  void _deleteItem(int cartItemId) async {
    await CartService.deleteItem(cartItemId);
    setState(() => _loadCart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: FutureBuilder<CartResponse?>(
        future: _futureCart,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) {
            print('Cart load error: ${snapshot.error}');
            return Center(child: Text('Error loading cart: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.cartItemResponseList.isEmpty)
            return Center(child: Text('Cart is empty'));

          final cart = snapshot.data!;
          double totalPriceAfterDiscount = cart.totalPrice;
          if (_selectedCoupon != null) {
            totalPriceAfterDiscount -= _selectedCoupon!.discountPrice;
            if (totalPriceAfterDiscount < 0) totalPriceAfterDiscount = 0;
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.cartItemResponseList.length,
                  itemBuilder: (context, index) {
                    final item = cart.cartItemResponseList[index];
                    return ListTile(
                      leading: Image.network(item.image, width: 60, height: 60),
                      title: Text(item.productName),
                      subtitle: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => _updateQuantity(item.id, item.quantity - 1),
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => _updateQuantity(item.id, item.quantity + 1),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteItem(item.id),
                          ),
                        ],
                      ),

                      trailing: Text(_currencyFormat.format(item.price * item.quantity)),
                    );
                  },
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: DropdownButton<Coupon>(
                  hint: Text('Select a voucher'),
                  value: _selectedCoupon,
                  isExpanded: true,
                  items: _coupons.map((coupon) {
                    return DropdownMenuItem(
                      value: coupon,
                      child: Text('${coupon.code} - Giảm ${_currencyFormat.format(coupon.discountPrice)}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCoupon = value;
                    });
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Tổng cộng: ${_currencyFormat.format(_calculateDiscountedTotal(cart.totalPrice))}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

