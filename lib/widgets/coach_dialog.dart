import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:code_route_flutter/core/constants/app_colors.dart';

enum CoachDialogType { intro, success, failure }

class CoachDialog {
  static final _random = Random();

  static final List<String> _successPhrases = [
    "Super !",
    "Génial !",
    "Parfait, tu gères !",
    "Excellente réponse !",
    "C'est tout à fait ça !",
    "Bien joué !",
    "Tu es sur la bonne voie !",
  ];

  static final List<String> _failurePhrases = [
    "Aïe, presque !",
    "Attention à ce piège !",
    "Pas tout à fait...",
    "Regardons l'explication.",
    "Ne te décourage pas !",
    "C'était une question difficile.",
    "Oups, petite erreur.",
  ];

  static String _getRandomPhrase(CoachDialogType type) {
    switch (type) {
      case CoachDialogType.intro:
        return "Top, c'est parti ! Concentre-toi bien.";
      case CoachDialogType.success:
        return _successPhrases[_random.nextInt(_successPhrases.length)];
      case CoachDialogType.failure:
        return _failurePhrases[_random.nextInt(_failurePhrases.length)];
    }
  }

  static Future<void> show(
    BuildContext context, {
    required FlutterTts tts,
    required CoachDialogType type,
    VoidCallback? onComplete,
  }) async {
    final String message = _getRandomPhrase(type);

    Color getPrimaryColor() {
      switch (type) {
        case CoachDialogType.intro:
          return AppColors.primaryPurple; // Couleur neutre/intro
        case CoachDialogType.success:
          return const Color(0xFF00E676); // Vert validation
        case CoachDialogType.failure:
          return const Color(0xFFFF5252); // Rouge erreur
      }
    }

    IconData getIcon() {
      switch (type) {
        case CoachDialogType.intro:
          return Icons.rocket_launch_rounded;
        case CoachDialogType.success:
          return Icons.check_circle_rounded;
        case CoachDialogType.failure:
          return Icons.cancel_rounded;
      }
    }

    final Color primaryColor = getPrimaryColor();
    final IconData icon = getIcon();

    await tts.stop();
    
    // On demande au TTS d'attendre la fin de la lecture pour résoudre le Future
    await tts.awaitSpeakCompletion(true);
    if (!context.mounted) return;

    bool isDialogOpen = true;

    // Afficher le dialog sans bloquer l'exécution (pas de await ici)
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return _CoachDialogWidget(
          message: message,
          primaryColor: primaryColor,
          iconData: icon,
          type: type,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    ).then((_) {
      isDialogOpen = false;
      if (onComplete != null) {
        onComplete();
      }
    });

    final stopwatch = Stopwatch()..start();
    
    // Lancer la lecture TTS. Le await attendra la fin de la voix !
    await tts.speak(message);
    
    stopwatch.stop();
    final elapsed = stopwatch.elapsedMilliseconds;
    
    // Si le TTS a été instantané (désactivé ou erreur), on force un délai minimum pour que l'utilisateur ait le temps de lire
    if (elapsed < 2000) {
      await Future.delayed(Duration(milliseconds: 2000 - elapsed));
    } else {
      // Petit délai de confort après la fin de la voix
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Fermer automatiquement le dialog s'il est toujours ouvert
    if (isDialogOpen && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

class _CoachDialogWidget extends StatefulWidget {
  final String message;
  final Color primaryColor;
  final IconData iconData;
  final CoachDialogType type;
  const _CoachDialogWidget({
    Key? key,
    required this.message,
    required this.primaryColor,
    required this.iconData,
    required this.type,
  }) : super(key: key);

  @override
  State<_CoachDialogWidget> createState() => _CoachDialogWidgetState();
}

class _CoachDialogWidgetState extends State<_CoachDialogWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Le panneau (Croix rouge ou Check vert) - sauf pour intro où c'est juste le coach
              if (widget.type != CoachDialogType.intro)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.primaryColor.withOpacity(0.15),
                    border: Border.all(color: widget.primaryColor.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Icon(
                    widget.iconData,
                    size: 80,
                    color: widget.primaryColor,
                  ),
                ),

              // Le Coach (Avatar flottant)
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_bounceAnimation.value),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3B5BDB).withOpacity(0.2),
                        border: Border.all(color: const Color(0xFF3B5BDB), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B5BDB).withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded, // Icône stylisée pour le coach
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Bulle de dialogue (Glassmorphism)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B2A).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: widget.primaryColor.withOpacity(0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Coach Max",
                      style: TextStyle(
                        color: widget.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
