import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/screens/dashcam/dashcam_live_scan_screen.dart';
import 'package:flutter/material.dart';

class DashcamScanScreen extends StatelessWidget {
  const DashcamScanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.appBackgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const _FeatureBox(
                        icon: Icons.videocam_rounded,
                        title: 'Situation reelle',
                        desc:
                            'Filme ou photographie une rue pour transformer l environnement en exercice.',
                      ),
                      const SizedBox(height: 14),
                      const _FeatureBox(
                        icon: Icons.priority_high_rounded,
                        title: 'Priorite et correction',
                        desc:
                            'L app pose une question de priorite puis affiche une correction immediate.',
                      ),
                      const SizedBox(height: 14),
                      const _FeatureBox(
                        icon: Icons.warning_amber_rounded,
                        title: 'Detection des dangers',
                        desc:
                            'Enfant au bord du trottoir, pieton hesitant, visibilite masquee ou cycliste proche.',
                      ),
                      const SizedBox(height: 14),
                      const _FeatureBox(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Scenes generees',
                        desc:
                            'Des objets apparaissent aleatoirement pour entrainer le balayage visuel du conducteur.',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DashcamLiveScanScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: const Text('OUVRIR LE COACH DASHCAM'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentCyan,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0E7490), Color(0xFF12356F), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const Spacer(),
              const _Pill(text: 'AI Scan'),
            ],
          ),
          const SizedBox(height: 26),
          const Center(
            child: _ScannerIcon(color: AppColors.accentCyan),
          ),
          const SizedBox(height: 24),
          const Text(
            'Dashcam Coach',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Apprends a scanner une rue comme un conducteur: panneaux, priorites, pietons, dangers et zones masquees.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerIcon extends StatelessWidget {
  final Color color;

  const _ScannerIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.38), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 32,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Icon(Icons.center_focus_strong_rounded, color: color, size: 52),
    );
  }
}

class _FeatureBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureBox({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.accentCyan, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
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
}
