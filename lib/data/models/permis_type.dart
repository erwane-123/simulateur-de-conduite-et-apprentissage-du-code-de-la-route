import 'package:flutter/material.dart';

class PermisType {
  final String code;
  final String nom;
  final String description;
  final int ageMin;
  final String icon;
  final Color color;

  const PermisType({
    required this.code,
    required this.nom,
    required this.description,
    required this.ageMin,
    required this.icon,
    required this.color,
  });

  // MOTOS
  static const PermisType AM = PermisType(code: 'AM', nom: 'Cyclomoteur', description: 'Scooter 50cm³', ageMin: 14, icon: '🛵', color: Color(0xFFFF6B6B));
  static const PermisType A1 = PermisType(code: 'A1', nom: 'Moto légère', description: 'Moto jusqu\'à 125cm³', ageMin: 16, icon: '🏍️', color: Color(0xFFEE5A6F));
  static const PermisType A2 = PermisType(code: 'A2', nom: 'Moto intermédiaire', description: 'Moto jusqu\'à 35kW', ageMin: 18, icon: '🏍️', color: Color(0xFFC44569));
  static const PermisType A = PermisType(code: 'A', nom: 'Moto', description: 'Toutes les motos', ageMin: 20, icon: '🏍️', color: Color(0xFF8B2635));

  // VOITURES
  static const PermisType B = PermisType(code: 'B', nom: 'Voiture', description: 'Véhicule léger (3,5T max)', ageMin: 18, icon: '🚗', color: Color(0xFF2563EB));
  static const PermisType B1 = PermisType(code: 'B1', nom: 'Quadricycle lourd', description: 'Quadricycle jusqu\'à 550kg', ageMin: 16, icon: '🚙', color: Color(0xFF3B82F6));
  static const PermisType BE = PermisType(code: 'B+E', nom: 'Voiture + remorque', description: 'Remorque > 750kg', ageMin: 18, icon: '🚗🚛', color: Color(0xFF1E40AF));

  // POIDS LOURDS
  static const PermisType C = PermisType(code: 'C', nom: 'Poids lourd', description: 'Véhicule > 3,5T', ageMin: 21, icon: '🚚', color: Color(0xFF10B981));
  static const PermisType C1 = PermisType(code: 'C1', nom: 'Poids lourd léger', description: 'Véhicule 3,5T à 7,5T', ageMin: 18, icon: '🚚', color: Color(0xFF34D399));
  static const PermisType CE = PermisType(code: 'C+E', nom: 'PL + remorque', description: 'Ensemble > 3,5T', ageMin: 21, icon: '🚚🚛', color: Color(0xFF059669));

  // TRANSPORT EN COMMUN
  static const PermisType D = PermisType(code: 'D', nom: 'Transport en commun', description: 'Bus > 9 places', ageMin: 24, icon: '🚌', color: Color(0xFFF59E0B));
  static const PermisType D1 = PermisType(code: 'D1', nom: 'Minibus', description: 'Bus 9 à 16 places', ageMin: 21, icon: '🚐', color: Color(0xFFFBBF24));
  static const PermisType DE = PermisType(code: 'D+E', nom: 'Bus + remorque', description: 'Bus avec remorque', ageMin: 24, icon: '🚌🚛', color: Color(0xFFD97706));

  static List<PermisType> getAll() => [AM, A1, A2, A, B, B1, BE, C, C1, CE, D, D1, DE];
}
