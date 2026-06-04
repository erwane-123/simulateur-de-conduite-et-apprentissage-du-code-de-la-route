import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code_route_flutter/core/localization/app_localizations.dart';

class LocalizationProvider extends ChangeNotifier {
  String _locale = 'fr'; // Par défaut en français
  static const String _localeKey = 'app_language';

  LocalizationProvider() {
    _loadLocale();
  }

  String get locale => _locale;

  // Change la langue et sauvegarde la préférence
  Future<void> setLocale(String locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale);
    notifyListeners(); // Demande de recharger l'interface graphique globalement
  }

  // Charge la préférence sauvegardée au démarrage
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString(_localeKey) ?? 'fr';
    notifyListeners();
  }

  // Fonction clé pour récupérer le texte traduit
  String translate(String key) {
    return AppLocalizations.translate(key, _locale);
  }
}

// Helper pratique pour un usage plus lisible
extension LocalizationHelper on BuildContext {
  String tr(String key) {
    return Provider.of<LocalizationProvider>(this).translate(key);
  }
}
