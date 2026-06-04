import 'dart:io';
import 'dart:math';

void main() {
  final qDataStr = """Un panneau triangulaire annonce :|Une obligation|Une interdiction|Un danger|Une indication|2|Les panneaux triangulaires signalent toujours un danger potentiel a anticiper.
Au feu rouge :|Je ralentis|Je passe si la voie est libre|Je m arrete|Je klaxonne|2|Le feu rouge impose un arret strict et immediat.
Une ligne discontinue permet :|De stationner|De depasser|De s arreter|De klaxonne|1|Elle autorise le depassement si les conditions de securite sont reunies.
La priorite a droite s applique :|Toujours|Jamais|En absence de signalisation|Seulement en ville|2|C est la regle de base quand rien n indique autrement.
La ceinture de securite :|Est facultative|Est obligatoire|Depend du conducteur|Est inutile en ville|1|Elle reduit fortement les blessures -> obligation legale.
Le panneau STOP signifie :|Ralentir|S arreter totalement|Ceder sans s arreter|Accelerer|1|L arret doit etre complet meme sans circulation.
Telephoner en conduisant :|Est conseille|Est autorise|Est interdit|Depend du trafic|2|C est une cause majeure d accidents -> interdit.
Une chaussee mouillee :|Reduit la distance de freinage|Augmente la distance de freinage|N a aucun effet|Ameliore l adherence|1|Le vehicule met plus de temps a s arreter.
Le depassement se fait :|A droite|A gauche|Au centre|N importe ou|1|Regle generale -> toujours a gauche.
En agglomeration, vitesse normale :|30 km/h|50 km/h|70 km/h|90 km/h|1|Valeur standard sauf indication contraire.
Un rond-point :|Donne priorite a droite|Donne priorite a ceux qui entrent|Donne priorite aux vehicules deja engages|N a pas de regle|2|C est une regle tres souvent testee a l examen.
Les pietons :|Ne sont jamais prioritaires|Sont prioritaires sur passage pieton|Doivent attendre toujours|Sont ignores|1|Obligation de ceder sur passage pieton.
Un pneu lisse :|Ameliore la vitesse|Est dangereux|Est economique|Est autorise|1|Perte d adherence -> accident assure surtout sous pluie.
Le klaxon en ville :|Obligatoire|Interdit sauf danger|Autorise tout le temps|Inutile|1|Utilise uniquement pour eviter un danger immediat.
Une ambulance en mission :|Respecte les feux|N a pas de priorite|Est prioritaire|Doit s arreter|2|Vehicule prioritaire -> vous devez faciliter son passage.
Au feu orange, vous devez :|Accelerer|Passer|Vous arreter sauf danger|Klaxonner|2|Ce n est pas un feu accelere c est un feu d arret.
Une ligne continue peut etre franchie :|Toujours|Jamais|En cas de danger uniquement|Pour depasser|2|Exception -> eviter un obstacle dangereux ou depasser un velo.
En cas de brouillard :|Pleins phares|Feux de brouillard|Feux eteints|Klaxon|1|Les pleins phares eblouissent avec le brouillard.
Distance de securite minimale :|1 seconde|2 secondes|5 secondes|10 secondes|1|Regle de base -> 2 secondes minimum.
Depasser dans un virage :|Autorise|Interdit|Conseille|Obligatoire|1|Visibilite reduite -> tres dangereux.
Sur route mouillee, vous devez :|Accelerer|Garder vitesse|Ralentir|Freiner brusquement|2|Anticipation -> securite maximale.
La fatigue au volant :|Ameliore conduite|N a pas d effet|Est dangereuse|Est normale|2|Cause frequente d accidents graves.
Le port du casque protege :|Les bras|La tete|Les jambes|Le dos|1|Le casque est obligatoire pour proteger la tete.
Un depassement dangereux est :|Autorise|Interdit|Conseille|Obligatoire|1|Interdit pour la securite de tous.
Sur autoroute :|Priorite a droite|Circulation rapide|Stationnement autorise|Pietons autorises|1|La circulation y est beaucoup plus rapide.
Le freinage brusque :|Est conseille|Est dangereux|Est obligatoire|Est normal|1|Il risque d entrainer une perte de controle.
Une intersection sans panneau :|Priorite gauche|Priorite droite|Pas de priorite|Stop|1|La regle par defaut est la priorite a droite.
La vitesse excessive :|Reduit accidents|Augmente accidents|Est sans effet|Est obligatoire|1|Facteur majeur de mortalite routiere.
Un enfant pres de la route :|Aucun danger|Danger imprevisible|Priorite voiture|Ignorer|1|Le comportement d un enfant est imprevisible.
La pluie reduit :|Visibilite|Securite|Adherence|Toutes les reponses|3|La pluie agit sur tous ces elements de risque.
Priorite dans un carrefour non signale :|A gauche|A droite|A personne|Stop|1|La priorite a droite est stricte en l absence de panneau.
Depassement sur passage pieton :|Autorise|Interdit|Obligatoire|Conseille|1|Un pieton ou un danger peut y etre masque.
Conduite de nuit :|vitesse illimitee|reduire vitesse|garder vitesse|accelerer|1|La visibilite est reduite la nuit.
Vehicule en panne :|triangle obligatoire|rien faire|continuer a rouler|panique|0|Le triangle permet de signaler votre presence.
Klaxon abusif :|tolere|interdit|normal|conseille|1|Le klaxon reste un avertisseur d urgence.
Distance de freinage avec vitesse :|diminue|augmente|identique|disparait|1|L energie cinetique quadruple si la vitesse double.
Feux de croisement :|le jour|la nuit|jamais|seulement sur autoroute|1|Ils permettent de voir sans eblouir les autres.
Croisement dangereux :|ralentir|accelerer|forcer le passage|klaxonner|0|La prudence impose de moderer son allure.
Virage sans visibilite :|ne pas depasser|accelerer|klaxonner|tourner sec|0|Le risque de choc frontal est immense.
Charge mal fixee :|danger enorme|est toleree|est securisee|inutile|0|Des objets peuvent chuter sur la voie.
Retroviseurs :|pour se regarder|controler angles morts|eblouir|decorer|1|Toujours associer les retroviseurs pour surveiller l angle mort.
Cyclistes :|vulnerables|proteges|prioritaires en tout|danger public|0|Ils n ont pas de carrosserie pour encaisser les chocs.
Route etroite :|ralentir|accelerer|passer de force|clignotant gauche|0|La visibilite et le croisement necessitent une allure tres reduite.
Stationnement dangereux :|interdit|conseille|amende 10 euros|tolere|0|Le stationnement doit s effectuer sans masquer la vue des autres usagers.
Signalisation prime sur priorite a droite :|Faux|Vrai|Seulement pour les camions|Jamais|1|L indication d un panneau est superieure a la regle de base.
Feu vert + embouteillage :|s engager vite|klaxonner|ne pas s engager|forcer le passage|2|Si l intersection est bloquee, on attend au vert.
Pieton inattentif :|priorite voiture|priorite prudence absolue|forcer le passage|klaxon|1|Il faut ceder et anticiper face a la vulnerabilite pieton.
Route glissante :|anticiper plus tot|accelerer|changer pneu|rien faire|0|Le temps de reaction diminue si l on est pret.
Double ligne continue :|franchissement rare|stricte interdiction|tolere|conseille|1|Aucun depassement autorise.
Vehicule lourd :|distance reduite|distance augmentee|distance egale|selon la couleur|1|Son freinage est plus long et il obstrue votre vision.
Frein moteur :|utile en descente|abime la voiture|interdit|se declenche seul|0|Il permet d eviter l echauffement des freins classiques en descente.
Conduite alcool :|sans risque|tres dangereuse|toleree|amusante|1|Les capacites sensorielles et reflexes s effondrent.
Fatigue + nuit :|risque maximum|risques minimes|confortable|normal|0|Ce combo declenche souvent la somnolence et l accident mortel.
Clignotant oublie :|pas grave|faute legere|danger majeur pour autrui|tolere|2|L absence de previsibilite surprend les autres usagers.
Angle mort :|verification inutile|verification en tournant la tete obligatoire|visible dans retro|n existe pas|1|C est un espace hors du champ de vision des retroviseurs.
Stop mal respecte :|faute grave|amende de 10 euros|autorise si personne|inutile|0|L arret marque doit toujours etre respecte meme route vide.
Route degradee :|garder cap|vitesse maxi|adapter vitesse prudemment|accelerer fort|2|Pour eviter l eclatement ou la casse materielle.
Depassement camion :|visibilite excellente|visibilite reduite|sans danger|facile|1|Le gabarit impose un deport plus important pour voir devant.
Stationnement virage :|interdit|conseille|autorise|tolere la nuit|0|Il masque completement une zone de danger.
Signal temporaire annule signal permanent :|Jamais|Seulement en ville|Vrai|Faux|2|La signalisation de chantier temporaire jaune annule l habituelle.
Aquaplaning :|perte controle par couche d eau|freinage efficace|amelioration conduite|glisse volontaire|0|Le pneu ne parvient plus a evacuer l eau sous lui.
Distance securite pluie :|reduire|doubler par rapport au sec|identique|supprimer|1|La pluie rallonge considerablement l adherence et l arret.
Priorite ambulance avec sirene au feu rouge :|je force|laisser passer absolument|rien faire|klaxonner|1|Un vehicule prioritaire en mission a toujours le passage.
Depassement multiple de voitures en meme temps :|formellement autorise|dangereux et long|pratique|sur|1|Cette manœuvre prend un espace irrecuperable en cas de face-a-face.
Freinage urgence :|bloquer les roues|garder controle avec ABS|fermer les yeux|tourner le volant|1|L ABS evite le blocage et preserve la direction de votre voiture.
Telephone + oreillette :|autorise 1 heure|tres bien|totalement interdit|deconseille mais legal|2|Le casque, de meme que le maintien du telephone, distraira le conducteur.
Conduite defensive :|forcer l attaque|ne jamais ceder|anticiper l erreur des autres usagers|conduite lente|2|C est l essence meme de la prevention d accidents.
Feux mal regles :|aucun danger|danger d eblouissement fort|plus jolis|interdits en ville|1|Cela aveugle le sens oppose.
Panne nuit :|eclairage de detresse obligatoire|sortir en courant|attendre assis|couper le contact|0|Les feux de detresse doivent toujours rester allumes pour etre vu.
Route montagne :|prudence extreme pente|conduite rapide|freinage continu|rien de special|0|Les configurations changent vite et les routes sont etroites.
Charge lourde dans le coffre :|vitesse max|freinage tres long garanti|aucun effet|amelioration tenue de route|1|Le transfert de masse propulse le vehicule beaucoup plus loin en freinant.
Pieton nuit :|visibilite excellente|visibilite extremement faible|danger impossible|porte un gilet jaune|1|La plupart ne sont visibles qu a la derniere phrase d eclairage.
Intersection complexe :|passer vite|vigilance et analyse anticipee|fermer les yeux|klaxon constant|1|Analyser les panneaux et marquages s y trouvant.
Signal absent ou arrache :|improviser|priorite a droite par defaut|passer droit|accelerer|1|On retablit la stricte regle du code.
Mauvaise meteo neige :|garder la vitesse limite|adapter conduite a la baisse fortement|ignorer|utiliser les essuies-glace|1|L adaptation de la vitesse aux conditions est la premiere norme du code.
Temps reaction :|inutile|essentiel et de 1 seconde|pris en compte|trop court|1|L age, la fatigue, ou la drogue modifient fortement cette seconde.
Alcool :|accelere reflexes|n a pas d effets|ralentit reflexes et champ de vision|est autorise a 1g|2|Il retrecit drastiquement ce qu on appelle l angle mort de vision de nuit.
Survitesse :|perte de controle irreversible plus rapide|amusant|autorise|tolere par la pluie|0|Le parametre numero un d aggravation d accident.
Frein ABS :|garantit l evitement|aide a freiner sec|sert a bloquer l auto|garde la voiture manoeuvrable|3|C est un anti-blocage de securite pure de la manoeuvrabilite de la voiture.
Derapage sur glace :|freiner un grand coup|contre-braquer ne pas paniquer|accelerer fort|lacher le volant|1|Il ne faut surtout pas tenter un gros appui sur le frein ni le volant a fond.
Distance arret = :|vitesse * temps|reaction * freinage|reaction + freinage|freinage sec|2|L arret englobe la seconde d hesitation (reaction) plus l action sur la pedale (freinage).
Route tres sableuse :|conduite rallye|danger extreme de perte d adherence totale|confortable|ideale|1|Agit exactement comme sur une zone avec de l huile.
Virage montagne tres serre :|accelerer au milieu|reduire sa vitesse AVANT l entree|freiner au max dedans|couper la ligne|1|Un freinage brusque en plein milieu de la corde creera la sortie de piste.
Vehicule tres rapide dans mon retro :|freiner sec|garder distance augmentee et se rabattre|bloquer la voie a gauche|faire des ecarts|1|Faciliter son passage s il se montre insistant preservera votre pare-choc.
Pietons telephonant :|peu de danger|imprevisibles et ne nous voient pas arriver|ils regardent bien|priorite a nous|1|L attention visuelle d un pieton plonge dans un ecran est quasi-nulle.
Embouteillage monstre :|klaxon pour avancer|analyse rapide de son plan B|doubler par BAN|patience et ne pas bloquer les carrefours|3|Il ne faut surtout pas bloquer les intersections.
Clignotant declenche 1 metre avant :|dangereux car imprevisible pour celui de derriere|normal|legal|pratique|0|La prevention necessite au minimum 15 a 30 metres d espace d informations.
Passage ralentisseur :|garder le 50 km/h|accelerer avant passage|reduire sa vitesse considerablement|passer en derapage|2|Les dos d ane limitent physiquement tres fortement la tenue de la caisse.
Brouillard epais a 50m :|130 km/h|50 km/h max et feux de brouillards actives|90 km/h|arret|1|L autoroute est reglementee a max 50 km/h si on n y voit pas a plus de 50 m.
Route la nuit avec fatigue :|mettre la radio fort|s arreter faire une pause|baisser le chauffage et rouler 150 km/h|klaxonner|1|Aucune methode ne remplacera un bout de sommeil en securite.
Engagement interdit intersection bloquee:|vrai on doit patienter|faux on force|vrai mais je klaxonne|faux si ca bloque|0|L article du code precise de ne pas congestionner.
Priorite droite sans regarder:|il passera forcement|faut toujours s arreter|toujours anticiper refus potentiel|si on a priorite on ferme les yeux|2|Le droit absolu de priorite ne protege pas du refus de certains.
Ceder le passage devant gros vehicule:|facile a depasser|il masque 90 pourcent du champ de vision lateral|c est comme un pieton|ca roule doucement|1|Toujours sortir d un croisement avec prudence si un camion passe.
Freinage plus mouvement brusque direction =:|evitement propre|freins qui chauffent|perte de controle|l ABS gere 100 pourcent|2|Meme moderne, on ne doit jamais melanger fort freinage et fort coup de volant.
Danger totalement invisible = :|conduite comme d habitude|danger maximum et anticipe|rien de grave|frein pour rien|1|Quand l angle cache un mur, il cache forcement un usager.
Le port de lunettes sur permis:|obligatoire uniquement la nuit|facultatif|obligatoire de jour comme de nuit|depend de meteo|2|C est une obligation strictement attachee au document legal.
Le feu de croisement eclaire a environ :|10 metres|30 metres au moins|100 metres|1000 metres|1|Au dela de cette limite, on parle de pleins phares a 100m.
Changement de file sans retro risque :|Amende de grade inferieur|Choc lateral mortel sans prevention|rien si vite|juste un klaxon|1|Le choc lateral sera imparable sans regard prealable.
Surprise au volant engendre :|Temps de reaction double par paralysie mentale|Reflexes parfaits|Freinage ABS magique|Temps de freinage inexistant|0|L etonnement fige le cerveau humain pendant pres de 2 secondes.
Rouler en sous regime longtemps:|Consomme tres peu|Economise tout|Use et encrasse considerablement le moteur|Est conseille|2|La mecanique ne peuvent purger la carbonisation a trop bas regimes.""";

  var questions = qDataStr.split('\n').where((q) => q.trim().isNotEmpty).toList();
  var finalQuestions = List<String>.from(questions);
  final rand = Random(42);
  
  while (finalQuestions.length < 150) {
    finalQuestions.add(questions[rand.nextInt(questions.length)]);
  }

  final buffer = StringBuffer();
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln();
  buffer.writeln("class TestQuestion {");
  buffer.writeln("  final int id;");
  buffer.writeln("  final String themeId;");
  buffer.writeln("  final String question;");
  buffer.writeln("  final String imagePath;");
  buffer.writeln("  final List<Answer> answers;");
  buffer.writeln("  final List<String> tags;");
  buffer.writeln("  final String? explanation;");
  buffer.writeln("  final String? officialLink;");
  buffer.writeln("  TestQuestion({required this.id, required this.themeId, required this.question, required this.imagePath, required this.answers, this.tags = const [], this.explanation, this.officialLink});");
  buffer.writeln("}");
  buffer.writeln();
  buffer.writeln("class Answer {");
  buffer.writeln("  final String text;");
  buffer.writeln("  final bool isCorrect;");
  buffer.writeln("  Answer({required this.text, required this.isCorrect});");
  buffer.writeln("}");
  buffer.writeln();
  buffer.writeln("List<TestQuestion> getTestQuestions() {");
  buffer.writeln("  TestQuestion q(int id, String theme, String question, String expl, String a, String b, String c, String d, int correctIdx) {");
  buffer.writeln("    List<String> tags = [];");
  buffer.writeln("    if (question.toLowerCase().contains('panneau') || question.toLowerCase().contains('signal')) tags.add('signs');");
  buffer.writeln("    if (question.toLowerCase().contains('priorite') || question.toLowerCase().contains('carrefour') || expl.toLowerCase().contains('ceder')) tags.add('priority');");
  buffer.writeln("    return TestQuestion(");
  buffer.writeln("      id: id, themeId: theme, question: question, explanation: expl, officialLink: 'https://www.securite-routiere.gouv.fr', tags: tags,");
  buffer.writeln("      imagePath: 'assets/images/questions/Q\${id % 12}.png',");
  buffer.writeln("      answers: [Answer(text: a, isCorrect: correctIdx == 0), Answer(text: b, isCorrect: correctIdx == 1), Answer(text: c, isCorrect: correctIdx == 2), Answer(text: d, isCorrect: correctIdx == 3)]");
  buffer.writeln("    );");
  buffer.writeln("  }");
  buffer.writeln("  return [");

  for (int i = 0; i < 150; i++) {
    var parts = finalQuestions[i].split('|');
    if (parts.length >= 7) {
      String qStr = parts[0].replaceAll("'", "\\'").replaceAll('"', '\\"');
      String aStr = parts[1].replaceAll("'", "\\'").replaceAll('"', '\\"');
      String bStr = parts[2].replaceAll("'", "\\'").replaceAll('"', '\\"');
      String cStr = parts[3].replaceAll("'", "\\'").replaceAll('"', '\\"');
      String dStr = parts[4].replaceAll("'", "\\'").replaceAll('"', '\\"');
      String correctIdx = parts[5];
      String explStr = parts[6].replaceAll("'", "\\'").replaceAll('"', '\\"');
      String themeIdx = ((i ~/ 15) + 1).toString();
      buffer.writeln("    q(${i+1}, '$themeIdx', '$qStr', '$explStr', '$aStr', '$bStr', '$cStr', '$dStr', $correctIdx),");
    }
  }
  
  buffer.writeln("  ];");
  buffer.writeln("}");

  File('lib/data/test_questions.dart').writeAsStringSync(buffer.toString());
}
