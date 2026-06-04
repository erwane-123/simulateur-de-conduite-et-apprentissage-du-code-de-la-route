// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:code_route_flutter/core/constants/app_colors.dart';
// import 'package:code_route_flutter/screens/candidat/registration_pdf_generator.dart';
// import 'package:code_route_flutter/services/firebase/firestore_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class CandidatScreen extends StatefulWidget {
//   const CandidatScreen({Key? key}) : super(key: key);

//   @override
//   State<CandidatScreen> createState() => _CandidatScreenState();
// }

// class _CandidatScreenState extends State<CandidatScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _firestoreService = FirestoreService();

//   // Contrôleurs
//   final TextEditingController _nomCtrl = TextEditingController();
//   final TextEditingController _prenomCtrl = TextEditingController();
//   final TextEditingController _telCtrl = TextEditingController();
//   final TextEditingController _emailCtrl = TextEditingController();
//   final TextEditingController _cniCtrl = TextEditingController();
//   final TextEditingController _dateNaissCtrl = TextEditingController();
//   final TextEditingController _lieuNaissCtrl = TextEditingController();
//   final TextEditingController _nationaliteCtrl = TextEditingController();
//   String _categoriePermis = 'B';

//   // Pièces stockées
//   Uint8List? _cniBytes;
//   Uint8List? _photoBytes;
//   Uint8List? _certificatBytes;

//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _nomCtrl.text = prefs.getString('candidat_nom') ?? '';
//       _prenomCtrl.text = prefs.getString('candidat_prenom') ?? '';
//       _telCtrl.text = prefs.getString('candidat_tel') ?? '';
//       _emailCtrl.text = prefs.getString('candidat_email') ?? '';
//       _cniCtrl.text = prefs.getString('candidat_cni') ?? '';
//       _dateNaissCtrl.text = prefs.getString('candidat_date_naiss') ?? '';
//       _lieuNaissCtrl.text = prefs.getString('candidat_lieu_naiss') ?? '';
//       _nationaliteCtrl.text =
//           prefs.getString('candidat_nationalite') ?? 'Camerounaise';
//       _categoriePermis = prefs.getString('candidat_permis') ?? 'B';
//       _isLoading = false;
//     });
//   }

//   Future<void> _saveDataLocally() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('candidat_nom', _nomCtrl.text);
//     await prefs.setString('candidat_prenom', _prenomCtrl.text);
//     await prefs.setString('candidat_tel', _telCtrl.text);
//     await prefs.setString('candidat_email', _emailCtrl.text);
//     await prefs.setString('candidat_cni', _cniCtrl.text);
//     await prefs.setString('candidat_date_naiss', _dateNaissCtrl.text);
//     await prefs.setString('candidat_lieu_naiss', _lieuNaissCtrl.text);
//     await prefs.setString('candidat_nationalite', _nationaliteCtrl.text);
//     await prefs.setString('candidat_permis', _categoriePermis);
//   }

//   Future<void> _saveDataToFirebase() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     await _firestoreService.saveCandidateProfile(
//       uid: user.uid,
//       profile: {
//         'nom': _nomCtrl.text.trim(),
//         'prenom': _prenomCtrl.text.trim(),
//         'telephone': _telCtrl.text.trim(),
//         'email': _emailCtrl.text.trim(),
//         'cni': _cniCtrl.text.trim(),
//         'dateNaissance': _dateNaissCtrl.text.trim(),
//         'lieuNaissance': _lieuNaissCtrl.text.trim(),
//         'nationalite': _nationaliteCtrl.text.trim(),
//         'categoriePermis': _categoriePermis,
//         'documents': {
//           'cni': _cniBytes != null,
//           'photo': _photoBytes != null,
//           'certificatMedical': _certificatBytes != null,
//         },
//       },
//     );
//   }

//   Future<void> _pickImage(String type) async {
//     final ImagePicker picker = ImagePicker();
//     try {
//       final XFile? image = await picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 70,
//         maxWidth: 1024,
//       );

