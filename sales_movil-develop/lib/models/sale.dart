class Sale {
  final int? id;
  final int clientId;
  final int productId;
  final int quantity;

  Sale({
    this.id,
    required this.clientId,
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      "client": clientId,
      "details": [
        {
          "product": productId,
          "quantity": quantity,
        }
      ]
    };
  }
}