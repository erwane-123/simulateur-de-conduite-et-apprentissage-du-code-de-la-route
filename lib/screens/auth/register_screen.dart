// import 'package:code_route_flutter/core/constants/app_colors.dart';
// import 'package:code_route_flutter/screens/home/main_navigation.dart';
// import 'package:code_route_flutter/services/firebase/auth_service.dart';
// import 'package:code_route_flutter/services/firebase/firestore_service.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({Key? key}) : super(key: key);

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _authService = AuthService();
//   final _firestoreService = FirestoreService();

//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _register() async {
//     if (_nameController.text.isEmpty ||
//         _emailController.text.isEmpty ||
//         _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Veuillez remplir tous les champs')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final result = await _authService.register(
//         _emailController.text,
//         _passwordController.text,
//       );

//       if (result != null && result.user != null) {
//         await _firestoreService.createUserProfile(result.user!.uid, {
//           'name': _nameController.text,
//           'email': _emailController.text,
//           'xp': 0,
//           'level': 1,
//           'createdAt': DateTime.now().toIso8601String(),
//         });

//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('isLoggedIn', true);
//         await prefs.setBool('isGuest', false);
//         await prefs.setString('userName', _nameController.text);
//         await prefs.setString('user_name', _nameController.text);
//         await prefs.setString('userEmail', _emailController.text);
//         await prefs.setString('user_email', _emailController.text);

