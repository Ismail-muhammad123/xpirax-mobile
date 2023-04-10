import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
          ),
        ],
        title: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: profileInfo,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("...");
            }
            return Text(
              snapshot.data!.docs.first.data()['businessName'].toUpperCase(),
            );
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.tealAccent,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.all(12.0),
                      height: 120.0,
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

                              var total = snapshot.data!.docs.length;
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
                        color: Colors.tealAccent,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Amount",
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
                                  .map((e) => e.data()['amountPaid'])
                                  .fold<num>(
                                      0,
                                      (previousValue, element) =>
                                          previousValue + element)
                                  .toDouble();
                              return Text(
                                "NGN ${NumberFormat('###,###,###').format(cash)}",
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
                        color: Colors.tealAccent,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Balance",
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
                                  .map((e) => e.data()['balance'])
                                  .fold<num>(
                                      0,
                                      (previousValue, element) =>
                                          previousValue + element)
                                  .toDouble();
                              return Text(
                                "NGN ${NumberFormat('###,###,###').format(debt)}",
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
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: inventoryStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Your Inventory is Empty"),
                  );
                }

                return SizedBox(
                  height: 400.0,
                  child: BarChartWidget(
                    data: snapshot.data!.docs
                        .map(
                          (e) => SummaryDataItem(
                            item: e.data()['name'],
                            value: e.data()['available_quantity'],
                            id: e.id,
                            barColor: charts.Color.fromOther(
                              color: charts.Color.fromHex(code: "#008080"),
                            ),
                          ),
                        )
                        .toList(),
                    heading: "Inventory",
                  ),
                );
              },
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
              stream: sales,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No Item is sold, yet."),
                  );
                }

                var items = snapshot.data!.docs
                    .map(
                      (e) => SoldItem(
                        id: e.id,
                        name: e.data()['name'],
                        quantity: e.data()['quantity'],
                        price: e.data()['price'],
                        amount: e.data()['amount'],
                        salesTime: e.data()['salesTime'],
                      ),
                    )
                    .toList();
                items.sort(
                  (a, b) => a.salesTime.millisecondsSinceEpoch
                      .compareTo(b.salesTime.millisecondsSinceEpoch),
                );
                return Column(
                  children: items
                      .sublist(0, items.length > 6 ? 6 : items.length)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(e.name),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Text(
                                      "X ${NumberFormat('###,###,###').format(e.quantity)}"),
                                )
                              ],
                            ),
                            subtitle: Text(
                              DateFormat("d/M/y").format(
                                e.salesTime.toDate(),
                              ),
                            ),
                            trailing: Text(
                              "NGN ${NumberFormat('###,###,###').format(e.amount)}",
                              style: const TextStyle(color: Colors.red),
                            ),
                            tileColor: Colors.tealAccent,
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
