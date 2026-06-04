class User {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final int niveau;
  final int xp;
  final int xpProchainNiveau;

  String? selectedPermisCategory;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.niveau,
    required this.xp,
    required this.xpProchainNiveau,
    this.selectedPermisCategory,
  });

  // ✅ GETTER nom complet
  String get nomComplet => "$prenom $nom";

  // ✅ GETTER initiale
  String get initiale {
    if (prenom.isNotEmpty) {
      return prenom[0].toUpperCase();
    }
    return '';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      niveau: json['niveau'] ?? 1,
      xp: json['xp'] ?? 0,
      xpProchainNiveau: json['xpProchainNiveau'] ?? 1000,
      selectedPermisCategory: json['selectedPermisCategory'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'niveau': niveau,
      'xp': xp,
      'xpProchainNiveau': xpProchainNiveau,
      'selectedPermisCategory': selectedPermisCategory,
    };
  }
}