class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      // Dashboard
      'dashboard_title': 'Tableau de bord',
      'dashboard_hello': 'Bonjour,',
      'dashboard_choose': 'Choisir',
      'dashboard_success': 'Réussite',
      'dashboard_tests': 'Tests',
      'dashboard_mistakes': 'Fautes',
      'dashboard_streak': 'Série',
      'dashboard_level': 'Niveau 12',
      'dashboard_driver': 'Conducteur Confirmé',
      'dashboard_overview': 'Aperçu',
      'dashboard_see_all': 'Voir tout',
      'dashboard_traffic': 'Circulation',
      'dashboard_the_driver': 'Le conducteur',
      'dashboard_the_road': 'La route',
      'dashboard_test': 'Test',
      'dashboard_review': 'Révision',
      'dashboard_course': 'Cours',
      'dashboard_challenge': 'Défi',

      // Login
      'login_welcome': 'Bienvenue à bord !',
      'login_subtitle': 'Connectez-vous pour continuer',
      'login_email_hint': 'Email',
      'login_password_hint': 'Mot de passe',
      'login_forgot_password': 'Mot de passe oublié ?',
      'login_button': 'Se connecter',
      'login_no_account': 'Nouveau ici ? ',
      'login_register': 'Créer un compte',
      'login_error_empty': 'Veuillez remplir tous les champs',
      'login_guest': 'Consulter l\'application sans compte',

      // Defi (Challenges)
      'defi_title': 'Défis',
      'defi_fast': 'Défi rapide',
      'defi_fast_desc': '10 questions • 5 secondes par question',
      'defi_perfect': 'Défi sans erreur',
      'defi_perfect_desc': '20 questions • aucune erreur autorisée',
      'defi_signs': 'Défi signalisation',
      'defi_signs_desc': 'Questions sur les panneaux',
      'defi_priority': 'Défi priorités',
      'defi_priority_desc': 'Maîtrisez les priorités',
      'defi_exam': 'Simulation examen',
      'defi_exam_desc': '40 questions • 35 minimum pour réussir',

      // Profile / Settings
      'profile_title': 'Profil',
      'profile_edit': 'Modifier le profil',
      'profile_notifications': 'Notifications',
      'profile_stats': 'Statistiques détaillées',
      'profile_settings': 'Paramètres',
      'profile_language': 'Langue / Language',
      'profile_help': 'Aide & Support',
      'profile_about': 'À propos',
      'profile_logout': 'Se déconnecter',
      'profile_logout_confirm_title': 'Déconnexion',
      'profile_logout_confirm_body': 'Voulez-vous vraiment vous déconnecter ?',
      'profile_cancel': 'Annuler',
      'profile_close': 'Fermer',
      'profile_save': 'Enregistrer',
      'profile_name': 'Nom',
      'profile_updated': 'Profil mis à jour',
      'profile_photo_updated': 'Photo de profil mise à jour',

      // PDF Viewer
      'pdf_error_load': 'Le PDF n\'a pas pu être chargé. Erreur :',
    },
    'en': {
      // Dashboard
      'dashboard_title': 'Dashboard',
      'dashboard_hello': 'Hello,',
      'dashboard_choose': 'Choose',
      'dashboard_success': 'Success',
      'dashboard_tests': 'Tests',
      'dashboard_mistakes': 'Mistakes',
      'dashboard_streak': 'Streak',
      'dashboard_level': 'Level 12',
      'dashboard_driver': 'Confirmed Driver',
      'dashboard_overview': 'Overview',
      'dashboard_see_all': 'See all',
      'dashboard_traffic': 'Traffic',
      'dashboard_the_driver': 'The driver',
      'dashboard_the_road': 'The road',
      'dashboard_test': 'Test',
      'dashboard_review': 'Review',
      'dashboard_course': 'Course',
      'dashboard_challenge': 'Challenge',

      // Login
      'login_welcome': 'Welcome back!',
      'login_subtitle': 'Sign in to continue',
      'login_email_hint': 'Email',
      'login_password_hint': 'Password',
      'login_forgot_password': 'Forgot password?',
      'login_button': 'Sign In',
      'login_no_account': 'New here? ',
      'login_register': 'Create account',
      'login_error_empty': 'Please fill all fields',
      'login_guest': 'Browse the app without an account',

      // Defi (Challenges)
      'defi_title': 'Challenges',
      'defi_fast': 'Fast Challenge',
      'defi_fast_desc': '10 questions • 5 seconds per question',
      'defi_perfect': 'Perfect Challenge',
      'defi_perfect_desc': '20 questions • no mistakes allowed',
      'defi_signs': 'Signs Challenge',
      'defi_signs_desc': 'Questions about road signs',
      'defi_priority': 'Priority Challenge',
      'defi_priority_desc': 'Master the right-of-way rules',
      'defi_exam': 'Exam Simulation',
      'defi_exam_desc': '40 questions • 35 minimum to pass',

      // Profile / Settings
      'profile_title': 'Profile',
      'profile_edit': 'Edit profile',
      'profile_notifications': 'Notifications',
      'profile_stats': 'Detailed stats',
      'profile_settings': 'Settings',
      'profile_language': 'Language / Langue',
      'profile_help': 'Help & Support',
      'profile_about': 'About',
      'profile_logout': 'Log out',
      'profile_logout_confirm_title': 'Log out',
      'profile_logout_confirm_body': 'Are you sure you want to log out?',
      'profile_cancel': 'Cancel',
      'profile_close': 'Close',
      'profile_save': 'Save',
      'profile_name': 'Name',
      'profile_updated': 'Profile updated',
      'profile_photo_updated': 'Profile photo updated',

      // PDF Viewer
      'pdf_error_load': 'The PDF could not be loaded. Error:',
    }
  };

  static String translate(String key, String locale) {
    return _localizedValues[locale]?[key] ?? key; // Retourne la clé originale si non trouvée
  }
}
