// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:code_route_flutter/core/constants/app_colors.dart';
// import 'package:code_route_flutter/data/models/permis_category.dart';
// import 'package:code_route_flutter/screens/auth/register_screen.dart';
// import 'package:code_route_flutter/screens/home/main_navigation.dart';
// import 'package:code_route_flutter/core/providers/localization_provider.dart';
// import 'package:code_route_flutter/services/firebase/auth_service.dart';
// import 'package:code_route_flutter/services/firebase/firestore_service.dart';
// import 'package:code_route_flutter/data/test_questions.dart';
// import 'package:code_route_flutter/screens/auth/welcome_celebration_screen.dart';

// class LoginScreen extends StatefulWidget {
//   final bool isFromDemo;
//   const LoginScreen({Key? key, this.isFromDemo = false}) : super(key: key);

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   late AnimationController _animController;
//   final _authService = AuthService();
//   final _firestoreService = FirestoreService();

//   final List<PermisCategory> _categories = PermisCategory.getAllCategories();
//   String _selectedCategoryCode = 'B';

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     )..forward();
//   }

//   Future<void> _loadInitialData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedCat = prefs.getString('selected_permis_category');
//     if (savedCat != null && _categories.any((c) => c.code == savedCat)) {
//       setState(() => _selectedCategoryCode = savedCat);
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(context.tr('login_error_empty')),
//           backgroundColor: AppColors.error,
//           behavior: SnackBarBehavior.floating,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       );
//       return;
//     }
//     setState(() => _isLoading = true);

//     final result = await _authService.signIn(
//         _emailController.text, _passwordController.text);

//     if (result != null) {
//       await _persistAuthenticatedUser(
//         result,
//         fallbackEmail: _emailController.text,
//       );

//       if (mounted) {
//         Navigator.of(context).pushReplacement(PageRouteBuilder(
//           pageBuilder: (c, a, b) => widget.isFromDemo
//               ? const WelcomeCelebrationScreen()
//               : const MainNavigation(),
//           transitionsBuilder: (c, a, b, child) =>
//               FadeTransition(opacity: a, child: child),
//         ));
//       }
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Erreur de connexion : Vérifiez vos identifiants')),
//         );
//       }
//     }
//     setState(() => _isLoading = false);
//   }

//   Future<void> _persistAuthenticatedUser(
//     UserCredential result, {
//     String? fallbackName,
//     String? fallbackEmail,
//   }) async {
//     final user = result.user;
//     if (user == null) return;

//     final displayName = _resolveDisplayName(
//       rawDisplayName: user.displayName,
//       fallbackName: fallbackName,
//     );
//     final email = user.email ?? fallbackEmail ?? '';

//     if (result.additionalUserInfo?.isNewUser == true) {
//       await _firestoreService.createUserProfile(user.uid, {
//         'name': displayName,
//         'email': email,
//         'xp': 0,
//         'level': 1,
//         'createdAt': DateTime.now().toIso8601String(),
//       });
//     }

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isLoggedIn', true);
//     await prefs.setBool('isGuest', false);
//     await prefs.setString('selected_permis_category', _selectedCategoryCode);
//     await prefs.setString('userEmail', email);
//     await prefs.setString('user_email', email);
//     await prefs.setString('userName', displayName);
//     await prefs.setString('user_name', displayName);
//   }

//   String _resolveDisplayName({
//     String? rawDisplayName,
//     String? fallbackName,
//   }) {
//     final name = (rawDisplayName ?? fallbackName ?? '').trim();
//     if (name.isNotEmpty) return name;
//     if (_emailController.text.trim().isNotEmpty) {
//       return _emailController.text.trim().split('@').first;
//     }
//     return 'Utilisateur';
//   }

//   Future<void> _handleGoogleLogin() async {
//     setState(() => _isLoading = true);
//     try {
//       final result = await _authService.signInWithGoogle();
//       if (result == null) {
//         return;
//       }

//       await _persistAuthenticatedUser(result);

//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           PageRouteBuilder(
//             pageBuilder: (c, a, b) => widget.isFromDemo
//                 ? const WelcomeCelebrationScreen()
//                 : const MainNavigation(),
//             transitionsBuilder: (c, a, b, child) =>
//                 FadeTransition(opacity: a, child: child),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.toString())),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _handleAppleLogin() async {
//     setState(() => _isLoading = true);
//     try {
//       final result = await _authService.signInWithApple();
//       if (result == null) {
//         return;
//       }

