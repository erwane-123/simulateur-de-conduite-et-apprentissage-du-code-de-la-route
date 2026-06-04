import 'package:code_route_flutter/data/test_questions.dart' as legacy_questions;
import 'package:code_route_flutter/models/test_question.dart';

class PermitQuestionBank {
  static const int questionsPerSeries = legacy_questions.questionsPerSeries;

  static List<TestQuestion> getQuestionsForPermit(String permitCode) {
    final normalized = permitCode.toUpperCase();
    switch (normalized) {
      case 'A':
        return _questionsA;
      case 'A1':
        return _questionsA1;
      case 'C':
        return _questionsC;
      case 'D':
        return _questionsD;
      case 'BE':
        return _questionsBE;
      case 'B':
      default:
        return legacy_questions
            .getTestQuestions()
            .map((q) => q.copyWith(permitCode: 'B'))
            .toList();
    }
  }

  static int getSeriesCountForPermit(String permitCode) {
    final totalQuestions = getQuestionsForPermit(permitCode).length;
    return (totalQuestions / questionsPerSeries).ceil();
  }

  static String getPermitDisplayName(String permitCode) {
    switch (permitCode.toUpperCase()) {
      case 'A':
        return 'Permis A (Moto)';
      case 'A1':
        return 'Permis A1 (125 cm³)';
      case 'C':
        return 'Permis C (Poids lourd)';
      case 'D':
        return 'Permis D (Transport de personnes)';
      case 'BE':
        return 'Permis BE (Voiture + remorque)';
      case 'B':
      default:
        return 'Permis B (Voiture)';
    }
  }

  static TestQuestion _q({
    required int id,
    required String permitCode,
    required String themeId,
    required String question,
    required List<String> options,
    required int correctIdx,
    required String explanation,
    List<String> tags = const [],
  }) {
    return TestQuestion(
      id: id,
      permitCode: permitCode,
      themeId: themeId,
      question: question,
      imagePath: 'assets/images/questions/permits/$permitCode/question_$id.png',
      fallbackImagePath:
          legacy_questions.getLegacyQuestionImagePath(((id - 1) % 150) + 1),
      answers: options
          .asMap()
          .entries
          .map((entry) =>
              Answer(text: entry.value, isCorrect: entry.key == correctIdx))
          .toList(),
      tags: tags,
      explanation: explanation,
      officialLink: 'https://www.securite-routiere.gouv.fr',
    );
  }

