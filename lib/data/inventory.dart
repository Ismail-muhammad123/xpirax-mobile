class Inventory {
  int? id;
  String name;
  String description;
  double price;
  int availableQuantity;
  String? dataAdded;

  Inventory({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.availableQuantity,
    this.dataAdded,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      price: json["price"],
      availableQuantity: json["available_quantity"],
      dataAdded: json["data_added"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["name"] = name;
    data["description"] = description;
    data["price"] = price;
    data["available_quantity"] = availableQuantity;
    data["data_added"] = dataAdded;
    return data;
  }
}