//       if (image != null) {
//         final bytes = await image.readAsBytes();
//         setState(() {
//           if (type == 'cni') {
//             _cniBytes = bytes;
//           } else if (type == 'photo') {
//             _photoBytes = bytes;
//           } else if (type == 'certificat') {
//             _certificatBytes = bytes;
//           }
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   Future<void> _generatePdf() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     await _saveDataLocally();
//     try {
//       await _saveDataToFirebase();
//     } catch (_) {
//       // Le PDF reste generable meme si la synchronisation cloud echoue.
//     }

//     if (!mounted) return;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const AlertDialog(
//         backgroundColor: Color(0xFF0F172A),
//         content: Row(
//           children: [
//             CircularProgressIndicator(color: Color(0xFF00E5FF)),
//             SizedBox(width: 16),
//             Expanded(
//                 child: Text("Génération du document...",
//                     style: TextStyle(color: Colors.white))),
//           ],
//         ),
//       ),
//     );

//     try {
//       await RegistrationPdfGenerator.generateAndPrintPdf(
//         nom: _nomCtrl.text,
//         prenom: _prenomCtrl.text,
//         tel: _telCtrl.text,
//         email: _emailCtrl.text,
//         cni: _cniCtrl.text,
//         dateNaiss: _dateNaissCtrl.text,
//         lieuNaiss: _lieuNaissCtrl.text,
//         nationalite: _nationaliteCtrl.text,
//         categorie: _categoriePermis,
//         cniBytes: _cniBytes,
//         photoBytes: _photoBytes,
//         certificatBytes: _certificatBytes,
//       );
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) {
//         Navigator.pop(context);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: AppColors.backgroundDark,
//         body: Center(
//             child: CircularProgressIndicator(color: AppColors.accentCyan)),
//       );
//     }

//     return Scaffold(
//       backgroundColor: AppColors.backgroundDark,
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/candidat_bg.jpg',
//               fit: BoxFit.cover,
//               color: Colors.black.withValues(alpha: 0.68),
//               colorBlendMode: BlendMode.darken,
//             ),
//           ),
//           Positioned.fill(
//             child: DecoratedBox(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppColors.backgroundDeep.withValues(alpha: 0.86),
//                     AppColors.backgroundDark.withValues(alpha: 0.74),
//                     AppColors.surface.withValues(alpha: 0.92),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//             ),
//           ),

//           // Main Content
//           SafeArea(
//             child: Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//               child: LayoutBuilder(builder: (context, constraints) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildHeader(),
//                     const SizedBox(height: 15),
//                     Expanded(
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildSectionTitle(
//                                 Icons.person_outline, 'IDENTITÉ DU CANDIDAT'),
//                             const SizedBox(height: 10),
//                             _buildGlassPanel(
//                               child: Column(
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                           child: _buildTextField(
//                                               'NOM DE NAISSANCE',
//                                               _nomCtrl,
//                                               'NOM')),
//                                       const SizedBox(width: 15),
//                                       Expanded(
//                                           child: _buildTextField(
//                                               'PRÉNOM', _prenomCtrl, 'PRÉNOM')),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                           child: _buildTextField(
//                                               'DATE DE NAISSANCE',
//                                               _dateNaissCtrl,
//                                               'jj/mm/aaaa',
//                                               icon: Icons
//                                                   .calendar_today_outlined)),
//                                       const SizedBox(width: 15),
//                                       Expanded(
//                                           child: _buildTextField(
//                                               'LIEU DE NAISSANCE',
//                                               _lieuNaissCtrl,
//                                               'Ville')),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                           child: _buildTextField(
//                                               'NATIONALITÉ',
//                                               _nationaliteCtrl,
//                                               'Camerounaise')),
//                                       const SizedBox(width: 15),
//                                       Expanded(
//                                           child: _buildDropdownField(
//                                               'CATÉGORIE PERMIS')),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                           child: _buildTextField('EMAIL',
//                                               _emailCtrl, 'votre@email.com')),
//                                       const SizedBox(width: 15),
//                                       Expanded(
//                                           child: _buildTextField('TÉLÉPHONE',
//                                               _telCtrl, '+237 ...')),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 15),
//                             _buildSectionTitle(
//                                 Icons.folder_open, 'PIÈCES JUSTIFICATIVES'),
//                             const SizedBox(height: 10),
//                             Expanded(
//                               child: _buildGlassPanel(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 15, vertical: 10),
//                                 child: Column(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     _buildFileSlot(
//                                         'Pièce d\'Identité (CNI)',
//                                         'VÉRIFICATION D\'IDENTITÉ',
//                                         _cniBytes != null,
//                                         () => _pickImage('cni')),
//                                     _buildFileSlot(
//                                         'Photo Récente',
//                                         'PORTRAIT CANDIDAT',
//                                         _photoBytes != null,
//                                         () => _pickImage('photo')),
//                                     _buildFileSlot(
//                                         'Certificat Médical',
//                                         'OPTIONNEL',
//                                         _certificatBytes != null,
//                                         () => _pickImage('certificat')),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             _buildValidateButton(),
//                             const SizedBox(height: 10),
//                             const Center(
//                               child: Text(
//                                 'La validation prepare votre dossier officiel.',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     color: AppColors.textSecondary,
//                                     fontSize: 9,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 0.5),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }),
//             ),
//           ),

//           // Decoration: Top line
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: 2,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.transparent,
//                     Color(0xFF00E5FF),
//                     Colors.transparent
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Decoration: Top dot
//           Positioned(
//             top: 40,
//             left: 10,
//             child: Container(
//               width: 8,
//               height: 8,
//               decoration: const BoxDecoration(
//                 color: Color(0xFF00E5FF),
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                       color: Color(0xFF00E5FF), blurRadius: 10, spreadRadius: 2)
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             top: 40,
//             left: 13,
//             child: Container(
//               width: 2,
//               height: 100,
//               color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 20),
//         const Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               'DOSSIER D\'INSCRIPTION ',
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.w900,
//                   letterSpacing: -1),
//             ),
//             Text(
//               'OFFICIEL',
//               style: TextStyle(
//                   color: Color(0xFF00E5FF),
//                   fontSize: 24,
//                   fontWeight: FontWeight.w900,
//                   letterSpacing: -1),
//             ),
//           ],
//         ),
//         const SizedBox(height: 5),
//         Text(
//           'SYSTEM_STATUS: READY // VERIFICATION_REQUIRED',
//           style: TextStyle(
//               color: Colors.white.withValues(alpha: 0.5),
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionTitle(IconData icon, String title) {
//     return Row(
//       children: [
//         Icon(icon, color: const Color(0xFF00E5FF), size: 18),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: const TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.w800,
//               letterSpacing: 1),
//         ),
//       ],
//     );
//   }

//   Widget _buildGlassPanel(
//       {required Widget child, EdgeInsets padding = const EdgeInsets.all(15)}) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: padding,
//           decoration: BoxDecoration(
//             color: Colors.white.withValues(alpha: 0.05),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//                 color: Colors.white.withValues(alpha: 0.1), width: 1),
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//       String label, TextEditingController controller, String hint,
//       {IconData? icon}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//               color: Colors.white.withValues(alpha: 0.6),
//               fontSize: 9,
//               fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 6),
//         Container(
//           height: 45,
//           decoration: BoxDecoration(
//             color: Colors.black.withValues(alpha: 0.3),
//             borderRadius: BorderRadius.circular(6),
//             border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   style: const TextStyle(color: Colors.white, fontSize: 13),
//                   decoration: InputDecoration(
//                     hintText: hint,
//                     hintStyle: TextStyle(
//                         color: Colors.white.withValues(alpha: 0.2),
//                         fontSize: 13),
//                     border: InputBorder.none,
//                     isDense: true,
//                   ),
//                 ),
//               ),
//               if (icon != null)
//                 Icon(icon,
//                     color: Colors.white.withValues(alpha: 0.4), size: 16),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdownField(String label) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//               color: Colors.white.withValues(alpha: 0.6),
//               fontSize: 9,
//               fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 6),
//         Container(
//           height: 45,
//           decoration: BoxDecoration(
//             color: Colors.black.withValues(alpha: 0.3),
//             borderRadius: BorderRadius.circular(6),
//             border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: _categoriePermis,
//               dropdownColor: const Color(0xFF1E293B),
//               icon: const Icon(Icons.keyboard_arrow_down,
//                   color: Color(0xFF00E5FF), size: 18),
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600),
//               isExpanded: true,
//               onChanged: (val) => setState(() => _categoriePermis = val!),
//               items: ['A', 'B', 'C', 'D']
//                   .map((c) =>
//                       DropdownMenuItem(value: c, child: Text('CATEGORIE $c')))
//                   .toList(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFileSlot(
//       String title, String subtitle, bool isDone, VoidCallback onTap) {
//     return Container(
//       height: 60,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.03),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: 0.05),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Icon(
//               title.contains('Photo')
//                   ? Icons.person_outline
//                   : (title.contains('Médical')
//                       ? Icons.medical_services_outlined
//                       : Icons.badge_outlined),
//               color: Colors.white.withValues(alpha: 0.4),
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold)),
//                 Text(subtitle,
//                     style: TextStyle(
//                         color: Colors.white.withValues(alpha: 0.4),
//                         fontSize: 9,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           SizedBox(
//             height: 32,
//             child: ElevatedButton(
//               onPressed: onTap,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     isDone ? const Color(0xFF1E293B) : const Color(0xFF00E5FF),
//                 foregroundColor: isDone ? Colors.white70 : Colors.black,
//                 elevation: 0,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(4)),
//               ),
//               child: Row(
//                 children: [
//                   Text(isDone ? 'RE-UPLOAD' : 'JOIN',
//                       style: const TextStyle(
//                           fontSize: 10, fontWeight: FontWeight.w900)),
//                   const SizedBox(width: 6),
//                   Icon(isDone ? Icons.refresh : Icons.file_upload_outlined,
//                       size: 12),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildValidateButton() {
//     return Container(
//       width: double.infinity,
//       height: 60,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
//             blurRadius: 15,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         onPressed: _generatePdf,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           padding: EdgeInsets.zero,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//             side: const BorderSide(color: Color(0xFF00E5FF), width: 2),
//           ),
//         ).copyWith(
//           backgroundColor: WidgetStateProperty.resolveWith((states) {
//             if (states.contains(WidgetState.pressed)) {
//               return const Color(0xFF00E5FF).withValues(alpha: 0.2);
//             }
//             return const Color(0xFF0F172A).withValues(alpha: 0.8);
//           }),
//         ),
//         child: Ink(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(30),
//           ),
//           child: const Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.power_settings_new_rounded,
//                   color: Color(0xFF00E5FF), size: 24),
//               SizedBox(width: 12),
//               Text(
//                 'VALIDER LE DOSSIER',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w900,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/screens/candidat/registration_pdf_generator.dart';
import 'package:code_route_flutter/services/firebase/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CandidatScreen extends StatefulWidget {
  const CandidatScreen({Key? key}) : super(key: key);

  @override
  State<CandidatScreen> createState() => _CandidatScreenState();
}

