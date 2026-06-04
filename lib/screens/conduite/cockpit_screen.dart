import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:code_route_flutter/widgets/coach_dialog.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum DashboardControl {
  headlightLow,
  headlightHigh,
  fogLightRear,
  turnSignalLeft,
  turnSignalRight,
  hazardLights,
  wipers,
}

class CockpitMission {
  final String description;
  final DashboardControl targetControl;
  final String successMessage;

  CockpitMission({
    required this.description,
    required this.targetControl,
    required this.successMessage,
  });
}

// Fonction utilitaire pour obtenir le nom français d'un contrôle
String getControlName(DashboardControl control) {
  switch (control) {
    case DashboardControl.headlightLow: return "Feux de croisement";
    case DashboardControl.headlightHigh: return "Feux de route (Phares)";
    case DashboardControl.fogLightRear: return "Feu de brouillard arrière";
    case DashboardControl.turnSignalLeft: return "Clignotant gauche";
    case DashboardControl.turnSignalRight: return "Clignotant droit";
    case DashboardControl.hazardLights: return "Feux de détresse (Warnings)";
    case DashboardControl.wipers: return "Essuie-glaces";
  }
}

class CockpitScreen extends StatefulWidget {
  const CockpitScreen({Key? key}) : super(key: key);

  @override
  State<CockpitScreen> createState() => _CockpitScreenState();
}

class _CockpitScreenState extends State<CockpitScreen> {
  final FlutterTts _tts = FlutterTts();
  int _currentMissionIndex = 0;
  bool _missionCompleted = false;
  
  // État des boutons
  final Map<DashboardControl, bool> _controlStates = {
    for (var control in DashboardControl.values) control: false
  };

  final List<CockpitMission> _missions = [
    CockpitMission(
      description: "Il commence à faire nuit. Allume tes feux de croisement pour voir et être vu sans éblouir.",
      targetControl: DashboardControl.headlightLow,
      successMessage: "Parfait ! Les feux de croisement sont obligatoires la nuit.",
    ),
    CockpitMission(
      description: "Tu vas changer de voie vers la gauche. Indique ton intention aux autres conducteurs.",
      targetControl: DashboardControl.turnSignalLeft,
      successMessage: "Bien joué. Toujours le clignotant avant de déboîter !",
    ),
    CockpitMission(
      description: "Gros ralentissement inattendu devant toi sur l'autoroute ! Préviens les véhicules derrière.",
      targetControl: DashboardControl.hazardLights,
      successMessage: "Exactement. Les feux de détresse permettent d'éviter les carambolages.",
    ),
    CockpitMission(
      description: "Une forte pluie soudaine réduit la visibilité. Active les essuie-glaces.",
      targetControl: DashboardControl.wipers,
      successMessage: "Super. Garder un pare-brise propre est essentiel.",
    ),
    CockpitMission(
      description: "Brouillard épais. Allume ton feu de brouillard arrière pour être repéré.",
      targetControl: DashboardControl.fogLightRear,
      successMessage: "C'est ça ! Mais n'oublie pas de l'éteindre quand il pleut, ça éblouit !",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    _playMissionAudio();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.5);
  }