//       await _persistAuthenticatedUser(result);

//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           PageRouteBuilder(
//             pageBuilder: (c, a, b) => widget.isFromDemo
//                 ? const WelcomeCelebrationScreen()
//                 : const MainNavigation(),
//             transitionsBuilder: (c, a, b, child) =>
//                 FadeTransition(opacity: a, child: child),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.toString())),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _seedDatabase() async {
//     setState(() => _isLoading = true);
//     try {
//       final questions = getTestQuestions();
//       await _firestoreService.seedQuestions(questions);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Base de données initialisée avec succès !')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erreur d\'initialisation : $e')),
//         );
//       }
//     }
//     setState(() => _isLoading = false);
//   }

//   Future<void> _goGuest() async {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Connexion requise pour acceder a l application.'),
//         ),
//       );
//     }
//   }

//   Widget _slide({required Widget child, required double delay}) {
//     return AnimatedBuilder(
//       animation: _animController,
//       builder: (ctx, w) {
//         final t = (((_animController.value - delay) / 0.4).clamp(0.0, 1.0));
//         final curve = Curves.easeOutCubic.transform(t);
//         return Opacity(
//           opacity: curve,
//           child: Transform.translate(
//               offset: Offset(0, 24 * (1 - curve)), child: w),
//         );
//       },
//       child: child,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F172A),
//       body: Stack(
//         children: [
//           // ── Image de fond plein écran ─────────────────────────────
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/login_bg.png',
//               fit: BoxFit.cover,
//             ),
//           ),
//           // ── Overlay dégradé sombre pour lisibilité ────────────────
//           Positioned.fill(
//             child: DecoratedBox(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black.withValues(alpha: 0.45),
//                     Colors.black.withValues(alpha: 0.70),
//                     Colors.black.withValues(alpha: 0.85),
//                   ],
//                   stops: const [0.0, 0.45, 1.0],
//                 ),
//               ),
//             ),
//           ),
//           SafeArea(
//             child: Center(
//               child: SingleChildScrollView(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
//                 child: Column(
//                   children: [
//                     // ── Icône voiture ──────────────────────────────────
//                     _slide(
//                       delay: 0.0,
//                       child: Container(
//                         width: 72,
//                         height: 72,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFDDE8FF),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.directions_car_rounded,
//                           color: Color(0xFF3B5BDB),
//                           size: 36,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // ── Titre ──────────────────────────────────────────
//                     _slide(
//                       delay: 0.08,
//                       child: Text(
//                         context.tr('login_welcome'),
//                         style: const TextStyle(
//                           fontSize: 26,
//                           fontWeight: FontWeight.w800,
//                           color: Colors.white,
//                           letterSpacing: -0.5,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     const SizedBox(height: 6),

//                     // ── Sous-titre ─────────────────────────────────────
//                     _slide(
//                       delay: 0.14,
//                       child: Text(
//                         context.tr('login_subtitle'),
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF93C5FD),
//                           fontWeight: FontWeight.w500,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     const SizedBox(height: 32),

//                     // ── Carte blanche ──────────────────────────────────
//                     _slide(
//                       delay: 0.22,
//                       child: Container(
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withValues(alpha: 0.13),
//                           borderRadius: BorderRadius.circular(24),
//                           border: Border.all(
//                             color: Colors.white.withValues(alpha: 0.22),
//                             width: 1.5,
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withValues(alpha: 0.25),
//                               blurRadius: 40,
//                               offset: const Offset(0, 12),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // -- Catégorie permis --
//                             _fieldLabel('Catégorie de permis'),
//                             const SizedBox(height: 8),
//                             _buildCategoryDropdown(),
//                             const SizedBox(height: 20),

//                             // -- Email --
//                             _fieldLabel(context.tr('login_email_hint')),
//                             const SizedBox(height: 8),
//                             _LoginField(
//                               controller: _emailController,
//                               hint: 'votre@email.com',
//                               icon: Icons.mail_outline_rounded,
//                               keyboardType: TextInputType.emailAddress,
//                             ),
//                             const SizedBox(height: 20),

