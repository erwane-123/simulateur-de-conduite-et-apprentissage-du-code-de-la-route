class ThemeCours {
  final int id;
  final String title;
  final String content;
  final String icon;
  final String pdfPath;

  ThemeCours({
    required this.id,
    required this.title,
    required this.content,
    required this.icon,
    required this.pdfPath,
  });

  static List<ThemeCours> getAllThemes() {
    return [
      ThemeCours(
        id: 1,
        title: 'Signalisation routiere',
        content: 'Panneaux, marquage au sol et signaux a reconnaitre rapidement.',
        icon: '1',
        pdfPath: 'assets/cours/chapitre1_formatted.pdf',
      ),
      ThemeCours(
        id: 2,
        title: 'Regles de circulation',
        content: 'Placement, voies, intersections et conduite en agglomeration.',
        icon: '2',
        pdfPath: 'assets/cours/chapitre2_formatted.pdf',
      ),
      ThemeCours(
        id: 3,
        title: 'Priorites et intersections',
        content: 'Priorite a droite, stop, cedez-le-passage et ronds-points.',
        icon: '3',
        pdfPath: 'assets/cours/chapitre3_formatted.pdf',
      ),
      ThemeCours(
        id: 4,
        title: 'Vitesse et distances',
        content: 'Adapter son allure, anticiper et garder les bonnes distances.',
        icon: '4',
        pdfPath: 'assets/cours/chapitre4_formatted.pdf',
      ),
      ThemeCours(
        id: 5,
        title: 'Arret et stationnement',
        content: 'Savoir ou s arreter, stationner et eviter les situations dangereuses.',
        icon: '5',
        pdfPath: 'assets/cours/chapitre5_formatted.pdf',
      ),
      ThemeCours(
        id: 6,
        title: 'Conduite de nuit et meteo',
        content: 'Pluie, brouillard, nuit, adherence et visibilite reduite.',
        icon: '6',
        pdfPath: 'assets/cours/chapitre6_formatted.pdf',
      ),
      ThemeCours(
        id: 7,
        title: 'Usagers vulnerables',
        content: 'Pietons, cyclistes, deux-roues et partage de la route.',
        icon: '7',
        pdfPath: 'assets/cours/chapitre7_formatted.pdf',
      ),
      ThemeCours(
        id: 8,
        title: 'Securite du conducteur',
        content: 'Fatigue, alcool, telephone, ceinture et comportements a risque.',
        icon: '8',
        pdfPath: 'assets/cours/chapitre8_formatted.pdf',
      ),
      ThemeCours(
        id: 9,
        title: 'Vehicule et entretien',
        content: 'Equipements, pneus, feux, controles et entretien courant.',
        icon: '9',
        pdfPath: 'assets/cours/chapitre9_formatted.pdf',
      ),
      ThemeCours(
        id: 10,
        title: 'Autoroute et voies rapides',
        content: 'Insertion, depassement, distances et conduite a vitesse elevee.',
        icon: '10',
        pdfPath: 'assets/cours/chapitre10_formatted.pdf',
      ),
      ThemeCours(
        id: 11,
        title: 'Revision generale',
        content: 'Synthese des notions importantes avant les series de tests.',
        icon: '11',
        pdfPath: 'assets/cours/chapitre11_formatted.pdf',
      ),
    ];
  }
}
