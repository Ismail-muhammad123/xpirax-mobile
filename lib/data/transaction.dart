class Transaction {
  String uid;
  String customerName;
  String phoneNumber;
  String email;
  String address;
  double amount;
  double amountPaid;
  double discount;
  double balance;
  String? date;
  bool isSynced;
  List<Item>? items;

  Transaction({
    required this.customerName,
    required this.uid,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.amount,
    required this.amountPaid,
    required this.discount,
    required this.balance,
    required this.date,
    this.isSynced = false,
    required this.items,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      uid: json["uid"],
      customerName: json["customerName"],
      address: json["address"],
      phoneNumber: json["phoneNumber"].toString(),
      email: json["email"],
      amount: json["amount"],
      amountPaid: json["amountPaid"],
      discount: json["discount"],
      balance: json["balance"],
      date: json["date"],
      items: json['items'] != null
          ? (json['items'] as List).map((e) => Item.fromJson(e)).toList()
          : null,
      isSynced: json['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["uid"] = uid;
    data["customerName"] = customerName;
    data["address"] = address;
    data["phoneNumber"] = phoneNumber;
    data["email"] = email;
    data["amount"] = amount;
    data["amountPaid"] = amountPaid;
    data["discount"] = discount;
    data["balance"] = balance;
    data["date"] = date;
    data['isSynced'] = isSynced ? 1 : 0;
    if (items != null) {
      data["items"] = items!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class Item {
  String uid;
  String productUID;
  String transactionUID;
  String name;
  double price;
  int quantity;
  double amount;
  String date;
  bool isSynced;

  Item({
    required this.uid,
    required this.productUID,
    required this.transactionUID,
    required this.name,
    required this.price,
    required this.quantity,
    required this.date,
    required this.amount,
    this.isSynced = false,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      uid: json["uid"],
      productUID: json["productUID"],
      name: json["name"],
      price: json["price"],
      quantity: json["quantity"],
      transactionUID: json["transactionUID"],
      date: json['date'],
      amount: json['amount'],
      isSynced: json['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["uid"] = uid;
    data["productUID"] = productUID;
    data["name"] = name;
    data["price"] = price;
    data["quantity"] = quantity;
    data["transactionUID"] = transactionUID;
    data["amount"] = amount;
    data["date"] = date;
    data['isSynced'] = isSynced ? 1 : 0;
    return data;
  }
}
