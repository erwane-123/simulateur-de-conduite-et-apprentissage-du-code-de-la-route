import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _enabled = true;
  bool _dailyReminder = true;
  bool _weeklyReport = true;
  bool _achievementAlerts = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _enabled = prefs.getBool('notifications_enabled') ?? true;
      _dailyReminder = prefs.getBool('notif_daily_reminder') ?? true;
      _weeklyReport = prefs.getBool('notif_weekly_report') ?? true;
      _achievementAlerts = prefs.getBool('notif_achievement_alerts') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Notifications'),
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
                _SwitchCard(
                  title: 'Activer les notifications',
                  subtitle:
                      'Controle global des rappels et messages de progression.',
                  value: _enabled,
                  onChanged: (value) async {
                    await _saveBool('notifications_enabled', value);
                    setState(() => _enabled = value);
                  },
                ),
                const SizedBox(height: 12),
                _SwitchCard(
                  title: 'Rappel quotidien',
                  subtitle:
                      'Recevoir un rappel pour maintenir votre serie de revision.',
                  value: _dailyReminder,
                  onChanged: _enabled
                      ? (value) async {
                          await _saveBool('notif_daily_reminder', value);
                          setState(() => _dailyReminder = value);
                        }
                      : null,
                ),
                const SizedBox(height: 12),
                _SwitchCard(
                  title: 'Resume hebdomadaire',
                  subtitle:
                      'Afficher un bilan simple de vos tests et de votre progression.',
                  value: _weeklyReport,
                  onChanged: _enabled
                      ? (value) async {
                          await _saveBool('notif_weekly_report', value);
                          setState(() => _weeklyReport = value);
                        }
                      : null,
                ),
                const SizedBox(height: 12),
                _SwitchCard(
                  title: 'Alertes de niveaux et succes',
                  subtitle:
                      'Etre prevenu lors des passages de niveau ou de bons scores.',
                  value: _achievementAlerts,
                  onChanged: _enabled
                      ? (value) async {
                          await _saveBool('notif_achievement_alerts', value);
                          setState(() => _achievementAlerts = value);
                        }
                      : null,
                ),
              ],
            ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SwitchCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }
}
