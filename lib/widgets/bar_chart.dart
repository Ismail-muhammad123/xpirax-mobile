import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../data/data.dart';


class BarChartWidget extends StatelessWidget {
  final List<SummaryDataItem> data;
  final String heading;
  const BarChartWidget({
    Key? key,
    required this.data,
    required this.heading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var chart = [
      charts.Series(
        id: data.first.id,
        data: data,
        domainFn: (SummaryDataItem item, _) => item.item,
        measureFn: (SummaryDataItem item, _) => item.value,
        colorFn: (SummaryDataItem item, _) => item.barColor,
      ),
    ];

    return Container(
      height: 450.0,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        margin: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            children: [
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      heading,
                      style: const TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Total: ${data.length}'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0,
                      ),
                    )
                  ],
                ),
              ),
              Divider(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 6.0)),
              Expanded(
                child: charts.BarChart(
                  chart,
                  animate: true,
                ),
              ),
              Container(
                width: double.maxFinite,
                alignment: Alignment.centerRight,
              )
            ],
          ),
        ),
      ),
    );
  }
}
