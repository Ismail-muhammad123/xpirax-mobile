import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:xpirax/data/inventory.dart';
import 'package:xpirax/data/transaction.dart' as trx;
import 'package:xpirax/data/transaction.dart';

String dbFileName = "Xpirax.db";

class LocalDatabaseHandler extends ChangeNotifier {
  String inventoryItemsTable = 'inventoryItemsRecord';
  String transactionBdName = 'transactionTable';
  String salesTableName = 'ItemsSalesRecord';

  openDB() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;
    var pat = await getApplicationSupportDirectory();
    var db = await databaseFactory.openDatabase(join(pat.path, dbFileName));
    await db.execute('''
        CREATE TABLE IF NOT EXISTS $inventoryItemsTable  (
          uid STRING UNIQUE,
          name STRING,
          description STRING,
          availableQuantity INTEGER,
          price FLOAT, 
          dataAdded DATETIME,
          isSynced INTEGER
        );
         CREATE TABLE IF NOT EXISTS $transactionBdName  (
          uid STRING UNIQUE,
          customerName STRING,
          phoneNumber STRING,
          email STRING,
          address STRING,
          amount FLOAT,
          amountPaid FLOAT,
          discount FLOAT,
          balance FLOAT,
          date STRING,
          isSynced INTEGER
        );
         CREATE TABLE IF NOT EXISTS $salesTableName  (
          uid STRING UNIQUE,
          productUID STRING,
          transactionUID STRING,
          name STRING,
          quantity INTEGER,
          price FLOAT,
          amount FLOAT,
          date DATETIME,
          isSynced INTEGER
        );
      ''');

    return db;
  }

  // ================================> Inventory <=========================================

  Future<List<Inventory>> getItemsFromInventory() async {
    Database db = await openDB();
    var dbResult = await db.query(inventoryItemsTable);
    var inventories = dbResult.map((e) => Inventory.fromJson(e)).toList();
    return inventories;
  }

  Future insertItemsToInventory(List<Inventory> items) async {
    Database db = await openDB();
    for (Inventory item in items) {
      var iObj = await db.query(
        inventoryItemsTable,
        where: 'uid=?',
        whereArgs: [item.uid],
      );
      if (iObj.isNotEmpty) {
        await updateInventoryItem(item);
        continue;
      } else {
        await db.insert(inventoryItemsTable, item.toJson());
      }
    }
    notifyListeners();
    return 1;
  }

  Future<List<Inventory>> searchForItemInInventory(String name) async {
    if (name.isEmpty) {
      return [];
    }
    Database db = await openDB();
    return db
        .query(
          inventoryItemsTable,
        )
        .then((value) => value.map((e) => Inventory.fromJson(e)))
        .then((value) => value.where((element) => element.name.contains(name)))
        .then((value) => value.toList());
  }

  Future<int> updateInventoryItem(Inventory obj) async {
    Database db = await openDB();
    int i = await db.update(
      inventoryItemsTable,
      obj.toJson(),
      where: 'uid = ?',
      whereArgs: [
        obj.uid,
      ],
    );
    notifyListeners();
    return i;
  }

  // ==============================> Transactions <===================================

  Future<List<trx.Transaction>> getTransactions() async {
    Database db = await openDB();
    var res = await db.query(transactionBdName);
    var result = res.map((e) => trx.Transaction.fromJson(e)).toList();
    for (var r in result) {
      r.items = await getSoldItems(r.uid);
    }
    return result;
  }

  Future<List<trx.Transaction>> searchForTransaction(String term) async {
    if (term.isEmpty) {}
    Database db = await openDB();
    return db
        .query(transactionBdName)
        .then(
          (value) => value.map(
            (e) => trx.Transaction.fromJson(e),
          ),
        )
        .then(
          (value) => value.where(
            (element) => element.customerName.contains(term),
          ),
        )
        .then((value) => value.toList());
  }

  Future insertTransaction(trx.Transaction item) async {
    Database db = await openDB();
    var soldItems = item.items!;
    var transactionJson = item.toJson();
    transactionJson.remove('items');
    await db.insert(transactionBdName, transactionJson);
    await inserSoldtItems(soldItems);
    notifyListeners();
    return 1;
  }

  Future<int> updateTransaction(trx.Transaction transaction) async {
    Database db = await openDB();
    await db.delete(transactionBdName,
        where: "uid=?", whereArgs: [transaction.uid]);
    var i = await db.insert(
      transactionBdName,
      transaction.toJson(),
    );
    notifyListeners();
    return i;
  }

  Future<List<Map<String, dynamic>>> getTransactionsSummary() async {
    Database db = await openDB();

    return await db
        .rawQuery(
            "SELECT name, date, SUM(quantity) AS quantity from $salesTableName GROUP BY name")
        .then((value) => value.toList());
  }

  // ===============================> Sold Items <=================================

  Future<List<Item>> getSoldItems(String id) async {
    Database db = await openDB();
    return db
        .query(
          salesTableName,
          where: 'transactionUID = ?',
          whereArgs: [
            id,
          ],
        )
        .then((value) => value.toList())
        .then((value) => value.map((e) => Item.fromJson(e)))
        .then((value) => value.toList());
  }

  Future<List<Item>> getAllSoldItems() async {
    Database db = await openDB();
    return db
        .query(
          salesTableName,
        )
        .then((value) => value.map((e) => Item.fromJson(e)).toList());
  }

  Future inserSoldtItems(List<Item> items) async {
    Database db = await openDB();
    for (var element in items) {
      await db.insert(salesTableName, element.toJson());
    }
    notifyListeners();
    return 1;
  }

  Future searchSoldItems(String name) async {
    Database db = await openDB();
    return db
        .query(
          salesTableName,
          where: 'name = ?',
          whereArgs: [
            name,
          ],
        )
        .then((value) => value.toList())
        .then(
          (value) => value.map(
            (element) => Item.fromJson(element),
          ),
        )
        .then((value) => value.toList());
  }
}
