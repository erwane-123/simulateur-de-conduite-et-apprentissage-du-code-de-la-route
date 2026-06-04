import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/data/models/theme_code.dart';
import 'package:code_route_flutter/services/user_progress_service.dart';
import 'package:flutter/material.dart';

class StatsDetailScreen extends StatefulWidget {
  const StatsDetailScreen({Key? key}) : super(key: key);

  @override
  State<StatsDetailScreen> createState() => _StatsDetailScreenState();
}

class _StatsDetailScreenState extends State<StatsDetailScreen> {
  final _progressService = UserProgressService();

  bool _isLoading = true;
  String _selectedPermit = 'B';
  PermitStats _stats = const PermitStats(
    testsCount: 0,
    successRate: 0,
    mistakesCount: 0,
    streakCount: 0,
    xp: 0,
    level: 1,
  );
  Map<String, double> _themeProgress = const {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final permit = await _progressService.getSelectedPermitCode();
    final stats = await _progressService.getStatsForPermit(permit);
    final themes = ThemeCode.getAllThemes();
    final progress = await _progressService.getThemeProgressMap(
      themes.map((t) => t.id).toList(),
      permitCode: permit,
    );

    if (!mounted) return;
    setState(() {
      _selectedPermit = permit;
      _stats = stats;
      _themeProgress = progress;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Statistiques detaillees'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Permis $_selectedPermit',
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Les indicateurs ci-dessous sont lus depuis la couche centrale de progression utilisateur.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatTile(
                      title: 'Tests',
                      value: _stats.testsCount.toString(),
                      icon: Icons.fact_check_outlined,
                      color: const Color(0xFF38BDF8),
                    ),
                    _StatTile(
                      title: 'Reussite',
                      value: '${_stats.successRate}%',
                      icon: Icons.track_changes,
                      color: const Color(0xFF34D399),
                    ),
                    _StatTile(
                      title: 'Fautes',
                      value: _stats.mistakesCount.toString(),
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFF97316),
                    ),
                    _StatTile(
                      title: 'Serie',
                      value: '${_stats.streakCount} j',
                      icon: Icons.local_fire_department_outlined,
                      color: const Color(0xFFE879F9),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progression XP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Niveau ${_stats.level}',
                            style: const TextStyle(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_stats.xp} XP',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (_stats.xp % 1000) / 1000,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progression par theme',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...ThemeCode.getAllThemes().map((theme) {
                        final progress = _themeProgress[theme.id] ?? 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    theme.icon,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      theme.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).round()}%',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.08),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF22D3EE),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardBackground.withOpacity(0.85),
            AppColors.cardBackground.withOpacity(0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 44) / 2;
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
