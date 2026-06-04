import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/data/models/permis_category.dart';
import 'package:code_route_flutter/screens/arena/code_arena_screen.dart';
import 'package:code_route_flutter/screens/auto_ecole/auto_ecole_screen.dart';
import 'package:code_route_flutter/screens/candidat/candidat_screen.dart';
import 'package:code_route_flutter/screens/categories/category_selection_screen.dart';
import 'package:code_route_flutter/screens/cours/cours_list_screen.dart';
import 'package:code_route_flutter/screens/dashcam/dashcam_scan_screen.dart';
import 'package:code_route_flutter/screens/guides/guides_screen.dart';
import 'package:code_route_flutter/screens/profile/profile_screen.dart';
import 'package:code_route_flutter/screens/series/series_screen.dart';
import 'package:code_route_flutter/screens/themes/theme_selection_screen.dart';
import 'package:code_route_flutter/services/user_progress_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _progressService = UserProgressService();

  String? _selectedCategory;
  IconData _categoryIcon = Icons.directions_car_rounded;
  String _userName = 'Utilisateur';
  int _successRate = 0;
  int _testsCount = 0;
  int _mistakesCount = 0;
  int _streakCount = 0;
  int _xp = 0;
  int _level = 1;
  double _circulationProgress = 0;
  double _conductorProgress = 0;
  double _roadProgress = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedPermit = await _progressService.getSelectedPermitCode();
    final permitStats =
        await _progressService.getStatsForPermit(selectedPermit);

    if (!mounted) return;
    setState(() {
      _selectedCategory = selectedPermit;
      _userName = prefs.getString('candidat_prenom') ??
          prefs.getString('userName') ??
          'Utilisateur';
      _successRate = permitStats.successRate;
      _testsCount = permitStats.testsCount;
      _mistakesCount = permitStats.mistakesCount;
      _streakCount = permitStats.streakCount;
      _xp = permitStats.xp;
      _level = permitStats.level;
      _circulationProgress =
          prefs.getDouble('prog_${selectedPermit.toUpperCase()}_1') ??
              prefs.getDouble('prog_circulation') ??
              0;
      _conductorProgress =
          prefs.getDouble('prog_${selectedPermit.toUpperCase()}_2') ??
              prefs.getDouble('prog_conductor') ??
              0;
      _roadProgress =
          prefs.getDouble('prog_${selectedPermit.toUpperCase()}_3') ??
              prefs.getDouble('prog_road') ??
              0;

      final categories = PermisCategory.getAllCategories();
      final category = categories.firstWhere(
        (item) => item.code == _selectedCategory,
        orElse: () => categories.first,
      );
      _categoryIcon = category.icon;
    });
  }

  Future<void> _showCategorySelection() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
    );
    if (result == null) return;

    await _progressService.setSelectedPermitCode(result);
    await _loadUserData();
  }

  Future<void> _openThemeSelection() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThemeSelectionScreen()),
    );
    if (mounted) await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width >= 900 ? 32.0 : 18.0;
    final contentMaxWidth = width >= 1180 ? 1080.0 : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    96,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _DashboardHeader(
                          userName: _userName,
                          selectedCategory: _selectedCategory ?? 'Catégorie',
                          categoryIcon: _categoryIcon,
                          onCategoryTap: _showCategorySelection,
                          onProfileTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        _PrimaryActionCard(
                          level: _level,
                          xp: _xp,
                          onStart: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SeriesScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        _StatsGrid(
                          stats: [
                            _StatData(
                              Icons.verified_outlined,
                              'Réussite',
                              '$_successRate%',
                              AppColors.success,
                            ),
                            _StatData(
                              Icons.quiz_outlined,
                              'Tests',
                              '$_testsCount',
                              AppColors.accentCyan,
                            ),
                            _StatData(
                              Icons.error_outline,
                              'Fautes',
                              '$_mistakesCount',
                              AppColors.warning,
                            ),
                            _StatData(
                              Icons.local_fire_department_outlined,
                              'Série',
                              '${_streakCount}j',
                              AppColors.accentTeal,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _SectionTitle(
                          title: 'Révision',
                          actionLabel: 'Tous les thèmes',
                          onActionTap: _openThemeSelection,
                        ),
                        const SizedBox(height: 10),
                        _RevisionCard(
                          items: [
                            _ProgressData(
                              Icons.alt_route_rounded,
                              'Circulation',
                              _circulationProgress,
                              AppColors.accentCyan,
                            ),
                            _ProgressData(
                              Icons.psychology_outlined,
                              'Le conducteur',
                              _conductorProgress,
                              AppColors.primaryPurple,
                            ),
                            _ProgressData(
                              Icons.route_rounded,
                              'La route',
                              _roadProgress,
                              AppColors.accentTeal,
                            ),
                          ],
                          onTap: _openThemeSelection,
                        ),
                        const SizedBox(height: 18),
                        const _SectionTitle(title: 'Accès rapide'),
                        const SizedBox(height: 10),
                        _QuickActions(
                          actions: [
                            _ActionData(
                              Icons.traffic_rounded,
                              'Séries',
                              'Tests d’entraînement',
                              AppColors.accentCyan,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SeriesScreen(),
                                ),
                              ),
                            ),
                            _ActionData(
                              Icons.menu_book_rounded,
                              'Guides',
                              'Conseils pratiques',
                              AppColors.success,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GuidesScreen(),
                                ),
                              ),
                            ),
                            _ActionData(
                              Icons.badge_rounded,
                              'Dossier',
                              'Profil candidat',
                              AppColors.warning,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CandidatScreen(),
                                ),
                              ),
                            ),
                            _ActionData(
                              Icons.school_rounded,
                              'Cours',
                              'Supports PDF',
                              AppColors.primaryPurple,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CoursListScreen(),
                                ),
                              ),
                            ),
                            _ActionData(
                              Icons.groups_2_rounded,
                              'Auto-école',
                              'Inscription',
                              AppColors.accentTeal,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AutoEcoleScreen(),
                                ),
                              ),
                            ),
                            _ActionData(
                              Icons.center_focus_strong,
                              'Dashcam',
                              'Analyse visuelle',
                              AppColors.error,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DashcamScanScreen(),
                                ),
                              ),
                            ),
                            _ActionData(
                              Icons.emoji_events_outlined,
                              'Arena',
                              'Défis rapides',
                              AppColors.accentBlue,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CodeArenaScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String userName;
  final String selectedCategory;
  final IconData categoryIcon;
  final VoidCallback onCategoryTap;
  final VoidCallback onProfileTap;

  const _DashboardHeader({
    required this.userName,
    required this.selectedCategory,
    required this.categoryIcon,
    required this.onCategoryTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, $userName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Votre espace code de la route',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _IconTextButton(
          icon: categoryIcon,
          label: selectedCategory,
          onTap: onCategoryTap,
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onProfileTap,
          icon: const Icon(Icons.person_outline_rounded),
          tooltip: 'Profil',
        ),
      ],
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  final int level;
  final int xp;
  final VoidCallback onStart;

  const _PrimaryActionCard({
    required this.level,
    required this.xp,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final progress = ((xp % 1000) / 1000).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _surfaceDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.accentCyan,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continuer l’entraînement',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Une série courte pour progresser régulièrement.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accentCyan,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Niv. $level',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Commencer'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<_StatData> stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 4 ? 1.65 : 1.45,
          ),
          itemBuilder: (context, index) => _StatTile(data: stats[index]),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final _StatData data;

  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _surfaceDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(data.icon, color: data.color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _RevisionCard extends StatelessWidget {
  final List<_ProgressData> items;
  final VoidCallback onTap;

  const _RevisionCard({
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: _surfaceDecoration(),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _ProgressRow(data: items[i]),
                if (i < items.length - 1)
                  Divider(
                    height: 22,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final _ProgressData data;

  const _ProgressRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final percent = (data.progress.clamp(0.0, 1.0) * 100).round();

    return Row(
      children: [
        Icon(data.icon, color: data.color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: data.progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(data.color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final List<_ActionData> actions;

  const _QuickActions({required this.actions});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
                ? 3
                : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 2 ? 1.14 : 1.5,
          ),
          itemBuilder: (context, index) => _ActionTile(data: actions[index]),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  final _ActionData data;

  const _ActionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: data.onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: _surfaceDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(data.icon, color: data.color, size: 24),
              const Spacer(),
              Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTextButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconTextButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.accentCyan, size: 18),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 78),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _surfaceDecoration() {
  return BoxDecoration(
    color: AppColors.surfaceElevated,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.borderSoft),
  );
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatData(this.icon, this.label, this.value, this.color);
}

class _ProgressData {
  final IconData icon;
  final String title;
  final double progress;
  final Color color;

  const _ProgressData(this.icon, this.title, this.progress, this.color);
}

class _ActionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionData(
    this.icon,
    this.title,
    this.subtitle,
    this.color,
    this.onTap,
  );
}
