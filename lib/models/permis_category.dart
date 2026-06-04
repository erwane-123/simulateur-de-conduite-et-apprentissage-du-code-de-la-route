class PermisCategory {
  final String id;
  final String code;
  final String name;
  final String description;
  final String icon;
  final bool isAvailable;

  PermisCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.icon,
    this.isAvailable = true,
  });

  factory PermisCategory.fromJson(Map<String, dynamic> json) {
    return PermisCategory(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🚗',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'icon': icon,
      'isAvailable': isAvailable,
    };
  }

  static List<PermisCategory> getAllCategories() {
    return [
      PermisCategory(
        id: '1',
        code: 'B',
        name: 'Permis B',
        description: 'Voiture (jusqu\'à 3,5 tonnes)',
        icon: '🚗',
      ),
      PermisCategory(
        id: '2',
        code: 'A',
        name: 'Permis A',
        description: 'Moto (toutes cylindrées)',
        icon: '🏍️',
      ),
      PermisCategory(
        id: '3',
        code: 'A1',
        name: 'Permis A1',
        description: 'Moto légère (125 cm³)',
        icon: '🛵',
      ),
      PermisCategory(
        id: '4',
        code: 'C',
        name: 'Permis C',
        description: 'Poids lourd (> 3,5 tonnes)',
        icon: '🚚',
      ),
      PermisCategory(
        id: '5',
        code: 'D',
        name: 'Permis D',
        description: 'Transport de personnes',
        icon: '🚌',
      ),
      PermisCategory(
        id: '6',
        code: 'BE',
        name: 'Permis BE',
        description: 'Voiture + remorque',
        icon: '🚙',
      ),
    ];
  }
}
