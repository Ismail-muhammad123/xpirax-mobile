class Transaction {
  int? id;
  String customerName;
  String address;
  String phoneNumber;
  String email;
  double amount;
  double amountPaid;
  double discount;
  double balance;
  String? date;
  int? business;
  int? soldBy;
  List<Items>? items;

  Transaction({
    this.id,
    required this.customerName,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.amount,
    required this.amountPaid,
    required this.discount,
    required this.balance,
    required this.date,
    this.business,
    this.soldBy,
    required this.items,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json["id"],
      customerName: json["customerName"],
      address: json["address"],
      phoneNumber: json["phoneNumber"],
      email: json["email"],
      amount: json["amount"],
      amountPaid: json["amountPaid"],
      discount: json["discount"],
      balance: json["balance"],
      date: json["date"],
      business: json["business"],
      soldBy: json["sold_by"],
      items: (json['items'] as List).map((e) => Items.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["customerName"] = customerName;
    data["address"] = address;
    data["phoneNumber"] = phoneNumber;
    data["email"] = email;
    data["amount"] = amount;
    data["amountPaid"] = amountPaid;
    data["discount"] = discount;
    data["balance"] = balance;
    data["date"] = date;
    data["business"] = business;
    data["sold_by"] = soldBy;
    if (items != null) {
      data["items"] = items!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class Items {
  int? id;
  int item;
  String itemName;
  double price;
  int quantity;
  int? transaction;

  Items({
    this.id,
    required this.item,
    required this.itemName,
    required this.price,
    required this.quantity,
    this.transaction,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      id: json["id"],
      item: json["item"],
      itemName: json["item_name"],
      price: json["price"],
      quantity: json["quantity"],
      transaction: json["transaction"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["item"] = item;
    data["item_name"] = itemName;
    data["price"] = price;
    data["quantity"] = quantity;
    data["transaction"] = transaction;
    return data;
  }
}
