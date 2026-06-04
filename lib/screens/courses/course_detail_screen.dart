import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class CourseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> themeData;

  const CourseDetailScreen({
    Key? key,
    required this.themeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Text(themeData['title']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône et titre
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(themeData['color']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      themeData['icon'],
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                themeData['title'],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                themeData['subtitle'],
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              
              // Contenu du cours
              _buildSection(
                '📖 Introduction',
                'Ce chapitre couvre les aspects essentiels de ${themeData['title'].toLowerCase()}. '
                'Vous apprendrez les règles fondamentales et les situations pratiques.',
              ),
              
              _buildSection(
                '✅ Points clés',
                '• Connaître la signification de chaque élément\n'
                '• Savoir réagir dans chaque situation\n'
                '• Anticiper les dangers potentiels\n'
                '• Respecter les règles de sécurité',
              ),
              
              _buildSection(
                '💡 Conseils pratiques',
                'Prenez le temps de bien comprendre chaque concept avant de passer au suivant. '
                'N\'hésitez pas à refaire plusieurs fois les exercices pour bien mémoriser.',
              ),
              
              const SizedBox(height: 30),
              
              // Bouton commencer
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Naviguer vers les questions du thème
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité à venir : Questions du thème'),
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(themeData['color']),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Commencer les exercices',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
