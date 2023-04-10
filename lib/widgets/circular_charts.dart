// import "package:flutter/material.dart";
// import 'package:syncfusion_flutter_charts/charts.dart';

// class PieChart extends StatefulWidget {
//   final List<ChartData> chartData;
//   final String title;
//   const PieChart({
//     Key? key,
//     required this.title,
//     required this.chartData,
//   }) : super(key: key);

//   @override
//   State<PieChart> createState() => _PieChartState();
// }

// class _PieChartState extends State<PieChart> {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SizedBox(
//         child: SfCircularChart(
//           title: ChartTitle(text: widget.title),
//           legend: Legend(isVisible: true),
//           series: <PieSeries<ChartData, String>>[
//             PieSeries<ChartData, String>(
//                 explode: true,
//                 explodeIndex: 1,
//                 radius: "100%",
//                 dataSource: widget.chartData,
//                 pointColorMapper: (ChartData data, _) => data.color,
//                 xValueMapper: (ChartData data, _) => data.x.toUpperCase(),
//                 yValueMapper: (ChartData data, _) => data.y)
//           ],
//         ),
//       ),
//     );
//   }
// }
