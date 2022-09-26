import 'package:charts_flutter/flutter.dart' as charts;


class SummaryDataItem {
  final String id;
  final String item;
  final int value;
  final charts.Color barColor;

  SummaryDataItem({
    required this.item,
    required this.value,
    required this.barColor,
    required this.id,
  });
}