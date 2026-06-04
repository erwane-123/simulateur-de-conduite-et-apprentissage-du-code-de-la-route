import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream for auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      developer.log('Error signing in', error: e);
      return null;
    }
  }

  // Register with email and password
  Future<UserCredential?> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw "Une erreur inconnue est survenue";
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } on PlatformException catch (e) {
      throw _handlePlatformAuthError(e, provider: 'Google');
    } catch (e) {
      throw _handleSocialAuthError(e, provider: 'Google');
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final supportsNativeAppleSignIn =
          defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS;
      if (!kIsWeb && !supportsNativeAppleSignIn) {
        throw 'La connexion Apple n\'est disponible que sur iPhone, iPad ou macOS.';
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await _auth.signInWithCredential(oauthCredential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      throw 'Connexion Apple impossible : ${e.message}.';
    } on PlatformException catch (e) {
      throw _handlePlatformAuthError(e, provider: 'Apple');
    } catch (e) {
      throw _handleSocialAuthError(e, provider: 'Apple');
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Cet email est déjà utilisé par un autre compte.";
      case 'invalid-email':
        return "L'adresse email n'est pas valide.";
      case 'weak-password':
        return "Le mot de passe est trop faible.";
      case 'network-request-failed':
        return "Erreur réseau. Vérifiez votre connexion internet.";
      default:
        return e.message ?? "Erreur d'authentification";
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut().catchError((_) => null);
    await _auth.signOut();
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  String _handleSocialAuthError(Object error, {required String provider}) {
    final message = error.toString().toLowerCase();
    if (message.contains('network')) {
      return 'Erreur réseau pendant la connexion $provider.';
    }
    if (message.contains('googleservice-info')) {
      return 'Fichier GoogleService-Info.plist manquant ou invalide pour iOS.';
    }
    if (message.contains('oauth') || message.contains('12500')) {
      return 'Configuration OAuth $provider incomplète côté Firebase/console développeur.';
    }
    if (message.contains('cancel')) {
      return 'Connexion $provider annulée.';
    }
    return 'Connexion $provider impossible pour le moment.';
  }

  String _handlePlatformAuthError(
    PlatformException error, {
    required String provider,
  }) {
    final code = error.code.toLowerCase();
    final message = (error.message ?? '').toLowerCase();

    if (code.contains('sign_in_failed') ||
        code.contains('network_error') ||
        message.contains('network')) {
      return 'Connexion $provider impossible : problème réseau ou service indisponible.';
    }
    if (code.contains('sign_in_canceled') || message.contains('cancel')) {
      return 'Connexion $provider annulée.';
    }
    if (message.contains('googleservice-info')) {
      return 'Google Sign-In iOS nécessite un GoogleService-Info.plist valide.';
    }
    if (message.contains('12500') ||
        message.contains('developer error') ||
        message.contains('oauth')) {
      return 'Configuration OAuth $provider incomplète côté Firebase/console développeur.';
    }

    return 'Connexion $provider impossible : ${error.message ?? error.code}.';
  }
}
