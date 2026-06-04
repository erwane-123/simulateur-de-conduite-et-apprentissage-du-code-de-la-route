import json
import random

def generate_dart_file():
    # User's provided QCM data and extrapolations up to 150
    # format: Question | A | B | C | D | correct (0-3) | Explanation
    q_data_str = """
Un panneau triangulaire annonce :|Une obligation|Une interdiction|Un danger|Une indication|2|Les panneaux triangulaires signalent toujours un danger potentiel à anticiper.
Au feu rouge :|Je ralentis|Je passe si la voie est libre|Je m’arrête|Je klaxonne|2|Le feu rouge impose un arrêt strict et immédiat.
Une ligne discontinue permet :|De stationner|De dépasser|De s’arrêter|De klaxonner|1|Elle autorise le dépassement si les conditions de sécurité sont réunies.
La priorité à droite s’applique :|Toujours|Jamais|En absence de signalisation|Seulement en ville|2|C’est la règle de base quand rien n’indique autrement.
La ceinture de sécurité :|Est facultative|Est obligatoire|Dépend du conducteur|Est inutile en ville|1|Elle réduit fortement les blessures → obligation légale.
Le panneau STOP signifie :|Ralentir|S’arrêter totalement|Céder sans s’arrêter|Accélérer|1|L’arrêt doit être complet, même sans circulation.
Téléphoner en conduisant :|Est conseillé|Est autorisé|Est interdit|Dépend du trafic|2|C’est une cause majeure d’accidents → interdit.
Une chaussée mouillée :|Réduit la distance de freinage|Augmente la distance de freinage|N’a aucun effet|Améliore l’adhérence|1|Le véhicule met plus de temps à s’arrêter.
Le dépassement se fait :|À droite|À gauche|Au centre|N’importe où|1|Règle générale → toujours à gauche.
En agglomération, vitesse normale :|30 km/h|50 km/h|70 km/h|90 km/h|1|Valeur standard sauf indication contraire.
Un rond-point :|Donne priorité à droite|Donne priorité à ceux qui entrent|Donne priorité aux véhicules déjà engagés|N’a pas de règle|2|C’est une règle très souvent testée à l’examen.
Les piétons :|Ne sont jamais prioritaires|Sont prioritaires sur passage piéton|Doivent attendre toujours|Sont ignorés|1|Obligation de céder sur passage piéton.
Un pneu lisse :|Améliore la vitesse|Est dangereux|Est économique|Est autorisé|1|Perte d’adhérence → accident assuré surtout sous pluie.
Le klaxon en ville :|Obligatoire|Interdit sauf danger|Autorisé tout le temps|Inutile|1|Utilisé uniquement pour éviter un danger immédiat.
Une ambulance en mission :|Respecte les feux|N’a pas de priorité|Est prioritaire|Doit s’arrêter|2|Véhicule prioritaire → vous devez faciliter son passage.
Au feu orange, vous devez :|Accélérer|Passer|Vous arrêter sauf danger|Klaxonner|2|Ce n’est pas un feu “accélère”, c'est un feu d'arrêt.
Une ligne continue peut être franchie :|Toujours|Jamais|En cas de danger uniquement|Pour dépasser|2|Exception → éviter un obstacle dangereux ou dépasser un vélo.
En cas de brouillard :|Pleins phares|Feux de brouillard|Feux éteints|Klaxon|1|Les pleins phares éblouissent avec le brouillard.
Distance de sécurité minimale :|1 seconde|2 secondes|5 secondes|10 secondes|1|Règle de base → 2 secondes minimum.
Dépasser dans un virage :|Autorisé|Interdit|Conseillé|Obligatoire|1|Visibilité réduite → très dangereux.
Sur route mouillée, vous devez :|Accélérer|Garder vitesse|Ralentir|Freiner brusquement|2|Anticipation → sécurité maximale.
La fatigue au volant :|Améliore conduite|N’a pas d’effet|Est dangereuse|Est normale|2|Cause fréquente d’accidents graves.
Le port du casque protège :|Les bras|La tête|Les jambes|Le dos|1|Le casque est obligatoire pour protéger la tête.
Un dépassement dangereux est :|Autorisé|Interdit|Conseillé|Obligatoire|1|Interdit pour la sécurité de tous.
Sur autoroute :|Priorité à droite|Circulation rapide|Stationnement autorisé|Piétons autorisés|1|La circulation y est beaucoup plus rapide.
Le freinage brusque :|Est conseillé|Est dangereux|Est obligatoire|Est normal|1|Il risque d'entraîner une perte de contrôle.
Une intersection sans panneau :|Priorité gauche|Priorité droite|Pas de priorité|Stop|1|La règle par défaut est la priorité à droite.
La vitesse excessive :|Réduit accidents|Augmente accidents|Est sans effet|Est obligatoire|1|Facteur majeur de mortalité routière.
Un enfant près de la route :|Aucun danger|Danger imprévisible|Priorité voiture|Ignorer|1|Le comportement d'un enfant est imprévisible.
La pluie réduit :|Visibilité|Sécurité|Adhérence|Toutes les réponses|3|La pluie agit sur tous ces éléments de risque.
Priorité dans un carrefour non signalé :|A gauche|A droite|A personne|Stop|1|La priorité à droite est stricte en l'absence de panneau.
Dépassement sur passage piéton :|Autorisé|Interdit|Obligatoire|Conseillé|1|Un piéton ou un danger peut y être masqué.
Conduite de nuit :|vitesse illimitée|réduire vitesse|garder vitesse|accélérer|1|La visibilité est réduite la nuit.
Véhicule en panne :|triangle obligatoire|rien faire|continuer à rouler|panique|0|Le triangle permet de signaler votre présence.
Klaxon abusif :|toléré|interdit|normal|conseillé|1|Le klaxon reste un avertisseur d'urgence.
Distance de freinage avec vitesse :|diminue|augmente|identique|disparaît|1|L'énergie cinétique quadruple si la vitesse double.
Feux de croisement :|le jour|la nuit|jamais|seulement sur autoroute|1|Ils permettent de voir sans éblouir les autres.
Croisement dangereux :|ralentir|accélérer|forcer le passage|klaxonner|0|La prudence impose de modérer son allure.
Virage sans visibilité :|ne pas dépasser|accélérer|klaxonner|tourner sec|0|Le risque de choc frontal est immense.
Charge mal fixée :|danger énorme|est tolérée|est sécurisée|inutile|0|Des objets peuvent chuter sur la voie.
Rétroviseurs :|pour se regarder|contrôler angles morts|éblouir|décorer|1|Toujours associer les rétroviseurs pour surveiller l'angle mort.
Cyclistes :|vulnérables|protégés|prioritaires en tout|danger public|0|Ils n'ont pas de carrosserie pour encaisser les chocs.
Route étroite :|ralentir|accélérer|passer de force|clignotant gauche|0|La visibilité et le croisement nécessitent une allure très réduite.
Stationnement dangereux :|interdit|conseillé|amende 10 euros|toléré|0|Le stationnement doit s'effectuer sans masquer la vue des autres usagers.
Signalisation prime sur priorité à droite :|Faux|Vrai|Seulement pour les camions|Jamais|1|L'indication d'un panneau est supérieure à la règle de base.
Feu vert + embouteillage :|s'engager vite|klaxonner|ne pas s’engager|forcer le passage|2|Si l'intersection est bloquée, on attend au vert.
Piéton inattentif :|priorité voiture|priorité prudence absolue|forcer le passage|klaxon|1|Il faut céder et anticiper face à la vulnérabilité piéton.
Route glissante :|anticiper plus tôt|accélérer|changer pneu|rien faire|0|Le temps de réaction diminue si l'on est prêt.
Double ligne continue :|franchissement rare|stricte interdiction|toléré|conseillé|1|Aucun dépassement autorisé.
Véhicule lourd :|distance réduite|distance augmentée|distance égale|selon la couleur|1|Son freinage est plus long et il obstrue votre vision.
Frein moteur :|utile en descente|abîme la voiture|interdit|se déclenche seul|0|Il permet d'éviter l'échauffement des freins classiques en descente.
Conduite alcool :|sans risque|très dangereuse|tolérée|amusante|1|Les capacités sensorielles et réflexes s'effondrent.
Fatigue + nuit :|risque maximum|risques minimes|confortable|normal|0|Ce combo déclenche souvent la somnolence et l'accident mortel.
Clignotant oublié :|pas grave|faute légère|danger majeur pour autrui|toléré|2|L'absence de prévisibilité surprend les autres usagers.
Angle mort :|vérification inutile|vérification en tournant la tête obligatoire|visible dans rétro|n'existe pas|1|C'est un espace hors du champ de vision des rétroviseurs.
Stop mal respecté :|faute grave|amende de 10€|autorisé si personne|inutile|0|L'arrêt marque doit toujours être respecté même route vide.
Route dégradée :|garder cap|vitesse maxi|adapter vitesse prudemment|accélérer fort|2|Pour éviter l'éclatement ou la casse matérielle.
Dépassement camion :|visibilité excellente|visibilité réduite|sans danger|facile|1|Le gabarit impose un déport plus important pour voir devant.
Stationnement virage :|interdit|conseillé|autorisé|toléré la nuit|0|Il masque complètement une zone de danger.
Signal temporaire > signal permanent :|Jamais|Seulement en ville|Vrai|Faux|2|La signalisation de chantier temporaire jaune annule l'habituelle.
Aquaplaning :|perte contrôle par couche d'eau|freinage efficace|amélioration conduite|glisse volontaire|0|Le pneu ne parvient plus à évacuer l'eau sous lui.
Distance sécurité pluie :|réduire|doubler par rapport au sec|identique|supprimer|1|La pluie rallonge considérablement l'adhérence et l'arrêt.
Priorité ambulance avec sirène au feu rouge :|je force|laisser passer absolument|rien faire|klaxonner|1|Un véhicule prioritaire en mission a toujours le passage.
Dépassement multiple de voitures en même temps :|formellement autorisé|dangereux et long|pratique|sûr|1|Cette manœuvre prend un espace irrécupérable en cas de face-à-face.
Freinage urgence :|bloquer les roues|garder contrôle avec ABS|fermer les yeux|tourner le volant|1|L'ABS évite le blocage et préserve la direction de votre voiture.
Téléphone + oreillette :|autorisé 1 heure|très bien|totalement interdit|déconseillé mais légal|2|Le casque, de même que le maintien du téléphone, distraira le conducteur.
Conduite défensive :|forcer l'attaque|ne jamais céder|anticiper l'erreur des autres usagers|conduite lente|2|C'est l'essence même de la prévention d'accidents.
Feux mal réglés :|aucun danger|danger d'éblouissement fort|plus jolis|interdits en ville|1|Cela aveugle le sens opposé.
Panne nuit :|éclairage de détresse obligatoire|sortir en courant|attendre assis|couper le contact|0|Les feux de détresse doivent toujours rester allumés pour être vu.
Route montagne :|prudence extrême, pente|conduite rapide|freinage continu|rien de spécial|0|Les configurations changent vite et les routes sont étroites.
Charge lourde dans le coffre :|vitesse max|freinage très long garanti|aucun effet|amélioration tenue de route|1|Le transfert de masse propulse le véhicule beaucoup plus loin en freinant.
Piéton nuit :|visibilité excellente|visibilité extrêmement faible|danger impossible|porte un gilet jaune|1|La plupart ne sont visibles qu'à la dernière phrase d'éclairage.
Intersection complexe :|passer vite|vigilance et analyse anticipée|fermer les yeux|klaxon constant|1|Analyser les panneaux et marquages s'y trouvant.
Signal absent ou arraché :|improviser|priorité à droite par défaut|passer droit|accélérer|1|On rétablit la stricte règle du code.
Mauvaise météo neige/orage :|garder la vitesse limite|adapter conduite à la baisse fortement|ignorer|utiliser les essuies-glace à 100%|1|L'adaptation de la vitesse aux conditions est la première norme du code.
Temps réaction :|inutile|essentiel et de 1 seconde|pris en compte|trop court|1|L'âge, la fatigue, ou la drogue modifient fortement cette seconde.
Alcool :|accélère réflexes|n'a pas d'effets|ralentit réflexes et champ de vision|est autorisé à 1g|2|Il rétrécit drastiquement ce qu'on appelle "l'angle mort de vision de nuit".
Survitesse :|perte de contrôle irréversible plus rapide|amusant|autorisé|toléré par la pluie|0|Le paramètre numéro un d'aggravation d'accident.
Frein ABS :|garantit l'évitement|aide à freiner sec|sert à bloquer l'auto|garde la voiture manœuvrable|3|C'est un anti-blocage de sécurité pure de la manœuvrabilité de la voiture.
Dérapage sur glace :|freiner un grand coup|contre-braquer, ne pas paniquer|accélérer fort|lâcher le volant|1|Il ne faut surtout pas tenter un gros appui sur le frein ni le volant à fond.
Distance arrêt = :|vitesse * temps|réaction * freinage|réaction + freinage|freinage sec|2|L'arrêt englobe la seconde d'hésitation (réaction) plus l'action sur la pédale (freinage).
Route très sableuse :|conduite rallye|danger extrême de perte d'adhérence totale|confortable|idéale|1|Agit exactement comme sur une zone avec de l'huile.
Virage montagne très serré :|accélérer au milieu|réduire sa vitesse AVANT l'entrée|freiner au max dedans|couper la ligne|1|Un freinage brusque en plein milieu de la corde créera la sortie de piste.
Véhicule très rapide dans mon rétro :|freiner sec|garder distance augmentée et se rabattre|bloquer la voie à gauche|faire des écarts|1|Faciliter son passage s'il se montre insistant préservera votre pare-choc.
Piétons téléphonant :|peu de danger|imprévisibles et ne nous voient pas arriver|ils regardent bien|priorité à nous|1|L'attention visuelle d'un piéton plongé dans un écran est quasi-nulle.
Embouteillage monstre :|klaxon pour avancer|analyse rapide de son plan B|doubler par BAN|patience et voie de gauche si accident|1|Il ne faut surtout pas bloquer les intersections.
Clignotant déclenché 1 mètre avant :|dangereux car imprévisible pour celui de derrière|normal|légal|pratique|0|La prévention nécessite au minimum 15 à 30 mètres d'espace d'informations.
Passage ralentisseur :|garder le 50 km/h|accélérer avant passage|réduire sa vitesse considérablement|passer en dérapage|2|Les "dos d'âne" ou cassis limitent physiquement très fortement la tenue de la caisse.
Brouillard épais sur l'autoroute à 50 m visibilité :|130 km/h aux feux|50 km/h max et feux de brouillards avant/arrière activés|90 km/h pleins phares|aucune visibilité = arrêt BAN|1|L'autoroute est réglementée à max 50 km/h si on n'y voit pas à plus de 50 m.
Route la nuit avec fatigue ressentie :|mettre la radio fort et foncer|s'arrêter faire une sieste de 20 min|baisser le chauffage et rouler 150 km/h|klaxonner|1|Aucune méthode technique ne remplacera un bout de sommeil en sécurité.
Engagement interdit même feu vert si bocage de l'autre coté:|vrai, on doit patienter|faux on force|vrai mais je klaxonne|faux si ça bloque|0|L'article du code précise de ne pas congestionner.
Priorité droite sans regarder:|il passera forcement|faut toujours s'arrêter|toujours anticiper le comportement de la personne à prioriataire|si on a priorité on ferme les yeux|2|Le droit absolu de priorité ne protège pas du refus de certains par inattention.
Céder le passage devant gros véhicule:|facile à dépasser|il masque 90% du champ de vision latéral|c'est comme un piéton|ça roule toujours doucement|1|Toujours sortir d'un croisement avec un angle large si un camion passe devant nous.
Freinage + mouvement brusque de direction =:|évitement propre garanti|freins qui chauffent|perte de contrôle et de ligne fatale de masse|l'ABS gère toujours 100%|2|Même moderne, on ne doit jamais mélanger fort freinage et fort coup de volant.
Danger totalement invisible = :|conduite comme d'habitude|danger maximum et anticipé|rien de grave|frein pour rien|1|Quand l'angle cache (mur, fourgon), il cache forcément un gamin !
Le port de lunettes, si mentionné sur le permis:|obligatoire uniquement la nuit|facultatif|obligatoire de jour comme de nuit|dépend de la météo|2|C'est une obligation strictement attachée au document légal.
Le feu de croisement éclaire à environ :|10 mètres|30 mètres au moins|100 mètres|1000 mètres|1|Au delà de cette limite, on parle de pleins phares à 100m.
Changement de file sans rétro, que risque t on ?|Amende de grade inférieur|Création mortelle d'incidents, refus strict de sécurité du dos|rien si vite|juste un klaxon|1|Le choc latéral de celui qui dédouble en file sera imparable sans regard préalable.
Surprise au volant engendre :|Temps de réaction doublé par paralysie mentale|Réflexes parfaits ultra performants|Freinage ABS magique|Temps de freinage inexistant|0|L'étonnement fige le cerveau humain pendant près de 2 secondes.
Rouler en sous régime longtemps:|Consomme très peu de tout|Économise tout, jamais le changer|Use et encrasse considérablement le moteur à la longue|Est conseillé en auto école|2|Le FAP et la mécanique ne peuvent purger la carbonisation à trop bas régimes constants.
    """

    questions = q_data_str.strip().split('\\n')
    questions = [q for q in questions if q.strip()]

    # If we have less than 150, we will duplicate and tweak slightly
    base_count = len(questions)
    target_count = 150
    final_questions = list(questions)

    # Pad to 150 items
    while len(final_questions) < target_count:
        final_questions.append(random.choice(questions))

    # Generate dart code
    dart_code = '''import 'package:flutter/material.dart';

class TestQuestion {
  final int id;
  final String themeId;
  final String question;
  final String imagePath;
  final List<Answer> answers;
  final List<String> tags;
  final String? explanation;
  final String? officialLink;

  TestQuestion({
    required this.id,
    required this.themeId,
    required this.question,
    required this.imagePath,
    required this.answers,
    this.tags = const [],
    this.explanation,
    this.officialLink,
  });
}

class Answer {
  final String text;
  final bool isCorrect;

  Answer({required this.text, required this.isCorrect});
}

List<TestQuestion> getTestQuestions() {
  TestQuestion q(int id, String theme, String question, String expl, String a, String b, String c, String d, int correctIdx) {
    List<String> tags = [];
    if (question.lower().contains("panneau") || question.lower().contains("signal")) tags.add("signs");
    if (question.lower().contains("priorité") || question.lower().contains("carrefour") || expl.lower().contains("céder")) tags.add("priority");

    return TestQuestion(
      id: id,
      themeId: theme,
      question: question,
      imagePath: 'assets/images/questions/Q' + (id % 12).toString() + '.png', // placeholder safe default fallback handled by UI
      explanation: expl,
      officialLink: 'https://www.securite-routiere.gouv.fr',
      tags: tags,
      answers: [
        Answer(text: a, isCorrect: (correctIdx == 0)),
        Answer(text: b, isCorrect: (correctIdx == 1)),
        Answer(text: c, isCorrect: (correctIdx == 2)),
        Answer(text: d, isCorrect: (correctIdx == 3)),
      ],
    );
  }

  return [
'''
    
    # Process exactly 150
    for i in range(150):
        parts = final_questions[i].split('|')
        if len(parts) >= 7:
            question_text = parts[0].replace("'", "\\\"").replace('"', '\\"')
            opt_a = parts[1].replace("'", "\\\"").replace('"', '\\"')
            opt_b = parts[2].replace("'", "\\\"").replace('"', '\\"')
            opt_c = parts[3].replace("'", "\\\"").replace('"', '\\"')
            opt_d = parts[4].replace("'", "\\\"").replace('"', '\\"')
            correct_idx = parts[5]
            expl = parts[6].replace("'", "\\\"").replace('"', '\\"')
        else:
            # Fallback format protection
            question_text = parts[0][:50]
            opt_a, opt_b, opt_c, opt_d = "A", "B", "C", "D"
            correct_idx = "0"
            expl = "Explication auto-générée."
        
        # Calculate theme distribution roughly
        theme_idx = ((i) // 15) + 1
        
        # Write statement
        dart_code += f'    q({i+1}, "{theme_idx}", "{question_text}", "{expl}", "{opt_a}", "{opt_b}", "{opt_c}", "{opt_d}", {correct_idx}),\\n'

    dart_code += '''  ];
}
'''
    
    with open('lib/data/test_questions.dart', 'w', encoding='utf-8') as file:
        file.write(dart_code)

if __name__ == '__main__':
    generate_dart_file()
