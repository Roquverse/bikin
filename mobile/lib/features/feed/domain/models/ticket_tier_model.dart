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
}
