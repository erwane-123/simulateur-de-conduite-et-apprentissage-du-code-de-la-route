import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const ProgressBar({Key? key, required this.label, required this.value, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Text('${(value * 100).toInt()}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ]),
      const SizedBox(height: 8),
      Container(
        height: 8,
        decoration: BoxDecoration(color: AppColors.bgElevated, borderRadius: BorderRadius.circular(4)),
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          alignment: Alignment.centerLeft,
          child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        ),
      ),
    ]);
  }
}
