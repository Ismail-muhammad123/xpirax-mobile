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
    "Today",
    "This Month",
    "This Year",
  ];

  int _sortVal = 0;

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

        var filteredData = snapshot.data!.where((e) {
          String date = e["date"];
          DateTime dt = DateTime.parse(date);
          switch (_sortVal) {
            case 1:
              return dt == DateTime.now();
            case 2:
              return dt.month == DateTime.now().month &&
                  dt.year == DateTime.now().year;
            case 3:
              return dt.year == DateTime.now().year;
            default:
              return true;
          }
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

        return filteredData.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(6.0),
                child: SummaryChart(
                  heading: 'Sold Items'.toUpperCase(),
                  data: chartData,
                ),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Container(
                  color: Colors.white,
                  child: const Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "No Transactions recorded today.",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat.yMMMMEEEEd().format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Dashboard"),
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
                value: _sortVal,
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
                    _sortVal = v as int;
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
                      if (!snapshot.hasData) {
                        return Text(
                          "Business Name..",
                          textAlign: TextAlign.center,
                        );
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
                    const InventoryItemsSummaryCard(),
                    TransactionsSummaryCard(
                      filterValue: _sortVal,
                    ),
                    SalesSummaryCard(
                      filterValue: _sortVal,
                    ),
                    DebtSummaryCard(
                      filterValue: _sortVal,
                    ),
                  ]
                      .map((e) => Card(
                            shape: const RoundedRectangleBorder(),
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

                          var transactions = snapshot.data!.where(
                            (e) {
                              String date = e.date!;
                              DateTime dt = DateTime.parse(date);
                              switch (_sortVal) {
                                case 1:
                                  return dt == DateTime.now();
                                case 2:
                                  return dt.month == DateTime.now().month &&
                                      dt.year == DateTime.now().year;
                                case 3:
                                  return dt.year == DateTime.now().year;
                                default:
                                  return true;
                              }
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

                          var transactions = snapshot.data!.where(
                            (e) {
                              String date = e.date!;
                              DateTime dt = DateTime.parse(date);
                              switch (_sortVal) {
                                case 1:
                                  return dt == DateTime.now();
                                case 2:
                                  return dt.month == DateTime.now().month &&
                                      dt.year == DateTime.now().year;
                                case 3:
                                  return dt.year == DateTime.now().year;
                                default:
                                  return true;
                              }
                            },
                          ).toList();

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
                                  rows: transactions
                                      .sublist(
                                          0, transactions.length > 5 ? 5 : null)
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
  final int filterValue;
  const DebtSummaryCard({
    this.filterValue = 0,
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

            var filteredData = snapshot.data!.where((e) {
              DateTime dt = DateTime.parse(e.date!);
              switch (filterValue) {
                case 1:
                  return dt == DateTime.now();
                case 2:
                  return dt.month == DateTime.now().month &&
                      dt.year == DateTime.now().year;
                case 3:
                  return dt.year == DateTime.now().year;
                default:
                  return true;
              }
            }).toList();

            double debts = (filteredData).fold(
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
  final int filterValue;
  const SalesSummaryCard({
    this.filterValue = 0,
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

            var filteredData = snapshot.data!.where((e) {
              DateTime dt = DateTime.parse(e.date!);
              switch (filterValue) {
                case 1:
                  return dt == DateTime.now();
                case 2:
                  return dt.month == DateTime.now().month &&
                      dt.year == DateTime.now().year;
                case 3:
                  return dt.year == DateTime.now().year;
                default:
                  return true;
              }
            }).toList();

            double transactionSum = (filteredData).fold(
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
  final int filterValue;
  const TransactionsSummaryCard({
    this.filterValue = 0,
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

            var filteredData = snapshot.data!.where((e) {
              DateTime dt = DateTime.parse(e.date!);
              switch (filterValue) {
                case 1:
                  return dt == DateTime.now();
                case 2:
                  return dt.month == DateTime.now().month &&
                      dt.year == DateTime.now().year;
                case 3:
                  return dt.year == DateTime.now().year;
                default:
                  return true;
              }
            }).toList();

            int count = (filteredData).length;

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
