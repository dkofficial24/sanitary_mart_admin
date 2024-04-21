class OrderItem {
  String productId;
  String productName;
  String brand;
  double price;
  int quantity;
  String? productImg;
  double discountAmount;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.brand,
    this.discountAmount = 0,
    this.productImg,
  });

  // Convert OrderItem object to a Map for serialization
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'brand': brand,
      'productImg': productImg,
      'discountAmount': discountAmount,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      productName: json['productName'],
      price: json['price'],
      quantity: json['quantity'],
      productImg: json['productImg'],
      brand: json['brand'],
      discountAmount: json['discountAmount'] ?? 0,
    );
  }
}