//         if (mounted) {
//           Navigator.of(context).pushReplacement(
//             PageRouteBuilder(
//               pageBuilder: (_, __, ___) => const MainNavigation(),
//               transitionsBuilder: (_, animation, __, child) {
//                 return FadeTransition(opacity: animation, child: child);
//               },
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(e.toString()), backgroundColor: AppColors.error),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDark,
//       body: Container(
//         decoration:
//             const BoxDecoration(gradient: AppColors.appBackgroundGradient),
//         child: SafeArea(
//           child: CustomScrollView(
//             physics: const BouncingScrollPhysics(),
//             slivers: [
//               SliverToBoxAdapter(child: _buildHeader(context)),
//               SliverPadding(
//                 padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
//                 sliver: SliverToBoxAdapter(
//                   child: Container(
//                     padding: const EdgeInsets.all(18),
//                     decoration: BoxDecoration(
//                       color: AppColors.cardBackground.withValues(alpha: 0.84),
//                       borderRadius: BorderRadius.circular(24),
//                       border: Border.all(
//                           color: Colors.white.withValues(alpha: 0.08)),
//                     ),
//                     child: Column(
//                       children: [
//                         TextField(
//                           controller: _nameController,
//                           textInputAction: TextInputAction.next,
//                           decoration: const InputDecoration(
//                             hintText: 'Nom complet',
//                             prefixIcon: Icon(Icons.person_outline_rounded),
//                           ),
//                         ),
//                         const SizedBox(height: 14),
//                         TextField(
//                           controller: _emailController,
//                           keyboardType: TextInputType.emailAddress,
//                           textInputAction: TextInputAction.next,
//                           decoration: const InputDecoration(
//                             hintText: 'Email',
//                             prefixIcon: Icon(Icons.email_outlined),
//                           ),
//                         ),
//                         const SizedBox(height: 14),
//                         TextField(
//                           controller: _passwordController,
//                           obscureText: _obscurePassword,
//                           decoration: InputDecoration(
//                             hintText: 'Mot de passe',
//                             prefixIcon: const Icon(Icons.lock_outline_rounded),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _obscurePassword
//                                     ? Icons.visibility_outlined
//                                     : Icons.visibility_off_outlined,
//                               ),
//                               onPressed: () {
//                                 setState(
//                                     () => _obscurePassword = !_obscurePassword);
//                               },
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 54,
//                           child: ElevatedButton.icon(
//                             onPressed: _isLoading ? null : _register,
//                             icon: _isLoading
//                                 ? const SizedBox(
//                                     width: 18,
//                                     height: 18,
//                                     child: CircularProgressIndicator(
//                                       color: Colors.white,
//                                       strokeWidth: 2,
//                                     ),
//                                   )
//                                 : const Icon(Icons.person_add_alt_rounded),
//                             label: Text(_isLoading
//                                 ? 'Creation...'
//                                 : 'Creer mon compte'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom: 24),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'Deja un compte ? ',
//                         style: TextStyle(color: AppColors.textSecondary),
//                       ),
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text('Se connecter'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(18, 18, 18, 18),
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(28),
//         gradient: const LinearGradient(
//           colors: [Color(0xFF12356F), Color(0xFF0F766E), Color(0xFF111827)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               IconButton.filledTonal(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.arrow_back_rounded),
//               ),
//               const Spacer(),
//               const Icon(Icons.directions_car_rounded,
//                   color: Colors.white, size: 32),
//             ],
//           ),
//           const SizedBox(height: 26),
//           const Text(
//             'Creer un compte',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 31,
//               fontWeight: FontWeight.w900,
//               height: 1.05,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Sauvegarde ta progression, tes revisions et tes statistiques de conduite.',
//             style: TextStyle(
//               color: Colors.white.withValues(alpha: 0.78),
//               fontSize: 14,
//               height: 1.45,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:code_route_flutter/screens/home/main_navigation.dart';
// import 'package:code_route_flutter/services/firebase/auth_service.dart';
// import 'package:code_route_flutter/services/firebase/firestore_service.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({Key? key}) : super(key: key);

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   final _authService = AuthService();
//   final _firestoreService = FirestoreService();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _register() async {
//     if (_nameController.text.isEmpty ||
//         _emailController.text.isEmpty ||
//         _passwordController.text.isEmpty) {
//       _showSnack('Veuillez remplir tous les champs.', isError: true);
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final result = await _authService.register(
//           _emailController.text, _passwordController.text);

//       if (result != null && result.user != null) {
//         await _firestoreService.createUserProfile(result.user!.uid, {
//           'name': _nameController.text,
//           'email': _emailController.text,
//           'xp': 0,
//           'level': 1,
//           'createdAt': DateTime.now().toIso8601String(),
//         });

//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('isLoggedIn', true);
//         await prefs.setBool('isGuest', false);
//         await prefs.setString('userName', _nameController.text);
//         await prefs.setString('user_name', _nameController.text);
//         await prefs.setString('userEmail', _emailController.text);
//         await prefs.setString('user_email', _emailController.text);

//         if (mounted) {
//           Navigator.of(context).pushReplacement(PageRouteBuilder(
//             pageBuilder: (c, a, b) => const MainNavigation(),
//             transitionsBuilder: (c, a, b, child) =>
//                 FadeTransition(opacity: a, child: child),
//           ));
//         }
//       }
//     } catch (e) {
//       if (mounted) _showSnack(e.toString(), isError: true);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showSnack(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(message),
//       backgroundColor:
//           isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.all(16),
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       body: Stack(
//         children: [
//           // Bandeau bleu en haut
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             height: size.height * 0.32,
//             child: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
//                 ),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(40),
//                   bottomRight: Radius.circular(40),
//                 ),
//               ),
//             ),
//           ),

//           SafeArea(
//             child: Center(
//               child: ConstrainedBox(
//                 constraints:
//                     BoxConstraints(maxWidth: isTablet ? 480 : double.infinity),
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isTablet ? 32 : 24,
//                     vertical: 24,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // ── Bouton retour ────────────────────────────
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: GestureDetector(
//                           onTap: () => Navigator.pop(context),
//                           child: Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withValues(alpha: 0.20),
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: Colors.white.withValues(alpha: 0.40),
//                               ),
//                             ),
//                             child: const Icon(
//                               Icons.arrow_back_rounded,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       // ── Logo + titre ─────────────────────────────
//                       Center(
//                         child: Column(
//                           children: [
//                             Container(
//                               width: 72,
//                               height: 72,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color:
//                                         Colors.black.withValues(alpha: 0.12),
//                                     blurRadius: 20,
//                                     offset: const Offset(0, 8),
//                                   ),
//                                 ],
//                               ),
//                               child: const Icon(
//                                 Icons.person_add_rounded,
//                                 color: Color(0xFF1E40AF),
//                                 size: 34,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             const Text(
//                               'Créer un compte',
//                               style: TextStyle(
//                                 fontSize: 26,
//                                 fontWeight: FontWeight.w800,
//                                 color: Colors.white,
//                                 letterSpacing: -0.5,
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               'Commencez votre apprentissage',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.white.withValues(alpha: 0.80),
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 32),

//                       // ── Carte formulaire ─────────────────────────
//                       Container(
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(28),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withValues(alpha: 0.08),
//                               blurRadius: 30,
//                               offset: const Offset(0, 10),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             // Nom complet
//                             _label('Nom complet'),
//                             const SizedBox(height: 8),
//                             _buildField(
//                               controller: _nameController,
//                               hint: 'Jean Dupont',
//                               icon: Icons.person_outline_rounded,
//                             ),
//                             const SizedBox(height: 20),

//                             // Email
//                             _label('Adresse email'),
//                             const SizedBox(height: 8),
//                             _buildField(
//                               controller: _emailController,
//                               hint: 'votre@email.com',
//                               icon: Icons.mail_outline_rounded,
//                               keyboardType: TextInputType.emailAddress,
//                             ),
//                             const SizedBox(height: 20),

//                             // Mot de passe
//                             _label('Mot de passe'),
//                             const SizedBox(height: 8),
//                             _buildField(
//                               controller: _passwordController,
//                               hint: '••••••••',
//                               icon: Icons.lock_outline_rounded,
//                               isPassword: true,
//                             ),

//                             const SizedBox(height: 8),
//                             const Text(
//                               'Minimum 6 caractères.',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Color(0xFF94A3B8),
//                               ),
//                             ),

//                             const SizedBox(height: 28),

//                             // Bouton inscription
//                             SizedBox(
//                               height: 52,
//                               child: ElevatedButton(
//                                 onPressed: _isLoading ? null : _register,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF1E40AF),
//                                   foregroundColor: Colors.white,
//                                   elevation: 0,
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(14)),
//                                 ),
//                                 child: _isLoading
//                                     ? const SizedBox(
//                                         width: 22,
//                                         height: 22,
//                                         child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2.5),
//                                       )
//                                     : const Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             'Créer mon compte',
//                                             style: TextStyle(
//                                               fontSize: 15,
//                                               fontWeight: FontWeight.w700,
//                                               letterSpacing: 0.3,
//                                             ),
//                                           ),
//                                           SizedBox(width: 8),
//                                           Icon(Icons.arrow_forward_rounded,
//                                               size: 18),
//                                         ],
//                                       ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       // ── Lien connexion ───────────────────────────
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'Déjà un compte ? ',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Color(0xFF64748B),
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () => Navigator.pop(context),
//                             child: const Text(
//                               'Se connecter',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w700,
//                                 color: Color(0xFF1E40AF),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 32),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _label(String text) => Text(
//         text,
//         style: const TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: Color(0xFF374151),
//         ),
//       );

//   Widget _buildField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     bool isPassword = false,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword ? _obscurePassword : false,
//       keyboardType: keyboardType,
//       style: const TextStyle(
//         fontSize: 14,
//         color: Color(0xFF1E293B),
//         fontWeight: FontWeight.w500,
//       ),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
//         prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
//         suffixIcon: isPassword
//             ? IconButton(
//                 icon: Icon(
//                   _obscurePassword
//                       ? Icons.visibility_outlined
//                       : Icons.visibility_off_outlined,
//                   color: const Color(0xFF94A3B8),
//                   size: 20,
//                 ),
//                 onPressed: () =>
//                     setState(() => _obscurePassword = !_obscurePassword),
//               )
//             : null,
//         filled: true,
//         fillColor: const Color(0xFFF8FAFC),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code_route_flutter/screens/home/main_navigation.dart';
import 'package:code_route_flutter/services/firebase/auth_service.dart';
import 'package:code_route_flutter/services/firebase/firestore_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptTerms = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  // Validation states
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'Veuillez entrer votre nom'
          : null;
      _emailError = !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
              .hasMatch(_emailController.text.trim())
          ? 'Adresse email invalide'
          : null;
      _passwordError = _passwordController.text.length < 6
          ? 'Minimum 6 caractères'
          : null;
    });
    if (_nameError != null || _emailError != null || _passwordError != null) {
      valid = false;
    }
    return valid;
  }

  Future<void> _register() async {
    if (!_validate()) return;
    if (!_acceptTerms) {
      _showSnack('Veuillez accepter les conditions d\'utilisation.',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _authService.register(
          _emailController.text.trim(), _passwordController.text);

      if (result != null && result.user != null) {
        await _firestoreService.createUserProfile(result.user!.uid, {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'xp': 0,
          'level': 1,
          'createdAt': DateTime.now().toIso8601String(),
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('isGuest', false);
        await prefs.setString('userName', _nameController.text.trim());
        await prefs.setString('user_name', _nameController.text.trim());
        await prefs.setString('userEmail', _emailController.text.trim());
        await prefs.setString('user_email', _emailController.text.trim());

        if (mounted) {
          Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (c, a, b) => const MainNavigation(),
            transitionsBuilder: (c, a, b, child) =>
                FadeTransition(opacity: a, child: child),
          ));
        }
      }
    } catch (e) {
      if (mounted) _showSnack(_parseError(e.toString()), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseError(String raw) {
    if (raw.contains('email-already-in-use')) {
      return 'Cette adresse email est déjà utilisée.';
    }
    if (raw.contains('weak-password')) return 'Mot de passe trop faible.';
    if (raw.contains('network-request-failed')) return 'Pas de connexion réseau.';
    return 'Une erreur est survenue. Réessayez.';
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
        ],
      ),
      backgroundColor:
          isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
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
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // ── Bandeau haut ──────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.30,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: isTablet ? 480 : double.infinity),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32 : 22,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Retour ──────────────────────────
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _BackButton(
                                onTap: () => Navigator.pop(context)),
                          ),

                          const SizedBox(height: 18),

                          // ── En-tête ──────────────────────────
                          _buildHeader(),

                          const SizedBox(height: 28),

                          // ── Formulaire ───────────────────────
                          _buildForm(),

                          const SizedBox(height: 20),

                          // ── Lien connexion ───────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Déjà un compte ? ',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B)),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  'Se connecter',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E40AF),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Avatar
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E40AF).withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: Color(0xFF1E40AF),
            size: 32,
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'Créer un compte',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rejoignez des milliers d\'apprenants',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.75),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nom
          _FieldLabel(text: 'Nom complet'),
          const SizedBox(height: 6),
          _InputField(
            controller: _nameController,
            focusNode: _nameFocus,
            nextFocus: _emailFocus,
            hint: 'Jean Dupont',
            icon: Icons.person_outline_rounded,
            error: _nameError,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),

          const SizedBox(height: 18),

          // Email
          _FieldLabel(text: 'Adresse email'),
          const SizedBox(height: 6),
          _InputField(
            controller: _emailController,
            focusNode: _emailFocus,
            nextFocus: _passwordFocus,
            hint: 'votre@email.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            error: _emailError,
            onChanged: (_) {
              if (_emailError != null) setState(() => _emailError = null);
            },
          ),

          const SizedBox(height: 18),

          // Mot de passe
          _FieldLabel(text: 'Mot de passe'),
          const SizedBox(height: 6),
          _InputField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            obscure: _obscurePassword,
            onToggleObscure: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            error: _passwordError,
            onChanged: (_) {
              if (_passwordError != null) setState(() => _passwordError = null);
            },
          ),

          // Indicateur force mot de passe
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _PasswordStrengthBar(password: _passwordController.text),
          ],

          const SizedBox(height: 20),

          // Conditions
          GestureDetector(
            onTap: () => setState(() => _acceptTerms = !_acceptTerms),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _acceptTerms
                        ? const Color(0xFF1E40AF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _acceptTerms
                          ? const Color(0xFF1E40AF)
                          : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: _acceptTerms
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 13)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.5),
                      children: [
                        TextSpan(text: 'J\'accepte les '),
                        TextSpan(
                          text: 'conditions d\'utilisation',
                          style: TextStyle(
                            color: Color(0xFF1E40AF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' et la '),
                        TextSpan(
                          text: 'politique de confidentialité',
                          style: TextStyle(
                            color: Color(0xFF1E40AF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bouton
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E40AF),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF1E40AF).withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Row(
                        key: ValueKey('label'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Créer mon compte',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bouton retour ────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: const Icon(Icons.arrow_back_rounded,
            color: Colors.white, size: 18),
      ),
    );
  }
}

// ── Label de champ ───────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }
}

