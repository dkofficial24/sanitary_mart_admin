
class OrderItem {
  String productId;
  String productName;
  double price;
  int quantity;
  String brand;
  String? productImg;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.brand,
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
    );
  }
}
