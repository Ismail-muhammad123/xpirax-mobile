import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:xpirax/data/business.dart';
import 'package:xpirax/data/inventory.dart';
import 'package:xpirax/data/transaction.dart';
import 'package:xpirax/providers/web_database_providers.dart';
import 'package:xpirax/widgets/bar_chart.dart';
import 'package:xpirax/data/cart_data.dart';
import 'package:xpirax/widgets/circular_charts.dart';
import '../../data/summary_data.dart';
import 'package:intl/intl.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final List<String> _sort_words = [
    "All",
    "This Month",
    "This Year",
  ];

  int _sort_val = 0;

  final GlobalKey genKey = GlobalKey();

  FutureBuilder<List<Inventory>?> get _getInventoryChart {
    return FutureBuilder<List<Inventory>?>(
      future: context.watch<InventoryProvider>().getItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(14.0),
                child: Text(
                  "Inventory is Empty",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }

        List<SummaryDataItem> data = snapshot.data!
            .map(
              (e) => SummaryDataItem(
                id: e.id.toString(),
                item: e.name,
                value: e.availableQuantity,
                barColor: e.availableQuantity > 5
                    ? charts.ColorUtil.fromDartColor(Colors.green)
                    : charts.ColorUtil.fromDartColor(Colors.red),
              ),
            )
            .toList();

        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: SummaryChart(
            heading: 'Inventory'.toUpperCase(),
            data: data,
          ),
        );
      },
    );
  }

  FutureBuilder<List<Map<String, dynamic>>> get _getSalesChart {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: context.watch<TransactionsProvider>().getSummary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "No Transactions yet.",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }

        const uid = Uuid();

        var filteredData = snapshot.data!.map((e) {
          String date = e["date"];
          DateTime dt = DateTime.parse(date);

          if (_sort_val == 1) {
            if (dt.month == DateTime.now().month) {
              return e;
            }
          }
          if (_sort_val == 2) {
            if (dt.year == DateTime.now().year) {
              return e;
            }
          }
          return e;
        }).toList();

        var chartData = filteredData
            .map(
              (e) => SummaryDataItem(
                id: uid.v4(),
                item: e["name"],
                value: e["quantity"],
                barColor: e["quantity"] > 5
                    ? charts.ColorUtil.fromDartColor(Colors.green)
                    : charts.ColorUtil.fromDartColor(Colors.red),
              ),
            )
            .toList();

        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: SummaryChart(
            heading: 'Sold Items'.toUpperCase(),
            data: chartData,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat.yMMMMEEEEd().format(DateTime.now());
    var summaryCardsList = [
      Flexible(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: SizedBox(
            height: 150,
            child: InventoryItemsSummaryCard(),
          ),
        ),
      ),
      Flexible(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: SizedBox(
            height: 150,
            // width: 300,
            child: TransactionsSummaryCard(),
          ),
        ),
      ),
      Flexible(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: SizedBox(
            height: 150,
            // width: 300,
            child: SalesSummaryCard(),
          ),
        ),
      ),
      Flexible(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: SizedBox(
            height: 150,
            // width: 300,
            child: DebtSummaryCard(),
          ),
        ),
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Dashboard"),
        elevation: 0,
        // backgroundColor: Colors.tealAccent,
        actions: [
          SizedBox(
            width: 120.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              alignment: Alignment.center,
              height: 40.0,
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: DropdownButtonFormField<int>(
                icon: const Icon(Icons.sort),
                focusColor: Colors.white,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  fillColor: Colors.white,
                ),
                value: _sort_val,
                items: List.generate(
                  _sort_words.length,
                  (index) => DropdownMenuItem(
                    value: index,
                    child: Text(
                      _sort_words[index],
                    ),
                  ),
                ),
                onChanged: (int? v) => setState(
                  () {
                    _sort_val = v as int;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: genKey,
          child: Padding(
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width > 480 ? 30.0 : 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: FutureBuilder<Business?>(
                    future: context.read<Authentication>().getBusinessDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      return Text(
                        snapshot.data!.name!.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width > 480.0
                              ? 50.0
                              : 28.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal,
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: Text(
                    "Records Summary".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    today,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                GridView.count(
                  childAspectRatio:
                      MediaQuery.of(context).size.width > 400 ? 2.0 : 1.0,
                  shrinkWrap: true,
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 480 ? 4 : 2,
                  children: [
                    InventoryItemsSummaryCard(),
                    TransactionsSummaryCard(),
                    SalesSummaryCard(),
                    DebtSummaryCard(),
                  ]
                      .map((e) => Card(
                            shape: RoundedRectangleBorder(),
                            child: e,
                          ))
                      .toList(),
                ),
                _getInventoryChart,
                _getSalesChart,
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  child: SizedBox(
                    child: Center(
                      child: FutureBuilder<List<Transaction>?>(
                        future: context
                            .read<TransactionsProvider>()
                            .getTransactions(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container();
                          }

                          var transactions = snapshot.data!.map(
                            (e) {
                              String date = e.date!;
                              DateTime dt = DateTime.parse(date);

                              if (_sort_val == 1) {
                                if (dt.month == DateTime.now().month) {
                                  return e;
                                }
                              }
                              if (_sort_val == 2) {
                                if (dt.year == DateTime.now().year) {
                                  return e;
                                }
                              }
                              return e;
                            },
                          );

                          var debt = 0.0;
                          var paid = 0.0;

                          for (var item in transactions) {
                            debt = debt + item.balance;
                            paid = paid + item.amountPaid;
                          }

                          return PieChart(
                            title: "Transactions",
                            chartData: [
                              ChartData("Sales - NGN $paid", paid),
                              ChartData("Debt - NGN $debt", debt, Colors.red),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  child: Container(
                    color: Colors.white,
                    child: const Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Recent Transactions",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 200),
                    child: SingleChildScrollView(
                      child: FutureBuilder<List<Transaction>?>(
                        future: context
                            .read<TransactionsProvider>()
                            .getTransactions(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return SizedBox(
                            width: double.maxFinite,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width - 70),
                                child: DataTable(
                                  columnSpacing: 20.0,
                                  headingTextStyle: const TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                  ),
                                  dataTextStyle: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.0,
                                  ),
                                  columns: const [
                                    DataColumn(label: Text('Name')),
                                    DataColumn(label: Text('Date')),
                                    DataColumn(label: Text('Total Amount')),
                                  ],
                                  rows: snapshot.data!
                                      .map(
                                        (e) => DataRow(
                                          cells: [
                                            DataCell(Text(
                                              e.customerName,
                                              textAlign: TextAlign.center,
                                            )),
                                            DataCell(Text(
                                              DateFormat("dd/mm/yyyy").format(
                                                  DateTime.parse(e.date!)),
                                              textAlign: TextAlign.center,
                                            )),
                                            DataCell(Text(
                                              e.amount.toString(),
                                              textAlign: TextAlign.center,
                                            )),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DebtSummaryCard extends StatelessWidget {
  const DebtSummaryCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Transaction>?>(
          future: context.watch<TransactionsProvider>().getTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            double debts = (snapshot.data ?? []).fold(
                0, (previousValue, element) => previousValue + element.balance);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  debts.toString(),
                  style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width > 480 ? 28.0 : 20.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Debts",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.teal.withOpacity(0.5),
                  ),
                ),
              ],
            );
          }),
    );
  }
}

class SalesSummaryCard extends StatelessWidget {
  const SalesSummaryCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Transaction>?>(
          future: context.watch<TransactionsProvider>().getTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            double transactionSum = (snapshot.data ?? []).fold(
                0, (previousValue, element) => previousValue + element.amount);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  transactionSum.toString(),
                  style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width > 480 ? 28.0 : 20.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Amount",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.teal.withOpacity(0.5),
                  ),
                ),
              ],
            );
          }),
    );
  }
}

class TransactionsSummaryCard extends StatelessWidget {
  const TransactionsSummaryCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Transaction>?>(
          future: context.watch<TransactionsProvider>().getTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            int count = (snapshot.data ?? []).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width > 480 ? 28.0 : 20.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Transactions",
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.teal.withOpacity(0.5),
                  ),
                ),
              ],
            );
          }),
    );
  }
}

class InventoryItemsSummaryCard extends StatelessWidget {
  const InventoryItemsSummaryCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Inventory>?>(
          future: context.watch<InventoryProvider>().getItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            int inventoryCount = (snapshot.data ?? [])
                .where((item) => item.availableQuantity > 0)
                .length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  inventoryCount.toString(),
                  style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width > 480 ? 28.0 : 20.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Items",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.teal.withOpacity(0.5),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
