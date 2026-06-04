import 'package:flutter/material.dart';
import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/data/permit_question_bank.dart';
import 'package:code_route_flutter/data/models/theme_code.dart';
import 'package:code_route_flutter/screens/tests/test_screen.dart';
import 'package:code_route_flutter/services/user_progress_service.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  final _progressService = UserProgressService();
  List<ThemeCode> _themes = [];
  bool _isLoading = true;
  String _permitCode = 'B';

  @override
  void initState() {
    super.initState();
    _loadThemesData();
  }

  Future<void> _loadThemesData() async {
    final permit = await _progressService.getSelectedPermitCode();
    final allThemes = ThemeCode.getAllThemes();
    final questionsByTheme = <String, int>{};
    for (final question in PermitQuestionBank.getQuestionsForPermit(permit)) {
      questionsByTheme.update(
        question.themeId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    final updatedThemes = <ThemeCode>[];

    for (final theme in allThemes) {
      final progress = await _progressService.getThemeProgress(
        themeId: theme.id,
        permitCode: permit,
      );
      final questionsTotal = questionsByTheme[theme.id] ?? 0;
      updatedThemes.add(
        ThemeCode(
          id: theme.id,
          name: theme.name,
          icon: theme.icon,
          progress: progress,
          questionsTotal: questionsTotal,
          questionsAnswered: (progress * questionsTotal).round(),
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _permitCode = permit.toUpperCase();
      _themes = updatedThemes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accentCyan),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                    sliver: SliverList.separated(
                      itemCount: _themes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 220 + index * 35),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 18 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: _buildThemeCard(
                            _themes[index],
                            index,
                            _isThemeUnlocked(index),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final activeThemes = _themes.where((theme) => theme.progress > 0).toList();
    final average = activeThemes.isEmpty
        ? 0.0
        : activeThemes.fold<double>(0, (sum, theme) => sum + theme.progress) /
            activeThemes.length;
    final completed = _themes.where((theme) => theme.progress >= 0.8).length;
    final inProgress = _themes
        .where((theme) => theme.progress > 0 && theme.progress < 0.8)
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF12356F), Color(0xFF0F766E), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(alpha: 0.16),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                ),
              ),
              const Spacer(),
              _buildHeaderPill('Permis $_permitCode'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Revision par theme',
            style: TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Choisis un theme, revise avec des questions adaptees et fais monter ton niveau progressivement.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildSummaryMetric(
                '${(average * 100).round()}%',
                'moyenne',
                Icons.trending_up_rounded,
              ),
              const SizedBox(width: 10),
              _buildSummaryMetric(
                '$completed',
                'maitrises',
                Icons.verified_rounded,
              ),
              const SizedBox(width: 10),
              _buildSummaryMetric(
                '$inProgress',
                'en cours',
                Icons.bolt_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF020617).withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.68),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isThemeUnlocked(int index) {
    if (index == 0) return true;
    return _themes[index - 1].progress >= 0.8;
  }

  Widget _buildThemeCard(ThemeCode theme, int index, bool isUnlocked) {
    final color =
        isUnlocked ? _themeColor(index, theme.progress) : AppColors.textMuted;
    final percent = (theme.progress * 100).round();
    final status = isUnlocked
        ? _themeStatus(theme.progress)
        : const _ThemeStatus(
            'Verrouille',
            Icons.lock_rounded,
            AppColors.textMuted,
          );
    final icon = _themeIcon(theme.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () =>
            isUnlocked ? _startTheme(theme) : _showLockedThemeMessage(index),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnlocked
                ? AppColors.cardBackground
                : AppColors.cardBackground.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: color.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isUnlocked ? icon : Icons.lock_rounded,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          isUnlocked
                              ? 'Total: ${theme.questionsTotal} questions - ${theme.questionsAnswered} revisees'
                              : 'Total: ${theme.questionsTotal} questions - theme verrouille',
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
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$percent%',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: theme.progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.progress == 0 || !isUnlocked
                        ? AppColors.cardLight
                        : color,
                  ),
                  minHeight: 7,
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Icon(status.icon, color: status.color, size: 17),
                  const SizedBox(width: 6),
                  Text(
                    status.label,
                    style: TextStyle(
                      color: status.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: isUnlocked
                        ? () => _startTheme(theme)
                        : () => _showLockedThemeMessage(index),
                    style: TextButton.styleFrom(
                      foregroundColor: color,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      isUnlocked
                          ? Icons.play_arrow_rounded
                          : Icons.lock_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isUnlocked ? 'Reviser' : 'Bloque',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLockedThemeMessage(int index) {
    final previousThemeName = _themes[index - 1].name;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Termine $previousThemeName avec au moins 80% pour debloquer cette revision.',
        ),
        backgroundColor: AppColors.cardLight,
      ),
    );
  }

  Future<void> _startTheme(ThemeCode theme) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestScreen(
          questionCount: 30,
          timePerQuestion: 20,
          requiredScore: 24,
          challengeTitle: 'Revision: ${theme.name}',
          themeIdFilter: theme.id,
        ),
      ),
    );
    await _loadThemesData();
  }

  Color _themeColor(int index, double progress) {
    if (progress >= 0.8) return AppColors.success;
    if (progress >= 0.45) return AppColors.warning;
    const colors = [
      AppColors.accentCyan,
      AppColors.secondaryPink,
      AppColors.primaryPurple,
      Color(0xFF22C55E),
      Color(0xFFF97316),
    ];
    return colors[index % colors.length];
  }

  IconData _themeIcon(String id) {
    switch (id) {
      case '1':
        return Icons.alt_route_rounded;
      case '2':
        return Icons.psychology_rounded;
      case '3':
        return Icons.route_rounded;
      case '4':
        return Icons.groups_rounded;
      case '5':
        return Icons.rule_rounded;
      case '6':
        return Icons.medical_services_rounded;
      case '7':
        return Icons.sensor_door_rounded;
      case '8':
        return Icons.build_rounded;
      case '9':
        return Icons.airline_seat_recline_normal_rounded;
      default:
        return Icons.eco_rounded;
    }
  }

  _ThemeStatus _themeStatus(double progress) {
    if (progress >= 0.8) {
      return const _ThemeStatus(
        'Theme maitrise',
        Icons.verified_rounded,
        AppColors.success,
      );
    }
    if (progress > 0) {
      return const _ThemeStatus(
        'Progression active',
        Icons.trending_up_rounded,
        AppColors.warning,
      );
    }
    return const _ThemeStatus(
      'A commencer',
      Icons.radio_button_unchecked_rounded,
      AppColors.textMuted,
    );
  }
}

class _ThemeStatus {
  final String label;
  final IconData icon;
  final Color color;

  const _ThemeStatus(this.label, this.icon, this.color);
}
