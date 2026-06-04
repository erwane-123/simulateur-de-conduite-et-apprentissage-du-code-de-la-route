import 'package:flutter/material.dart';
import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/data/models/cours.dart';
import 'package:code_route_flutter/data/models/theme_cours.dart';
import 'package:code_route_flutter/models/chapitre.dart';
import 'package:code_route_flutter/screens/cours/pdf_viewer_screen.dart';

class ChapitresScreen extends StatelessWidget {
  final Cours cours;

  const ChapitresScreen({Key? key, required this.cours}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundDark, const Color(0xFF1E1B4B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              AppBar(
                title: Text(
                  cours.title,
                  style: const TextStyle(fontSize: 16),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),

              // Info du cours
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(cours.icon, style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${cours.chaptersCount} chapitres',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: cours.progress,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(cours.progress * 100).toInt()}% complété',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Liste des chapitres
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  // CORRECT : On utilise la liste 'chapitres', pas le nombre 'chaptersCount'
                  itemCount: cours.chapitres.length,
                  itemBuilder: (context, index) {
                    // CORRECT : On récupère l'objet dans la liste 'chapitres'
                    final chapitre = cours.chapitres[index];
                    return _buildChapitreCard(context, chapitre, index + 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapitreCard(
      BuildContext context, Chapitre chapitre, int numero) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardBackground.withOpacity(0.7),
            AppColors.cardBackground.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: chapitre.isCompleted
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.primaryPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerScreen(
                  // Force refresh
                  theme: ThemeCours(
                    id: numero,
                    title: chapitre.title,
                    content: chapitre.description,
                    icon: numero.toString(),
                    pdfPath: chapitre.pdfPath,
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Numéro
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: chapitre.isCompleted
                        ? AppColors.successGradient
                        : AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: chapitre.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : Text(
                            '$numero',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapitre.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chapitre.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${chapitre.duration} min',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Flèche
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