//                             // -- Mot de passe --
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 _fieldLabel(context.tr('login_password_hint')),
//                                 TextButton(
//                                   onPressed: () {},
//                                   style: TextButton.styleFrom(
//                                     padding: EdgeInsets.zero,
//                                     minimumSize: Size.zero,
//                                     tapTargetSize:
//                                         MaterialTapTargetSize.shrinkWrap,
//                                   ),
//                                   child: Text(
//                                     context.tr('login_forgot_password'),
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       color: Color(0xFF3B5BDB),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             _LoginField(
//                               controller: _passwordController,
//                               hint: '••••••••',
//                               icon: Icons.lock_outline_rounded,
//                               isPassword: true,
//                             ),
//                             const SizedBox(height: 28),

//                             // -- Bouton Connexion --
//                             _LoginButton(
//                               isLoading: _isLoading,
//                               label: context.tr('login_button'),
//                               onPressed: _login,
//                             ),
//                             const SizedBox(height: 24),

//                             // -- Séparateur --
//                             Row(
//                               children: [
//                                 Expanded(
//                                     child: Divider(
//                                         color: Colors.white
//                                             .withValues(alpha: 0.25))),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 12),
//                                   child: Text(
//                                     'Ou continuer avec',
//                                     style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.white
//                                             .withValues(alpha: 0.65)),
//                                   ),
//                                 ),
//                                 Expanded(
//                                     child: Divider(
//                                         color: Colors.white
//                                             .withValues(alpha: 0.25))),
//                               ],
//                             ),
//                             const SizedBox(height: 16),

//                             // -- Boutons sociaux --
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _SocialButton(
//                                     label: 'Google',
//                                     icon: _googleIcon(),
//                                     onPressed: _handleGoogleLogin,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: _SocialButton(
//                                     label: 'Apple',
//                                     icon: const Icon(Icons.apple,
//                                         size: 18, color: Colors.white),
//                                     onPressed: _handleAppleLogin,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // ── Lien inscription ───────────────────────────────
//                     _slide(
//                       delay: 0.4,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             context.tr('login_no_account'),
//                             style: const TextStyle(
//                                 fontSize: 14, color: Colors.white70),
//                           ),
//                           GestureDetector(
//                             onTap: () => Navigator.push(
//                               context,
//                               PageRouteBuilder(
//                                 pageBuilder: (c, a, b) =>
//                                     const RegisterScreen(),
//                                 transitionsBuilder: (c, a, b, child) =>
//                                     FadeTransition(opacity: a, child: child),
//                               ),
//                             ),
//                             child: Text(
//                               context.tr('login_register'),
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w700,
//                                 color: Color(0xFF93C5FD),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // ── Bouton Consulter (mode invité) ─────────────────
//                     _slide(
//                       delay: 0.5,
//                       child: GestureDetector(
//                         onTap: _goGuest,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 24, vertical: 14),
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                                 color: Colors.white.withValues(alpha: 0.25),
//                                 width: 1.5),
//                             borderRadius: BorderRadius.circular(16),
//                             color: Colors.white.withValues(alpha: 0.08),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.remove_red_eye_outlined,
//                                 color: Colors.white.withValues(alpha: 0.75),
//                                 size: 18,
//                               ),
//                               const SizedBox(width: 10),
//                               Text(
//                                 context.tr('login_guest'),
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.white.withValues(alpha: 0.80),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                     // Bouton secret pour initialiser Firestore (Admin)
//                     _slide(
//                       delay: 0.6,
//                       child: TextButton(
//                         onPressed: _isLoading ? null : _seedDatabase,
//                         child: Text(
//                           'INIT_DATABASE_CLOUD',
//                           style: TextStyle(
//                             color: Colors.white.withValues(alpha: 0.2),
//                             fontSize: 10,
//                             letterSpacing: 2,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // ── Sélecteur de langue (coin haut droit) ─────────────────
//           Positioned(
//             top: 12,
//             right: 16,
//             child: SafeArea(child: _buildLanguagePill()),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _fieldLabel(String text) => Text(
//         text,
//         style: const TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//       );

//   Widget _buildCategoryDropdown() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.12),
//         borderRadius: BorderRadius.circular(14),
//         border:
//             Border.all(color: Colors.white.withValues(alpha: 0.30), width: 1.5),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _selectedCategoryCode,
//           isExpanded: true,
//           icon: Icon(Icons.keyboard_arrow_down_rounded,
//               color: Colors.white.withValues(alpha: 0.70)),
//           dropdownColor: const Color(0xFF1E293B),
//           borderRadius: BorderRadius.circular(14),
//           style: const TextStyle(
//               color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
//           onChanged: (v) {
//             if (v != null) setState(() => _selectedCategoryCode = v);
//           },
//           items: _categories.map((c) {
//             return DropdownMenuItem<String>(
//               value: c.code,
//               child: Row(
//                 children: [
//                   Icon(c.icon, color: const Color(0xFF3B5BDB), size: 18),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text('${c.name} - ${c.description}',
//                         style: const TextStyle(fontSize: 13),
//                         overflow: TextOverflow.ellipsis),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildLanguagePill() {
//     final loc = Provider.of<LocalizationProvider>(context);
//     final isEn = loc.locale == 'en';
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withValues(alpha: 0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 3)),
//         ],
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: isEn ? 'en' : 'fr',
//           icon: const SizedBox.shrink(),
//           alignment: Alignment.center,
//           dropdownColor: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           style: const TextStyle(
//               color: Color(0xFF0F172A),
//               fontSize: 13,
//               fontWeight: FontWeight.bold),
//           onChanged: (v) {
//             if (v != null) loc.setLocale(v);
//           },
//           items: const [
//             DropdownMenuItem(
//                 value: 'fr',
//                 child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 14),
//                     child: Text('🇫🇷 FR'))),
//             DropdownMenuItem(
//                 value: 'en',
//                 child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 14),
//                     child: Text('🇬🇧 EN'))),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _googleIcon() {
//     return SizedBox(
//       width: 18,
//       height: 18,
//       child: CustomPaint(painter: _GoogleIconPainter()),
//     );
//   }
// }

// // ── Champ de saisie ────────────────────────────────────────────────────────────

// class _LoginField extends StatefulWidget {
//   final TextEditingController controller;
//   final String hint;
//   final IconData icon;
//   final bool isPassword;
//   final TextInputType keyboardType;

//   const _LoginField({
//     Key? key,
//     required this.controller,
//     required this.hint,
//     required this.icon,
//     this.isPassword = false,
//     this.keyboardType = TextInputType.text,
//   }) : super(key: key);

//   @override
//   State<_LoginField> createState() => _LoginFieldState();
// }

// class _LoginFieldState extends State<_LoginField> {
//   bool _obscure = true;
//   final _focus = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     _focus.addListener(() => setState(() {}));
//   }

//   @override
//   void dispose() {
//     _focus.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final focused = _focus.hasFocus;
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 180),
//       decoration: BoxDecoration(
//         color: focused
//             ? Colors.white.withValues(alpha: 0.22)
//             : Colors.white.withValues(alpha: 0.12),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: focused
//               ? Colors.white.withValues(alpha: 0.80)
//               : Colors.white.withValues(alpha: 0.30),
//           width: 1.5,
//         ),
//         boxShadow: focused
//             ? [
//                 BoxShadow(
//                     color: Colors.white.withValues(alpha: 0.08), blurRadius: 10)
//               ]
//             : [],
//       ),
//       child: TextField(
//         controller: widget.controller,
//         focusNode: _focus,
//         obscureText: widget.isPassword ? _obscure : false,
//         keyboardType: widget.keyboardType,
//         style: const TextStyle(
//             color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
//         decoration: InputDecoration(
//           hintText: widget.hint,
//           hintStyle: TextStyle(
//               color: Colors.white.withValues(alpha: 0.45), fontSize: 14),
//           prefixIcon: Icon(
//             widget.icon,
//             color:
//                 focused ? Colors.white : Colors.white.withValues(alpha: 0.55),
//             size: 20,
//           ),
//           suffixIcon: widget.isPassword
//               ? IconButton(
//                   icon: Icon(
//                     _obscure
//                         ? Icons.visibility_outlined
//                         : Icons.visibility_off_outlined,
//                     color: Colors.white.withValues(alpha: 0.70),
//                     size: 20,
//                   ),
//                   onPressed: () => setState(() => _obscure = !_obscure),
//                 )
//               : null,
//           border: InputBorder.none,
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         ),
//       ),
//     );
//   }
// }