// ── Champ de saisie ──────────────────────────────────────────────────────────

class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final String? error;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.error,
    this.onChanged,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null;
    final borderColor = hasError
        ? const Color(0xFFEF4444)
        : _isFocused
            ? const Color(0xFF2563EB)
            : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isFocused
                ? Colors.white
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: borderColor,
                width: _isFocused || hasError ? 1.5 : 1),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: widget.isPassword ? widget.obscure : false,
            keyboardType: widget.keyboardType,
            textInputAction: widget.nextFocus != null
                ? TextInputAction.next
                : TextInputAction.done,
            onSubmitted: (_) {
              if (widget.nextFocus != null) {
                FocusScope.of(context).requestFocus(widget.nextFocus);
              }
            },
            onChanged: widget.onChanged,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                  color: Color(0xFFCBD5E1), fontSize: 14),
              prefixIcon: Icon(
                widget.icon,
                color: _isFocused
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFCBD5E1),
                size: 19,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        widget.obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFFCBD5E1),
                        size: 19,
                      ),
                      onPressed: widget.onToggleObscure,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFFEF4444), size: 13),
              const SizedBox(width: 4),
              Text(
                widget.error!,
                style: const TextStyle(
                    color: Color(0xFFEF4444), fontSize: 11),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Barre de force du mot de passe ───────────────────────────────────────────

class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});

  int get _strength {
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%^&*]'))) score++;
    return score;
  }

  Color get _color {
    if (_strength <= 1) return const Color(0xFFEF4444);
    if (_strength <= 3) return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  String get _label {
    if (_strength <= 1) return 'Faible';
    if (_strength <= 3) return 'Moyen';
    return 'Fort';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _strength / 5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(_color),
              minHeight: 3,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _label,
          style: TextStyle(
              fontSize: 11,
              color: _color,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}