  static final List<TestQuestion> _questionsA = [
    _q(
      id: 2001,
      permitCode: 'A',
      themeId: '1',
      question: 'En moto, la distance latérale minimale pour dépasser un vélo en ville est :',
      options: ['30 cm', '50 cm', '1 mètre', '2 mètres'],
      correctIdx: 2,
      explanation:
          'À moto, vous devez laisser un mètre minimum en agglomération pour protéger les usagers vulnérables.',
      tags: ['priority', 'motorcycle'],
    ),
    _q(
      id: 2002,
      permitCode: 'A',
      themeId: '2',
      question: 'Avant un virage serré à moto, la bonne stratégie est :',
      options: [
        'Freiner en plein virage',
        'Entrer vite puis corriger',
        'Réduire l’allure avant l’entrée',
        'Débrayer pour rouler libre'
      ],
      correctIdx: 2,
      explanation:
          'La vitesse doit être adaptée avant l’entrée en virage pour garder stabilité et trajectoire.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2003,
      permitCode: 'A',
      themeId: '1',
      question: 'Un marquage au sol glissant (pluie) pour un deux-roues impose :',
      options: [
        'Un freinage plus appuyé',
        'Une conduite souple sans gestes brusques',
        'Un passage rapide pour éviter la glisse',
        'L’usage du klaxon'
      ],
      correctIdx: 1,
      explanation:
          'À moto, la souplesse est essentielle sur marquage humide pour éviter la perte d’adhérence.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2004,
      permitCode: 'A',
      themeId: '3',
      question: 'Le port des gants homologués en moto est :',
      options: ['Recommandé', 'Facultatif en été', 'Obligatoire', 'Obligatoire hors ville uniquement'],
      correctIdx: 2,
      explanation: 'Les gants homologués font partie de l’équipement obligatoire du motard.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2005,
      permitCode: 'A',
      themeId: '3',
      question: 'En interfile, le motard doit :',
      options: [
        'Rouler à la même vitesse que les voitures',
        'Conserver un écart de vitesse raisonnable',
        'Slalomer rapidement',
        'Utiliser les pleins phares'
      ],
      correctIdx: 1,
      explanation:
          'L’interfile doit se faire avec prudence, vitesse maîtrisée et anticipation maximale.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2006,
      permitCode: 'A',
      themeId: '2',
      question: 'Pour freiner efficacement à moto, vous utilisez :',
      options: [
        'Uniquement le frein arrière',
        'Uniquement le frein avant',
        'Les deux freins de façon progressive',
        'Le coupe-circuit moteur'
      ],
      correctIdx: 2,
      explanation:
          'Le freinage combiné et progressif est la méthode la plus sûre en conduite réelle.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2007,
      permitCode: 'A',
      themeId: '4',
      question: 'Face à un angle mort de camion, à moto vous devez :',
      options: [
        'Vous coller au camion',
        'Rester visible, éviter les zones latérales cachées',
        'Passer entre le camion et le trottoir',
        'Klaxonner puis dépasser par la droite'
      ],
      correctIdx: 1,
      explanation:
          'Les angles morts des poids lourds sont très importants : restez visible et prudent.',
      tags: ['priority', 'motorcycle'],
    ),
    _q(
      id: 2008,
      permitCode: 'A',
      themeId: '5',
      question: 'En descente longue à moto, il faut :',
      options: [
        'Laisser la moto en roue libre',
        'Utiliser le frein moteur et alterner les freinages',
        'Freiner en continu très fort',
        'Éteindre le moteur'
      ],
      correctIdx: 1,
      explanation:
          'Le frein moteur limite l’échauffement du système de freinage et améliore le contrôle.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2009,
      permitCode: 'A',
      themeId: '1',
      question: 'À moto, un panneau “chaussée déformée” signifie surtout :',
      options: [
        'Aucun impact',
        'Risque de déséquilibre accru',
        'Possibilité d’accélérer',
        'Priorité automatique'
      ],
      correctIdx: 1,
      explanation:
          'Les irrégularités de la chaussée impactent plus fortement la stabilité d’un deux-roues.',
      tags: ['signs', 'motorcycle'],
    ),
    _q(
      id: 2010,
      permitCode: 'A',
      themeId: '2',
      question: 'La trajectoire de sécurité en virage sert à :',
      options: [
        'Prendre plus d’angle',
        'Gagner du temps',
        'Voir plus tôt et se ménager une marge',
        'Freiner plus tard'
      ],
      correctIdx: 2,
      explanation:
          'Une bonne trajectoire augmente la visibilité et garde une marge de sécurité.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2011,
      permitCode: 'A',
      themeId: '3',
      question: 'Avec un passager, il faut en priorité :',
      options: [
        'Rouler plus vite pour stabiliser',
        'Adapter freinage et distances',
        'Supprimer les contrôles visuels',
        'Désactiver l’ABS'
      ],
      correctIdx: 1,
      explanation:
          'Le passager modifie la dynamique de la moto : distances et freinage doivent être adaptés.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2012,
      permitCode: 'A',
      themeId: '1',
      question: 'En cas de pluie intense, les premières minutes sont :',
      options: ['Les plus adhérentes', 'Les plus glissantes', 'Sans impact', 'Idéales pour doubler'],
      correctIdx: 1,
      explanation:
          'Le mélange eau + résidus de surface rend la route particulièrement glissante au début.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2013,
      permitCode: 'A',
      themeId: '4',
      question: 'La meilleure position dans sa voie à moto est :',
      options: [
        'Toujours au milieu exact',
        'Toujours collé à droite',
        'Variable selon visibilité et risques',
        'Toujours sur la ligne médiane'
      ],
      correctIdx: 2,
      explanation:
          'Le placement se choisit selon l’environnement pour maximiser visibilité et sécurité.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2014,
      permitCode: 'A',
      themeId: '5',
      question: 'Un motard fatigué doit :',
      options: ['Continuer doucement', 'S’arrêter pour une vraie pause', 'Boire un soda et repartir', 'Rouler en interfile'],
      correctIdx: 1,
      explanation:
          'La fatigue dégrade fortement la perception et le temps de réaction, pause obligatoire.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2015,
      permitCode: 'A',
      themeId: '1',
      question: 'Le regard du motard doit porter :',
      options: ['Au sol juste devant', 'Loin vers la zone utile', 'Sur le compteur en permanence', 'Sur la roue avant'],
      correctIdx: 1,
      explanation:
          'Le regard guide la trajectoire : regarder loin permet d’anticiper et d’éviter les dangers.',
      tags: ['motorcycle'],
    ),
  ];

