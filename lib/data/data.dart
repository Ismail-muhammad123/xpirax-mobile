import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

class ChartData {
  ChartData(this.x, this.y, [this.color = Colors.green]);
  final String x;
  final double y;
  Color color;
}

class TransactionData {
  String? id;
  late final String customerName;
  late final String customerAddress;
  late final String customerPhoneNumber;
  late final String customerEmail;
  late final num amount;
  late final num amountPaid;
  late final num balance;
  late final num discount;
  late final Timestamp time;
  late String? attendant;

  TransactionData({
    this.id,
    this.attendant,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhoneNumber,
    required this.customerEmail,
    required this.amount,
    required this.amountPaid,
    required this.discount,
    required this.balance,
    required this.time,
  });

  TransactionData.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    customerName = data["customerName"];
    customerAddress = data["customerAdress"];
    customerPhoneNumber = data["customerPhoneNumber"].toString();
    customerEmail = data["customerEmail"];
    amount = data["amount"];
    amountPaid = data["amountPaid"];
    discount = data["discount"];
    balance = data["balance"];
    time = data["time"];
    attendant = data["attendant"];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "customerName": customerName,
      "customerAdress": customerAddress,
      "customerPhoneNumber": customerPhoneNumber,
      "customerEmail": customerEmail,
      "amount": amount,
      "amountPaid": amountPaid,
      "discount": discount,
      "balance": balance,
      "time": time,
      "attendant": attendant,
    };
  }
}

class SoldItem {
  String? id;
  String? transactionID;
  late final String name;
  late final num quantity;
  late final num price;
  late final num amount;
  late final Timestamp salesTime;

  SoldItem({
    this.id,
    required this.name,
    this.transactionID,
    required this.quantity,
    required this.price,
    required this.amount,
    required this.salesTime,
  });

  SoldItem.fromJson(Map<String, dynamic> data) {
    name = data["name"];
    transactionID = data["transactionUid"];
    quantity = data["quantity"];
    price = data["price"];
    amount = data["amount"];
    salesTime = data["salesTime"];
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "transactionUid": transactionID,
      "quantity": quantity,
      "price": price,
      "amount": amount,
      "salesTime": salesTime,
    };
  }
}

// #######################################################################################################
class InventoryData {
  String? id;
  late String name;
  late String description;
  late num availableQuantity;
  late num price;

  InventoryData({
    this.id,
    required this.name,
    required this.description,
    required this.availableQuantity,
    required this.price,
  });

  InventoryData.fromMap(data) {
    description = data['description'] ?? "";
    name = data['name'] ?? "";
    availableQuantity = data['available_quantity'] ?? 0;
    price = data['price'];
  }

  toMap() {
    return {
      'name': name,
      'description': description,
      'available_quantity': availableQuantity,
      'price': price,
    };
  }
}

// #######################################################################################################