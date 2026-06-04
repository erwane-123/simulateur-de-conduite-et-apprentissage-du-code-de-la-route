import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faqs = [
      (
        'Comment progresser plus vite ?',
        'Travaillez par themes, puis enchainez avec des series completes pour consolider vos automatismes.'
      ),
      (
        'Comment fonctionne le choix du permis ?',
        'Le permis selectionne sert a filtrer la banque de questions et a lire les indicateurs correspondant a cette categorie.'
      ),
      (
        'Ou sont enregistrees mes statistiques ?',
        'Les stats sont conservees localement et relues via un service central de progression utilisateur.'
      ),
      (
        'Pourquoi certains modules ressemblent a des prototypes ?',
        'Des espaces comme l arena ou le dashcam montrent aussi des pistes d evolution produit et technologique.'
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Aide & support'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withOpacity(0.82),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Centre d aide rapide',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Cet ecran remplace le placeholder initial par une base d assistance lisible pour l utilisateur : questions frequentes, logique de progression et rappel du fonctionnement global.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...faqs.map(
            (faq) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                collapsedBackgroundColor:
                    AppColors.cardBackground.withOpacity(0.75),
                backgroundColor: AppColors.cardBackground.withOpacity(0.9),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                iconColor: AppColors.primaryPurple,
                collapsedIconColor: AppColors.primaryPurple,
                title: Text(
                  faq.$1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      faq.$2,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