  static final List<TestQuestion> _questionsA1 = [
    _q(
      id: 2101,
      permitCode: 'A1',
      themeId: '1',
      question: 'En 125 cm³, la position du corps en freinage doit être :',
      options: ['Très reculée', 'Stable et gainée', 'Complètement relâchée', 'Penchée à l’extrême'],
      correctIdx: 1,
      explanation:
          'Une position stable améliore le contrôle du deux-roues et limite les déséquilibres.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2102,
      permitCode: 'A1',
      themeId: '2',
      question: 'En circulation dense, la règle prioritaire est :',
      options: ['Se faufiler systématiquement', 'Anticiper et garder ses distances', 'Freiner uniquement de l’arrière', 'Suivre un bus de près'],
      correctIdx: 1,
      explanation:
          'La conduite défensive et les distances protègent le motard en environnement dense.',
      tags: ['priority', 'motorcycle'],
    ),
    _q(
      id: 2103,
      permitCode: 'A1',
      themeId: '1',
      question: 'Un panneau “dos-d’âne” à moto légère signifie :',
      options: ['Accélérer pour passer vite', 'Adapter fortement l’allure', 'Passer en zigzag', 'Se mettre en roue libre'],
      correctIdx: 1,
      explanation:
          'Les ralentisseurs exigent une vitesse modérée pour garder stabilité et confort.',
      tags: ['signs', 'motorcycle'],
    ),
    _q(
      id: 2104,
      permitCode: 'A1',
      themeId: '3',
      question: 'Le casque à jugulaire mal attachée est :',
      options: ['Acceptable en ville', 'Dangereux et non conforme', 'Autorisé de jour', 'Toléré si vitesse faible'],
      correctIdx: 1,
      explanation: 'Un casque mal attaché ne protège pas correctement en cas de chute.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2105,
      permitCode: 'A1',
      themeId: '4',
      question: 'À proximité d’une portière qui peut s’ouvrir, vous :',
      options: ['Restez collé au véhicule', 'Prenez une marge latérale', 'Accélérez pour passer vite', 'Coupez la voie opposée'],
      correctIdx: 1,
      explanation:
          'La marge latérale évite l’accident classique de la portière ouverte.',
      tags: ['priority', 'motorcycle'],
    ),
    _q(
      id: 2106,
      permitCode: 'A1',
      themeId: '2',
      question: 'Sur chaussée humide, une 125 cm³ doit :',
      options: ['Freiner fort en virage', 'Éviter les actions brusques', 'Rester à vitesse constante élevée', 'Se rapprocher des lignes blanches'],
      correctIdx: 1,
      explanation: 'La motricité d’une 125 est sensible sur pluie : conduite souple indispensable.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2107,
      permitCode: 'A1',
      themeId: '5',
      question: 'Le contrôle de pression des pneus doit être :',
      options: ['Hebdomadaire', 'Régulier selon recommandations constructeur', 'Uniquement avant examen', 'Inutile sur petite cylindrée'],
      correctIdx: 1,
      explanation:
          'Des pneus bien gonflés améliorent stabilité, freinage et tenue de route.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2108,
      permitCode: 'A1',
      themeId: '3',
      question: 'Le blouson renforcé est :',
      options: ['Un accessoire esthétique', 'Un équipement de protection recommandé', 'Interdit en été', 'Réservé à l’autoroute'],
      correctIdx: 1,
      explanation:
          'Même à vitesse modérée, l’équipement protège fortement en cas de chute.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2109,
      permitCode: 'A1',
      themeId: '1',
      question: 'À l’approche d’un passage piéton occupé, la conduite correcte est :',
      options: ['Continuer si vous êtes déjà engagé', 'Ralentir et céder le passage', 'Klaxonner pour prévenir', 'Contourner le passage'],
      correctIdx: 1,
      explanation: 'Les piétons engagés sont prioritaires, y compris face aux deux-roues.',
      tags: ['priority', 'motorcycle'],
    ),
    _q(
      id: 2110,
      permitCode: 'A1',
      themeId: '2',
      question: 'Le regard en sortie de virage permet :',
      options: ['D’ignorer la trajectoire', 'D’anticiper et stabiliser la courbe', 'De freiner plus tard', 'D’éviter l’éclairage de nuit'],
      correctIdx: 1,
      explanation:
          'Regarder la zone de sortie améliore naturellement trajectoire et contrôle.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2111,
      permitCode: 'A1',
      themeId: '4',
      question: 'Dans un rond-point, à moto légère, vous devez :',
      options: ['Forcer l’entrée pour ne pas tomber', 'Céder aux usagers déjà engagés', 'Rouler sur la bande extérieure uniquement', 'Klaxonner en entrant'],
      correctIdx: 1,
      explanation: 'La priorité reste aux véhicules déjà présents dans l’anneau.',
      tags: ['priority', 'motorcycle'],
    ),
    _q(
      id: 2112,
      permitCode: 'A1',
      themeId: '5',
      question: 'En période de vent latéral, la bonne conduite est :',
      options: ['Serrer le bord droit', 'Réduire l’allure et rester souple', 'Accélérer pour passer la zone vite', 'Freiner uniquement de l’avant'],
      correctIdx: 1,
      explanation:
          'Le vent peut déporter la moto : vitesse modérée et souplesse améliorent la stabilité.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2113,
      permitCode: 'A1',
      themeId: '1',
      question: 'Un feu orange impose :',
      options: ['D’accélérer pour passer', 'De s’arrêter sauf danger immédiat', 'De continuer sans hésiter', 'De contourner le carrefour'],
      correctIdx: 1,
      explanation: 'Le feu orange est un feu d’arrêt, sauf si un arrêt est dangereux.',
      tags: ['signs', 'motorcycle'],
    ),
    _q(
      id: 2114,
      permitCode: 'A1',
      themeId: '3',
      question: 'Rouler avec visière sale la nuit :',
      options: ['Sans conséquence', 'Augmente le risque par mauvaise visibilité', 'Améliore l’éclairage', 'Est obligatoire en ville'],
      correctIdx: 1,
      explanation:
          'Une visière sale provoque reflets et perte de vision nocturne.',
      tags: ['motorcycle'],
    ),
    _q(
      id: 2115,
      permitCode: 'A1',
      themeId: '2',
      question: 'Le freinage d’urgence en ligne droite sur 125 cm³ doit être :',
      options: ['Progressif puis ferme', 'Brutal et unique sur arrière', 'Uniquement moteur', 'Sans regard vers l’avant'],
      correctIdx: 0,
      explanation:
          'Un freinage progressif puis appuyé reste la méthode la plus sûre pour garder le contrôle.',
      tags: ['motorcycle'],
    ),
  ];

