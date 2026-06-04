import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.length >= 6) {
      _user = User(id: '1', nom: 'Dupont', prenom: email.split('@')[0], email: email, niveau: 12, xp: 6500, xpProchainNiveau: 10000);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'fake_token');
      _isLoading = false; notifyListeners(); return true;
    } else {
      _error = 'Email ou mot de passe incorrect';
      _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<bool> register(Map<String, String> data) async {
    _isLoading = true; _error = null; notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _user = User(id: '1', nom: data['nom'] ?? '', prenom: data['prenom'] ?? '', email: data['email'] ?? '', niveau: 1, xp: 0, xpProchainNiveau: 1000);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', 'fake_token');
    _isLoading = false; notifyListeners(); return true;
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _user = User(id: '1', nom: 'Dupont', prenom: 'Jean', email: 'jean@test.com', niveau: 12, xp: 6500, xpProchainNiveau: 10000);
      notifyListeners();
    }
  }
}
