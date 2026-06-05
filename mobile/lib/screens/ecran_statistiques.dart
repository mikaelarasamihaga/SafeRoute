import 'package:flutter/material.dart';
import 'package:saferoute/theme.dart';

class StatCardData {
  final String titre;
  final String valeur;
  final String sousTitre;
  final IconData icone;
  final Color couleur;

  StatCardData({
    required this.titre,
    required this.valeur,
    required this.sousTitre,
    required this.icone,
    required this.couleur,
  });
}

class EcranStatistiques extends StatelessWidget {
  const EcranStatistiques({super.key});

  @override
  Widget build(BuildContext context) {
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    final stats = [
      StatCardData(
        titre: "Zones Signalées",
        valeur: "14",
        sousTitre: "Dangers signalés",
        icone: Icons.report_problem_rounded,
        couleur: ThemeSafeRoute.rougeDanger,
      ),
      StatCardData(
        titre: "Refuges Sécurisés",
        valeur: "4",
        sousTitre: "Refuges à proximité",
        icone: Icons.security_rounded,
        couleur: ThemeSafeRoute.vertSecurite,
      ),
      StatCardData(
        titre: "Score Moyen",
        valeur: "92%",
        sousTitre: "Index de sécurité global",
        icone: Icons.shield_rounded,
        couleur: ThemeSafeRoute.bleuPrimaire,
      ),
      StatCardData(
        titre: "Distance Protégée",
        valeur: "4.8 km",
        sousTitre: "Parcourus en sécurité",
        icone: Icons.directions_walk_rounded,
        couleur: ThemeSafeRoute.bleuAccent,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("STATISTIQUES DE ZONE"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Safe Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ThemeSafeRoute.bleuAccent, ThemeSafeRoute.bleuPrimaire],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: ThemeSafeRoute.bleuPrimaire.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fianarantsoa, Madagascar",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Niveau de Sécurité : ÉLEVÉ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.92,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(ThemeSafeRoute.vertSecurite),
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section title
            const Text(
              "METRIQUES CLÉS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: ThemeSafeRoute.texteSecondaire,
              ),
            ),
            const SizedBox(height: 12),

            // Grid of Metrics
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.45,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final item = stats[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: item.couleur.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(item.icone, color: item.couleur, size: 16),
                            ),
                            Text(
                              item.valeur,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: estSombre ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.titre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              item.sousTitre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: ThemeSafeRoute.texteSecondaire,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Chart area mockup (Highly professional and beautiful list of active reported hazards)
            const Text(
              "RÉCENTES ALERTES DE ZONE",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: ThemeSafeRoute.texteSecondaire,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _alertTile(
                    Icons.lightbulb_outline_rounded,
                    ThemeSafeRoute.orangeDanger,
                    "Zone Sombre signalée",
                    "Avenue de l'Indépendance - Fianarantsoa",
                    "Il y a 2h",
                  ),
                  const Divider(indent: 56, endIndent: 16, height: 1),
                  _alertTile(
                    Icons.people_outline_rounded,
                    ThemeSafeRoute.rougeDanger,
                    "Zone Déserte signalée",
                    "Près du Campus Universitaire",
                    "Il y a 5h",
                  ),
                  const Divider(indent: 56, endIndent: 16, height: 1),
                  _alertTile(
                    Icons.lightbulb_outline_rounded,
                    ThemeSafeRoute.orangeDanger,
                    "Pas d'éclairage public",
                    "Quartier de Tsaralalana",
                    "Hier",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _alertTile(IconData icon, Color color, String title, String subtitle, String time) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: Text(
        time,
        style: const TextStyle(color: ThemeSafeRoute.texteSecondaire, fontSize: 10),
      ),
    );
  }
}