  static final List<TestQuestion> _questionsC = [
    _q(
      id: 2201,
      permitCode: 'C',
      themeId: '1',
      question: 'Avec un poids lourd chargé, la distance de freinage est :',
      options: ['Plus courte', 'Identique', 'Plus longue', 'Nulle avec ABS'],
      correctIdx: 2,
      explanation:
          'La masse augmente fortement la distance d’arrêt, surtout sur route humide.',
      tags: ['truck'],
    ),
    _q(
      id: 2202,
      permitCode: 'C',
      themeId: '2',
      question: 'Avant une descente prolongée en camion, vous devez :',
      options: ['Passer au point mort', 'Choisir un rapport adapté et utiliser le frein moteur', 'Freiner en continu', 'Accélérer pour garder l’inertie'],
      correctIdx: 1,
      explanation:
          'Le frein moteur limite l’échauffement des freins et stabilise le véhicule.',
      tags: ['truck'],
    ),
    _q(
      id: 2203,
      permitCode: 'C',
      themeId: '4',
      question: 'L’angle mort d’un poids lourd est :',
      options: ['Faible', 'Important', 'Inexistant avec caméra', 'Seulement arrière'],
      correctIdx: 1,
      explanation:
          'Les angles morts sont importants à l’avant, sur les côtés et à l’arrière.',
      tags: ['priority', 'truck'],
    ),
    _q(
      id: 2204,
      permitCode: 'C',
      themeId: '1',
      question: 'Un panneau de limitation de tonnage indique :',
      options: ['Un conseil', 'Une interdiction réglementaire', 'Une priorité', 'Un simple repère'],
      correctIdx: 1,
      explanation:
          'La limitation de tonnage est une interdiction légale à respecter strictement.',
      tags: ['signs', 'truck'],
    ),
    _q(
      id: 2205,
      permitCode: 'C',
      themeId: '5',
      question: 'La répartition de charge sur un camion doit être :',
      options: ['Aléatoire', 'Équilibrée et arrimée', 'Concentrée à l’arrière', 'Concentrée d’un côté'],
      correctIdx: 1,
      explanation:
          'Une charge mal répartie dégrade stabilité, freinage et sécurité globale.',
      tags: ['truck'],
    ),
    _q(
      id: 2206,
      permitCode: 'C',
      themeId: '2',
      question: 'En virage serré avec un poids lourd, le risque principal est :',
      options: ['Sous-vitesse', 'Déport et empiètement', 'Absence d’angle mort', 'Perte du klaxon'],
      correctIdx: 1,
      explanation:
          'Le gabarit impose un déport : anticipation et vitesse réduite obligatoires.',
      tags: ['truck'],
    ),
    _q(
      id: 2207,
      permitCode: 'C',
      themeId: '3',
      question: 'Le contrôle visuel des pneumatiques poids lourd est :',
      options: ['Occasionnel', 'Quotidien avant départ', 'Uniquement en atelier', 'Inutile avec capteurs'],
      correctIdx: 1,
      explanation:
          'L’inspection pré-départ est indispensable sur un véhicule de fort tonnage.',
      tags: ['truck'],
    ),
    _q(
      id: 2208,
      permitCode: 'C',
      themeId: '4',
      question: 'À l’approche d’un cycliste en ville, un camion doit :',
      options: ['Le dépasser sans écart', 'Laisser une marge latérale suffisante', 'Le coller pour éviter l’angle mort', 'Klaxonner longuement'],
      correctIdx: 1,
      explanation:
          'Les usagers vulnérables nécessitent un écart latéral important et une grande vigilance.',
      tags: ['priority', 'truck'],
    ),
    _q(
      id: 2209,
      permitCode: 'C',
      themeId: '5',
      question: 'Le temps de réaction d’un conducteur fatigué :',
      options: ['Diminue', 'Reste identique', 'Augmente', 'Devient nul'],
      correctIdx: 2,
      explanation:
          'La fatigue augmente les temps de réaction et le risque d’accident grave.',
      tags: ['truck'],
    ),
    _q(
      id: 2210,
      permitCode: 'C',
      themeId: '1',
      question: 'Un panneau “hauteur limitée” est à considérer comme :',
      options: ['Une recommandation', 'Une interdiction absolue', 'Un repère météo', 'Un marquage temporaire sans effet'],
      correctIdx: 1,
      explanation:
          'Le non-respect d’une hauteur limite peut entraîner un accident majeur.',
      tags: ['signs', 'truck'],
    ),
    _q(
      id: 2211,
      permitCode: 'C',
      themeId: '2',
      question: 'Le dépassement en poids lourd doit être :',
      options: ['Fréquent pour garder le rythme', 'Rare et parfaitement anticipé', 'Réalisé en côte uniquement', 'Toujours par la droite'],
      correctIdx: 1,
      explanation:
          'La longueur et l’inertie du camion imposent un dépassement exceptionnel et sécurisé.',
      tags: ['truck'],
    ),
    _q(
      id: 2212,
      permitCode: 'C',
      themeId: '3',
      question: 'Les dispositifs de retenue de charge servent à :',
      options: ['Réduire la consommation', 'Empêcher déplacement/chute de charge', 'Améliorer le confort cabine', 'Remplacer les freins'],
      correctIdx: 1,
      explanation:
          'L’arrimage garantit la sécurité du transport et des autres usagers.',
      tags: ['truck'],
    ),
    _q(
      id: 2213,
      permitCode: 'C',
      themeId: '4',
      question: 'Dans un rond-point, un poids lourd doit :',
      options: ['Entrer rapidement', 'Respecter priorité + trajectoire adaptée au gabarit', 'Bloquer l’anneau', 'S’arrêter au centre'],
      correctIdx: 1,
      explanation:
          'La priorité reste identique, avec adaptation de trajectoire au gabarit.',
      tags: ['priority', 'truck'],
    ),
    _q(
      id: 2214,
      permitCode: 'C',
      themeId: '5',
      question: 'En cas de vent latéral fort, un camion doit :',
      options: ['Accélérer pour stabiliser', 'Réduire la vitesse et corriger progressivement', 'Rouler au point mort', 'Freiner brutalement'],
      correctIdx: 1,
      explanation:
          'Le vent peut déporter fortement le véhicule : réduire l’allure est indispensable.',
      tags: ['truck'],
    ),
    _q(
      id: 2215,
      permitCode: 'C',
      themeId: '1',
      question: 'Le respect du PTAC est :',
      options: ['Optionnel selon trajet', 'Obligatoire', 'Réservé au contrôle technique', 'Inutile sur autoroute'],
      correctIdx: 1,
      explanation: 'Le PTAC conditionne sécurité, légalité et capacité de freinage du camion.',
      tags: ['truck'],
    ),
  ];

