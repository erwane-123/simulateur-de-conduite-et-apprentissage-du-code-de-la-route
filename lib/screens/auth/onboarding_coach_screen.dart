// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:code_route_flutter/screens/auth/login_screen.dart';

// class OnboardingCoachScreen extends StatefulWidget {
//   const OnboardingCoachScreen({Key? key}) : super(key: key);

//   @override
//   State<OnboardingCoachScreen> createState() => _OnboardingCoachScreenState();
// }

// class _OnboardingCoachScreenState extends State<OnboardingCoachScreen>
//     with SingleTickerProviderStateMixin {
//   int _currentStep = 0;
//   late AnimationController _animController;
//   String _selectedPermit = 'B';

//   final List<Map<String, dynamic>> _steps = [
//     {
//       'title': 'Bienvenue futur conducteur !',
//       'message':
//           'Je suis Max, votre coach personnel. Mon but est de vous accompagner jusqu\'à l\'obtention de votre code, sans stress !',
//       'image':
//           'assets/images/coach_happy.png', // Placeholder ou utiliser une icône si l'image n'existe pas
//       'icon': Icons.sentiment_very_satisfied_rounded,
//       'isQuestion': false,
//     },
//     {
//       'title': 'Quel permis visez-vous ?',
//       'message':
//           'Chaque permis a ses spécificités. Sélectionnez celui que vous préparez pour que je puisse adapter les questions.',
//       'icon': Icons.directions_car_rounded,
//       'isQuestion': true,
//       'options': [
//         'A (Moto)',
//         'A1 (Moto légère)',
//         'B (Auto)',
//         'C (Poids lourd)'
//       ],
//       'codes': ['A', 'A1', 'B', 'C'],
//     },
//     {
//       'title': 'Prêt à relever le défi ?',
//       'message':
//           'Nous allons utiliser des simulations Dashcam et des affrontements en Arena pour vous entraîner. C\'est parti !',
//       'icon': Icons.rocket_launch_rounded,
//       'isQuestion': false,
//     }
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     )..forward();
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }

//   void _nextStep() async {
//     if (_currentStep < _steps.length - 1) {
//       setState(() {
//         _currentStep++;
//       });
//       _animController.reset();
//       _animController.forward();
//     } else {
//       // Fin de l'onboarding
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('has_seen_onboarding', true);
//       await prefs.setString('selected_permis_category', _selectedPermit);

//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           PageRouteBuilder(
//             pageBuilder: (c, a, b) => const LoginScreen(),
//             transitionsBuilder: (c, a, b, child) =>
//                 FadeTransition(opacity: a, child: child),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final step = _steps[_currentStep];

//     return Scaffold(
//       backgroundColor: const Color(0xFF0F172A),
//       body: Stack(
//         children: [
//           // Background Gradient
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     const Color(0xFF0F172A),
//                     const Color(0xFF1E1B4B),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           SafeArea(
//             child: Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Coach Icon/Avatar
//                   AnimatedBuilder(
//                     animation: _animController,
//                     builder: (context, child) {
//                       return Transform.scale(
//                         scale:
//                             Curves.elasticOut.transform(_animController.value),
//                         child: Container(
//                           width: 120,
//                           height: 120,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color:
//                                 const Color(0xFF3B5BDB).withValues(alpha: 0.2),
//                             border: Border.all(
//                                 color: const Color(0xFF3B5BDB), width: 2),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0xFF3B5BDB)
//                                     .withValues(alpha: 0.3),
//                                 blurRadius: 30,
//                                 spreadRadius: 5,
//                               )
//                             ],
//                           ),
//                           child: Icon(
//                             step['icon'] as IconData,
//                             size: 60,
//                             color: Colors.white,
//                           ),
//                         ),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 40),

//                   // Message Bubble (Glassmorphism)
//                   FadeTransition(
//                     opacity: _animController,
//                     child: Container(
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: 0.1),
//                         borderRadius: BorderRadius.circular(24),
//                         border: Border.all(
//                             color: Colors.white.withValues(alpha: 0.2)),
//                       ),
//                       child: Column(
//                         children: [
//                           Text(
//                             step['title'] as String,
//                             style: const TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             step['message'] as String,
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white.withValues(alpha: 0.8),
//                               height: 1.5,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           if (step['isQuestion'] == true) ...[
//                             const SizedBox(height: 24),
//                             ...(step['options'] as List<String>)
//                                 .asMap()
//                                 .entries
//                                 .map((entry) {
//                               int idx = entry.key;
//                               String text = entry.value;
//                               String code =
//                                   (step['codes'] as List<String>)[idx];
//                               bool isSelected = _selectedPermit == code;

