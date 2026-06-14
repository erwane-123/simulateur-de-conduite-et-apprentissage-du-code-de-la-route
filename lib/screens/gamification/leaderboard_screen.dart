import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/services/firebase/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDeep,
        elevation: 0,
        title: const Text('Classement'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.leaderboardStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentCyan),
            );
          }

          if (snapshot.hasError) {
            return const _EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Classement indisponible',
              subtitle: 'Verifie la connexion puis reviens ici.',
            );
          }

          final users = [...(snapshot.data ?? <Map<String, dynamic>>[])];
          users.sort((a, b) {
            final xpCompare = _readInt(b['xp']).compareTo(_readInt(a['xp']));
            if (xpCompare != 0) return xpCompare;
            return _readInt(b['level']).compareTo(_readInt(a['level']));
          });

          if (users.isEmpty) {
            return const _EmptyState(
              icon: Icons.emoji_events_outlined,
              title: 'Aucun score pour le moment',
              subtitle: 'Termine un test pour entrer dans le classement.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final user = users[index];
              final isCurrentUser =
                  currentUid != null && user['uid'] == currentUid;

              return _LeaderboardRow(
                rank: index + 1,
                pseudo: (user['pseudo'] ?? 'Utilisateur').toString(),
                level: _readInt(user['level'], fallback: 1),
                xp: _readInt(user['xp']),
                isCurrentUser: isCurrentUser,
              );
            },
          );
        },
      ),
    );
  }

  static int _readInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String pseudo;
  final int level;
  final int xp;
  final bool isCurrentUser;

  const _LeaderboardRow({
    required this.rank,
    required this.pseudo,
    required this.level,
    required this.xp,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = rank == 1
        ? AppColors.warning
        : rank == 2
            ? AppColors.accentCyan
            : rank == 3
                ? AppColors.secondaryPink
                : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.accentCyan.withValues(alpha: 0.12)
            : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.accentCyan.withValues(alpha: 0.5)
              : AppColors.borderSoft,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                color: rankColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pseudo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Niveau $level',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$xp XP',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.accentCyan, size: 54),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
