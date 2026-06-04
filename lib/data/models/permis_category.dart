import 'package:flutter/material.dart';

class PermisCategory {
  final String id;
  final String code;
  final String name;
  final String description;
  final IconData icon;
  final bool isAvailable;

  PermisCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.icon,
    this.isAvailable = true,
  });

  static List<PermisCategory> getAllCategories() {
    return [
      PermisCategory(id: '1', code: 'B', name: 'Permis B', description: 'Voiture (jusqu\'à 3,5 tonnes)', icon: Icons.directions_car),
      PermisCategory(id: '2', code: 'A', name: 'Permis A', description: 'Moto (toutes cylindrées)', icon: Icons.two_wheeler),
      PermisCategory(id: '3', code: 'A1', name: 'Permis A1', description: 'Moto légère (125 cm³)', icon: Icons.moped),
      PermisCategory(id: '4', code: 'C', name: 'Permis C', description: 'Poids lourd (> 3,5 tonnes)', icon: Icons.local_shipping),
      PermisCategory(id: '5', code: 'D', name: 'Permis D', description: 'Transport de personnes', icon: Icons.directions_bus),
      PermisCategory(id: '6', code: 'BE', name: 'Permis BE', description: 'Voiture + remorque', icon: Icons.rv_hookup),
    ];
  }
}
