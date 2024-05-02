enum OrderStatus { pending, delivered, canceled, returned }

OrderStatus parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'delivered':
        return OrderStatus.delivered;
      case 'canceled':
        return OrderStatus.canceled;
      case 'returned':
        return OrderStatus.returned;
      default:
        throw FormatException('Unknown status: $status');
    }
}
