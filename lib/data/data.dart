import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SummaryDataItem {
  final String id;
  final String item;
  final double value;
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
  int? serialNumber;
  late final String customerName;
  late final String customerAddress;
  late final String customerPhoneNumber;
  late final String customerEmail;
  late final double amount;
  late final double amountPaid;
  late final double balance;
  late final Timestamp time;
  late final String? attendant;
  late final double? pos;
  late final double? cash;
  late final double? transfer;

  TransactionData({
    this.id,
    this.attendant,
    this.serialNumber,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhoneNumber,
    required this.customerEmail,
    required this.amount,
    required this.amountPaid,
    required this.balance,
    required this.time,
    required this.pos,
    required this.cash,
    required this.transfer,
  });

  TransactionData.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    serialNumber = data["serial number"];
    customerName = data["customerName"];
    customerAddress = data["customerAdress"];
    customerPhoneNumber = data["customerPhoneNumber"].toString();
    customerEmail = data["customerEmail"];
    amount = data["amount"] * 1.0;
    amountPaid = data["amountPaid"] * 1.0;
    balance = data["balance"] * 1.0;
    time = data["time"];
    attendant = data["attendant"];
    pos = data["pos"] * 1.0;
    cash = data["cash"] * 1.0;
    transfer = data["transfer"] * 1.0;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "serial number": serialNumber,
      "customerName": customerName,
      "customerAdress": customerAddress,
      "customerPhoneNumber": customerPhoneNumber,
      "customerEmail": customerEmail,
      "amount": amount,
      "amountPaid": amountPaid,
      "balance": balance,
      "time": time,
      "attendant": attendant,
      "pos": pos,
      "cash": cash,
      "transfer": transfer,
    };
  }
}

class SoldItem {
  String? id;
  String? transactionID;
  late final String name;
  late final double quantity;
  late final double price;
  late final double amount;
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
    quantity = data["quantity"] * 1.0;
    price = data["price"] * 1.0;
    amount = data["amount"] * 1.0;
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
  late double available_quantity;
  late double maxPrice;
  late double minPrice;
  late double cost;

  InventoryData({
    this.id,
    required this.name,
    required this.description,
    required this.available_quantity,
    required this.maxPrice,
    required this.minPrice,
    required this.cost,
  });

  InventoryData.fromMap(data) {
    description = data['description'] ?? "";
    name = data['name'] ?? "";
    available_quantity = data['available_quantity'] * 1.0;
    maxPrice = data['max price'] * 1.0;
    minPrice = data['min price'] * 1.0;
    cost = data['cost'] * 1.0;
  }

  toMap() {
    return {
      'name': name,
      'description': description,
      'available_quantity': available_quantity,
      'cost': cost,
      'max price': maxPrice,
      'min price': minPrice,
    };
  }
}

// #######################################################################################################