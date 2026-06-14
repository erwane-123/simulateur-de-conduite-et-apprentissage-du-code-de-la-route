import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/services/gamification_service.dart';
import 'package:flutter/material.dart';

class GamificationSummaryCard extends StatelessWidget {
  final GamificationState state;
  final VoidCallback onLeaderboardTap;

  const GamificationSummaryCard({
    Key? key,
    required this.state,
    required this.onLeaderboardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badges = _visibleBadges(state.badges);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123A5A), Color(0xFF163B2F), Color(0xFF3F2A68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Flame(streak: state.streak),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niveau ${state.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${state.totalXp} XP au total',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onLeaderboardTap,
                icon: const Icon(Icons.leaderboard_rounded),
                tooltip: 'Classement',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AnimatedXpBar(value: state.levelProgress),
          const SizedBox(height: 8),
          Text(
            state.level >= GamificationService.maxLevel
                ? 'Niveau max atteint'
                : '${state.xpInLevel}/${state.xpForNextLevel} XP avant niveau ${state.level + 1}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges.map((badge) => _BadgeChip(badge: badge)).toList(),
          ),
        ],
      ),
    );
  }

  List<_BadgeInfo> _visibleBadges(List<String> ids) {
    const all = [
      _BadgeInfo('first_pass', 'Premier test', Icons.flag_rounded,
          AppColors.accentCyan),
      _BadgeInfo('perfect', 'Sans faute', Icons.workspace_premium_rounded,
          AppColors.warning),
      _BadgeInfo('streak_3', '3 jours', Icons.local_fire_department_rounded,
          AppColors.error),
      _BadgeInfo('streak_7', '7 jours', Icons.whatshot_rounded,
          AppColors.secondaryPink),
      _BadgeInfo(
          'level_5', 'Niv. 5', Icons.military_tech_rounded, AppColors.success),
      _BadgeInfo(
          'xp_1000', '1000 XP', Icons.bolt_rounded, AppColors.accentTeal),
    ];

    final earned = all.where((badge) => ids.contains(badge.id)).toList();
    if (earned.isEmpty) {
      return const [
        _BadgeInfo('starter', 'Pret a rouler', Icons.rocket_launch_rounded,
            AppColors.accentCyan),
      ];
    }
    return earned;
  }
}

class _AnimatedXpBar extends StatelessWidget {
  final double value;

  const _AnimatedXpBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: 12,
            backgroundColor: Colors.white.withValues(alpha: 0.14),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.warning,
            ),
          ),
        );
      },
    );
  }
}

class _Flame extends StatelessWidget {
  final int streak;

  const _Flame({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.46)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.warning,
            size: 26,
          ),
          Text(
            '${streak}j',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final _BadgeInfo badge;

  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: badge.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badge.color.withValues(alpha: 0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badge.icon, size: 17, color: badge.color),
          const SizedBox(width: 6),
          Text(
            badge.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeInfo {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const _BadgeInfo(this.id, this.label, this.icon, this.color);
}
