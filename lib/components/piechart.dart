import 'package:flutter/material.dart';
import 'dart:math';

class PieChart extends StatelessWidget {
  // const PieChart({
  //   super.key,
  //   required this.data,
  // });
  // final List<PieData> data;
  final List<PieData> data = [
    PieData(value: 2, color: Colors.blue, label: 'Ticket Issued'),
    PieData(value: 2, color: Colors.red, label: 'Passenger Revenue'),
    PieData(value: 30, color: Colors.orange, label: 'Gross Revenue'),
    PieData(value: 1, color: Colors.green, label: 'Baggage Revenue'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
              color: Colors.white.withOpacity(.5),
              offset: Offset(0, 0),
              blurRadius: 10,
              spreadRadius: 2)
        ],
      ),
      child: CustomPaint(
        painter: PieChartPainter(data),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<PieData> data;
  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    double total = data.fold(0.0, (prev, element) => prev + element.value);
    double startRadian = 0.0;

    for (var pieData in data) {
      final sweepRadian = (pieData.value / total) * 2 * pi;
      final paint = Paint()..color = pieData.color;

      canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height), startRadian,
          sweepRadian, true, paint);

      // Calculate the position for label
      final centerX = size.width / 2 - 15;
      final centerY = size.height / 2 - 10;
      final angle = startRadian + sweepRadian / 2;
      final labelX =
          centerX + cos(angle) * size.width / 4; // 1/4 radius from center
      final labelY =
          centerY + sin(angle) * size.height / 4; // 1/4 radius from center

      // Draw label text
      pieData.value != 0
          ? TextPainter(
              text: TextSpan(
                text: "${pieData.value}",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              textAlign: TextAlign.left,
              textDirection: TextDirection.ltr,
            )
          : TextPainter()
        ..layout(
          minWidth: 0,
          maxWidth: size.width,
        )
        ..paint(
          canvas,
          Offset(labelX, labelY),
        );

      startRadian += sweepRadian;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PieData {
  final double value;
  final Color color;
  final String label;

  PieData({required this.value, required this.color, required this.label});
}