class _CandidatScreenState extends State<CandidatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();
  final TextEditingController _telCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _cniCtrl = TextEditingController();
  final TextEditingController _lieuNaissCtrl = TextEditingController();
  final TextEditingController _nationaliteCtrl = TextEditingController();
  String _categoriePermis = 'B';

  // Date de naissance
  DateTime? _dateNaissance;

  Uint8List? _cniBytes;
  Uint8List? _photoBytes;
  Uint8List? _certificatBytes;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    _cniCtrl.dispose();
    _lieuNaissCtrl.dispose();
    _nationaliteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('candidat_date_naiss');
    setState(() {
      _nomCtrl.text = prefs.getString('candidat_nom') ?? '';
      _prenomCtrl.text = prefs.getString('candidat_prenom') ?? '';
      _telCtrl.text = prefs.getString('candidat_tel') ?? '';
      _emailCtrl.text = prefs.getString('candidat_email') ?? '';
      _cniCtrl.text = prefs.getString('candidat_cni') ?? '';
      _lieuNaissCtrl.text = prefs.getString('candidat_lieu_naiss') ?? '';
      _nationaliteCtrl.text =
          prefs.getString('candidat_nationalite') ?? 'Camerounaise';
      _categoriePermis = prefs.getString('candidat_permis') ?? 'B';
      if (savedDate != null && savedDate.isNotEmpty) {
        _dateNaissance = DateTime.tryParse(savedDate);
      }
      _isLoading = false;
    });
  }

  Future<void> _saveDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('candidat_nom', _nomCtrl.text);
    await prefs.setString('candidat_prenom', _prenomCtrl.text);
    await prefs.setString('candidat_tel', _telCtrl.text);
    await prefs.setString('candidat_email', _emailCtrl.text);
    await prefs.setString('candidat_cni', _cniCtrl.text);
    await prefs.setString('candidat_date_naiss',
        _dateNaissance?.toIso8601String() ?? '');
    await prefs.setString('candidat_lieu_naiss', _lieuNaissCtrl.text);
    await prefs.setString('candidat_nationalite', _nationaliteCtrl.text);
    await prefs.setString('candidat_permis', _categoriePermis);
  }

  Future<void> _saveDataToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firestoreService.saveCandidateProfile(
      uid: user.uid,
      profile: {
        'nom': _nomCtrl.text.trim(),
        'prenom': _prenomCtrl.text.trim(),
        'telephone': '+237${_telCtrl.text.trim()}',
        'email': _emailCtrl.text.trim(),
        'cni': _cniCtrl.text.trim(),
        'dateNaissance': _dateNaissance?.toIso8601String() ?? '',
        'lieuNaissance': _lieuNaissCtrl.text.trim(),
        'nationalite': _nationaliteCtrl.text.trim(),
        'categoriePermis': _categoriePermis,
        'documents': {
          'cni': _cniBytes != null,
          'photo': _photoBytes != null,
          'certificatMedical': _certificatBytes != null,
        },
      },
    );
  }

  Future<void> _pickDateNaissance() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 16, now.month, now.day),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E5FF),
              onPrimary: Colors.black,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateNaissance = picked);
    }
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          if (type == 'cni') _cniBytes = bytes;
          else if (type == 'photo') _photoBytes = bytes;
          else if (type == 'certificat') _certificatBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur : $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _generatePdf() async {
    if (!_formKey.currentState!.validate()) return;
    await _saveDataLocally();
    try {
      await _saveDataToFirebase();
    } catch (_) {}
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        backgroundColor: Color(0xFF0F172A),
        content: Row(
          children: [
            CircularProgressIndicator(color: Color(0xFF00E5FF)),
            SizedBox(width: 16),
            Expanded(
              child: Text('Génération du document...',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    try {
      final dateStr = _dateNaissance != null
          ? '${_dateNaissance!.day.toString().padLeft(2, '0')}/'
            '${_dateNaissance!.month.toString().padLeft(2, '0')}/'
            '${_dateNaissance!.year}'
          : '';
      await RegistrationPdfGenerator.generateAndPrintPdf(
        nom: _nomCtrl.text,
        prenom: _prenomCtrl.text,
        tel: '+237${_telCtrl.text}',
        email: _emailCtrl.text,
        cni: _cniCtrl.text,
        dateNaiss: dateStr,
        lieuNaiss: _lieuNaissCtrl.text,
        nationalite: _nationaliteCtrl.text,
        categorie: _categoriePermis,
        cniBytes: _cniBytes,
        photoBytes: _photoBytes,
        certificatBytes: _certificatBytes,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur : $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.accentCyan)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Fond image
          Positioned.fill(
            child: Image.asset(
              'assets/images/candidat_bg.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.68),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.backgroundDeep.withValues(alpha: 0.86),
                    AppColors.backgroundDark.withValues(alpha: 0.74),
                    AppColors.surface.withValues(alpha: 0.92),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Ligne déco haut
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFF00E5FF),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),

          // Point déco
          Positioned(
            top: 40, left: 10,
            child: Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF00E5FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Color(0xFF00E5FF),
                      blurRadius: 10,
                      spreadRadius: 2)
                ],
              ),
            ),
          ),
          Positioned(
            top: 40, left: 13,
            child: Container(
              width: 2, height: 100,
              color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: SingleChildScrollView(   // ← correction overflow
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 15),

                    // ── Section identité ──────────────────────
                    _buildSectionTitle(
                        Icons.person_outline, 'IDENTITÉ DU CANDIDAT'),
                    const SizedBox(height: 10),
                    _buildGlassPanel(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: _buildTextField('NOM DE NAISSANCE',
                                      _nomCtrl, 'NOM')),
                              const SizedBox(width: 15),
                              Expanded(
                                  child: _buildTextField(
                                      'PRÉNOM', _prenomCtrl, 'PRÉNOM')),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              // Date naissance — date picker
                              Expanded(
                                child: _buildDateField(),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                  child: _buildTextField('LIEU DE NAISSANCE',
                                      _lieuNaissCtrl, 'Ville')),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                  child: _buildTextField('NATIONALITÉ',
                                      _nationaliteCtrl, 'Camerounaise')),
                              const SizedBox(width: 15),
                              Expanded(
                                  child: _buildDropdownField(
                                      'CATÉGORIE PERMIS')),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                  child: _buildTextField('EMAIL', _emailCtrl,
                                      'votre@email.com')),
                              const SizedBox(width: 15),
                              // Téléphone avec drapeau Cameroun
                              Expanded(child: _buildPhoneField()),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ── Section pièces ────────────────────────
                    _buildSectionTitle(
                        Icons.folder_open, 'PIÈCES JUSTIFICATIVES'),
                    const SizedBox(height: 10),
                    _buildGlassPanel(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Column(
                        children: [
                          _buildFileSlot(
                              'Pièce d\'Identité (CNI)',
                              'VÉRIFICATION D\'IDENTITÉ',
                              _cniBytes != null,
                              () => _pickImage('cni')),
                          const SizedBox(height: 8),
                          _buildFileSlot(
                              'Photo Récente',
                              'PORTRAIT CANDIDAT',
                              _photoBytes != null,
                              () => _pickImage('photo')),
                          const SizedBox(height: 8),
                          _buildFileSlot(
                              'Certificat Médical',
                              'OPTIONNEL',
                              _certificatBytes != null,
                              () => _pickImage('certificat')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildValidateButton(),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'La validation prépare votre dossier officiel.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Date picker ──────────────────────────────────────────────────────
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE DE NAISSANCE',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 9,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDateNaissance,
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _dateNaissance != null
                        ? _formatDate(_dateNaissance)
                        : 'jj/mm/aaaa',
                    style: TextStyle(
                      color: _dateNaissance != null
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.2),
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_outlined,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Champ téléphone avec drapeau Cameroun ────────────────────────────
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TÉLÉPHONE',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 9,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              // Drapeau + indicatif
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🇨🇲', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '+237',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.80),
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              // Numéro
              Expanded(
                child: TextField(
                  controller: _telCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '6XX XX XX XX',
                    hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.2),
                        fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'DOSSIER D\'INSCRIPTION ',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1),
            ),
            Text(
              'OFFICIEL',
              style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'SYSTEM_STATUS: READY // VERIFICATION_REQUIRED',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildGlassPanel(
      {required Widget child,
      EdgeInsets padding = const EdgeInsets.all(15)}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.1), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 9,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style:
                      const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.2),
                        fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 9,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _categoriePermis,
              dropdownColor: const Color(0xFF1E293B),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Color(0xFF00E5FF), size: 18),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
              isExpanded: true,
              onChanged: (val) =>
                  setState(() => _categoriePermis = val!),
              items: ['A', 'B', 'C', 'D']
                  .map((c) => DropdownMenuItem(
                      value: c, child: Text('CATEGORIE $c')))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileSlot(String title, String subtitle, bool isDone,
      VoidCallback onTap) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              title.contains('Photo')
                  ? Icons.person_outline
                  : (title.contains('Médical')
                      ? Icons.medical_services_outlined
                      : Icons.badge_outlined),
              color: Colors.white.withValues(alpha: 0.4),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF00E5FF),
                foregroundColor:
                    isDone ? Colors.white70 : Colors.black,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              child: Row(
                children: [
                  Text(isDone ? 'RE-UPLOAD' : 'JOIN',
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 6),
                  Icon(
                      isDone
                          ? Icons.refresh
                          : Icons.file_upload_outlined,
                      size: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidateButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _generatePdf,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFF00E5FF), width: 2),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return const Color(0xFF00E5FF).withValues(alpha: 0.2);
            }
            return const Color(0xFF0F172A).withValues(alpha: 0.8);
          }),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.power_settings_new_rounded,
                color: Color(0xFF00E5FF), size: 24),
            SizedBox(width: 12),
            Text(
              'VALIDER LE DOSSIER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
