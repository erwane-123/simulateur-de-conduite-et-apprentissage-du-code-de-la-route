import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code_route_flutter/screens/auth/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:code_route_flutter/core/providers/localization_provider.dart';
import 'package:code_route_flutter/services/firebase/auth_service.dart';
import 'package:code_route_flutter/screens/profile/app_settings_screen.dart';
import 'package:code_route_flutter/screens/profile/help_support_screen.dart';
import 'package:code_route_flutter/screens/profile/notification_settings_screen.dart';
import 'package:code_route_flutter/screens/profile/stats_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String userEmail = '';
  String? profileImageData;
  bool notificationsEnabled = true;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'Utilisateur';
      userEmail = prefs.getString('user_email') ?? 'email@example.com';
      profileImageData = prefs.getString('profile_image_data');
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      final encodedImage = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_data', encodedImage);
      await prefs.remove('profile_image');
      setState(() {
        profileImageData = encodedImage;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('profile_photo_updated')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(context.tr('profile_logout_confirm_title'),
            style: const TextStyle(color: Colors.white)),
        content: Text(
          context.tr('profile_logout_confirm_body'),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('profile_cancel'),
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(context.tr('profile_logout')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await _authService.signOut();
      await prefs.setBool('isLoggedIn', false);
      await prefs.setBool('isGuest', false);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundDark, Color(0xFF1E1B4B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              AppBar(
                title: Text(context.tr('profile_title')),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Photo de profil
                      _buildProfileHeader(),
                      const SizedBox(height: 30),

                      // Options du profil
                      _buildProfileOption(
                        icon: Icons.person,
                        title: context.tr('profile_edit'),
                        onTap: () => _showEditProfileDialog(context),
                      ),
                      _buildProfileOption(
                        icon: Icons.notifications,
                        title: context.tr('profile_notifications'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              notificationsEnabled ? 'ON' : 'OFF',
                              style: TextStyle(
                                color: notificationsEnabled
                                    ? AppColors.success
                                    : AppColors.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NotificationSettingsScreen(),
                            ),
                          );
                          if (!mounted) return;
                          _loadUserData();
                        },
                      ),
                      // LANGUAGE OPTION
                      _buildProfileOption(
                        icon: Icons.language,
                        title: context.tr('profile_language'),
                        trailing: DropdownButton<String>(
                          value: context.watch<LocalizationProvider>().locale,
                          dropdownColor: AppColors.cardBackground,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              context
                                  .read<LocalizationProvider>()
                                  .setLocale(newValue);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                                value: 'fr', child: Text('Français')),
                            DropdownMenuItem(
                                value: 'en', child: Text('English')),
                          ],
                        ),
                      ),
                      _buildProfileOption(
                        icon: Icons.bar_chart,
                        title: context.tr('profile_stats'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StatsDetailScreen(),
                          ),
                        ),
                      ),
                      _buildProfileOption(
                        icon: Icons.settings,
                        title: context.tr('profile_settings'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppSettingsScreen(),
                          ),
                        ),
                      ),
                      _buildProfileOption(
                        icon: Icons.help_outline,
                        title: context.tr('profile_help'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpSupportScreen(),
                          ),
                        ),
                      ),
                      _buildProfileOption(
                        icon: Icons.info_outline,
                        title: context.tr('profile_about'),
                        onTap: () => _showAboutDialog(context),
                      ),

                      const SizedBox(height: 20),

                      // Bouton déconnexion
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.error,
                                  AppColors.error.withValues(alpha: 0.7)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.logout, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.tr('profile_logout'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
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

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                border: Border.all(color: AppColors.primaryPurple, width: 3),
              ),
              child: profileImageData != null
                  ? ClipOval(
                      child: Image.memory(
                        base64Decode(profileImageData!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                      ),
                    )
                  : _buildAvatarFallback(),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.backgroundDark, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userEmail,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Text(
        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardBackground.withValues(alpha: 0.7),
            AppColors.cardBackground.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                trailing ??
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext outerContext) async {
    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail);

    await showDialog(
      context: outerContext,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(outerContext.tr('profile_edit'),
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: outerContext.tr('profile_name'),
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textSecondary),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryPurple),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textSecondary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryPurple),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(outerContext.tr('profile_cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_name', nameController.text);
              await prefs.setString('user_email', emailController.text);

              if (!mounted || !context.mounted || !outerContext.mounted) {
                return;
              }
              setState(() {
                userName = nameController.text;
                userEmail = emailController.text;
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(outerContext).showSnackBar(
                SnackBar(
                  content: Text(outerContext.tr('profile_updated')),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple),
            child: Text(outerContext.tr('profile_save')),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext outerContext) {
    showDialog(
      context: outerContext,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(outerContext.tr('profile_about'),
            style: const TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code de la Route',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 16),
            Text(
              'Application d\'apprentissage du code de la route pour le Cameroun.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(outerContext.tr('profile_close')),
          ),
        ],
      ),
    );
  }
}