  static final List<TestQuestion> _questionsD = [
    _q(
      id: 2301,
      permitCode: 'D',
      themeId: '1',
      question: 'Un conducteur de bus doit prioritairement assurer :',
      options: ['Le confort uniquement', 'La sécurité des passagers et des autres usagers', 'La vitesse commerciale', 'Le silence cabine'],
      correctIdx: 1,
      explanation:
          'La sécurité des passagers et de la route reste l’objectif principal du permis D.',
      tags: ['bus'],
    ),
    _q(
      id: 2302,
      permitCode: 'D',
      themeId: '2',
      question: 'Avant de démarrer à un arrêt, il faut :',
      options: ['Fermer les portes et vérifier l’environnement', 'Accélérer dès la fermeture', 'Ignorer les rétroviseurs', 'Klaxonner systématiquement'],
      correctIdx: 0,
      explanation:
          'Le contrôle des portes et des angles morts est indispensable avant remise en mouvement.',
      tags: ['bus'],
    ),
    _q(
      id: 2303,
      permitCode: 'D',
      themeId: '4',
      question: 'À proximité d’un arrêt scolaire, la conduite doit être :',
      options: ['Normale', 'Très prudente avec allure réduite', 'Rapide pour libérer la voie', 'En dépassement permanent'],
      correctIdx: 1,
      explanation:
          'Présence possible d’enfants : vitesse réduite et anticipation renforcée.',
      tags: ['priority', 'bus'],
    ),
    _q(
      id: 2304,
      permitCode: 'D',
      themeId: '3',
      question: 'Le transport de passagers debout impose :',
      options: ['Freinages progressifs et conduite souple', 'Freinages courts et appuyés', 'Aucune adaptation', 'Usage fréquent du klaxon'],
      correctIdx: 0,
      explanation:
          'Les passagers debout nécessitent une conduite fluide pour éviter les chutes.',
      tags: ['bus'],
    ),
    _q(
      id: 2305,
      permitCode: 'D',
      themeId: '1',
      question: 'Un couloir de bus signalé est :',
      options: ['Une zone facultative', 'Une voie réservée selon signalisation', 'Une voie de dépassement générale', 'Une zone de stationnement'],
      correctIdx: 1,
      explanation:
          'Les voies bus sont réglementées par la signalisation verticale/horizontale.',
      tags: ['signs', 'bus'],
    ),
    _q(
      id: 2306,
      permitCode: 'D',
      themeId: '5',
      question: 'Un conducteur de bus fatigué doit :',
      options: ['Terminer la ligne coûte que coûte', 'Signaler et s’arrêter en sécurité', 'Augmenter la ventilation', 'Boire du café et continuer'],
      correctIdx: 1,
      explanation:
          'La fatigue est incompatible avec le transport de passagers, arrêt et relais nécessaires.',
      tags: ['bus'],
    ),
    _q(
      id: 2307,
      permitCode: 'D',
      themeId: '2',
      question: 'En virage avec un bus articulé, le risque principal est :',
      options: ['Décrochage sonore', 'Balayage arrière', 'Disparition des angles morts', 'Surconsommation'],
      correctIdx: 1,
      explanation:
          'Le balayage arrière peut surprendre les usagers proches, vigilance maximale.',
      tags: ['bus'],
    ),
    _q(
      id: 2308,
      permitCode: 'D',
      themeId: '4',
      question: 'Face à un passager en difficulté à la montée, il faut :',
      options: ['Repartir immédiatement', 'Attendre sa stabilisation en sécurité', 'Fermer les portes rapidement', 'Demander aux autres de pousser'],
      correctIdx: 1,
      explanation:
          'Le conducteur doit garantir une montée/descente sécurisée des passagers.',
      tags: ['bus'],
    ),
    _q(
      id: 2309,
      permitCode: 'D',
      themeId: '3',
      question: 'Le freinage d’urgence en bus doit rester :',
      options: ['Exceptionnel', 'Régulier pour gagner du temps', 'La norme en ville', 'Remplacé par le klaxon'],
      correctIdx: 0,
      explanation:
          'La conduite bus privilégie l’anticipation pour éviter les freinages brusques.',
      tags: ['bus'],
    ),
    _q(
      id: 2310,
      permitCode: 'D',
      themeId: '1',
      question: 'Un panneau de gabarit limité pour un bus implique :',
      options: ['Passage possible en forçant', 'Interdiction de s’engager', 'Passage autorisé de nuit', 'Passage autorisé à vide'],
      correctIdx: 1,
      explanation:
          'Le non-respect des limitations de gabarit met en danger passagers et infrastructure.',
      tags: ['signs', 'bus'],
    ),
    _q(
      id: 2311,
      permitCode: 'D',
      themeId: '2',
      question: 'À un feu orange avec passagers debout :',
      options: ['Accélérer pour passer', 'Freiner progressivement si l’arrêt est possible', 'Rester au milieu du carrefour', 'Dévier sur la voie de gauche'],
      correctIdx: 1,
      explanation:
          'La priorité est un arrêt sécurisé, progressif et sans risque de chute passager.',
      tags: ['bus'],
    ),
    _q(
      id: 2312,
      permitCode: 'D',
      themeId: '5',
      question: 'Le contrôle des portes avant départ est :',
      options: ['Optionnel', 'Obligatoire', 'Réservé aux terminus', 'Inutile si caméra active'],
      correctIdx: 1,
      explanation: 'Un départ avec porte mal fermée crée un risque immédiat pour les voyageurs.',
      tags: ['bus'],
    ),
    _q(
      id: 2313,
      permitCode: 'D',
      themeId: '4',
      question: 'Dans une zone piétonne proche de l’arrêt, le conducteur de bus :',
      options: ['Garde son allure', 'Adapte fortement la vitesse et anticipe', 'Utilise uniquement le klaxon', 'Privilégie la voie opposée'],
      correctIdx: 1,
      explanation:
          'La présence piétonne impose anticipation constante et vitesse modérée.',
      tags: ['priority', 'bus'],
    ),
    _q(
      id: 2314,
      permitCode: 'D',
      themeId: '3',
      question: 'L’entretien des pneumatiques bus impacte :',
      options: ['Uniquement le confort', 'Freinage, stabilité et consommation', 'Seulement la direction assistée', 'Aucun élément de sécurité'],
      correctIdx: 1,
      explanation:
          'Les pneus influencent directement les performances de sécurité du véhicule.',
      tags: ['bus'],
    ),
    _q(
      id: 2315,
      permitCode: 'D',
      themeId: '1',
      question: 'Le respect des zones d’arrêt matérialisées est :',
      options: ['Facultatif', 'Obligatoire pour sécurité d’embarquement', 'Réservé aux heures de pointe', 'Inutile avec annonce sonore'],
      correctIdx: 1,
      explanation:
          'Les zones d’arrêt garantissent un accès sûr des passagers et une visibilité correcte.',
      tags: ['signs', 'bus'],
    ),
  ];

