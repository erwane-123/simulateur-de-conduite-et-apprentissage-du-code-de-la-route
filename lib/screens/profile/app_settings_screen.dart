import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/data/models/permis_category.dart';
import 'package:code_route_flutter/services/user_progress_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final _progressService = UserProgressService();
  final _categories = PermisCategory.getAllCategories();

  bool _isLoading = true;
  String _selectedPermit = 'B';
  bool _voiceEnabled = true;
  bool _autoReadQuestions = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final permit = await _progressService.getSelectedPermitCode();
    if (!mounted) return;
    setState(() {
      _selectedPermit = permit;
      _voiceEnabled = prefs.getBool('settings_voice_enabled') ?? true;
      _autoReadQuestions =
          prefs.getBool('settings_auto_read_questions') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _savePermit(String permitCode) async {
    await _progressService.setSelectedPermitCode(permitCode);
    if (!mounted) return;
    setState(() => _selectedPermit = permitCode);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Categorie de permis mise a jour.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.appBackgroundGradient),
        child: SafeArea(
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
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            _SettingsCard(
                              icon: Icons.credit_card_rounded,
                              title: 'Permis par defaut',
                              subtitle:
                                  'Choisis la categorie utilisee dans les tests et revisions.',
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedPermit,
                                dropdownColor: AppColors.cardBackground,
                                decoration: const InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.directions_car_rounded),
                                ),
                                style: const TextStyle(color: Colors.white),
                                items: _categories
                                    .map(
                                      (category) => DropdownMenuItem<String>(
                                        value: category.code,
                                        child: Text(
                                          '${category.name} - ${category.description}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) _savePermit(value);
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            _SettingsCard(
                              icon: Icons.record_voice_over_rounded,
                              title: 'Assistant vocal',
                              subtitle:
                                  'Controle les comportements audio pendant les exercices.',
                              child: Column(
                                children: [
                                  _SwitchRow(
                                    title: 'Lecture vocale active',
                                    subtitle:
                                        'Autoriser les fonctions vocales pendant les tests et les PDF.',
                                    value: _voiceEnabled,
                                    onChanged: (value) async {
                                      await _saveBool(
                                          'settings_voice_enabled', value);
                                      setState(() => _voiceEnabled = value);
                                    },
                                  ),
                                  Divider(
                                      color:
                                          Colors.white.withValues(alpha: 0.08)),
                                  _SwitchRow(
                                    title: 'Lecture automatique',
                                    subtitle:
                                        'Lire les questions des leur affichage.',
                                    value: _autoReadQuestions,
                                    onChanged: (value) async {
                                      await _saveBool(
                                          'settings_auto_read_questions',
                                          value);
                                      setState(
                                          () => _autoReadQuestions = value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            const _InfoPanel(),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF12356F), Color(0xFF0F766E), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Permis $_selectedPermit',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Parametres',
            style: TextStyle(
                color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Personnalise ton apprentissage et tes preferences de revision.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.76), height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.accentCyan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.35,
                        fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accentCyan,
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.accentTeal),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ces reglages sont gardes localement pour adapter ton experience sans ralentir ton apprentissage.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
