import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';
import 'package:xpirax/providers/web_database_providers.dart';
import 'package:xpirax/widgets/bar_chart.dart';

import '../../data/data.dart';
import '../../data/summary_data.dart' as summary_data;

class Dashboard extends StatelessWidget {
  Dashboard({
    Key? key,
  }) : super(key: key);

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
            // Padding(
            //   padding: EdgeInsets.all(14.0),
            //   child: Row(
            //     children: [
            //       Text(
            //         "Hello, Ismail Muhammad",
            //         style: TextStyle(
            //           fontSize: 18.0,
            //           color: Colors.teal,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
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
                        children: const [
                          Text(
                            "Total Sales",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "NGN 9,900,987",
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                            ),
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
                        children: const [
                          Text(
                            "Cash",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "NGN 987",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
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
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.grey.withOpacity(0.3),
                        //     offset: const Offset(6, 6),
                        //     blurRadius: 8.0,
                        //   ),
                        // ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Text(
                            "Debt",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "NGN 987",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 400.0,
              child: BarChartWidget(
                data: _barList,
                heading: "Transactions",
              ),
            ),
            Padding(
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
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Item Name"),
                subtitle: Text("12/12/2022"),
                trailing: Text("NGN 6,768"),
                tileColor: Colors.tealAccent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Item Name"),
                subtitle: Text("12/12/2022"),
                trailing: Text("NGN 6,768"),
                tileColor: Colors.tealAccent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                title: Text("Item Name"),
                subtitle: Text("12/12/2022"),
                trailing: Text("NGN 6,768"),
                tileColor: Colors.tealAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