//                               return Padding(
//                                 padding: const EdgeInsets.only(bottom: 12.0),
//                                 child: InkWell(
//                                   onTap: () {
//                                     setState(() {
//                                       _selectedPermit = code;
//                                     });
//                                   },
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: Container(
//                                     width: double.infinity,
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 16, horizontal: 20),
//                                     decoration: BoxDecoration(
//                                       color: isSelected
//                                           ? const Color(0xFF3B5BDB)
//                                           : Colors.white
//                                               .withValues(alpha: 0.05),
//                                       borderRadius: BorderRadius.circular(12),
//                                       border: Border.all(
//                                         color: isSelected
//                                             ? const Color(0xFF5C7CFA)
//                                             : Colors.white
//                                                 .withValues(alpha: 0.1),
//                                       ),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           text,
//                                           style: TextStyle(
//                                             color: isSelected
//                                                 ? Colors.white
//                                                 : Colors.white70,
//                                             fontWeight: isSelected
//                                                 ? FontWeight.bold
//                                                 : FontWeight.normal,
//                                           ),
//                                         ),
//                                         if (isSelected)
//                                           const Icon(Icons.check_circle,
//                                               color: Colors.white, size: 20),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ]
//                         ],
//                       ),
//                     ),
//                   ),

//                   const Spacer(),

//                   // Next Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 56,
//                     child: ElevatedButton(
//                       onPressed: _nextStep,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF3B5BDB),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                       ),
//                       child: Text(
//                         _currentStep == _steps.length - 1
//                             ? 'Commencer'
//                             : 'Suivant',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // Progress Indicator
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(
//                       _steps.length,
//                       (index) => Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 4),
//                         width: _currentStep == index ? 24 : 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: _currentStep == index
//                               ? const Color(0xFF3B5BDB)
//                               : Colors.white.withValues(alpha: 0.2),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code_route_flutter/screens/auth/login_screen.dart';

class OnboardingCoachScreen extends StatefulWidget {
  const OnboardingCoachScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingCoachScreen> createState() => _OnboardingCoachScreenState();
}

class _OnboardingCoachScreenState extends State<OnboardingCoachScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  String _selectedPermit = 'B';

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Bienvenue futur conducteur !',
      'message':
          'Je suis Max, votre coach personnel. Mon but est de vous accompagner jusqu\'à l\'obtention de votre code, sans stress !',
      'icon': Icons.sentiment_very_satisfied_rounded,
      'color': const Color(0xFF3B82F6),
      'isQuestion': false,
    },
    {
      'title': 'Quel permis visez-vous ?',
      'message':
          'Sélectionnez la catégorie que vous préparez pour que j\'adapte les questions à votre profil.',
      'icon': Icons.directions_car_rounded,
      'color': const Color(0xFF8B5CF6),
      'isQuestion': true,
      'options': ['A — Moto', 'A1 — Moto légère', 'B — Automobile', 'C — Poids lourd'],
      'codes': ['A', 'A1', 'B', 'C'],
    },
    {
      'title': 'Prêt à relever le défi ?',
      'message':
          'Simulations, quiz et entraînements intensifs vous attendent. On y va !',
      'icon': Icons.rocket_launch_rounded,
      'color': const Color(0xFF10B981),
      'isQuestion': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_currentStep < _steps.length - 1) {
      await _animController.reverse();
      setState(() => _currentStep++);
      _animController.forward();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
      await prefs.setString('selected_permis_category', _selectedPermit);
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (c, a, b) => const LoginScreen(),
          transitionsBuilder: (c, a, b, child) =>
              FadeTransition(opacity: a, child: child),
        ));
      }
    }
  }

  void _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    await prefs.setString('selected_permis_category', _selectedPermit);
    if (mounted) {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (c, a, b) => const LoginScreen(),
        transitionsBuilder: (c, a, b, child) =>
            FadeTransition(opacity: a, child: child),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final color = step['color'] as Color;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 480 : double.infinity),
            child: Column(
              children: [
                // ── Barre supérieure ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Indicateurs de progression
                      Row(
                        children: List.generate(_steps.length, (index) {
                          final isActive = index == _currentStep;
                          final isDone = index < _currentStep;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 6),
                            width: isActive ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? color.withValues(alpha: 0.4)
                                  : isActive
                                      ? color
                                      : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      // Bouton passer
                      if (_currentStep < _steps.length - 1)
                        TextButton(
                          onPressed: _skip,
                          child: const Text(
                            'Passer',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Contenu principal ────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          children: [
                            const SizedBox(height: 24),

                            // Icône animée
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withValues(alpha: 0.10),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.25),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                step['icon'] as IconData,
                                size: 52,
                                color: color,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Titre
                            Text(
                              step['title'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Message
                            Text(
                              step['message'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF64748B),
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            // Options permis
                            if (step['isQuestion'] == true) ...[
                              const SizedBox(height: 28),
                              ...(step['options'] as List<String>)
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final idx = entry.key;
                                final text = entry.value;
                                final code = (step['codes'] as List<String>)[idx];
                                final isSelected = _selectedPermit == code;

                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedPermit = code),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? color.withValues(alpha: 0.08)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? color
                                            : const Color(0xFFE2E8F0),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: color.withValues(alpha: 0.12),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              )
                                            ]
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.04),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              )
                                            ],
                                    ),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected
                                                ? color
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected
                                                  ? color
                                                  : const Color(0xFFCBD5E1),
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? const Icon(Icons.check,
                                                  color: Colors.white, size: 14)
                                              : null,
                                        ),
                                        const SizedBox(width: 14),
                                        Text(
                                          text,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? color
                                                : const Color(0xFF374151),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Bouton bas ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.30),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentStep == _steps.length - 1
                                  ? 'Commencer'
                                  : 'Suivant',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentStep == _steps.length - 1
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
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