import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:xpirax/providers/database/dataBase_manager.dart';
import 'package:xpirax/providers/web_database_providers.dart';
import 'package:xpirax/widgets/bar_chart.dart';

import '../../data/data.dart';
import '../../data/inventory.dart';
import '../../data/summary_data.dart' as summary_data;
import '../../data/transaction.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    Key? key,
  }) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final List<summary_data.SummaryDataItem> _barList = [
    summary_data.SummaryDataItem(
      item: "mon",
      value: 3,
      id: "mon1",
      barColor: charts.Color.fromOther(
        color: charts.Color.fromHex(code: "#008080"),
      ),
    ),
    summary_data.SummaryDataItem(
      item: "tue",
      value: 4,
      id: "tues2",
      barColor: charts.Color.fromOther(
        color: charts.Color.fromHex(code: "#008080"),
      ),
    ),
    summary_data.SummaryDataItem(
      item: "wed",
      value: 8,
      id: "wed3",
      barColor: charts.Color.fromOther(
        color: charts.Color.fromHex(code: "#008080"),
      ),
    ),
  ];

  double _totalSales = 0;
  double _debt = 0;
  double _cash = 0;

  List<Item> _latestSoldItems = [];
  List<SummaryDataItem> _inventoryBarChartItems = [];

  // @override
  // void initState() {
  //   context.watch<LocalDatabaseHandler>().getTransactions().then((value) {
  //     var cash = value
  //         .map((e) => e.amountPaid)
  //         .fold<num>(0, (previousValue, element) => previousValue + element)
  //         .toDouble();
  //     var debt = value
  //         .map((e) => e.balance)
  //         .fold<num>(0, (previousValue, element) => previousValue + element)
  //         .toDouble();
  //     setState(() {
  //       _totalSales = totalSales;
  //       _debt = debt;
  //       _cash = cash;
  //     });
  //     context
  //         .watch<LocalDatabaseHandler>()
  //         .getItemsFromInventory()
  //         .then(
  //           (value) => value
  //               .map(
  //                 (e) => SummaryDataItem(
  //                   barColor: charts.Color.fromHex(code: "#008080"),
  //                   item: e.name,
  //                   value: e.availableQuantity,
  //                   id: e.uid,
  //                 ),
  //               )
  //               .toList(),
  //         )
  //         .then(
  //           (value) => setState(
  //             () => _inventoryBarChartItems = value,
  //           ),
  //         );
  //   });
  //   context.watch<LocalDatabaseHandler>().getAllSoldItems().then(
  //     (value) {
  //       value.sort(
  //         (a, b) => DateTime.parse(a.date)
  //             .millisecondsSinceEpoch
  //             .compareTo(DateTime.parse(b.date).millisecondsSinceEpoch),
  //       );
  //       return value.reversed.toList();
  //     },
  //   ).then(
  //     (value) => setState(
  //       () => _latestSoldItems =
  //           value.sublist(0, value.length > 10 ? 10 : value.length),
  //     ),
  //   );
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: context.watch<Authentication>().getOfflineBusinessName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("...");
            }
            return Text(
              snapshot.data!.toUpperCase(),
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
                            "Total Sales",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          FutureBuilder<List<Transaction>>(
                            future: context
                                .watch<LocalDatabaseHandler>()
                                .getTransactions(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text(
                                  "0.0",
                                  style: TextStyle(
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              var total = snapshot.data!
                                  .map((e) => e.amount)
                                  .fold<num>(
                                      0,
                                      (previousValue, element) =>
                                          previousValue + element)
                                  .toDouble();
                              return Text(
                                "NGN ${NumberFormat('###,###,###').format(total)}",
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
                            "Cash",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          FutureBuilder<List<Transaction>>(
                            future: context
                                .watch<LocalDatabaseHandler>()
                                .getTransactions(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text(
                                  "0.0",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              var cash = snapshot.data!
                                  .map((e) => e.amountPaid)
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
                            "Debt",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          FutureBuilder<List<Transaction>>(
                            future: context
                                .watch<LocalDatabaseHandler>()
                                .getTransactions(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text(
                                  "0.0",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              var debt = snapshot.data!
                                  .map((e) => e.balance)
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
            FutureBuilder<List<Inventory>>(
              future:
                  context.watch<LocalDatabaseHandler>().getItemsFromInventory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Your Inventory is Empty"),
                  );
                }

                return SizedBox(
                  height: 400.0,
                  child: BarChartWidget(
                    data: snapshot.data!
                        .map(
                          (e) => summary_data.SummaryDataItem(
                            item: e.name,
                            value: e.availableQuantity,
                            id: e.uid,
                            barColor: charts.Color.fromOther(
                              color: charts.Color.fromHex(code: "#008080"),
                            ),
                          ),
                        )
                        .toList(),
                    heading: "Transactions",
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
                children: [
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
            FutureBuilder<List<Item>>(
              future: context.watch<LocalDatabaseHandler>().getAllSoldItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text("No Item is sold, yet."),
                  );
                }

                var items = snapshot.data;
                items!.sort(
                  (a, b) => DateTime.parse(a.date)
                      .millisecondsSinceEpoch
                      .compareTo(DateTime.parse(b.date).millisecondsSinceEpoch),
                );
                return Column(
                  children: items
                      .sublist(0, items.length > 10 ? 10 : items.length)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(e.name),
                                Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Text(
                                      "X ${NumberFormat('###,###,###').format(e.quantity)}"),
                                )
                              ],
                            ),
                            subtitle: Text(
                              DateFormat("d/M/y").format(
                                DateTime.parse(e.date),
                              ),
                            ),
                            trailing: Text(
                              "NGN ${NumberFormat('###,###,###').format(e.amount)}",
                              style: TextStyle(color: Colors.red),
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