  static final List<TestQuestion> _questionsBE = [
    _q(
      id: 2401,
      permitCode: 'BE',
      themeId: '1',
      question: 'Avant le départ avec remorque, il faut vérifier :',
      options: ['Uniquement les feux du véhicule tracteur', 'Attelage + feux + pression + charge', 'Seulement la plaque', 'Rien, la remorque suit'],
      correctIdx: 1,
      explanation:
          'Le contrôle complet de l’ensemble tracteur/remorque est obligatoire avant départ.',
      tags: ['trailer'],
    ),
    _q(
      id: 2402,
      permitCode: 'BE',
      themeId: '2',
      question: 'Avec une remorque, la distance de freinage est :',
      options: ['Plus courte', 'Identique', 'Plus longue', 'Nulle avec ABS'],
      correctIdx: 2,
      explanation:
          'L’ensemble est plus lourd et freine plus longuement, surtout chargé.',
      tags: ['trailer'],
    ),
    _q(
      id: 2403,
      permitCode: 'BE',
      themeId: '3',
      question: 'En marche arrière avec remorque, vous devez :',
      options: ['Tourner vite le volant', 'Manœuvrer lentement avec corrections progressives', 'Accélérer pour stabiliser', 'Freiner par à-coups'],
      correctIdx: 1,
      explanation:
          'Les manœuvres avec remorque exigent lenteur, précision et anticipation.',
      tags: ['trailer'],
    ),
    _q(
      id: 2404,
      permitCode: 'BE',
      themeId: '4',
      question: 'En descente avec remorque, la conduite correcte est :',
      options: ['Point mort', 'Rapport engagé + frein moteur', 'Freinage continu fort', 'Accélération constante'],
      correctIdx: 1,
      explanation:
          'Le frein moteur protège les freins et améliore le contrôle de l’attelage.',
      tags: ['trailer'],
    ),
    _q(
      id: 2405,
      permitCode: 'BE',
      themeId: '1',
      question: 'Le PTAC de l’ensemble tracteur/remorque doit être :',
      options: ['Ignoré si trajet court', 'Respecté strictement', 'Vérifié uniquement par le loueur', 'Dépendant de la météo'],
      correctIdx: 1,
      explanation:
          'Le dépassement du PTAC est dangereux et interdit réglementairement.',
      tags: ['trailer'],
    ),
    _q(
      id: 2406,
      permitCode: 'BE',
      themeId: '5',
      question: 'Une charge remorque mal arrimée peut :',
      options: ['N’avoir aucun effet', 'Déstabiliser l’ensemble', 'Améliorer la traction', 'Réduire la consommation'],
      correctIdx: 1,
      explanation:
          'L’arrimage est essentiel pour éviter balancement, perte de charge et accident.',
      tags: ['trailer'],
    ),
    _q(
      id: 2407,
      permitCode: 'BE',
      themeId: '2',
      question: 'En virage avec remorque, il faut :',
      options: ['Couper le virage', 'Élargir trajectoire et réduire allure', 'Accélérer avant la courbe', 'Freiner brusquement en plein virage'],
      correctIdx: 1,
      explanation:
          'La remorque suit une trajectoire différente, d’où adaptation du virage.',
      tags: ['trailer'],
    ),
    _q(
      id: 2408,
      permitCode: 'BE',
      themeId: '4',
      question: 'Le risque de mise en lacet est favorisé par :',
      options: ['Vitesse excessive', 'Vitesse modérée', 'Charge bien équilibrée', 'Pressions correctes'],
      correctIdx: 0,
      explanation:
          'La vitesse excessive augmente fortement le risque de lacet d’une remorque.',
      tags: ['trailer'],
    ),
    _q(
      id: 2409,
      permitCode: 'BE',
      themeId: '3',
      question: 'Pour stationner avec remorque, la bonne approche est :',
      options: ['Marche arrière rapide', 'Manœuvre lente avec repères visuels', 'Frein à main remorque inutile', 'Décrocher avant manœuvre'],
      correctIdx: 1,
      explanation:
          'Les manœuvres de stationnement demandent précision et contrôle progressif.',
      tags: ['trailer'],
    ),
    _q(
      id: 2410,
      permitCode: 'BE',
      themeId: '1',
      question: 'Un panneau “interdiction aux véhicules tractant une remorque” signifie :',
      options: ['Simple conseil', 'Interdiction réglementaire', 'Priorité spéciale', 'Passage autorisé si léger'],
      correctIdx: 1,
      explanation:
          'Cette signalisation interdit le passage des ensembles concernés.',
      tags: ['signs', 'trailer'],
    ),
    _q(
      id: 2411,
      permitCode: 'BE',
      themeId: '2',
      question: 'En cas de balancement de remorque, vous devez :',
      options: ['Freiner fortement', 'Ralentir progressivement sans gestes brusques', 'Accélérer fort', 'Tourner fortement le volant'],
      correctIdx: 1,
      explanation:
          'La réduction progressive de vitesse limite le phénomène de lacet.',
      tags: ['trailer'],
    ),
    _q(
      id: 2412,
      permitCode: 'BE',
      themeId: '5',
      question: 'Les rétroviseurs adaptés en conduite BE sont :',
      options: ['Optionnels', 'Indispensables à la visibilité', 'Utiles seulement la nuit', 'Réservés à l’autoroute'],
      correctIdx: 1,
      explanation:
          'La visibilité arrière et latérale est un point critique avec remorque.',
      tags: ['trailer'],
    ),
    _q(
      id: 2413,
      permitCode: 'BE',
      themeId: '4',
      question: 'Le dépassement avec remorque doit être :',
      options: ['Fréquent', 'Anticipé avec marge importante', 'Toujours à droite', 'Réalisé en courbe'],
      correctIdx: 1,
      explanation:
          'La longueur de l’ensemble impose un dépassement exceptionnel et préparé.',
      tags: ['trailer'],
    ),
    _q(
      id: 2414,
      permitCode: 'BE',
      themeId: '3',
      question: 'À l’arrêt, la remorque doit être sécurisée par :',
      options: ['La boîte de vitesse uniquement', 'Frein de stationnement/cales si nécessaire', 'Un passager à l’arrière', 'Le moteur allumé'],
      correctIdx: 1,
      explanation:
          'La sécurisation à l’arrêt évite tout déplacement intempestif de la remorque.',
      tags: ['trailer'],
    ),
    _q(
      id: 2415,
      permitCode: 'BE',
      themeId: '1',
      question: 'Le contrôle des feux de remorque avant départ est :',
      options: ['Facultatif', 'Obligatoire', 'Réservé aux longs trajets', 'Inutile en journée'],
      correctIdx: 1,
      explanation:
          'Feux et signalisation arrière doivent être fonctionnels pour la sécurité.',
      tags: ['signs', 'trailer'],
    ),
  ];
}
