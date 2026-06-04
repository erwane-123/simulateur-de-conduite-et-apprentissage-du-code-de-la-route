import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:code_route_flutter/core/providers/localization_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code_route_flutter/screens/auth/splash_screen.dart';
import 'package:code_route_flutter/screens/auth/login_screen.dart';
import 'package:code_route_flutter/screens/auth/demo_intro_screen.dart';
import 'package:code_route_flutter/screens/home/main_navigation.dart';
import 'package:code_route_flutter/core/theme/app_theme.dart';
import 'package:code_route_flutter/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocalizationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code de la Route',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    final bool isGuest = prefs.getBool('isGuest') ?? false;
    final bool hasSeenOnboarding =
        prefs.getBool('has_seen_onboarding') ?? false;
    final bool hasActiveSession = FirebaseAuth.instance.currentUser != null;

    if (!hasActiveSession || isGuest) {
      await prefs.setBool('isLoggedIn', false);
    }

    setState(() {
      _hasSeenOnboarding = hasSeenOnboarding;
      _isLoggedIn = hasActiveSession && !isGuest;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasSeenOnboarding) {
      return const DemoIntroScreen();
    }

    return _isLoggedIn ? const MainNavigation() : const LoginScreen();
  }
}
