import 'package:flutter/material.dart';

// ######################################################################################################

class ChartData {
  ChartData(this.x, this.y, [this.color = Colors.green]);
  final String x;
  final double y;
  Color color;
}