// // ── Bouton Connexion ───────────────────────────────────────────────────────────

// class _LoginButton extends StatelessWidget {
//   final bool isLoading;
//   final String label;
//   final VoidCallback onPressed;

//   const _LoginButton({
//     Key? key,
//     required this.isLoading,
//     required this.label,
//     required this.onPressed,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 52,
//       child: DecoratedBox(
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFF3B5BDB), Color(0xFF5C7CFA)],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xFF3B5BDB).withValues(alpha: 0.35),
//               blurRadius: 14,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: ElevatedButton(
//           onPressed: isLoading ? null : onPressed,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent,
//             shadowColor: Colors.transparent,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//           ),
//           child: isLoading
//               ? const SizedBox(
//                   width: 22,
//                   height: 22,
//                   child: CircularProgressIndicator(
//                       color: Colors.white, strokeWidth: 2.5),
//                 )
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(label,
//                         style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white,
//                             letterSpacing: 0.3)),
//                     const SizedBox(width: 8),
//                     const Icon(Icons.arrow_forward_rounded,
//                         color: Colors.white, size: 18),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }

// // ── Bouton Social ──────────────────────────────────────────────────────────────

// class _SocialButton extends StatelessWidget {
//   final String label;
//   final Widget icon;
//   final VoidCallback onPressed;

//   const _SocialButton({
//     Key? key,
//     required this.label,
//     required this.icon,
//     required this.onPressed,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton(
//       onPressed: onPressed,
//       style: OutlinedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         side:
//             BorderSide(color: Colors.white.withValues(alpha: 0.30), width: 1.5),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         backgroundColor: Colors.white.withValues(alpha: 0.10),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           icon,
//           const SizedBox(width: 8),
//           Text(label,
//               style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white)),
//         ],
//       ),
//     );
//   }
// }

// // ── Icône Google dessinée ──────────────────────────────────────────────────────

// class _GoogleIconPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final cx = size.width / 2;
//     final cy = size.height / 2;
//     final r = size.width / 2;

//     // Cercle de fond
//     final bgPaint = Paint()..color = Colors.white;
//     canvas.drawCircle(Offset(cx, cy), r, bgPaint);

//     // Lettre "G" simplifiée via arcs colorés
//     final colors = [
//       const Color(0xFF4285F4),
//       const Color(0xFF34A853),
//       const Color(0xFFFBBC05),
//       const Color(0xFFEA4335),
//     ];
//     const sweepAngles = [1.57, 1.57, 0.78, 0.78];
//     double startAngle = -0.39;

//     for (int i = 0; i < 4; i++) {
//       final p = Paint()
//         ..color = colors[i]
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = size.width * 0.22
//         ..strokeCap = StrokeCap.butt;
//       canvas.drawArc(
//         Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.58),
//         startAngle,
//         sweepAngles[i],
//         false,
//         p,
//       );
//       startAngle += sweepAngles[i];
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/data/models/permis_category.dart';
import 'package:code_route_flutter/screens/auth/register_screen.dart';
import 'package:code_route_flutter/screens/home/main_navigation.dart';
import 'package:code_route_flutter/core/providers/localization_provider.dart';
import 'package:code_route_flutter/services/firebase/auth_service.dart';
import 'package:code_route_flutter/services/firebase/firestore_service.dart';
import 'package:code_route_flutter/data/test_questions.dart';
import 'package:code_route_flutter/screens/auth/welcome_celebration_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isFromDemo;
  const LoginScreen({Key? key, this.isFromDemo = false}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final List<PermisCategory> _categories = PermisCategory.getAllCategories();
  String _selectedCategoryCode = 'B';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCat = prefs.getString('selected_permis_category');
    if (savedCat != null && _categories.any((c) => c.code == savedCat)) {
      setState(() => _selectedCategoryCode = savedCat);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnack('Veuillez remplir tous les champs.', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    final result = await _authService.signIn(
        _emailController.text, _passwordController.text);
    if (result != null) {
      await _persistAuthenticatedUser(result,
          fallbackEmail: _emailController.text);
      if (mounted) _navigateAfterLogin();
    } else {
      if (mounted) _showSnack('Identifiants incorrects.', isError: true);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null) {
        await _persistAuthenticatedUser(result);
        if (mounted) _navigateAfterLogin();
      }
    } catch (e) {
      if (mounted) _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleLogin() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithApple();
      if (result != null) {
        await _persistAuthenticatedUser(result);
        if (mounted) _navigateAfterLogin();
      }
    } catch (e) {
      if (mounted) _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateAfterLogin() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (c, a, b) => widget.isFromDemo
          ? const WelcomeCelebrationScreen()
          : const MainNavigation(),
      transitionsBuilder: (c, a, b, child) =>
          FadeTransition(opacity: a, child: child),
    ));
  }

  Future<void> _persistAuthenticatedUser(
    UserCredential result, {
    String? fallbackEmail,
  }) async {
    final user = result.user;
    if (user == null) return;
    final displayName = (user.displayName ?? '').trim().isNotEmpty
        ? user.displayName!
        : _emailController.text.split('@').first;
    final email = user.email ?? fallbackEmail ?? '';
    if (result.additionalUserInfo?.isNewUser == true) {
      await _firestoreService.createUserProfile(user.uid, {
        'name': displayName,
        'email': email,
        'xp': 0,
        'level': 1,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isGuest', false);
    await prefs.setString('selected_permis_category', _selectedCategoryCode);
    await prefs.setString('userEmail', email);
    await prefs.setString('user_email', email);
    await prefs.setString('userName', displayName);
    await prefs.setString('user_name', displayName);
  }

  Future<void> _seedDatabase() async {
    setState(() => _isLoading = true);
    try {
      final questions = getTestQuestions();
      await _firestoreService.seedQuestions(questions);
      if (mounted) _showSnack('Base de données initialisée.');
    } catch (e) {
      if (mounted) _showSnack('Erreur : $e', isError: true);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Fond dégradé subtil en haut
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.35,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 480 : double.infinity,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 24,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── En-tête ──────────────────────────────────
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 8),
                          _buildLanguagePill(),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Logo + titre
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.directions_car_rounded,
                                color: Color(0xFF1E40AF),
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Bon retour !',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Connectez-vous pour continuer',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.80),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Carte formulaire ─────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Catégorie permis
                            _label('Catégorie de permis'),
                            const SizedBox(height: 8),
                            _buildCategoryDropdown(),
                            const SizedBox(height: 20),

                            // Email
                            _label('Adresse email'),
                            const SizedBox(height: 8),
                            _buildField(
                              controller: _emailController,
                              hint: 'votre@email.com',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),

                            // Mot de passe
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _label('Mot de passe'),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Mot de passe oublié ?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildField(
                              controller: _passwordController,
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                            ),
                            const SizedBox(height: 28),

                            // Bouton connexion
                            _buildLoginButton(),
                            const SizedBox(height: 20),

                            // Séparateur
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        color: const Color(0xFFE2E8F0),
                                        thickness: 1)),
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'ou continuer avec',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Divider(
                                        color: const Color(0xFFE2E8F0),
                                        thickness: 1)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Boutons sociaux
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSocialButton(
                                    label: 'Google',
                                    icon: const Icon(Icons.g_mobiledata_rounded,
                                        size: 22,
                                        color: Color(0xFF4285F4)),
                                    onPressed: _handleGoogleLogin,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSocialButton(
                                    label: 'Apple',
                                    icon: const Icon(Icons.apple_rounded,
                                        size: 20,
                                        color: Color(0xFF1C1C1E)),
                                    onPressed: _handleAppleLogin,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Lien inscription ─────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Pas encore de compte ? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (c, a, b) =>
                                    const RegisterScreen(),
                                transitionsBuilder: (c, a, b, child) =>
                                    FadeTransition(opacity: a, child: child),
                              ),
                            ),
                            child: const Text(
                              "S'inscrire",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Mode invité ──────────────────────────────
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Connexion requise pour accéder à l\'application.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.remove_red_eye_outlined,
                            size: 18),
                        label: const Text('Continuer en tant qu\'invité'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Bouton admin secret
                      Center(
                        child: TextButton(
                          onPressed: _isLoading ? null : _seedDatabase,
                          child: const Text(
                            'INIT_DATABASE_CLOUD',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 9,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF1E293B),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E40AF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Se connecter',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: _isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF374151),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: const Color(0xFFF8FAFC),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)), // ← corrigé
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategoryCode,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF94A3B8)),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (v) {
            if (v != null) setState(() => _selectedCategoryCode = v);
          },
          items: _categories.map((c) {
            return DropdownMenuItem<String>(
              value: c.code,
              child: Row(
                children: [
                  Icon(c.icon, color: const Color(0xFF3B82F6), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${c.name} — ${c.description}',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLanguagePill() {
    final loc = Provider.of<LocalizationProvider>(context);
    final isEn = loc.locale == 'en';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.40), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: isEn ? 'en' : 'fr',
          icon: const SizedBox.shrink(),
          alignment: Alignment.center,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (v) {
            if (v != null) loc.setLocale(v);
          },
          items: const [
            DropdownMenuItem(
              value: 'fr',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text('🇫🇷 FR'),
              ),
            ),
            DropdownMenuItem(
              value: 'en',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text('🇬🇧 EN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}