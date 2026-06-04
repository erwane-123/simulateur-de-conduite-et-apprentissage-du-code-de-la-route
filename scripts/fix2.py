import re

explanations = {
    1: "Le panneau a une forme et une couleur spécifiques pour imposer un arrêt total.",
    2: "Le feu rouge impose un arrêt absolu pour laisser passer les autres usagers.",
    3: "La règle générale en agglomération est de 50 km/h pour réduire les risques d'accident.",
    4: "Ce panneau de signalisation indique spécifiquement un passage pour les piétons.",
    5: "Il est important de prévenir suffisamment à l'avance, environ 50 mètres, pour ne pas surprendre.",
    6: "Une ligne continue est infranchissable, il est strictement interdit de la chevaucher ou de la franchir.",
    7: "En l'absence de signalisation, c'est la priorité à droite qui s'applique.",
    8: "Il faut conserver un intervalle de sécurité d'au moins 2 secondes avec le véhicule qui précède.",
    9: "Ce panneau bleu circulaire avec des flèches indique une obligation de contourner par la droite.",
    10: "Le taux limite est de 0,5 g/L de sang (ou 0,2 g/L pour les probatoires). L'option correcte ici ciblait 0,5 g/L.",
    11: "En l'absence de panneau, c'est la règle de la priorité à droite qui prime.",
    12: "Ce panneau d'interdiction (rouge et rond) interdit de tourner à gauche.",
    13: "La période probatoire dure 3 ans (réduite à 2 ans en cas de conduite accompagnée).",
    14: "Sur autoroute, la vitesse maximale autorisée est de 130 km/h par temps sec.",
    15: "Le panneau rond avec fond bleu entrelouré de rouge et barré d'une ligne interdit le stationnement.",
    16: "Le feu jaune (ou orange) impose l'arrêt, sauf si le véhicule est trop près pour s'arrêter en sécurité.",
    17: "La distance de freinage augmente avec le carré de la vitesse (ici environ 14m sur sol sec).",
    18: "Le panneau de danger triangulaire avec une flèche courbée indique un virage dangereux.",
    19: "Le dépassement est strictement interdit si vous devez franchir une ligne continue.",
    20: "Le permis probatoire est initialement doté d'un capital de 6 points.",
    21: "Le port de la ceinture de sécurité est obligatoire pour tous les occupants du véhicule, à l'avant comme à l'arrière.",
    22: "L'angle mort est l'espace qui n'est pas couvert par les rétroviseurs. Il faut tourner la tête pour vérifier.",
    23: "La vitesse en ville est par défaut limitée à 50 km/h.",
    24: "L'usage du téléphone tenu en main, ainsi que le port de tout dispositif à l'oreille, est interdit au volant.",
    25: "Ce panneau triangulaire avec une barrière ou une loco indique un passage à niveau.",
    26: "Pour votre sécurité et limiter la surconsommation, la pression des pneus se vérifie à froid une fois par mois.",
    27: "Les feux de brouillard avant complètent l'éclairage en cas de pluie, neige ou brouillard.",
    28: "Après les 4 premières années du véhicule, le contrôle technique doit s'effectuer tous les 2 ans.",
    29: "Le gilet de haute visibilité doit obligatoirement être à portée de main dans l'habitacle.",
    30: "Le triangle de pré-signalisation doit être posé à une distance minimale de 30 mètres du danger.",
    31: "Le panneau \"cédez le passage\" à l'entrée du rond-point oblige à laisser passer les véhicules déjà engagés.",
    32: "La bande d'arrêt d'urgence est strictement réservée aux cas de panne, accident ou autre urgence majeure.",
    33: "Le dépassement s'effectue toujours par la gauche, sauf cas très exceptionnels (ex. véhicule tournant à gauche).",
    34: "Les enfants de moins de 10 ans doivent être installés dans un dispositif de retenue adapté à l'arrière du véhicule.",
    35: "En cas d'aquaplaning, il faut éviter de braquer ou de freiner brusquement. Il faut lever le pied de l'accélérateur.",
    36: "Une récupération automatique des points est possible après 3 ans sans commettre de nouvelle infraction (selon les cas).",
    37: "Les feux de route (pleins phares) s'utilisent de nuit sur une route non éclairée et en l'absence d'autres usagers.",
    38: "Le temps de réaction moyen d'un conducteur en bonne condition est évalué à 1 seconde.",
    39: "Le stationnement sur un emplacement gênant est passible d'une amende et peut entraîner la mise en fourrière du véhicule.",
    40: "La récidive de conduite sous l'empire d'un état alcoolique entraîne automatiquement l'annulation du permis de conduire."
}

file_path = "c:\\Users\\Romeo\\projet-2026\\code_route_flutter\\lib\\data\\models\\question.dart"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

class_def_pattern = r"(class TestQuestion\s*\{[^\}]*?)(final List<Answer> answers;\s*\})"
replacement = r"\1\2\n  final String? explanation;\n  final List<String> tags;\n  final String? themeId;\n  final String? officialLink;\n"
if "final String? explanation;" not in content:
    content = re.sub(class_def_pattern, replacement, content, count=1)

constructor_pattern = r"(TestQuestion\(\{\s*required this\.id,\s*required this\.question,\s*required this\.imagePath,\s*required this\.answers,)(\s*\}\);)"
if "this.explanation" not in content:
    content = re.sub(constructor_pattern, r"\1\n    this.explanation,\n    this.tags = const [],\n    this.themeId,\n    this.officialLink,\2", content, count=1)

for q_id, expl in explanations.items():
    if f'explanation: "{expl}"' in content:
        continue
    content = re.sub(
        rf"(id:\s*{q_id},)(?!\s*explanation:)",
        rf"\1\n      explanation: \"{expl}\",",
        content,
        count=1
    )

with open(file_path, "w", encoding="utf-8", newline='') as f:
    f.write(content)

print("SUCCESS: Updated question.dart")
