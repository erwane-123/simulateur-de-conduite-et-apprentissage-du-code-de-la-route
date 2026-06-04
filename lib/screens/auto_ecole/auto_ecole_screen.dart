import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/services/firebase/auto_ecole_service.dart';
import 'package:code_route_flutter/services/user_progress_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AutoEcoleScreen extends StatefulWidget {
  const AutoEcoleScreen({Key? key}) : super(key: key);

  @override
  State<AutoEcoleScreen> createState() => _AutoEcoleScreenState();
}

class _AutoEcoleScreenState extends State<AutoEcoleScreen> {
  final _service = AutoEcoleService();
  final _progressService = UserProgressService();

  final _schoolNameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _monitorNameCtrl = TextEditingController();
  final _classCodeCtrl = TextEditingController();
  final _studentNomCtrl = TextEditingController();
  final _studentPrenomCtrl = TextEditingController();
  final _lessonTitleCtrl = TextEditingController();
  final _lessonDurationCtrl = TextEditingController(text: '60');
  final _lessonDescriptionCtrl = TextEditingController();
  final _lessonGoalsCtrl = TextEditingController();

  bool _isSaving = false;
  int _monitorSection = 0;
  int _studentSection = 0;
  String _lessonType = 'conduite';
  final Set<String> _repairedAutoEcoleIds = {};
  final Set<String> _seededCatalogAutoEcoleIds = {};

  @override
  void initState() {
    super.initState();
    _loadIdentity();
  }

  @override
  void dispose() {
    _schoolNameCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _monitorNameCtrl.dispose();
    _classCodeCtrl.dispose();
    _studentNomCtrl.dispose();
    _studentPrenomCtrl.dispose();
    _lessonTitleCtrl.dispose();
    _lessonDurationCtrl.dispose();
    _lessonDescriptionCtrl.dispose();
    _lessonGoalsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    _studentNomCtrl.text = prefs.getString('candidat_nom') ?? '';
    _studentPrenomCtrl.text = prefs.getString('candidat_prenom') ?? '';
    _monitorNameCtrl.text = [
      prefs.getString('candidat_prenom') ?? '',
      prefs.getString('candidat_nom') ?? '',
    ].where((part) => part.trim().isNotEmpty).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _buildShell(
        child: _buildEmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Connexion requise',
          subtitle:
              'Connecte-toi pour lier ton profil a une auto-ecole et synchroniser les operations.',
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _service.watchCurrentUserProfile(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final role = data?['role'] as String?;
        final autoEcoleId = data?['autoEcoleId'] as String?;

        return _buildShell(
          child: role == 'moniteur' && autoEcoleId != null
              ? _buildMonitorSpace(data!, autoEcoleId)
              : role == 'eleve' && autoEcoleId != null
                  ? _buildStudentSpace(data!, autoEcoleId)
                  : _buildOnboarding(),
        );
      },
    );
  }

