import 'package:charts_flutter/flutter.dart' as charts;

class SummaryDataItem {
  final String id;
  final String item;
  final int value;
  final charts.Color barColor;

  SummaryDataItem({
    required this.item,
    required this.value,
    required this.barColor,
    required this.id,
  });
}

// ######################################################################################################

// class ChartData {
//   ChartData(this.x, this.y, [this.color = Colors.green]);
//   final String x;
//   final double y;
//   Color color;
// }

// class SalesTransaction {
//   late final String id;
//   late final String customerName;
//   late final String address;
//   late final String phoneNumber;
//   late final String email;
//   late final double amount;
//   late final double amountPaid;
//   late final double discount;
//   late final double balance;
//   late final String date;

//   SalesTransaction({
//     required this.id,
//     required this.customerName,
//     required this.address,
//     required this.phoneNumber,
//     required this.email,
//     required this.amount,
//     required this.amountPaid,
//     required this.discount,
//     required this.balance,
//     required this.date,
//   });

//   SalesTransaction.fromJson(Map<String, dynamic> data) {
//     id = data["id"];
//     customerName = data["customerName"];
//     address = data["address"];
//     phoneNumber = data["phoneNumber"].toString();
//     email = data["email"];
//     amount = double.parse(data["amount"].toString());
//     amountPaid = data["amountPaid"];
//     discount = data["discount"];
//     balance = data["balance"];
//     date = data["date"];
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "customerName": customerName,
//       "address": address,
//       "phoneNumber": phoneNumber,
//       "email": email,
//       "amount": amount,
//       "amountPaid": amountPaid,
//       "discount": discount,
//       "balance": balance,
//       "date": date,
//     };
//   }
// }

// class SellsRecordData {
//   late String id;
//   late final String transactionID;
//   late final String name;
//   late final int quantity;
//   late final double price;
//   late final double amount;
//   late final String date;

//   SellsRecordData({
//     required this.id,
//     required this.name,
//     required this.transactionID,
//     required this.quantity,
//     required this.price,
//     required this.amount,
//     required this.date,
//   });

//   SellsRecordData.fromJson(Map<String, dynamic> data) {
//     id = data["id"];
//     name = data["name"];
//     transactionID = data["transactionID"];
//     quantity = data["quantity"];
//     price = double.parse(data["price"].toString());
//     amount = double.parse(data["amount"].toString());
//     date = data["date"];
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "name": name,
//       "transactionID": transactionID,
//       "quantity": quantity,
//       "price": price,
//       "amount": amount,
//       "date": date,
//     };
//   }
// }

// // #######################################################################################################
// class InventoryData {
//   late String id;
//   late String name;
//   late String description;
//   late int available;
//   late double price;

//   InventoryData({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.available,
//     required this.price,
//   });

//   InventoryData.fromMap(data) {
//     id = data['id'];
//     description = data['description'] ?? "";
//     name = data['name'] ?? "";
//     available = data['available'] ?? 0;
//     price = data['price'];
//   }

//   toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'available': available,
//       'price': price,
//     };
//   }
// }

// // #######################################################################################################