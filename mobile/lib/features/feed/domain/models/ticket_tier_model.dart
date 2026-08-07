class TicketTierModel {
  final String id;
  final String name; // e.g., "General Admission", "VIP"
  final double price;
  final int availableQuantity;

  const TicketTierModel({
    required this.id,
    required this.name,
    required this.price,
    required this.availableQuantity,
  });

  factory TicketTierModel.fromJson(Map<String, dynamic> json) {
    return TicketTierModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      availableQuantity: json['availableQuantity'] as int,
    );
  }
}
