import 'package:flutter/material.dart';

enum CoachMood { excited, happy, neutral, warning, sad }

class CoachCharacter extends StatelessWidget {
  final CoachMood mood;
  final String message;
  final String name;
  final bool compact;

  const CoachCharacter({
    Key? key,
    required this.mood,
    required this.message,
    this.name = 'Kody',
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _colorForMood(mood);
    final emoji = _emojiForMood(mood);
    final bubblePadding = compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 10);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: compact ? 44 : 56,
          height: compact ? 44 : 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(color: color.withOpacity(0.8), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: compact ? 20 : 24),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: bubblePadding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$name  ',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: compact ? 12 : 13,
                    ),
                  ),
                  TextSpan(
                    text: message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: compact ? 12 : 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _emojiForMood(CoachMood mood) {
    switch (mood) {
      case CoachMood.excited:
        return '🤩';
      case CoachMood.happy:
        return '😄';
      case CoachMood.warning:
        return '🫣';
      case CoachMood.sad:
        return '🥲';
      case CoachMood.neutral:
        return '🙂';
    }
  }

  Color _colorForMood(CoachMood mood) {
    switch (mood) {
      case CoachMood.excited:
        return const Color(0xFFF59E0B);
      case CoachMood.happy:
        return const Color(0xFF22C55E);
      case CoachMood.warning:
        return const Color(0xFFF97316);
      case CoachMood.sad:
        return const Color(0xFFEF4444);
      case CoachMood.neutral:
        return const Color(0xFF60A5FA);
    }
  }
}
