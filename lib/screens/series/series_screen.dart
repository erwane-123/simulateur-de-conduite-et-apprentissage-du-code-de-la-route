import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/data/permit_question_bank.dart';
import 'package:code_route_flutter/models/test_question.dart';
import 'package:code_route_flutter/screens/tests/test_screen.dart';
import 'package:code_route_flutter/services/user_progress_service.dart';
import 'package:flutter/material.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({Key? key}) : super(key: key);

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  final _progressService = UserProgressService();
  String _selectedPermit = 'B';
  List<TestQuestion> _questions = const [];
  int _globalMastery = 0;
  bool _isLoading = true;

  final Map<String, _PermitTab> _permitCategories = const {
    'B': _PermitTab('Voiture', Icons.directions_car_rounded),
    'A': _PermitTab('Moto', Icons.two_wheeler_rounded),
    'C': _PermitTab('Camion', Icons.local_shipping_rounded),
    'D': _PermitTab('Bus', Icons.directions_bus_rounded),
  };

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries([String? permitCode]) async {
    setState(() => _isLoading = true);
    final permit = permitCode ?? await _progressService.getSelectedPermitCode();
    final questions = PermitQuestionBank.getQuestionsForPermit(permit);
    final stats = await _progressService.getStatsForPermit(permit);

    if (!mounted) return;
    setState(() {
      _selectedPermit = permit.toUpperCase();
      _questions = questions;
      _globalMastery = stats.successRate;
      _isLoading = false;
    });

    if (permitCode != null) {
      await _progressService.setSelectedPermitCode(permitCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentCyan),
        ),
      );
    }

    final totalQuestions = _questions.length;
    final totalSeries =
        PermitQuestionBank.getSeriesCountForPermit(_selectedPermit);
    final permitLabel = _permitCategories[_selectedPermit]?.title ?? 'Voiture';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(permitLabel, totalQuestions, totalSeries),
              ),
              SliverToBoxAdapter(child: _buildPermitTabs()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                sliver: SliverList.separated(
                  itemCount: totalSeries,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 190 + (index * 18)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 12 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: _buildSeriesCard(
                        serieNumber: index + 1,
                        totalQuestions: totalQuestions,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String permitLabel, int totalQuestions, int totalSeries) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 18, 18, 16),
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
            color: AppColors.accentCyan.withValues(alpha: 0.14),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Permis $_selectedPermit - $permitLabel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _buildMasteryBadge(),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Series d entrainement',
            style: TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$totalQuestions questions organisees en $totalSeries series courtes pour progresser sans perdre le rythme.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (_globalMastery / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        '$_globalMastery%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildPermitTabs() {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        scrollDirection: Axis.horizontal,
        itemCount: _permitCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final key = _permitCategories.keys.elementAt(index);
          final tab = _permitCategories[key]!;
          final isSelected = _selectedPermit == key;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: isSelected ? null : () => _loadSeries(key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 132,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentCyan.withValues(alpha: 0.15)
                      : AppColors.cardBackground.withValues(alpha: 0.74),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentCyan.withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      tab.icon,
                      color: isSelected
                          ? AppColors.accentCyan
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            key,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            tab.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeriesCard({
    required int serieNumber,
    required int totalQuestions,
  }) {
    final startQuestion =
        ((serieNumber - 1) * PermitQuestionBank.questionsPerSeries) + 1;
    final endQuestion =
        (startQuestion + PermitQuestionBank.questionsPerSeries - 1)
            .clamp(1, totalQuestions);
    final requiredScore = (PermitQuestionBank.questionsPerSeries * 0.7).ceil();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TestScreen(
                questionCount: PermitQuestionBank.questionsPerSeries,
                timePerQuestion: 20,
                challengeTitle:
                    'Serie ${serieNumber.toString().padLeft(2, '0')} - $_selectedPermit',
                requiredScore: requiredScore,
                seriesIndex: serieNumber,
              ),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.accentCyan,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Serie ${serieNumber.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Questions $startQuestion-$endQuestion • objectif $requiredScore/${PermitQuestionBank.questionsPerSeries}',
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
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermitTab {
  final String title;
  final IconData icon;

  const _PermitTab(this.title, this.icon);
}
