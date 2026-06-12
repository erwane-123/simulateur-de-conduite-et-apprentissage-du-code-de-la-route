import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:code_route_flutter/widgets/coach_dialog.dart';

class ManoeuvreStep {
  final int id;
  final String description;
  ManoeuvreStep({required this.id, required this.description});
}

class ManoeuvreScenario {
  final String title;
  final String objective;
  final List<ManoeuvreStep> correctOrder;

  ManoeuvreScenario({
    required this.title,
    required this.objective,
    required this.correctOrder,
  });
}

class ManoeuvresScreen extends StatefulWidget {
  const ManoeuvresScreen({Key? key}) : super(key: key);

  @override
  State<ManoeuvresScreen> createState() => _ManoeuvresScreenState();
}

class _ManoeuvresScreenState extends State<ManoeuvresScreen> {
  final FlutterTts _tts = FlutterTts();
  int _currentScenarioIndex = 0;
  List<ManoeuvreStep> _currentItems = [];
  bool _hasChecked = false;

  final List<ManoeuvreScenario> _scenarios = [
    ManoeuvreScenario(
      title: "Démarrage en côte",
      objective: "Remets les actions dans l'ordre chronologique pour effectuer un démarrage en côte parfait sans caler.",
      correctOrder: [
        ManoeuvreStep(id: 1, description: "Débrayer à fond et passer la 1ère vitesse."),
        ManoeuvreStep(id: 2, description: "Accélérer légèrement (environ 1500 tr/min)."),
        ManoeuvreStep(id: 3, description: "Relâcher doucement l'embrayage jusqu'au point de patinage."),
        ManoeuvreStep(id: 4, description: "Desserrer le frein à main tout en maintenant les pédales."),
        ManoeuvreStep(id: 5, description: "Continuer d'accélérer et relâcher complètement l'embrayage."),
      ],
    ),
    ManoeuvreScenario(
      title: "Insertion sur autoroute",
      objective: "Comment t'insérer en toute sécurité sur une voie rapide ?",
      correctOrder: [
        ManoeuvreStep(id: 1, description: "Accélérer franchement dans la voie d'insertion."),
        ManoeuvreStep(id: 2, description: "Contrôler le rétroviseur intérieur puis extérieur gauche."),
        ManoeuvreStep(id: 3, description: "Mettre le clignotant à gauche."),
        ManoeuvreStep(id: 4, description: "Vérifier l'angle mort gauche en tournant la tête."),
        ManoeuvreStep(id: 5, description: "S'insérer en douceur sans gêner les autres véhicules."),
      ],
    ),
    ManoeuvreScenario(
      title: "Le Créneau (Côté Droit)",
      objective: "Range ta voiture entre deux véhicules stationnés.",
      correctOrder: [
        ManoeuvreStep(id: 1, description: "Mettre le clignotant à droite et s'arrêter à hauteur du véhicule de référence."),
        ManoeuvreStep(id: 2, description: "Reculer droit jusqu'à voir l'arrière du véhicule de référence au niveau de la vitre arrière."),
        ManoeuvreStep(id: 3, description: "Braquer le volant à fond à droite en continuant de reculer."),
        ManoeuvreStep(id: 4, description: "Contre-braquer à fond à gauche lorsque le véhicule est à environ 45 degrés."),
        ManoeuvreStep(id: 5, description: "Redresser les roues une fois le véhicule parallèle au trottoir."),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadScenario();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(kIsWeb ? 1.0 : 0.5);
  }

  void _loadScenario() {
    setState(() {
      _hasChecked = false;
      // On copie les étapes et on les mélange
      _currentItems = List.from(_scenarios[_currentScenarioIndex].correctOrder);
      _currentItems.shuffle();
    });
    _playObjectiveAudio();
  }

  void _playObjectiveAudio() {
    _tts.speak(_scenarios[_currentScenarioIndex].objective);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _currentItems.removeAt(oldIndex);
      _currentItems.insert(newIndex, item);
      _hasChecked = false; // Réinitialiser l'état de vérification
    });
  }

  bool _isOrderCorrect() {
    final correctOrder = _scenarios[_currentScenarioIndex].correctOrder;
    for (int i = 0; i < correctOrder.length; i++) {
      if (_currentItems[i].id != correctOrder[i].id) {
        return false;
      }
    }
    return true;
  }

  void _checkOrder() async {
    setState(() {
      _hasChecked = true;
    });

    await _tts.stop();
    if (!mounted) return;

    if (_isOrderCorrect()) {
      await CoachDialog.show(
        context,
        tts: _tts,
        type: CoachDialogType.success,
      );

      if (mounted) {
        if (_currentScenarioIndex < _scenarios.length - 1) {
          setState(() {
            _currentScenarioIndex++;
          });
          _loadScenario();
        } else {
          _showEndGameDialog();
        }
      }
    } else {
      await CoachDialog.show(
        context,
        tts: _tts,
        type: CoachDialogType.failure,
      );
    }
  }

  void _showEndGameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Expert en Manœuvres !', style: TextStyle(color: Color(0xFF00E5FF))),
        content: const Text(
          'Vous connaissez parfaitement l\'ordre des actions. La pratique sera un jeu d\'enfant !',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to hub
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
            child: const Text('Retour', style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenario = _scenarios[_currentScenarioIndex];

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
          'MANŒUVRES PAS-À-PAS',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header / Objective
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_currentScenarioIndex + 1}/${_scenarios.length}',
                              style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              scenario.title,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        scenario.objective,
                        style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.touch_app_rounded, color: Colors.white54, size: 16),
                SizedBox(width: 8),
                Text(
                  "Maintenez et glissez pour réorganiser",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          // Reorderable List
          Expanded(
            child: Theme(
              data: ThemeData(
                canvasColor: Colors.transparent, // Pour éviter le fond blanc pendant le glisser
              ),
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _currentItems.length,
                onReorder: _onReorder,
                proxyDecorator: (Widget child, int index, Animation<double> animation) {
                  return Material(
                    color: Colors.transparent,
                    elevation: 10,
                    shadowColor: const Color(0xFF00E5FF).withOpacity(0.5),
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final item = _currentItems[index];
                  
                  // Calculer la couleur si l'utilisateur a vérifié
                  Color borderColor = Colors.white.withOpacity(0.1);
                  Color bgColor = Colors.white.withOpacity(0.05);
                  if (_hasChecked) {
                    final correctOrder = scenario.correctOrder;
                    if (correctOrder[index].id == item.id) {
                      borderColor = const Color(0xFF00E676);
                      bgColor = const Color(0xFF00E676).withOpacity(0.1);
                    } else {
                      borderColor = const Color(0xFFFF5252);
                      bgColor = const Color(0xFFFF5252).withOpacity(0.1);
                    }
                  }

                  return Container(
                    key: ValueKey(item.id),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        item.description,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      trailing: const Icon(Icons.drag_handle_rounded, color: Colors.white30),
                    ),
                  );
                },
              ),
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _checkOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'VALIDER L\'ORDRE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
