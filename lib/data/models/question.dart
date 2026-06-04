class TestQuestion {
  final int id;
  final String question;
  final String imagePath;
  final List<Answer> answers;

  TestQuestion({
    required this.id,
    required this.question,
    required this.imagePath,
    required this.answers,
  });
}

class Answer {
  final String text;
  final bool isCorrect;

  Answer({required this.text, required this.isCorrect});
}

// 40 QUESTIONS DU CODE DE LA ROUTE
List<TestQuestion> getTestQuestions() {
  return [
    // Questions 1-10 : Signalisation
    TestQuestion(
      id: 1,
      question: "Que signifie ce panneau ?",
      imagePath: "assets/images/questions/q1.png",
      answers: [
        Answer(text: "Stop obligatoire", isCorrect: true),
        Answer(text: "Cédez le passage", isCorrect: false),
        Answer(text: "Sens interdit", isCorrect: false),
        Answer(text: "Stationnement interdit", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 2,
      question: "Que signifie ce feu tricolore ?",
      imagePath: "assets/images/questions/q2.png",
      answers: [
        Answer(text: "Je dois m'arrêter", isCorrect: true),
        Answer(text: "Je peux passer", isCorrect: false),
        Answer(text: "Je dois ralentir", isCorrect: false),
        Answer(text: "Je peux tourner à droite", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 3,
      question: "Quelle est la vitesse maximale en ville ?",
      imagePath: "assets/images/questions/q3.png",
      answers: [
        Answer(text: "50 km/h", isCorrect: true),
        Answer(text: "30 km/h", isCorrect: false),
        Answer(text: "70 km/h", isCorrect: false),
        Answer(text: "90 km/h", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 4,
      question: "Ce panneau indique :",
      imagePath: "assets/images/questions/q4.png",
      answers: [
        Answer(text: "Passage piétons", isCorrect: true),
        Answer(text: "École à proximité", isCorrect: false),
        Answer(text: "Zone résidentielle", isCorrect: false),
        Answer(text: "Travaux", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 5,
      question: "À quelle distance doit-on signaler un dépassement ?",
      imagePath: "assets/images/questions/q5.png",
      answers: [
        Answer(text: "50 mètres", isCorrect: true),
        Answer(text: "30 mètres", isCorrect: false),
        Answer(text: "100 mètres", isCorrect: false),
        Answer(text: "Pas nécessaire", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 6,
      question: "Ce marquage au sol signifie :",
      imagePath: "assets/images/questions/q6.png",
      answers: [
        Answer(
            text: "Ligne continue, interdiction de franchir", isCorrect: true),
        Answer(
            text: "Ligne discontinue, franchissement autorisé",
            isCorrect: false),
        Answer(text: "Voie de bus", isCorrect: false),
        Answer(text: "Piste cyclable", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 7,
      question: "Que faire à ce carrefour ?",
      imagePath: "assets/images/questions/q7.png",
      answers: [
        Answer(text: "Céder le passage à droite", isCorrect: true),
        Answer(text: "Passer en premier", isCorrect: false),
        Answer(text: "S'arrêter obligatoirement", isCorrect: false),
        Answer(text: "Tourner à gauche", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 8,
      question: "Distance de sécurité sur autoroute :",
      imagePath: "assets/images/questions/q8.png",
      answers: [
        Answer(text: "2 secondes minimum", isCorrect: true),
        Answer(text: "1 seconde", isCorrect: false),
        Answer(text: "5 mètres", isCorrect: false),
        Answer(text: "10 mètres", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 9,
      question: "Ce panneau indique :",
      imagePath: "assets/images/questions/q9.png",
      answers: [
        Answer(text: "Rond-point obligatoire", isCorrect: true),
        Answer(text: "Sens giratoire", isCorrect: false),
        Answer(text: "Demi-tour interdit", isCorrect: false),
        Answer(text: "Circulation dans les deux sens", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 10,
      question: "Taux d'alcoolémie maximum autorisé :",
      imagePath: "assets/images/questions/q10.png",
      answers: [
        Answer(text: "0,5 g/L de sang", isCorrect: true),
        Answer(text: "0,8 g/L de sang", isCorrect: false),
        Answer(text: "0,2 g/L de sang", isCorrect: false),
        Answer(text: "1,0 g/L de sang", isCorrect: false),
      ],
    ),

    // Questions 11-20 : Priorités et intersections
    TestQuestion(
      id: 11,
      question: "À qui devez-vous céder le passage ?",
      imagePath: "assets/images/questions/q11.png",
      answers: [
        Answer(text: "Au véhicule venant de droite", isCorrect: true),
        Answer(text: "Au véhicule venant de gauche", isCorrect: false),
        Answer(text: "Aux deux véhicules", isCorrect: false),
        Answer(text: "À personne", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 12,
      question: "Ce panneau signifie :",
      imagePath: "assets/images/questions/q12.png",
      answers: [
        Answer(text: "Interdiction de tourner à gauche", isCorrect: true),
        Answer(text: "Obligation de tourner à gauche", isCorrect: false),
        Answer(text: "Sens interdit", isCorrect: false),
        Answer(text: "Route barrée", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 13,
      question: "Durée maximale du permis probatoire :",
      imagePath: "assets/images/questions/q13.png",
      answers: [
        Answer(text: "3 ans", isCorrect: true),
        Answer(text: "2 ans", isCorrect: false),
        Answer(text: "5 ans", isCorrect: false),
        Answer(text: "1 an", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 14,
      question: "Sur autoroute, je peux rouler à :",
      imagePath: "assets/images/questions/q14.png",
      answers: [
        Answer(text: "130 km/h maximum", isCorrect: true),
        Answer(text: "110 km/h maximum", isCorrect: false),
        Answer(text: "150 km/h maximum", isCorrect: false),
        Answer(text: "90 km/h maximum", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 15,
      question: "Ce panneau indique :",
      imagePath: "assets/images/questions/q15.png",
      answers: [
        Answer(text: "Stationnement interdit", isCorrect: true),
        Answer(text: "Arrêt interdit", isCorrect: false),
        Answer(text: "Zone bleue", isCorrect: false),
        Answer(text: "Stationnement payant", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 16,
      question: "Que signifie ce feu orange ?",
      imagePath: "assets/images/questions/q16.png",
      answers: [
        Answer(
            text: "Je m'arrête si je peux le faire en sécurité",
            isCorrect: true),
        Answer(text: "J'accélère pour passer", isCorrect: false),
        Answer(text: "Je ralentis", isCorrect: false),
        Answer(text: "Je m'arrête obligatoirement", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 17,
      question: "Distance de freinage sur route sèche à 50 km/h :",
      imagePath: "assets/images/questions/q17.png",
      answers: [
        Answer(text: "Environ 14 mètres", isCorrect: true),
        Answer(text: "Environ 28 mètres", isCorrect: false),
        Answer(text: "Environ 7 mètres", isCorrect: false),
        Answer(text: "Environ 50 mètres", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 18,
      question: "Ce panneau signale :",
      imagePath: "assets/images/questions/q18.png",
      answers: [
        Answer(text: "Un virage dangereux", isCorrect: true),
        Answer(text: "Une descente", isCorrect: false),
        Answer(text: "Une route glissante", isCorrect: false),
        Answer(text: "Un rétrécissement", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 19,
      question: "Dépassement interdit si :",
      imagePath: "assets/images/questions/q19.png",
      answers: [
        Answer(text: "Ligne continue", isCorrect: true),
        Answer(text: "Ligne discontinue", isCorrect: false),
        Answer(text: "Route large", isCorrect: false),
        Answer(text: "Absence de panneau", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 20,
      question: "Nombre de points sur le permis probatoire :",
      imagePath: "assets/images/questions/q20.png",
      answers: [
        Answer(text: "6 points", isCorrect: true),
        Answer(text: "12 points", isCorrect: false),
        Answer(text: "3 points", isCorrect: false),
        Answer(text: "8 points", isCorrect: false),
      ],
    ),

    // Questions 21-30 : Sécurité routière
    TestQuestion(
      id: 21,
      question: "Port de la ceinture obligatoire :",
      imagePath: "assets/images/questions/q21.png",
      answers: [
        Answer(text: "Pour tous les passagers", isCorrect: true),
        Answer(text: "Seulement à l'avant", isCorrect: false),
        Answer(text: "Seulement en ville", isCorrect: false),
        Answer(text: "Pas obligatoire à l'arrière", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 22,
      question: "Angle mort : qu'est-ce que c'est ?",
      imagePath: "assets/images/questions/q22.png",
      answers: [
        Answer(text: "Zone non visible dans les rétroviseurs", isCorrect: true),
        Answer(text: "Zone interdite", isCorrect: false),
        Answer(text: "Zone de stationnement", isCorrect: false),
        Answer(text: "Virage sans visibilité", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 23,
      question: "Vitesse en agglomération :",
      imagePath: "assets/images/questions/q23.png",
      answers: [
        Answer(text: "50 km/h", isCorrect: true),
        Answer(text: "30 km/h", isCorrect: false),
        Answer(text: "70 km/h", isCorrect: false),
        Answer(text: "90 km/h", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 24,
      question: "Téléphone au volant :",
      imagePath: "assets/images/questions/q24.png",
      answers: [
        Answer(text: "Interdit, même avec kit mains libres", isCorrect: true),
        Answer(text: "Autorisé avec oreillette", isCorrect: false),
        Answer(text: "Autorisé si bref", isCorrect: false),
        Answer(text: "Autorisé à l'arrêt", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 25,
      question: "Ce panneau indique :",
      imagePath: "assets/images/questions/q25.png",
      answers: [
        Answer(text: "Passage à niveau", isCorrect: true),
        Answer(text: "Pont mobile", isCorrect: false),
        Answer(text: "Voie ferrée", isCorrect: false),
        Answer(text: "Danger", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 26,
      question: "Pression des pneus : à vérifier :",
      imagePath: "assets/images/questions/q26.png",
      answers: [
        Answer(text: "Une fois par mois", isCorrect: true),
        Answer(text: "Une fois par an", isCorrect: false),
        Answer(text: "Jamais nécessaire", isCorrect: false),
        Answer(text: "Seulement en été", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 27,
      question: "Feux de brouillard : quand les utiliser ?",
      imagePath: "assets/images/questions/q27.png",
      answers: [
        Answer(text: "En cas de brouillard ou neige", isCorrect: true),
        Answer(text: "La nuit", isCorrect: false),
        Answer(text: "En ville", isCorrect: false),
        Answer(text: "Toujours", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 28,
      question: "Contrôle technique obligatoire tous les :",
      imagePath: "assets/images/questions/q28.png",
      answers: [
        Answer(text: "2 ans", isCorrect: true),
        Answer(text: "1 an", isCorrect: false),
        Answer(text: "5 ans", isCorrect: false),
        Answer(text: "3 ans", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 29,
      question: "Gilet jaune obligatoire :",
      imagePath: "assets/images/questions/q29.png",
      answers: [
        Answer(text: "Oui, dans l'habitacle", isCorrect: true),
        Answer(text: "Non, pas obligatoire", isCorrect: false),
        Answer(text: "Seulement dans le coffre", isCorrect: false),
        Answer(text: "Seulement pour motos", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 30,
      question: "Triangle de signalisation : distance de placement :",
      imagePath: "assets/images/questions/q30.png",
      answers: [
        Answer(text: "30 mètres minimum", isCorrect: true),
        Answer(text: "10 mètres", isCorrect: false),
        Answer(text: "50 mètres", isCorrect: false),
        Answer(text: "Pas de distance imposée", isCorrect: false),
      ],
    ),

    // Questions 31-40 : Situations pratiques
    TestQuestion(
      id: 31,
      question: "Dans un rond-point, je dois :",
      imagePath: "assets/images/questions/q31.png",
      answers: [
        Answer(
            text: "Céder le passage aux véhicules déjà engagés",
            isCorrect: true),
        Answer(text: "Avoir la priorité", isCorrect: false),
        Answer(text: "M'arrêter systématiquement", isCorrect: false),
        Answer(text: "Klaxonner", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 32,
      question: "Arrêt d'urgence sur autoroute :",
      imagePath: "assets/images/questions/q32.png",
      answers: [
        Answer(
            text: "Sur la bande d'arrêt d'urgence uniquement", isCorrect: true),
        Answer(text: "Sur la voie de droite", isCorrect: false),
        Answer(text: "N'importe où", isCorrect: false),
        Answer(text: "Interdit", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 33,
      question: "Dépassement par la droite :",
      imagePath: "assets/images/questions/q33.png",
      answers: [
        Answer(text: "Interdit sauf cas particuliers", isCorrect: true),
        Answer(text: "Toujours autorisé", isCorrect: false),
        Answer(text: "Autorisé en ville", isCorrect: false),
        Answer(text: "Obligatoire", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 34,
      question: "Enfant de moins de 10 ans :",
      imagePath: "assets/images/questions/q34.png",
      answers: [
        Answer(text: "Doit être à l'arrière", isCorrect: true),
        Answer(text: "Peut être à l'avant", isCorrect: false),
        Answer(text: "Pas de restriction", isCorrect: false),
        Answer(text: "Sans ceinture possible", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 35,
      question: "Aquaplaning : que faire ?",
      imagePath: "assets/images/questions/q35.png",
      answers: [
        Answer(
            text: "Lever le pied, ne pas freiner brutalement", isCorrect: true),
        Answer(text: "Freiner fort", isCorrect: false),
        Answer(text: "Accélérer", isCorrect: false),
        Answer(text: "Braquer", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 36,
      question: "Perte de points : récupération automatique après :",
      imagePath: "assets/images/questions/q36.png",
      answers: [
        Answer(text: "3 ans sans infraction", isCorrect: true),
        Answer(text: "1 an", isCorrect: false),
        Answer(text: "5 ans", isCorrect: false),
        Answer(text: "Impossible", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 37,
      question: "Feux de route : à utiliser :",
      imagePath: "assets/images/questions/q37.png",
      answers: [
        Answer(text: "Hors agglomération la nuit", isCorrect: true),
        Answer(text: "En ville", isCorrect: false),
        Answer(text: "Le jour", isCorrect: false),
        Answer(text: "Jamais", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 38,
      question: "Temps de réaction moyen :",
      imagePath: "assets/images/questions/q38.png",
      answers: [
        Answer(text: "1 seconde", isCorrect: true),
        Answer(text: "0,5 seconde", isCorrect: false),
        Answer(text: "2 secondes", isCorrect: false),
        Answer(text: "3 secondes", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 39,
      question: "Stationnement gênant :",
      imagePath: "assets/images/questions/q39.png",
      answers: [
        Answer(text: "Amende + fourrière possible", isCorrect: true),
        Answer(text: "Pas de sanction", isCorrect: false),
        Answer(text: "Simple avertissement", isCorrect: false),
        Answer(text: "Amende seulement", isCorrect: false),
      ],
    ),
    TestQuestion(
      id: 40,
      question: "Alcool au volant : sanction en cas de récidive :",
      imagePath: "assets/images/questions/q40.png",
      answers: [
        Answer(text: "Annulation du permis", isCorrect: true),
        Answer(text: "Amende seulement", isCorrect: false),
        Answer(text: "Stage de sensibilisation", isCorrect: false),
        Answer(text: "Retrait de 3 points", isCorrect: false),
      ],
    ),
  ];
}