  void _playMissionAudio() {
    if (_currentMissionIndex < _missions.length) {
      _tts.speak(_missions[_currentMissionIndex].description);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _handleControlTap(DashboardControl control) async {
    if (_missionCompleted) return;

    final currentMission = _missions[_currentMissionIndex];

    setState(() {
      _controlStates[control] = !_controlStates[control]!;
    });

    if (control == currentMission.targetControl && _controlStates[control] == true) {
      // Succès !
      setState(() {
        _missionCompleted = true;
      });
      
      await _tts.stop();
      if (!mounted) return;
      await CoachDialog.show(
        context,
        tts: _tts,
        type: CoachDialogType.success,
      );

      // Passer à la mission suivante
      if (mounted) {
        if (_currentMissionIndex < _missions.length - 1) {
          setState(() {
            _currentMissionIndex++;
            _missionCompleted = false;
            // Réinitialiser les boutons
            _controlStates.updateAll((key, value) => false);
          });
          _playMissionAudio();
        } else {
          // Fin du jeu
          _showEndGameDialog();
        }
      }
    } else if (_controlStates[control] == true) {
      // Mauvais bouton activé (erreur)
      await _tts.stop();
      final wrongLabel = getControlName(control);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Oups ! Tu as activé : $wrongLabel", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: const Color(0xFFFF5252),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      await CoachDialog.show(
        context,
        tts: _tts,
        type: CoachDialogType.failure,
      );
      if (mounted) {
        setState(() {
          _controlStates[control] = false; // On l'éteint
        });
        _playMissionAudio(); // Répéter la mission
      }
    }
  }

  void _showEndGameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Félicitations !', style: TextStyle(color: Color(0xFF00E5FF))),
        content: const Text(
          'Vous avez maîtrisé le cockpit. Vous êtes prêt pour la pratique en conditions réelles !',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to hub
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
            child: const Text('Retour au menu', style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mission = _currentMissionIndex < _missions.length ? _missions[_currentMissionIndex] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SIMULATEUR DE COCKPIT',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.1), blurRadius: 100, spreadRadius: 50),
                ],
              ),
            ),
          ),
          
          Column(
            children: [
              // Mission Card
              if (mission != null)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.campaign_rounded, color: Color(0xFF00E5FF)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MISSION ${_currentMissionIndex + 1}/${_missions.length}',
                                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    mission.description,
                                    style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              
              const Spacer(),
              
              // The Dashboard UI
              _buildDashboard(),
              
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Top Row: Wipers and Hazards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CockpitButton(
                icon: Icons.waves_rounded,
                isActive: _controlStates[DashboardControl.wipers]!,
                activeColor: const Color(0xFF38BDF8),
                onTap: () => _handleControlTap(DashboardControl.wipers),
              ),
              _CockpitButton(
                icon: Icons.warning_rounded, // Standard hazard triangle
                isActive: _controlStates[DashboardControl.hazardLights]!,
                activeColor: const Color(0xFFFF3D00),
                onTap: () => _handleControlTap(DashboardControl.hazardLights),
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          // Middle Row: Steering wheel area
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Stalk (Turn Left)
              _CockpitButton(
                icon: Icons.arrow_back_rounded,
                isActive: _controlStates[DashboardControl.turnSignalLeft]!,
                activeColor: const Color(0xFF00E676),
                onTap: () => _handleControlTap(DashboardControl.turnSignalLeft),
              ),
              
              // Steering Wheel Representation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 8),
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.05), Colors.transparent],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.drive_eta_rounded, color: Colors.white24, size: 40),
                ),
              ),
              
              // Right Stalk (Turn Right)
              _CockpitButton(
                icon: Icons.arrow_forward_rounded,
                isActive: _controlStates[DashboardControl.turnSignalRight]!,
                activeColor: const Color(0xFF00E676),
                onTap: () => _handleControlTap(DashboardControl.turnSignalRight),
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          // Bottom Row: Lights
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CockpitButton(
                icon: Icons.brightness_medium_rounded, // Resembles low beams
                isActive: _controlStates[DashboardControl.headlightLow]!,
                activeColor: const Color(0xFF00E5FF),
                onTap: () => _handleControlTap(DashboardControl.headlightLow),
              ),
              _CockpitButton(
                icon: Icons.brightness_high_rounded, // High beams
                isActive: _controlStates[DashboardControl.headlightHigh]!,
                activeColor: const Color(0xFF2962FF),
                onTap: () => _handleControlTap(DashboardControl.headlightHigh),
              ),
              _CockpitButton(
                icon: Icons.blur_on_rounded, // Fog light
                isActive: _controlStates[DashboardControl.fogLightRear]!,
                activeColor: const Color(0xFFFF9100),
                onTap: () => _handleControlTap(DashboardControl.fogLightRear),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CockpitButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _CockpitButton({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24), // Un peu plus grand pour compenser l'absence de texte
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? activeColor : Colors.white.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: activeColor.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)]
              : [],
        ),
        child: Icon(
          icon,
          size: 40, // Icônes plus grandes
          color: isActive ? activeColor : Colors.white54,
        ),
      ),
    );
  }
}
