import 'package:dltb/components/color.dart';
import 'package:flutter/material.dart';

class DLTBContainer extends StatelessWidget {
  const DLTBContainer({
    super.key,
    required this.isTop,
    required this.isBottom,
    required this.label,
    required this.value,
  });

  final String value;
  final String label;
  final bool isTop;
  final bool isBottom;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: isTop
              ? BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))
              : (isBottom
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))
                  : BorderRadius.circular(0))),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                '${label.toUpperCase()}',
                style: TextStyle(color: Colors.white),
              ),
            )),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.35,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: isTop
                      ? BorderRadius.only(topRight: Radius.circular(20))
                      : (isBottom
                          ? BorderRadius.only(bottomRight: Radius.circular(20))
                          : BorderRadius.circular(0))),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${value}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
