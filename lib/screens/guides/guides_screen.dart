import 'package:flutter/material.dart';
import 'package:code_route_flutter/screens/guides/guide_detail_screen.dart';

class GuideItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color themeColor;
  final String content;
  final String? actionLink;
  final String? actionText;

  const GuideItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    required this.content,
    this.actionLink,
    this.actionText,
  });
}

class GuidesScreen extends StatelessWidget {
  const GuidesScreen({Key? key}) : super(key: key);

  static const List<GuideItem> guides = [
    GuideItem(
      title: 'Tous les panneaux',
      subtitle: 'Danger, interdiction, obligation et indication.',
      icon: Icons.traffic_rounded,
      themeColor: Color(0xFF06B6D4),
      content: '''Panneaux de danger
Ils annoncent un risque a venir: virage dangereux, route glissante, passage d animaux, travaux.

Panneaux d interdiction
Ils interdisent une action stricte: sens interdit, interdiction de depasser, limitation de vitesse. Les ignorer peut entrainer une faute grave.

Panneaux d obligation
Ils imposent une action: tourner a droite, direction obligatoire, piste reservee.

Panneaux d indication
Ils donnent une information utile: parking, hopital, station-service, itineraire.

Astuce
Entraine-toi souvent avec des quiz rapides de reconnaissance.''',
    ),
    GuideItem(
      title: 'Comment s inscrire',
      subtitle: 'Dossier, auto-ecole, formation et examens.',
      icon: Icons.app_registration_rounded,
      themeColor: Color(0xFFEC4899),
      content: '''Conditions
Tu dois avoir l age minimum requis, une piece d identite valide, et etre apte physiquement a conduire.

Documents frequents
Piece d identite, photos, formulaire d inscription, certificat medical si demande, et justificatif de paiement.

Auto-ecole
Choisis une auto-ecole agreee, ouvre ton dossier et suis la formation theorique puis pratique.

Examens
Tu passes d abord le code, puis l examen pratique avec un examinateur.

Important
Le permis est obligatoire pour conduire. Conduire sans permis expose a une amende et a des poursuites.''',
    ),
    GuideItem(
      title: 'Le creneau',
      subtitle: 'Les reperes pour stationner calmement.',
      icon: Icons.local_parking_rounded,
      themeColor: Color(0xFF22C55E),
      content: '''1. Signaler
Mets le clignotant pour prevenir les autres usagers.

2. Se placer
Arrete-toi droit et parallele, environ 50 cm a cote du vehicule devant la place.

3. Reculer doucement
Recule en ligne droite jusqu a ce que tes roues arriere arrivent au niveau de l arriere de l autre voiture.

4. Braquer
Braque vers le trottoir et recule lentement en controlant les retros.

5. Contre-braquer
Quand la voiture est inclinee, tourne le volant dans l autre sens pour t aligner.

6. Ajuster
Termine doucement et verifie que tu ne genes pas les autres.''',
    ),
    GuideItem(
      title: 'Comportement examen',
      subtitle: 'Rester calme, observer, eviter les fautes.',
      icon: Icons.psychology_rounded,
      themeColor: Color(0xFFF59E0B),
      content: '''Examen theorique
Lis chaque mot, observe toute l image, repere les panneaux et les vehicules dans les retros. La reponse la plus sure est souvent la bonne.

Examen pratique
Regarde loin, anticipe, controle tes retros et angles morts de facon visible. L inspecteur evalue ta conduite en securite.

Fautes eliminatoires
Ne pas s arreter au STOP, prendre un sens interdit, refuser une priorite, ignorer un pieton ou perdre la maitrise du vehicule.''',
    ),
    GuideItem(
      title: 'Candidat libre',
      subtitle: 'Reviser seul et reserver son examen.',
      icon: Icons.badge_rounded,
      themeColor: Color(0xFF8B5CF6),
      content: '''Apprendre en autonomie
Travaille les regles, entraine-toi avec des QCM et comprends pourquoi une reponse est correcte.

Obtenir son identifiant
Selon le pays, tu dois obtenir le numero ou dossier officiel requis avant de passer l examen.

Choisir un centre
Reserve ta place dans un centre agree et prepare les documents demandes.

Le jour J
Apporte ta convocation et une piece d identite valide. Arrive en avance pour eviter le stress.''',
    ),
    GuideItem(
      title: 'Lors de la pratique',
      subtitle: 'Les bons reflexes avant et pendant la route.',
      icon: Icons.drive_eta_rounded,
      themeColor: Color(0xFF14B8A6),
      content: '''Avant de partir
Verifie les freins, pneus, retros, siege, ceinture et visibilite.

Pendant la conduite
Respecte la vitesse, garde tes distances, utilise le clignotant et controle avant chaque changement.

Attitude
Reste concentre, tolere les erreurs des autres et garde toujours une marge de securite.''',
    ),
    GuideItem(
      title: 'Delais resultats',
      subtitle: 'Comprendre quand et comment consulter.',
      icon: Icons.hourglass_top_rounded,
      themeColor: Color(0xFF0EA5E9),
      content: '''Code
Les resultats peuvent arriver rapidement, souvent par mail ou via une plateforme officielle.

Conduite
Le resultat pratique est generalement disponible apres un delai administratif. Les week-ends et jours feries peuvent rallonger l attente.

Si le resultat est favorable
Conserve le document provisoire si ton pays le prevoit, puis attends la fabrication du permis definitif.''',
    ),
    GuideItem(
      title: 'Themes officiels',
      subtitle: 'Securite, respect et organisation.',
      icon: Icons.gavel_rounded,
      themeColor: Color(0xFFEF4444),
      content: '''Securite
Le code sert d abord a proteger les vies et eviter les accidents.

Respect
Chaque usager doit respecter les autres, surtout les pietons, cyclistes, enfants et personnes vulnerables.

Organisation
Les regles rendent la circulation plus fluide et plus previsible pour tout le monde.''',
    ),
    GuideItem(
      title: 'Chaine YouTube',
      subtitle: 'Videos, astuces et situations expliquees.',
      icon: Icons.play_circle_fill_rounded,
      themeColor: Color(0xFFFF0033),
      content:
          '''Les videos aident a mieux comprendre les situations de route, les intersections et les manoeuvres.

La chaine peut proposer:
- des situations complexes expliquees pas a pas;
- des astuces pour l examen pratique;
- des series de code blanc;
- des tutoriels de manoeuvres comme le creneau.

Reviens souvent pour decouvrir les nouveautes.''',
      actionLink: 'https://www.youtube.com/',
      actionText: 'Ouvrir la chaine YouTube',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHero()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final crossAxisCount = width >= 820
                      ? 4
                      : width >= 560
                          ? 3
                          : 2;

                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildGuideCard(context, guides[index], index),
                      childCount: guides.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: width < 380 ? 0.78 : 0.9,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF12356F), Color(0xFF0F766E), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.16),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.22)),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Guide de conduite',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
              ),
              _buildPill('${guides.length} fiches'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Tout ce qu il faut retenir avant la route',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Panneaux, examens, manoeuvres et conseils pratiques reunis dans des fiches courtes et faciles a consulter.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 14,
                height: 1.45),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMetric(Icons.timer_rounded, '5 min', 'par guide'),
              const SizedBox(width: 10),
              _buildMetric(Icons.verified_rounded, 'Pratique', 'examen'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF020617).withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, GuideItem guide, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GuideDetailScreen(
                title: guide.title,
                content: guide.content,
                icon: guide.icon,
                iconColor: guide.themeColor,
                actionLink: guide.actionLink,
                actionText: guide.actionText,
              ),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: guide.themeColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(guide.icon, color: guide.themeColor, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    '${index + 1}'.padLeft(2, '0'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.24),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                guide.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.15),
              ),
              const SizedBox(height: 7),
              Text(
                guide.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 11.5,
                    height: 1.25),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: ((index % 4) + 1) / 4,
                        minHeight: 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(guide.themeColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded,
                      color: guide.themeColor, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
