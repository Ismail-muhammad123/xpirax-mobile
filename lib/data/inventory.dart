class Inventory {
  String uid;
  String name;
  String description;
  double price;
  int availableQuantity;
  String? dataAdded;
  bool isSynced;

  Inventory({
    required this.uid,
    required this.name,
    required this.description,
    required this.price,
    required this.availableQuantity,
    this.dataAdded,
    this.isSynced = false,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      uid: json["uid"],
      name: json["name"],
      description: json["description"],
      price: json["price"],
      availableQuantity: json["availableQuantity"],
      dataAdded: json["dataAdded"],
      isSynced: json["isSynced"] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["name"] = name;
    data["uid"] = uid;
    data["description"] = description;
    data["price"] = price;
    data["availableQuantity"] = availableQuantity;
    data["dataAdded"] = dataAdded;
    data['isSynced'] = isSynced ? 1 : 0;
    return data;
  }
}
