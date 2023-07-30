import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:xpirax/filters.dart';
import '../../data/data.dart';
import '../../widgets/bar_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    Key? key,
  }) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var transactionStream =
      FirebaseFirestore.instance.collection('transactions').snapshots();
  var inventoryStream =
      FirebaseFirestore.instance.collection('inventory').snapshots();
  var sales = FirebaseFirestore.instance.collection('sales').snapshots();
  var profileInfo =
      FirebaseFirestore.instance.collection('profile').snapshots();

  var user = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

  DateTimeRange _sortDateRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  _select(String val) async {
    switch (val.toLowerCase()) {
      case 'all':
        setState(() {
          _sortDateRange =
              DateTimeRange(start: DateTime(2022), end: DateTime.now());
        });
        break;
      case 'today':
        setState(() {
          _sortDateRange =
              DateTimeRange(start: DateTime.now(), end: DateTime.now());
        });
        break;
      case 'select':
        var start = await showDatePicker(
          context: context,
          helpText: "Select Start Date",
          initialDate: DateTime.now(),
          firstDate: DateTime(2022),
          lastDate: DateTime(2040),
          currentDate: DateTime.now(),
        );
        var end = await showDatePicker(
          context: context,
          helpText: "Select End Date",
          initialDate: DateTime.now(),
          firstDate: DateTime(2022),
          lastDate: DateTime(2040),
          currentDate: DateTime.now(),
        );

        if (start != null && end != null) {
          setState(
            () => _sortDateRange = DateTimeRange(start: start, end: end),
          );
        }

        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.calendar_month),
            onSelected: _select,
            padding: EdgeInsets.zero,
            // initialValue: choices[_selection],
            itemBuilder: (BuildContext context) {
              return ['all', 'today', 'select'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice.toUpperCase()),
                );
              }).toList();
            },
          )
        ],
        title: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: profileInfo,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Dashboard");
            }
            return Text(
              snapshot.data!.docs.first.data()['businessName'].toUpperCase(),
            );
          },
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: Colors.tealAccent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 150,
                width: double.maxFinite,
                color: Colors.tealAccent,
                padding: const EdgeInsets.all(4),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            !snapshot.hasData) {
                          return const Text("");
                        }
                        return Text(
                          (snapshot.data!.data()!['full name'] as String)
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.teal,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    Text(FirebaseAuth.instance.currentUser?.email ?? ""),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  height: double.maxFinite,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Card(
                            child: ListTile(
                              title: const Text(
                                "Log out",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 16),
                              ),
                              leading: const Icon(
                                Icons.logout,
                                color: Color.fromARGB(255, 255, 17, 0),
                              ),
                              onTap: () async =>
                                  await FirebaseAuth.instance.signOut(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              width: double.maxFinite,
              color: Colors.tealAccent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${DateFormat.yMd().format(_sortDateRange.start)} to ${DateFormat.yMd().format(_sortDateRange.end)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border:
                              Border.all(color: Colors.tealAccent, width: 2.0)),
                      padding: const EdgeInsets.all(12.0),
                      height: 100.0,
                      width: double.maxFinite,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Transactions",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: transactionStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Text(
                                  "0.0",
                                  style: TextStyle(
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              var total = snapshot.data!.docs
                                  .where((e) => passedDateFilter(
                                      e.data()['time'], _sortDateRange))
                                  .length;
                              return Text(
                                NumberFormat('###,###,###').format(total),
                                style: const TextStyle(
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border:
                            Border.all(color: Colors.tealAccent, width: 2.0),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      height: 100.0,
                      width: double.maxFinite,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Amount",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: transactionStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Text(
                                  "0.0",
                                  style: TextStyle(
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              var total = snapshot.data!.docs
                                  .map((e) => e.data())
                                  .where((e) => passedDateFilter(
                                      e['time'], _sortDateRange))
                                  .fold<double>(
                                      0,
                                      (previousValue, element) =>
                                          previousValue + element['amount']);
                              return Text(
                                NumberFormat('###,###,###').format(total),
                                style: const TextStyle(
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      height: 100.0,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.tealAccent, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "POS",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: transactionStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Text(
                                  "0.0",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              var pos = snapshot.data!.docs
                                  .where((e) => passedDateFilter(
                                      e.data()['time'], _sortDateRange))
                                  .map((e) => e.data()['pos'])
                                  .fold<num>(
                                      0,
                                      (previousValue, element) =>
                                          previousValue + element)
                                  .toDouble();
                              return Text(
                                "NGN ${NumberFormat('###,###,###').format(pos)}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      height: 100.0,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.tealAccent, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "CASH",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: transactionStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Text(
                                  "0.0",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              var cash = snapshot.data!.docs
                                  .where((e) => passedDateFilter(
                                      e.data()['time'], _sortDateRange))
                                  .map((e) => e.data()['cash'])
                                  .fold<num>(
                                      0,
                                      (previousValue, element) =>
                                          previousValue + element)
                                  .toDouble();
                              return Text(
                                "NGN ${NumberFormat('###,###,###').format(cash)}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      height: 100.0,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.tealAccent, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "TRANSFER",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: transactionStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Text(
                                  "0.0",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              var cash = snapshot.data!.docs
                                  .where((e) => passedDateFilter(
                                      e.data()['time'], _sortDateRange))
                                  .map((e) => e.data()['transfer'])
                                  .fold<num>(
                                      0,
                                      (previousValue, element) =>
                                          previousValue + element)
                                  .toDouble();
                              return Text(
                                "NGN ${NumberFormat('###,###,###').format(cash)}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      height: 100.0,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.tealAccent, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "BALANCE",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: transactionStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Text(
                                  "0.0",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              var debt = snapshot.data!.docs
                                  .where((e) => passedDateFilter(
                                      e.data()['time'], _sortDateRange))
                                  .map((e) => e.data()['balance'])
                                  .fold<num>(
                                      0,
                                      (previousValue, element) =>
                                          previousValue + element)
                                  .toDouble();
                              return Text(
                                "NGN ${NumberFormat('###,###,###').format(debt)}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      height: 100.0,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.tealAccent, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Inventory Items",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: inventoryStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Text(
                                  "0.0",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              var items = snapshot.data!.docs.length;

                              return Text(
                                "${NumberFormat('###,###,###').format(items)}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      height: 100.0,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.tealAccent, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Total Quantity",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: inventoryStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Text(
                                  "0.0",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              var count = snapshot.data!.docs
                                  .map((e) => InventoryData.fromMap(e.data()))
                                  .map((e) => e.available_quantity)
                                  .fold<num>(
                                      0,
                                      (previousValue, element) =>
                                          previousValue + element)
                                  .toDouble();
                              return Text(
                                "${NumberFormat('###,###,###').format(count)}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      height: 100.0,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.tealAccent, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Inventory Amount",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: inventoryStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Text(
                                  "0.0",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              var amount = snapshot.data!.docs
                                  .map((e) => InventoryData.fromMap(e.data()))
                                  .fold<double>(
                                      0,
                                      (previousValue, element) =>
                                          previousValue +
                                          element.available_quantity *
                                              element.maxPrice);

                              return Text(
                                "NGN ${NumberFormat('###,###,###').format(amount)}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: const [
                  Text(
                    "Latest Sales",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: transactionStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No Transactions, yet."),
                  );
                }

                var items = snapshot.data!.docs.map((e) {
                  var t = TransactionData.fromJson(e.data());
                  t.id = e.id;
                  return t;
                }).toList();
                items.sort(
                  (a, b) => b.time.compareTo(a.time),
                );
                return Column(
                  children: items
                      .sublist(0, items.length < 6 ? items.length : 6)
                      .map(
                        (e) => Card(
                          child: ListTile(
                            tileColor: const Color.fromARGB(255, 225, 248, 242)
                                .withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            title: Text(
                              "#${e.serialNumber != null ? e.serialNumber.toString().padLeft(7, "0") : e.id}",
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                            ),
                            subtitle: Text(
                              DateFormat('yMMMMEEEEd').add_jm().format(
                                    e.time.toDate(),
                                  ),
                            ),
                            trailing: Text(
                                NumberFormat('###,###,###').format(e.amount)),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