  Widget _buildShell({required Widget child}) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.appBackgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 18),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF12356F), Color(0xFF0F766E), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Row(
        children: [
          Icon(Icons.groups_2_rounded, color: Colors.white, size: 36),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Auto-ecole',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Suivi eleves, lecons standards, devoirs et heures.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboarding() {
    return Column(
      children: [
        _buildPanel(
          title: 'Je suis moniteur',
          icon: Icons.admin_panel_settings_rounded,
          child: Column(
            children: [
              _buildInput(_schoolNameCtrl, 'Nom de l auto-ecole'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildInput(_cityCtrl, 'Ville')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInput(_phoneCtrl, 'Telephone')),
                ],
              ),
              const SizedBox(height: 10),
              _buildInput(_monitorNameCtrl, 'Nom du moniteur'),
              const SizedBox(height: 14),
              _buildPrimaryButton(
                icon: Icons.add_business_rounded,
                label: 'Creer la classe',
                onPressed: _createSchool,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildPanel(
          title: 'Je suis eleve',
          icon: Icons.school_rounded,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildInput(_studentPrenomCtrl, 'Prenom')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInput(_studentNomCtrl, 'Nom')),
                ],
              ),
              const SizedBox(height: 10),
              _buildInput(_classCodeCtrl, 'Code de classe'),
              const SizedBox(height: 14),
              _buildPrimaryButton(
                icon: Icons.login_rounded,
                label: 'Rejoindre',
                onPressed: _joinSchool,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonitorSpace(Map<String, dynamic> profile, String autoEcoleId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _service.watchAutoEcole(autoEcoleId),
      builder: (context, schoolSnapshot) {
        _repairLegacyReservationsOnce(autoEcoleId);
        _seedCatalogsOnce(autoEcoleId);
        final school = schoolSnapshot.data?.data();
        final code =
            school?['codeClasse'] as String? ?? profile['codeClasse'] ?? '';
        final name = school?['nom'] as String? ?? profile['autoEcoleNom'] ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonitorDashboardCard(
              schoolName: name.isEmpty ? 'Tableau moniteur' : name,
              code: code,
              studentsCount: (school?['eleveUids'] as List?)?.length ?? 0,
              autoEcoleId: autoEcoleId,
            ),
            const SizedBox(height: 14),
            _buildSectionTabs(
              selectedIndex: _monitorSection,
              items: const [
                _AutoEcoleSection(Icons.dashboard_outlined, 'Dashboard'),
                _AutoEcoleSection(Icons.people_outline_rounded, 'Élèves'),
                _AutoEcoleSection(Icons.assignment_outlined, 'Devoirs'),
                _AutoEcoleSection(Icons.event_note_outlined, 'Demandes'),
                _AutoEcoleSection(Icons.calendar_month_outlined, 'Calendrier'),
              ],
              onChanged: (index) => setState(() => _monitorSection = index),
            ),
            const SizedBox(height: 14),
            _buildNotificationsPanel(),
            const SizedBox(height: 14),
            switch (_monitorSection) {
              0 => _buildMonitorOverview(autoEcoleId, profile, code),
              1 => _buildStudentsManagementPanel(autoEcoleId, profile, code),
              2 => _buildMonitorCatalogsPanel(autoEcoleId),
              3 => Column(
                  children: [
                    _buildReservationsPanel(
                      autoEcoleId: autoEcoleId,
                      isMonitor: true,
                    ),
                    const SizedBox(height: 14),
                    _buildLegacyReservationsPanel(autoEcoleId),
                  ],
                ),
              _ =>
                _buildCalendarPanel(autoEcoleId: autoEcoleId, isMonitor: true),
            },
          ],
        );
      },
    );
  }

  void _repairLegacyReservationsOnce(String autoEcoleId) {
    if (_repairedAutoEcoleIds.contains(autoEcoleId)) return;
    _repairedAutoEcoleIds.add(autoEcoleId);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final repairedCount =
            await _service.repairLegacyReservationsForMonitor(autoEcoleId);
        if (repairedCount > 0) {
          _showSnack('$repairedCount ancienne(s) demande(s) rattachee(s).');
        }
      } catch (e) {
        _showSnack('Anciennes demandes non rattachees: $e', isError: true);
      }
    });
  }

  void _seedCatalogsOnce(String autoEcoleId) {
    if (_seededCatalogAutoEcoleIds.contains(autoEcoleId)) return;
    _seededCatalogAutoEcoleIds.add(autoEcoleId);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final lessonsCount =
            await _service.importPredefinedLessons(autoEcoleId);
        final homeworksCount =
            await _service.importPredefinedHomeworks(autoEcoleId);
        if (lessonsCount > 0 || homeworksCount > 0) {
          _showSnack(
            '$lessonsCount lecon(s) standard(s) et $homeworksCount devoir(s) standard(s) ajoutes.',
          );
        }
      } catch (e) {
        _showSnack('Catalogue non initialise: $e', isError: true);
      }
    });
  }

  Widget _buildStudentSpace(Map<String, dynamic> profile, String autoEcoleId) {
    final name = profile['autoEcoleNom'] as String? ?? 'Auto-ecole';
    final displayName = [
      _studentPrenomCtrl.text,
      _studentNomCtrl.text,
    ].where((part) => part.trim().isNotEmpty).join(' ');

    return Column(
      children: [
        _buildStudentDashboardCard(
          schoolName: name,
          displayName: displayName,
          autoEcoleId: autoEcoleId,
        ),
        const SizedBox(height: 14),
        _buildSectionTabs(
          selectedIndex: _studentSection,
          items: const [
            _AutoEcoleSection(Icons.home_work_outlined, 'Accueil'),
            _AutoEcoleSection(Icons.assignment_outlined, 'Devoirs'),
            _AutoEcoleSection(Icons.event_available_outlined, 'Demandes'),
            _AutoEcoleSection(Icons.calendar_month_outlined, 'Calendrier'),
            _AutoEcoleSection(Icons.insights_outlined, 'Stats'),
          ],
          onChanged: (index) => setState(() => _studentSection = index),
        ),
        const SizedBox(height: 14),
        _buildNotificationsPanel(),
        const SizedBox(height: 14),
        switch (_studentSection) {
          0 => _buildStudentOverview(
              autoEcoleId: autoEcoleId,
              displayName: displayName,
            ),
          1 => Column(
              children: [
                _buildAssignedLessonsPanel(),
                const SizedBox(height: 14),
                _buildStudentHomeworkPanel(),
              ],
            ),
          2 => _buildReservationsPanel(
              autoEcoleId: autoEcoleId,
              isMonitor: false,
            ),
          3 => _buildCalendarPanel(autoEcoleId: autoEcoleId, isMonitor: false),
          _ => _buildStudentStatsPanel(),
        },
      ],
    );
  }

  Widget _buildSectionTabs({
    required int selectedIndex,
    required List<_AutoEcoleSection> items,
    required ValueChanged<int> onChanged,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ChoiceChip(
              selected: selectedIndex == i,
              onSelected: (_) => onChanged(i),
              avatar: Icon(
                items[i].icon,
                size: 18,
                color: selectedIndex == i
                    ? AppColors.backgroundDeep
                    : AppColors.textSecondary,
              ),
              label: Text(items[i].label),
              labelStyle: TextStyle(
                color: selectedIndex == i
                    ? AppColors.backgroundDeep
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              selectedColor: AppColors.accentCyan,
              backgroundColor: AppColors.surfaceElevated,
              side: const BorderSide(color: AppColors.borderSoft),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            if (i < items.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildMonitorDashboardCard({
    required String schoolName,
    required String code,
    required int studentsCount,
    required String autoEcoleId,
  }) {
    return _buildPanel(
      title: schoolName,
      icon: Icons.dashboard_customize_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildMetric('Code', code, AppColors.accentCyan)),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetric(
                  'Élèves',
                  '$studentsCount',
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPrimaryButton(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Partager le code classe',
            onPressed: () => _showSnack('Code classe: $code'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentDashboardCard({
    required String schoolName,
    required String displayName,
    required String autoEcoleId,
  }) {
    return _buildPanel(
      title: schoolName,
      icon: Icons.verified_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayName.isEmpty
                ? 'Ton profil est lié à cette auto-école.'
                : '$displayName, ton profil est lié à cette auto-école.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          _buildPrimaryButton(
            icon: Icons.event_available_rounded,
            label: 'Demander des heures de conduite',
            onPressed: () => _showReservationDialog(autoEcoleId, displayName),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitorOverview(
    String autoEcoleId,
    Map<String, dynamic> profile,
    String code,
  ) {
    return Column(
      children: [
        _buildPanel(
          title: 'Gestion rapide',
          icon: Icons.tune_rounded,
          child: _buildResponsiveActions([
            _AutoEcoleAction(
              Icons.assignment_add,
              'Créer un devoir',
              () => setState(() => _monitorSection = 2),
            ),
            _AutoEcoleAction(
              Icons.event_note_rounded,
              'Voir les demandes',
              () => setState(() => _monitorSection = 3),
            ),
            _AutoEcoleAction(
              Icons.people_alt_rounded,
              'Suivi élèves',
              () => setState(() => _monitorSection = 1),
            ),
            _AutoEcoleAction(
              Icons.calendar_month_rounded,
              'Calendrier cours',
              () => setState(() => _monitorSection = 4),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        _buildStudentsManagementPanel(autoEcoleId, profile, code),
      ],
    );
  }

  Widget _buildMonitorCatalogsPanel(String autoEcoleId) {
    return Column(
      children: [
        _buildHomeworkCatalogPanel(autoEcoleId),
        const SizedBox(height: 14),
        _buildCreateLessonCatalogPanel(autoEcoleId),
        const SizedBox(height: 14),
        _buildLessonCatalogPanel(autoEcoleId),
      ],
    );
  }

  Widget _buildCreateLessonCatalogPanel(String autoEcoleId) {
    return _buildPanel(
      title: 'Créer une leçon',
      icon: Icons.add_circle_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'La leçon sera ajoutée au catalogue et pourra ensuite être assignée aux élèves.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          _buildInput(_lessonTitleCtrl, 'Titre de la leçon'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _lessonType,
                  dropdownColor: AppColors.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'conduite',
                      child: Text('Conduite'),
                    ),
                    DropdownMenuItem(
                      value: 'manoeuvre',
                      child: Text('Manoeuvre'),
                    ),
                    DropdownMenuItem(value: 'code', child: Text('Code')),
                  ],
                  onChanged: (value) {
                    setState(() => _lessonType = value ?? 'conduite');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInput(
                  _lessonDurationCtrl,
                  'Durée en min',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInput(_lessonGoalsCtrl, 'Objectifs'),
          const SizedBox(height: 10),
          _buildInput(_lessonDescriptionCtrl, 'Description / consignes'),
          const SizedBox(height: 14),
          _buildPrimaryButton(
            icon: Icons.library_add_rounded,
            label: _isSaving ? 'Création...' : 'Ajouter au catalogue',
            onPressed: _isSaving
                ? () {}
                : () => _createLessonCatalogEntry(autoEcoleId),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsManagementPanel(
    String autoEcoleId,
    Map<String, dynamic> profile,
    String code,
  ) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.watchEleves(autoEcoleId),
      builder: (context, snapshot) {
        final eleves = snapshot.data?.docs ?? [];
        if (eleves.isEmpty) {
          return _buildEmptyState(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Aucun élève lié',
            subtitle: 'Partage le code $code pour commencer le suivi.',
          );
        }

        return Column(
          children: [
            for (final doc in eleves) ...[
              _buildStudentCard(autoEcoleId, doc.id, doc.data(), profile),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStudentOverview({
    required String autoEcoleId,
    required String displayName,
  }) {
    return Column(
      children: [
        _buildPanel(
          title: 'Mes raccourcis',
          icon: Icons.grid_view_rounded,
          child: _buildResponsiveActions([
            _AutoEcoleAction(
              Icons.event_available_rounded,
              'Demander des heures',
              () => _showReservationDialog(autoEcoleId, displayName),
            ),
            _AutoEcoleAction(
              Icons.assignment_rounded,
              'Voir mes devoirs',
              () => setState(() => _studentSection = 1),
            ),
            _AutoEcoleAction(
              Icons.event_note_rounded,
              'Mes demandes',
              () => setState(() => _studentSection = 2),
            ),
            _AutoEcoleAction(
              Icons.insights_rounded,
              'Mes statistiques',
              () => setState(() => _studentSection = 4),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        _buildStudentStatsPanel(),
      ],
    );
  }

  Widget _buildResponsiveActions(List<_AutoEcoleAction> actions) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 4 ? 1.7 : 1.25,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: action.onTap,
                child: Ink(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(action.icon, color: AppColors.accentCyan),
                      const Spacer(),
                      Text(
                        action.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentHomeworkPanel() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.watchDevoirsForCurrentUser(),
      builder: (context, snapshot) {
        final devoirs = snapshot.data?.docs ?? [];
        if (devoirs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.assignment_outlined,
            title: 'Aucun devoir',
            subtitle: 'Les devoirs assignés par ton moniteur apparaîtront ici.',
          );
        }
        return _buildPanel(
          title: 'Mes devoirs',
          icon: Icons.assignment_rounded,
          child: Column(
            children: [
              for (final doc in devoirs) _buildHomeworkTile(doc.data()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentStatsPanel() {
    return FutureBuilder<PermitStats>(
      future: _progressService.getStatsForPermit(),
      builder: (context, snapshot) {
        final stats = snapshot.data ??
            const PermitStats(
              testsCount: 0,
              successRate: 0,
              mistakesCount: 0,
              streakCount: 0,
              xp: 0,
              level: 1,
            );

        return _buildPanel(
          title: 'Mes statistiques',
          icon: Icons.insights_rounded,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      'Réussite',
                      '${stats.successRate}%',
                      AppColors.accentCyan,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetric(
                      'Tests',
                      '${stats.testsCount}',
                      AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      'Fautes',
                      '${stats.mistakesCount}',
                      AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetric(
                      'Niveau',
                      '${stats.level}',
                      AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: ((stats.xp % 1000) / 1000).clamp(0.0, 1.0),
                  minHeight: 7,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accentCyan,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${stats.xp} XP - série ${stats.streakCount}j',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarPanel({
    required String autoEcoleId,
    required bool isMonitor,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: isMonitor
          ? _service.watchReservationsForCurrentMonitor()
          : _service.watchReservationsForCurrentStudent(),
      builder: (context, snapshot) {
        final reservations = (snapshot.data?.docs ?? []).where((doc) {
          final data = doc.data();
          return data['autoEcoleId'] == autoEcoleId &&
              data['statut'] == 'confirme';
        }).toList()
          ..sort((a, b) {
            final aDate = _readTimestamp(a.data()['dateHeure']);
            final bDate = _readTimestamp(b.data()['dateHeure']);
            return aDate.compareTo(bDate);
          });

        if (reservations.isEmpty) {
          return _buildEmptyState(
            icon: Icons.calendar_month_outlined,
            title: 'Calendrier vide',
            subtitle: isMonitor
                ? 'Les cours confirmés apparaîtront ici.'
                : 'Tes réservations confirmées apparaîtront ici.',
          );
        }

        return _buildPanel(
          title: 'Calendrier des cours',
          icon: Icons.calendar_month_rounded,
          child: Column(
            children: [
              for (final doc in reservations)
                _buildCalendarTile(doc.data(), isMonitor: isMonitor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarTile(
    Map<String, dynamic> reservation, {
    required bool isMonitor,
  }) {
    final dateHeure = _readTimestamp(reservation['dateHeure']);
    final type = reservation['typeLecon'] as String? ?? 'conduite';
    final duration = reservation['dureeMinutes'] ?? 60;
    final studentName = reservation['eleveNom'] as String? ?? 'Élève';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMonitor ? studentName : 'Leçon $type',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDateTime(dateHeure)} - $duration min',
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
        ],
      ),
    );
  }

  Widget _buildReservationsPanel({
    required String autoEcoleId,
    required bool isMonitor,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: isMonitor
          ? _service.watchReservationsForCurrentMonitor()
          : _service.watchReservationsForCurrentStudent(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.error_outline_rounded,
            title: isMonitor
                ? 'Demandes recues indisponibles'
                : 'Demandes envoyees indisponibles',
            subtitle:
                'Firestore refuse la lecture pour le moment: ${snapshot.error}',
          );
        }

        final reservations = snapshot.data?.docs ?? [];
        final visibleReservations = reservations.where((doc) {
          final data = doc.data();
          return data['autoEcoleId'] == autoEcoleId;
        }).toList()
          ..sort((a, b) {
            final aDate = _readTimestamp(a.data()['dateCreation']);
            final bDate = _readTimestamp(b.data()['dateCreation']);
            return bDate.compareTo(aDate);
          });

        if (visibleReservations.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_busy_rounded,
            title:
                isMonitor ? 'Aucune demande recue' : 'Aucune demande envoyee',
            subtitle: isMonitor
                ? 'Les nouvelles demandes envoyees par les eleves apparaitront ici.'
                : 'Quand tu demandes une lecon, son statut apparait ici.',
          );
        }

        return _buildPanel(
          title: isMonitor ? 'Demandes recues' : 'Mes demandes envoyees',
          icon: Icons.event_note_rounded,
          child: Column(
            children: [
              for (final doc in visibleReservations)
                _buildReservationTile(
                  reservationId: doc.id,
                  reservation: doc.data(),
                  isMonitor: isMonitor,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegacyReservationsPanel(String autoEcoleId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.watchReservations(autoEcoleId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.lock_outline_rounded,
            title: 'Anciennes demandes bloquees',
            subtitle:
                'Firestore refuse la lecture par auto-ecole: ${snapshot.error}',
          );
        }

        final legacyReservations = (snapshot.data?.docs ?? []).where((doc) {
          final data = doc.data();
          final rawMonitors = data['moniteurUids'];
          final monitors = rawMonitors is List
              ? rawMonitors.whereType<String>().toList()
              : <String>[];
          return data['autoEcoleId'] == autoEcoleId && monitors.isEmpty;
        }).toList()
          ..sort((a, b) {
            final aDate = _readTimestamp(a.data()['dateCreation']);
            final bDate = _readTimestamp(b.data()['dateCreation']);
            return bDate.compareTo(aDate);
          });

        if (legacyReservations.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildPanel(
          title: 'Anciennes demandes a rattacher',
          icon: Icons.history_toggle_off_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ces demandes ont ete envoyees avant la liaison moniteur. Rattache-les pour les confirmer ou les annuler.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              _buildPrimaryButton(
                icon: Icons.link_rounded,
                label: 'Rattacher les anciennes demandes',
                onPressed: () => _repairLegacyReservations(autoEcoleId),
              ),
              const SizedBox(height: 12),
              for (final doc in legacyReservations)
                _buildReservationTile(
                  reservationId: doc.id,
                  reservation: doc.data(),
                  isMonitor: false,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsPanel() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.watchNotificationsForCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.notifications_off_rounded,
            title: 'Notifications indisponibles',
            subtitle:
                'Firestore refuse la lecture des notifications: ${snapshot.error}',
          );
        }

        final notifications = snapshot.data?.docs ?? [];
        final visibleNotifications = notifications.toList()
          ..sort((a, b) {
            final aDate = _readTimestamp(a.data()['createdAt']);
            final bDate = _readTimestamp(b.data()['createdAt']);
            return bDate.compareTo(aDate);
          });

        if (visibleNotifications.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildPanel(
          title: 'Notifications',
          icon: Icons.notifications_active_rounded,
          child: Column(
            children: [
              for (final doc in visibleNotifications.take(5))
                _buildNotificationTile(doc.id, doc.data()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignedLessonsPanel() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.watchAssignedLessonsForCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.menu_book_outlined,
            title: 'Lecons indisponibles',
            subtitle:
                'Firestore refuse la lecture des lecons: ${snapshot.error}',
          );
        }

        final lessons = snapshot.data?.docs ?? [];
        final visibleLessons = lessons.toList()
          ..sort((a, b) {
            final aDate = _readTimestamp(a.data()['dateCreation']);
            final bDate = _readTimestamp(b.data()['dateCreation']);
            return bDate.compareTo(aDate);
          });

        if (visibleLessons.isEmpty) {
          return _buildEmptyState(
            icon: Icons.local_library_outlined,
            title: 'Aucune lecon assignee',
            subtitle: 'Les lecons envoyees par ton moniteur apparaitront ici.',
          );
        }

        return _buildPanel(
          title: 'Mes lecons',
          icon: Icons.local_library_rounded,
          child: Column(
            children: [
              for (final doc in visibleLessons)
                _buildAssignedLessonTile(doc.id, doc.data()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignedLessonTile(
    String lessonId,
    Map<String, dynamic> lesson,
  ) {
    final title = lesson['titre'] as String? ?? 'Lecon';
    final type = lesson['type'] as String? ?? 'conduite';
    final description = lesson['description'] as String? ?? '';
    final objectifs = lesson['objectifs'] as String? ?? '';
    final duration = lesson['dureeMinutes'] ?? 60;
    final status = lesson['statut'] as String? ?? 'envoyee';
    final deadline = _readTimestamp(lesson['dateLimite']);
    final statusColor = switch (status) {
      'terminee' => AppColors.success,
      'vue' => AppColors.accentCyan,
      _ => AppColors.warning,
    };
    final statusLabel = switch (status) {
      'terminee' => 'Terminee',
      'vue' => 'Vue',
      _ => 'Envoyee',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, color: statusColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$type - $duration min - limite ${_formatDateTime(deadline)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          if (objectifs.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              objectifs,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
          _buildAttachmentLink(lesson),
          if (status != 'terminee') ...[
            const SizedBox(height: 10),
            _buildSecondaryButton(
              icon: Icons.check_circle_outline_rounded,
              label: 'Terminer',
              onPressed: () => _updateAssignedLessonStatus(
                lessonId,
                'terminee',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLessonCatalogPanel(String autoEcoleId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.watchLessonCatalog(autoEcoleId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.menu_book_outlined,
            title: 'Catalogue indisponible',
            subtitle:
                'Firestore refuse la lecture du catalogue: ${snapshot.error}',
          );
        }

        final lessons = snapshot.data?.docs ?? [];
        return _buildPanel(
          title: 'Catalogue de lecons standards',
          icon: Icons.library_books_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSecondaryButton(
                      icon: Icons.playlist_add_check_rounded,
                      label: 'Standards',
                      onPressed: () => _importPredefinedLessons(autoEcoleId),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSecondaryButton(
                      icon: Icons.upload_file_rounded,
                      label: 'Importer doc',
                      onPressed: () => _showImportLessonsDialog(autoEcoleId),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildPrimaryButton(
                icon: Icons.add_rounded,
                label: 'Creer un standard',
                onPressed: () => _showLessonDialog(autoEcoleId),
              ),
              const SizedBox(height: 14),
              if (lessons.isEmpty)
                const Text(
                  'Aucune lecon standard pour le moment. Importe les standards ou ajoute un document.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                )
              else
                for (final doc in lessons.take(8)) _buildLessonTile(doc.data()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeworkCatalogPanel(String autoEcoleId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.watchHomeworkCatalog(autoEcoleId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.assignment_late_outlined,
            title: 'Catalogue devoirs indisponible',
            subtitle:
                'Firestore refuse la lecture du catalogue: ${snapshot.error}',
          );
        }

        final homeworks = snapshot.data?.docs ?? [];
        return _buildPanel(
          title: 'Catalogue de devoirs standards',
          icon: Icons.assignment_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSecondaryButton(
                      icon: Icons.playlist_add_check_rounded,
                      label: 'Standards',
                      onPressed: () => _importPredefinedHomeworks(autoEcoleId),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSecondaryButton(
                      icon: Icons.upload_file_rounded,
                      label: 'Importer doc',
                      onPressed: () => _showImportHomeworksDialog(autoEcoleId),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildPrimaryButton(
                icon: Icons.add_task_rounded,
                label: 'Creer un standard',
                onPressed: () => _showHomeworkTemplateDialog(autoEcoleId),
              ),
              const SizedBox(height: 14),
              if (homeworks.isEmpty)
                const Text(
                  'Aucun devoir standard pour le moment. Importe les standards ou ajoute un document.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                )
              else
                for (final doc in homeworks.take(8))
                  _buildHomeworkTemplateTile(doc.data()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationTile(
    String notificationId,
    Map<String, dynamic> notification,
  ) {
    final isRead = notification['read'] == true;
    final title = notification['title'] as String? ?? 'Notification';
    final message = notification['message'] as String? ?? '';
    final createdAt = _readTimestamp(notification['createdAt']);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap:
          isRead ? null : () => _service.markNotificationAsRead(notificationId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.black.withValues(alpha: 0.12)
              : AppColors.accentCyan.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.accentCyan.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isRead
                  ? Icons.notifications_none_rounded
                  : Icons.notifications_rounded,
              color: isRead ? AppColors.textSecondary : AppColors.accentCyan,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$message - ${_formatDateTime(createdAt)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationTile({
    required String reservationId,
    required Map<String, dynamic> reservation,
    required bool isMonitor,
  }) {
    final status = reservation['statut'] as String? ?? 'en_attente';
    final type = reservation['typeLecon'] as String? ?? 'conduite';
    final duration = reservation['dureeMinutes'] ?? 60;
    final studentName = reservation['eleveNom'] as String? ?? 'Eleve';
    final dateHeure = _readTimestamp(reservation['dateHeure']);
    final statusColor = switch (status) {
      'confirme' => AppColors.success,
      'annule' => AppColors.error,
      _ => AppColors.warning,
    };
    final statusLabel = switch (status) {
      'confirme' => 'Confirmee',
      'annule' => 'Annulee',
      _ => 'En attente',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_available_rounded, color: statusColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMonitor ? studentName : 'Lecon $type',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${_formatDateTime(dateHeure)} - $duration min - $type',
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (isMonitor && status == 'en_attente') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryButton(
                    icon: Icons.check_rounded,
                    label: 'Confirmer',
                    onPressed: () => _updateReservationStatus(
                      reservationId,
                      'confirme',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSecondaryButton(
                    icon: Icons.close_rounded,
                    label: 'Annuler',
                    onPressed: () => _updateReservationStatus(
                      reservationId,
                      'annule',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentCard(
    String autoEcoleId,
    String eleveUid,
    Map<String, dynamic> eleve,
    Map<String, dynamic> profile,
  ) {
    final fullName = '${eleve['prenom'] ?? ''} ${eleve['nom'] ?? ''}'.trim();
    final moniteurNom = profile['displayName'] as String? ?? 'Moniteur';

    return _buildPanel(
      title: fullName.isEmpty ? 'Eleve' : fullName,
      icon: Icons.person_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Reussite',
                  '${eleve['tauxReussite'] ?? 0}%',
                  AppColors.accentCyan,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetric(
                  'Tests',
                  '${eleve['testsCount'] ?? 0}',
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetric(
                  'Fautes',
                  '${eleve['fautesCount'] ?? 0}',
                  AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  icon: Icons.assignment_add,
                  label: 'Devoir',
                  onPressed: () => _showHomeworkDialog(
                    autoEcoleId: autoEcoleId,
                    eleveUid: eleveUid,
                    moniteurNom: moniteurNom,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSecondaryButton(
                  icon: Icons.menu_book_rounded,
                  label: 'Lecon',
                  onPressed: () => _showAssignLessonDialog(
                    autoEcoleId: autoEcoleId,
                    eleveUid: eleveUid,
                    moniteurNom: moniteurNom,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSecondaryButton(
                  icon: Icons.timer_rounded,
                  label: 'Heures',
                  onPressed: () => _showHoursDialog(autoEcoleId, eleveUid),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkTile(Map<String, dynamic> devoir) {
    final status = devoir['statut'] as String? ?? 'en_attente';
    final title = devoir['titre'] as String? ?? 'Devoir';
    final theme = devoir['themeName'] as String? ?? 'Theme';
    final score = devoir['scoreObtenu'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status == 'termine'
                    ? Icons.check_circle_rounded
                    : Icons.pending_actions_rounded,
                color:
                    status == 'termine' ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      score == null ? theme : '$theme - score $score',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildAttachmentLink(devoir),
        ],
      ),
    );
  }

  Widget _buildLessonTile(Map<String, dynamic> lesson) {
    final title = lesson['titre'] as String? ?? 'Lecon';
    final type = lesson['type'] as String? ?? 'conduite';
    final duration = lesson['dureeMinutes'] ?? 60;
    final objectifs = lesson['objectifs'] as String? ?? '';
    final predefined = lesson['predefined'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            predefined ? Icons.verified_outlined : Icons.edit_note_rounded,
            color: predefined ? AppColors.success : AppColors.accentCyan,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$type - $duration min',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (objectifs.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    objectifs,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                ],
                _buildAttachmentLink(lesson, compact: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkTemplateTile(Map<String, dynamic> homework) {
    final title = homework['titre'] as String? ?? 'Devoir';
    final theme = homework['themeName'] as String? ?? 'Theme';
    final questionCount = homework['nombreQuestions'] ?? 20;
    final deadlineDays = homework['delaiJours'] ?? 7;
    final description = homework['description'] as String? ?? '';
    final predefined = homework['predefined'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            predefined ? Icons.verified_outlined : Icons.assignment_add,
            color: predefined ? AppColors.success : AppColors.accentCyan,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$theme - $questionCount questions - $deadlineDays j',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                ],
                _buildAttachmentLink(homework, compact: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentLink(
    Map<String, dynamic> data, {
    bool compact = false,
  }) {
    final attachment = _attachmentFromData(data);
    if (attachment == null) return const SizedBox.shrink();
    final name = attachment['attachmentName'] as String? ?? 'Document';
    final size = attachment['attachmentSize'] as int?;
    final url = attachment['attachmentUrl'] as String;

    return Padding(
      padding: EdgeInsets.only(top: compact ? 6 : 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openAttachment(url),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.accentCyan.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accentCyan.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.attach_file_rounded,
                color: AppColors.accentCyan,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  size == null ? name : '$name - ${_formatBytes(size)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.open_in_new_rounded,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDocumentCard(
    _PickedCatalogDocument? document, {
    required VoidCallback onPick,
    VoidCallback? onClear,
  }) {
    final hasDocument = document != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasDocument
                    ? Icons.description_rounded
                    : Icons.upload_file_rounded,
                color: hasDocument ? AppColors.success : AppColors.accentCyan,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasDocument
                      ? '${document.name} - ${_formatBytes(document.size)}'
                      : 'Document standard',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  icon: hasDocument
                      ? Icons.swap_horiz_rounded
                      : Icons.folder_open_rounded,
                  label: hasDocument ? 'Remplacer' : 'Choisir',
                  onPressed: onPick,
                ),
              ),
              if (hasDocument && onClear != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSecondaryButton(
                    icon: Icons.close_rounded,
                    label: 'Retirer',
                    onPressed: onClear,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPanel({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accentCyan, size: 21),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentCyan),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentCyan,
          foregroundColor: AppColors.backgroundDeep,
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accentCyan,
        side: BorderSide(color: AppColors.accentCyan.withValues(alpha: 0.45)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentCyan, size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Future<void> _createSchool() async {
    if (_schoolNameCtrl.text.trim().isEmpty) {
      _showSnack('Nom de l auto-ecole requis.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final code = await _service.createAutoEcole(
        nom: _schoolNameCtrl.text,
        ville: _cityCtrl.text,
        telephone: _phoneCtrl.text,
        moniteurNom: _monitorNameCtrl.text,
      );
      _showSnack('Classe creee. Code: $code');
    } catch (e) {
      _showSnack('Erreur: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _joinSchool() async {
    if (_classCodeCtrl.text.trim().isEmpty) {
      _showSnack('Code de classe requis.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final stats = await _progressService.getStatsForPermit();
      await _service.joinAutoEcoleByCode(
        codeClasse: _classCodeCtrl.text,
        nom: _studentNomCtrl.text,
        prenom: _studentPrenomCtrl.text,
        stats: stats.toMap(),
      );
      _showSnack('Auto-ecole liee avec succes.');
    } catch (e) {
      _showSnack('Erreur: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _importPredefinedLessons(String autoEcoleId) async {
    setState(() => _isSaving = true);
    try {
      final importedCount = await _service.importPredefinedLessons(autoEcoleId);
      _showSnack(importedCount == 0
          ? 'Les standards sont deja importes.'
          : '$importedCount lecon(s) standard(s) importee(s).');
    } catch (e) {
      _showSnack('Import impossible: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showLessonDialog(String autoEcoleId) async {
    final titleCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '60');
    final descCtrl = TextEditingController();
    final goalsCtrl = TextEditingController();
    String type = 'conduite';
    _PickedCatalogDocument? selectedDocument;
    var isDialogSaving = false;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: const Text('Creer une lecon standard',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInput(titleCtrl, 'Titre de la lecon'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  dropdownColor: AppColors.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(
                        value: 'conduite', child: Text('Conduite')),
                    DropdownMenuItem(
                        value: 'manoeuvre', child: Text('Manoeuvre')),
                    DropdownMenuItem(value: 'code', child: Text('Code')),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => type = value ?? 'conduite'),
                ),
                const SizedBox(height: 10),
                _buildInput(durationCtrl, 'Duree en minutes',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildInput(descCtrl, 'Contenu standard / consignes'),
                const SizedBox(height: 10),
                _buildInput(goalsCtrl, 'Objectifs de la lecon'),
                const SizedBox(height: 10),
                _buildSelectedDocumentCard(
                  selectedDocument,
                  onPick: () async {
                    final document = await _pickCatalogDocument();
                    if (document == null) return;
                    setDialogState(() => selectedDocument = document);
                  },
                  onClear: () => setDialogState(() => selectedDocument = null),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDialogSaving ? null : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: isDialogSaving
                  ? null
                  : () async {
                      if (titleCtrl.text.trim().isEmpty) {
                        _showSnack('Titre de lecon requis.', isError: true);
                        return;
                      }
                      setDialogState(() => isDialogSaving = true);
                      try {
                        final attachment = await _uploadPickedDocument(
                          autoEcoleId: autoEcoleId,
                          catalogType: 'lecons',
                          document: selectedDocument,
                        );
                        await _service.createLesson(
                          autoEcoleId: autoEcoleId,
                          titre: titleCtrl.text,
                          type: type,
                          dureeMinutes: int.tryParse(durationCtrl.text) ?? 60,
                          description: descCtrl.text,
                          objectifs: goalsCtrl.text,
                          attachment: attachment,
                        );
                        if (context.mounted) Navigator.pop(context);
                        _showSnack('Lecon standard creee.');
                      } catch (e) {
                        _showSnack('Creation impossible: $e', isError: true);
                      } finally {
                        if (context.mounted) {
                          setDialogState(() => isDialogSaving = false);
                        }
                      }
                    },
              child: Text(isDialogSaving ? 'Envoi...' : 'Creer'),
            ),
          ],
        ),
      ),
    );

    titleCtrl.dispose();
    durationCtrl.dispose();
    descCtrl.dispose();
    goalsCtrl.dispose();
  }

  Future<void> _createLessonCatalogEntry(String autoEcoleId) async {
    final title = _lessonTitleCtrl.text.trim();
    if (title.isEmpty) {
      _showSnack('Titre de leçon requis.', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _service.createLesson(
        autoEcoleId: autoEcoleId,
        titre: title,
        type: _lessonType,
        dureeMinutes: int.tryParse(_lessonDurationCtrl.text) ?? 60,
        objectifs: _lessonGoalsCtrl.text,
        description: _lessonDescriptionCtrl.text,
      );

      _lessonTitleCtrl.clear();
      _lessonDurationCtrl.text = '60';
      _lessonDescriptionCtrl.clear();
      _lessonGoalsCtrl.clear();
      setState(() => _lessonType = 'conduite');
      _showSnack('Leçon ajoutée au catalogue.');
    } catch (e) {
      _showSnack('Création impossible: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showImportLessonsDialog(String autoEcoleId) async {
    final importCtrl = TextEditingController(
      text:
          'Conduite en agglomeration;conduite;60;Observer, anticiper, respecter les priorites\nStationnement en epi;manoeuvre;45;Placement, controles, precision',
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Importer des lecons',
            style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Une lecon par ligne: titre;type;duree;objectifs',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: importCtrl,
                minLines: 6,
                maxLines: 10,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.22),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.accentCyan),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final count = await _service.importLessonsFromText(
                autoEcoleId: autoEcoleId,
                rawText: importCtrl.text,
              );
              if (context.mounted) Navigator.pop(context);
              _showSnack(count == 0
                  ? 'Aucune lecon importee.'
                  : '$count lecon(s) importee(s).');
            },
            child: const Text('Importer'),
          ),
        ],
      ),
    );

    importCtrl.dispose();
  }

  Future<void> _importPredefinedHomeworks(String autoEcoleId) async {
    setState(() => _isSaving = true);
    try {
      final importedCount =
          await _service.importPredefinedHomeworks(autoEcoleId);
      _showSnack(importedCount == 0
          ? 'Les standards de devoirs sont deja importes.'
          : '$importedCount devoir(s) standard(s) importe(s).');
    } catch (e) {
      _showSnack('Import impossible: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showHomeworkTemplateDialog(String autoEcoleId) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final countCtrl = TextEditingController(text: '20');
    final deadlineCtrl = TextEditingController(text: '7');
    String themeId = '1';
    String themeName = 'Circulation';

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: const Text('Creer un devoir',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInput(titleCtrl, 'Titre du devoir'),
                const SizedBox(height: 10),
                _buildInput(descCtrl, 'Description'),
                const SizedBox(height: 10),
                _buildInput(countCtrl, 'Nombre de questions',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildInput(deadlineCtrl, 'Delai en jours',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: themeId,
                  dropdownColor: AppColors.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Theme'),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('Circulation')),
                    DropdownMenuItem(value: '2', child: Text('Conducteur')),
                    DropdownMenuItem(value: '3', child: Text('Route')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      themeId = value ?? '1';
                      themeName = switch (themeId) {
                        '2' => 'Conducteur',
                        '3' => 'Route',
                        _ => 'Circulation',
                      };
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) {
                  _showSnack('Titre de devoir requis.', isError: true);
                  return;
                }
                await _service.createHomeworkTemplate(
                  autoEcoleId: autoEcoleId,
                  titre: titleCtrl.text,
                  description: descCtrl.text,
                  themeId: themeId,
                  themeName: themeName,
                  nombreQuestions: int.tryParse(countCtrl.text) ?? 20,
                  delaiJours: int.tryParse(deadlineCtrl.text) ?? 7,
                );
                if (context.mounted) Navigator.pop(context);
                _showSnack('Devoir cree.');
              },
              child: const Text('Creer'),
            ),
          ],
        ),
      ),
    );

    titleCtrl.dispose();
    descCtrl.dispose();
    countCtrl.dispose();
    deadlineCtrl.dispose();
  }

  Future<void> _showImportHomeworksDialog(String autoEcoleId) async {
    final importCtrl = TextEditingController(
      text:
          'Revision signalisation;Circulation;20;7;Panneaux, priorites et marquages\nPreparation conduite;Conducteur;15;5;Vigilance, observation, decisions',
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Importer des devoirs',
            style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Un devoir par ligne: titre;theme;questions;delai_jours;description',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: importCtrl,
                minLines: 6,
                maxLines: 10,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.22),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.accentCyan),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final count = await _service.importHomeworksFromText(
                autoEcoleId: autoEcoleId,
                rawText: importCtrl.text,
              );
              if (context.mounted) Navigator.pop(context);
              _showSnack(count == 0
                  ? 'Aucun devoir importe.'
                  : '$count devoir(s) importe(s).');
            },
            child: const Text('Importer'),
          ),
        ],
      ),
    );

    importCtrl.dispose();
  }

  Future<void> _showHomeworkDialog({
    required String autoEcoleId,
    required String eleveUid,
    required String moniteurNom,
  }) async {
    final titleCtrl = TextEditingController(text: 'Revision Signalisation');
    final descCtrl = TextEditingController(
        text: 'Travaille ce theme avant la prochaine seance.');
    final countCtrl = TextEditingController(text: '20');
    String themeId = '1';
    String themeName = 'Circulation';

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Assigner un devoir',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInput(titleCtrl, 'Titre'),
            const SizedBox(height: 10),
            _buildInput(descCtrl, 'Description'),
            const SizedBox(height: 10),
            _buildInput(countCtrl, 'Nombre de questions',
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: themeId,
              dropdownColor: AppColors.surfaceElevated,
              decoration: const InputDecoration(labelText: 'Theme'),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Circulation')),
                DropdownMenuItem(value: '2', child: Text('Conducteur')),
                DropdownMenuItem(value: '3', child: Text('Route')),
              ],
              onChanged: (value) {
                themeId = value ?? '1';
                themeName = switch (themeId) {
                  '2' => 'Conducteur',
                  '3' => 'Route',
                  _ => 'Circulation',
                };
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await _service.assignDevoir(
                autoEcoleId: autoEcoleId,
                eleveUid: eleveUid,
                titre: titleCtrl.text,
                description: descCtrl.text,
                themeId: themeId,
                themeName: themeName,
                nombreQuestions: int.tryParse(countCtrl.text) ?? 20,
                dateLimite: DateTime.now().add(const Duration(days: 7)),
                moniteurNom: moniteurNom,
              );
              if (context.mounted) Navigator.pop(context);
              _showSnack('Devoir envoye.');
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );

    titleCtrl.dispose();
    descCtrl.dispose();
    countCtrl.dispose();
  }

  Future<void> _showAssignLessonDialog({
    required String autoEcoleId,
    required String eleveUid,
    required String moniteurNom,
  }) async {
    final catalogLessons = await _service.getLessonCatalog(autoEcoleId);
    if (!mounted) return;
    final titleCtrl = TextEditingController(text: 'Lecon de conduite');
    final descCtrl = TextEditingController();
    final goalsCtrl = TextEditingController(
      text: 'Observer, anticiper, appliquer les consignes du moniteur.',
    );
    final durationCtrl = TextEditingController(text: '60');
    String type = 'conduite';
    String selectedCatalogId = 'custom';
    DateTime deadline = DateTime.now().add(const Duration(days: 7));

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: const Text('Envoyer une lecon',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedCatalogId,
                  dropdownColor: AppColors.surfaceElevated,
                  decoration:
                      const InputDecoration(labelText: 'Source catalogue'),
                  items: [
                    const DropdownMenuItem(
                      value: 'custom',
                      child: Text('Lecon personnalisee'),
                    ),
                    for (final lesson in catalogLessons)
                      DropdownMenuItem(
                        value: lesson.id,
                        child: Text(
                          lesson.data()['titre'] as String? ?? 'Lecon',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    final nextValue = value ?? 'custom';
                    setDialogState(() {
                      selectedCatalogId = nextValue;
                      if (nextValue == 'custom') return;

                      final lessonDoc = catalogLessons.firstWhere(
                        (doc) => doc.id == nextValue,
                      );
                      final lesson = lessonDoc.data();
                      titleCtrl.text = lesson['titre'] as String? ?? '';
                      type = lesson['type'] as String? ?? 'conduite';
                      durationCtrl.text = '${lesson['dureeMinutes'] ?? 60}';
                      goalsCtrl.text = lesson['objectifs'] as String? ?? '';
                      descCtrl.text = lesson['description'] as String? ??
                          'Lecon assignee depuis le catalogue.';
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildInput(titleCtrl, 'Titre'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  key: ValueKey(type),
                  initialValue: type,
                  dropdownColor: AppColors.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(
                        value: 'conduite', child: Text('Conduite')),
                    DropdownMenuItem(
                        value: 'manoeuvre', child: Text('Manoeuvre')),
                    DropdownMenuItem(value: 'code', child: Text('Code')),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => type = value ?? 'conduite'),
                ),
                const SizedBox(height: 10),
                _buildInput(durationCtrl, 'Duree en minutes',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildInput(descCtrl, 'Description / consignes'),
                const SizedBox(height: 10),
                _buildInput(goalsCtrl, 'Objectifs'),
                const SizedBox(height: 10),
                _buildSecondaryButton(
                  icon: Icons.calendar_month_rounded,
                  label: 'Limite ${_formatDateTime(deadline)}',
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 120)),
                    );
                    if (pickedDate == null) return;
                    setDialogState(() {
                      deadline = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        23,
                        59,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) {
                  _showSnack('Titre de lecon requis.', isError: true);
                  return;
                }
                await _service.assignLesson(
                  autoEcoleId: autoEcoleId,
                  eleveUid: eleveUid,
                  titre: titleCtrl.text,
                  type: type,
                  description: descCtrl.text,
                  objectifs: goalsCtrl.text,
                  dureeMinutes: int.tryParse(durationCtrl.text) ?? 60,
                  dateLimite: deadline,
                  moniteurNom: moniteurNom,
                  sourceType: selectedCatalogId == 'custom'
                      ? 'personnalisee'
                      : 'catalogue',
                  sourceRef:
                      selectedCatalogId == 'custom' ? null : selectedCatalogId,
                );
                if (context.mounted) Navigator.pop(context);
                _showSnack('Lecon envoyee.');
              },
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );

    titleCtrl.dispose();
    descCtrl.dispose();
    goalsCtrl.dispose();
    durationCtrl.dispose();
  }

  Future<void> _showHoursDialog(String autoEcoleId, String eleveUid) async {
    final durationCtrl = TextEditingController(text: '60');
    final remarksCtrl = TextEditingController();
    final skillsCtrl =
        TextEditingController(text: 'Controle retros, Demarrage');
    final noteCtrl = TextEditingController(text: '4');

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Valider des heures',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInput(durationCtrl, 'Duree en minutes',
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _buildInput(remarksCtrl, 'Remarques'),
            const SizedBox(height: 10),
            _buildInput(skillsCtrl, 'Competences separees par virgule'),
            const SizedBox(height: 10),
            _buildInput(noteCtrl, 'Note sur 5',
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await _service.validateDrivingHours(
                autoEcoleId: autoEcoleId,
                eleveUid: eleveUid,
                dureeMinutes: int.tryParse(durationCtrl.text) ?? 60,
                date: DateTime.now(),
                remarques: remarksCtrl.text,
                competencesValidees: skillsCtrl.text
                    .split(',')
                    .map((skill) => skill.trim())
                    .where((skill) => skill.isNotEmpty)
                    .toList(),
                noteGenerale: int.tryParse(noteCtrl.text) ?? 4,
              );
              if (context.mounted) Navigator.pop(context);
              _showSnack('Heures validees.');
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    durationCtrl.dispose();
    remarksCtrl.dispose();
    skillsCtrl.dispose();
    noteCtrl.dispose();
  }

  Future<void> _showReservationDialog(
      String autoEcoleId, String displayName) async {
    final durationCtrl = TextEditingController(text: '60');
    DateTime selectedDateTime = DateTime.now().add(const Duration(days: 2));
    String type = 'conduite';

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: const Text('Demander une lecon',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInput(durationCtrl, 'Duree en minutes',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: type,
                dropdownColor: AppColors.surfaceElevated,
                decoration: const InputDecoration(labelText: 'Type de lecon'),
                items: const [
                  DropdownMenuItem(value: 'conduite', child: Text('Conduite')),
                  DropdownMenuItem(
                      value: 'manoeuvre', child: Text('Manoeuvre')),
                ],
                onChanged: (value) => type = value ?? 'conduite',
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Creneau souhaite',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDateTime(selectedDateTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSecondaryButton(
                            icon: Icons.calendar_month_rounded,
                            label: 'Date',
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDateTime,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 90)),
                              );
                              if (pickedDate == null) return;
                              setDialogState(() {
                                selectedDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  selectedDateTime.hour,
                                  selectedDateTime.minute,
                                );
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildSecondaryButton(
                            icon: Icons.schedule_rounded,
                            label: 'Heure',
                            onPressed: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime:
                                    TimeOfDay.fromDateTime(selectedDateTime),
                              );
                              if (pickedTime == null) return;
                              setDialogState(() {
                                selectedDateTime = DateTime(
                                  selectedDateTime.year,
                                  selectedDateTime.month,
                                  selectedDateTime.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await _service.requestReservation(
                  autoEcoleId: autoEcoleId,
                  eleveNom: displayName.isEmpty ? 'Eleve' : displayName,
                  dateHeure: selectedDateTime,
                  dureeMinutes: int.tryParse(durationCtrl.text) ?? 60,
                  typeLecon: type,
                );
                if (context.mounted) Navigator.pop(context);
                _showSnack('Demande envoyee.');
              },
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );

    durationCtrl.dispose();
  }

  Future<void> _updateReservationStatus(
    String reservationId,
    String status,
  ) async {
    try {
      await _service.updateReservationStatus(
        reservationId: reservationId,
        statut: status,
      );
      _showSnack(status == 'confirme'
          ? 'Lecon confirmee.'
          : 'Demande de lecon annulee.');
    } catch (e) {
      _showSnack('Erreur: $e', isError: true);
    }
  }

  Future<void> _updateAssignedLessonStatus(
    String lessonId,
    String status,
  ) async {
    try {
      await _service.updateAssignedLessonStatus(
        lessonId: lessonId,
        statut: status,
      );
      _showSnack(status == 'terminee'
          ? 'Lecon marquee comme terminee.'
          : 'Lecon mise a jour.');
    } catch (e) {
      _showSnack('Erreur: $e', isError: true);
    }
  }

  Future<void> _repairLegacyReservations(String autoEcoleId) async {
    setState(() => _isSaving = true);
    try {
      final repairedCount =
          await _service.repairLegacyReservationsForMonitor(autoEcoleId);
      _showSnack(repairedCount == 0
          ? 'Aucune ancienne demande a rattacher.'
          : '$repairedCount ancienne(s) demande(s) rattachee(s).');
    } catch (e) {
      _showSnack('Reparation impossible: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<_PickedCatalogDocument?> _pickCatalogDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'txt',
        'jpg',
        'jpeg',
        'png',
      ],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      _showSnack('Document non lisible sur cet appareil.', isError: true);
      return null;
    }
    if (bytes.length > _PickedCatalogDocument.maxBytes) {
      _showSnack('Document limite a 20 Mo.', isError: true);
      return null;
    }

    return _PickedCatalogDocument(
      name: file.name,
      bytes: bytes,
      size: bytes.length,
      extension: file.extension,
      contentType: _contentTypeForExtension(file.extension),
    );
  }

  Future<Map<String, dynamic>?> _uploadPickedDocument({
    required String autoEcoleId,
    required String catalogType,
    required _PickedCatalogDocument? document,
  }) async {
    if (document == null) return null;

    return _service.uploadCatalogDocument(
      autoEcoleId: autoEcoleId,
      catalogType: catalogType,
      fileName: document.name,
      bytes: document.bytes,
      contentType: document.contentType,
    );
  }

  Map<String, dynamic>? _attachmentFromData(Map<String, dynamic> data) {
    final url = data['attachmentUrl'] as String?;
    if (url == null || url.trim().isEmpty) return null;

    return {
      'attachmentName': data['attachmentName'] as String? ?? 'Document',
      'attachmentUrl': url,
      'attachmentPath': data['attachmentPath'] as String?,
      'attachmentContentType': data['attachmentContentType'] as String? ??
          'application/octet-stream',
      'attachmentSize': data['attachmentSize'] as int?,
    };
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showSnack('Lien document invalide.', isError: true);
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      _showSnack('Ouverture du document impossible.', isError: true);
    }
  }

  String _contentTypeForExtension(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes o';
    final ko = bytes / 1024;
    if (ko < 1024) return '${ko.toStringAsFixed(1)} Ko';
    final mo = ko / 1024;
    return '${mo.toStringAsFixed(1)} Mo';
  }

  DateTime _readTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  String _formatDateTime(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    final weekday = _weekdayName(value.weekday);
    final day = twoDigits(value.day);
    final month = twoDigits(value.month);
    final hour = twoDigits(value.hour);
    final minute = twoDigits(value.minute);
    return '$weekday $day/$month/${value.year} a $hour:$minute';
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lundi';
      case DateTime.tuesday:
        return 'Mardi';
      case DateTime.wednesday:
        return 'Mercredi';
      case DateTime.thursday:
        return 'Jeudi';
      case DateTime.friday:
        return 'Vendredi';
      case DateTime.saturday:
        return 'Samedi';
      case DateTime.sunday:
        return 'Dimanche';
      default:
        return '';
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }
}

class _PickedCatalogDocument {
  const _PickedCatalogDocument({
    required this.name,
    required this.bytes,
    required this.size,
    required this.extension,
    required this.contentType,
  });

  static const int maxBytes = 20 * 1024 * 1024;

  final String name;
  final Uint8List bytes;
  final int size;
  final String? extension;
  final String contentType;
}

class _AutoEcoleSection {
  final IconData icon;
  final String label;

  const _AutoEcoleSection(this.icon, this.label);
}

class _AutoEcoleAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AutoEcoleAction(this.icon, this.label, this.onTap);
}
