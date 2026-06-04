import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'custom_card.dart';

class StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String? subtitle;
  final String? badge;
  final Color? badgeColor;

  const StatCard({Key? key, required this.icon, required this.label, required this.value, this.subtitle, this.badge, this.badgeColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
          ),
          if (badge != null)
            Text(badge!, style: TextStyle(color: badgeColor ?? AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 16),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ]),
    );
  }
}
