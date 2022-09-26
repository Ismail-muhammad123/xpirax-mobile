import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpirax/data/business.dart';
import 'package:xpirax/data/inventory.dart';
import 'package:xpirax/data/transaction.dart';
import 'package:xpirax/data/user.dart';

const String baseAPIUrl = "https://xpirax.com/api/v1/";

class TransactionsProvider extends ChangeNotifier {
  final String transactionUrl = '${baseAPIUrl}transactions/';

  Future<Transaction?> insertTransaction(
      {required Transaction transaction}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("AuthToken");

    Map payload = transaction.toJson();

    try {
      var trx = await post(
        Uri.parse(transactionUrl),
        headers: {
          "Authorization": "Token $token",
          "Content-Type": "Application/Json"
        },
        body: jsonEncode(payload),
      );
      if (trx.statusCode == 201) {
        notifyListeners();
        return Transaction.fromJson(jsonDecode(trx.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Transaction>?> getTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("AuthToken");
    try {
      return get(
        Uri.parse(transactionUrl),
        headers: {"Authorization": "Token $token"},
      ).then((value) => jsonDecode(value.body) as List).then(
            (value) => value
                .map(
                  (e) => Transaction.fromJson(e),
                )
                .toList(),
          );
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getSummary() async {
    List<Transaction>? transactions = await getTransactions();

    if (transactions == null) {
      return [];
    }

    List<Map<String, dynamic>> result = [];

    // loop through the transactions and create a sorted list of Maps containing
    // sold items, quantity nd the date of the transaction
    for (Transaction transaction in transactions) {
      for (Items item in transaction.items!) {
        result.any((element) => element.containsKey(item.itemName))
            ? result.firstWhere((element) =>
                    element.containsKey(item.itemName))[item.itemName] +=
                item.quantity
            : result.add({
                "name": item.itemName,
                "quantity": item.quantity,
                "date": transaction.date,
              });
      }
    }
    return result;
  }
}

class InventoryProvider extends ChangeNotifier {
  final String inventoryPath = '${baseAPIUrl}inventory/';

  Future<List<Inventory>?> getItems() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("AuthToken") ?? "";
      var result = await get(Uri.parse("${inventoryPath}list"), headers: {
        "Authorization": "Token $token",
      });

      if (result.statusCode != 200) {
        return null;
      }

      return (jsonDecode(result.body) as List)
          .map((e) => Inventory.fromJson(e))
          .toList();
    } catch (e) {
      return null;
    }
  }

  Future insert(List<Inventory> data) async {
    // get token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("AuthToken") ?? "";

    try {
      var res = await post(
        Uri.parse('${baseAPIUrl}inventory/list'),
        headers: {
          "Authorization": "Token $token",
          "content-type": "Application/Json",
        },
        body: jsonEncode(data.map((e) => e.toJson()).toList()),
      );

      if (res.statusCode != 201) {
        return;
      }

      notifyListeners();
      return jsonDecode(res.body);
    } catch (e) {
      return null;
    }
  }

  Future updateInventory(Inventory obj) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("AuthToken") ?? "";

    try {
      var res = await put(
        Uri.parse('${baseAPIUrl}inventory/details/${obj.id}'),
        headers: {
          "Authorization": "Token $token",
          "content-type": "Application/Json",
        },
        body: jsonEncode(obj.toJson()),
      );

      if (res.statusCode != 200) {
        return;
      }

      notifyListeners();
      return jsonDecode(res.body);
    } catch (e) {
      return null;
    }
  }
}

class Authentication extends ChangeNotifier {
  Future<bool> isLogedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("AuthToken") ?? "";

    if (token.isEmpty) {
      return false;
    } else {
      var user = await getUserDetails();
      return user != null;
    }
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    const String loginUrl = "${baseAPIUrl}login";
    try {
      var result = await post(
        Uri.parse(loginUrl),
        body: {
          "username": username,
          "password": password,
        },
      );
      if (result.statusCode == 200) {
        var token = jsonDecode(result.body)['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("AuthToken", token);
        notifyListeners();
        return jsonDecode(result.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(
      "AuthToken",
    );
    notifyListeners();
  }

  Future<Business?> getBusinessDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("AuthToken") ?? "";
    if (token.isNotEmpty) {
      try {
        var result = await get(
          Uri.parse('${baseAPIUrl}account/business-details'),
          headers: {
            "Authorization": "Token $token",
          },
        );
        if (result.statusCode == 200) {
          return Business.fromJson(jsonDecode(result.body));
        }
        return null;
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<User?> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("AuthToken") ?? "";
    if (token.isNotEmpty) {
      try {
        var result = await get(
          Uri.parse('${baseAPIUrl}account/user-details'),
          headers: {
            "Authorization": "Token $token",
          },
        );
        if (result.statusCode == 200) {
          return User.fromJson(jsonDecode(result.body));
        }
        return null;
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }
}

// ////////////////////////////////////////////////////////////////////////////////////////////////////////////

// import 'package:flutter/cupertino.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:xpirax/data/data.dart';
// import 'package:xpirax/data/database.dart';

// class SalesRecordProvider extends ChangeNotifier {
//   // insert sells records

//   void insertRecords(List<Sales> records) async {
//     // insert to local DB
//     // TODO insert data to db
//     notifyListeners();
//   }

//   Future<List<Sales>> getRecords(String id) async => [];

//   Future<List<Map<String, dynamic>>> getSummary() async => [];
// }

// class TransactionsProvider extends ChangeNotifier {
//   void insertRecords(SalesTransaction transaction) async {
//     // insert to local DB
//     // TODO insert records
//   }

//   void update(SalesTransaction trx) async {}

//   // fetch transactions from local database
//   Future<List<SalesTransaction>> getTransactions() async => [];

//   Future<List<SalesTransaction>> search(String term) async => [];
// }

// class InventoryProvider extends ChangeNotifier {
//   Future<List<InventoryData>> getItems() async => [];

//   Future<List<InventoryData>> search(String name) async => [];

//   Future<void> insert(List<InventoryData> data) async {
//     [];
//   }

//   Future updateInventory(InventoryData obj) async {
//     notifyListeners();
//   }
// }

// class Preferences extends ChangeNotifier {
//   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

//   Future<void> setCompanyName(String name) async {
//     final SharedPreferences prefs = await _prefs;
//     await prefs.setString('BusinessName', name);
//     notifyListeners();
//   }

//   Future<String> getCompanyName() async {
//     final SharedPreferences prefs = await _prefs;
//     return prefs.getString('BusinessName') ?? "Xpirax Technologies";
//   }

//   Future removeLogo() async {
//     final SharedPreferences prefs = await _prefs;
//     prefs.setString('LogoPath', "");
//     notifyListeners();
//   }

//   Future<String> getLogoPath() async {
//     final SharedPreferences prefs = await _prefs;
//     return prefs.getString('LogoPath') ?? "";
//   }

//   Future<void> setLogoPath(String path) async {
//     final SharedPreferences prefs = await _prefs;
//     prefs.setString('LogoPath', path);
//     notifyListeners();
//   }

//   Future<String> getRecieptPath() async {
//     final SharedPreferences prefs = await _prefs;
//     return prefs.getString('RecieptPath') ?? "";
//   }

//   Future<void> setRecieptPath(String path) async {
//     final SharedPreferences prefs = await _prefs;
//     prefs.setString('RecieptPath', path);
//     notifyListeners();
//   }

//   Future<bool> isOnline() async {
//     final SharedPreferences prefs = await _prefs;
//     return prefs.getBool("isOnline") ?? false;
//   }

//   Future setIsOnline({bool val = true}) async {
//     final SharedPreferences prefs = await _prefs;
//     await prefs.setBool("isOnline", val);
//   }

//   Future<String> getToken() async {
//     final SharedPreferences prefs = await _prefs;
//     return prefs.getString("AuthToken") ?? "";
//   }

//   Future setToken(String token) async {
//     final SharedPreferences prefs = await _prefs;
//     await prefs.setString("AuthToken", token);
//   }
// }
