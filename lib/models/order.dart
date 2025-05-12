enum OrderStatus { active, completed, cancelled }

class Order {
  final String orderNumber;
  final int itemCount;
  final double totalAmount;
  final OrderStatus status;
  final String imageUrl;
  final DateTime orderDate;

  Order({
    required this.orderNumber,
    required this.itemCount,
    required this.totalAmount,
    required this.status,
    required this.imageUrl,
    required this.orderDate,
  });

  String get statusString => status.name;
}

class OrderRepository {
  List<Order> getOrders() {
    return [
      Order(
        orderNumber: '123456',
        itemCount: 3,
        totalAmount: 15000000.0,
        status: OrderStatus.active,
        imageUrl: 'assets/images/laptop.jpg',
        orderDate: DateTime.now(),
      ),
      Order(
        orderNumber: '654321',
        itemCount: 2,
        totalAmount: 200.0,
        status: OrderStatus.completed,
        imageUrl: 'assets/images/shoe.jpg',
        orderDate: DateTime.now().subtract(Duration(days: 1)),
      ),
      Order(
        orderNumber: '789012',
        itemCount: 1,
        totalAmount: 100.0,
        status: OrderStatus.cancelled,
        imageUrl: 'assets/images/shoes2.jpg',
        orderDate: DateTime.now().subtract(Duration(days: 2)),
      ),
    ];
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return getOrders().where((order) => order.status == status).toList();
  }
}
