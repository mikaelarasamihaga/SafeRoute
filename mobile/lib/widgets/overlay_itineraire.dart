import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saferoute/providers/fournisseur_itineraire.dart';
import 'package:saferoute/theme.dart';

class OverlayItineraire extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayItineraire({
    super.key,
    required this.onClose,
  });

  @override
  State<OverlayItineraire> createState() => _OverlayItineraireState();
}

class _OverlayItineraireState extends State<OverlayItineraire> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final fournisseur = Provider.of<FournisseurItineraire>(context);
    if (fournisseur.itineraireActuel.isEmpty) return const SizedBox.shrink();

    final distanceMetres = fournisseur.distanceTotale;
    final tempsMinutes = (distanceMetres / 75).round();
    final int scoreSecurite = fournisseur.modeSecurise ? 96 : 64;
    final Color couleurScore = fournisseur.modeSecurise
        ? ThemeSafeRoute.vertSecurite
        : ThemeSafeRoute.orangeDanger;

    return Stack(
      children: [
        // ─── EN-TÊTE : Positioned en haut, ne prend que la hauteur nécessaire ───
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Carte principale d'instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeSafeRoute.couleurSurfaceClaire,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: couleurScore.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: couleurScore.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            fournisseur.modeSecurise
                                ? Icons.verified_user_rounded
                                : Icons.directions_run_rounded,
                            color: couleurScore,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    fournisseur.modeSecurise
                                        ? "GUIDAGE SÉCURISÉ"
                                        : "GUIDAGE RAPIDE",
                                    style: TextStyle(
                                      color: couleurScore,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: couleurScore.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$scoreSecurite% Sûr',
                                      style: TextStyle(
                                        color: couleurScore,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fournisseur.instructions.isNotEmpty
                                    ? "Suivre : ${fournisseur.instructions.first['rue']}"
                                    : "Calcul de l'itinéraire...",
                                style: const TextStyle(
                                  color: ThemeSafeRoute.textePrimaire,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: ThemeSafeRoute.texteSecondaire),
                          onPressed: widget.onClose,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Sélecteur de mode (Rapide / Sécurisé)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: ThemeSafeRoute.couleurSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildModeButton(
                          context,
                          "Plus Rapide",
                          !fournisseur.modeSecurise,
                          Icons.bolt_rounded,
                          () => fournisseur.setModeSecurise(false),
                        ),
                        _buildModeButton(
                          context,
                          "Plus Sécurisé",
                          fournisseur.modeSecurise,
                          Icons.shield_rounded,
                          () => fournisseur.setModeSecurise(true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── PANNEAU BAS : Positioned en bas, la zone centrale reste libre ───
        // La carte reste interactive dans la zone du milieu !
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: ThemeSafeRoute.couleurSurface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Poignée – appuyer pour étendre / réduire
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Container(
                    color: Colors.transparent,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color:
                              ThemeSafeRoute.texteSecondaire.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),

                // En-tête distance / temps (toujours visible)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Détails du trajet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeSafeRoute.textePrimaire,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Vitesse de marche standard',
                            style: TextStyle(
                              fontSize: 11,
                              color: ThemeSafeRoute.texteSecondaire
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _badge(
                            '${(distanceMetres / 1000).toStringAsFixed(2)} km',
                            ThemeSafeRoute.bleuPrimaire,
                          ),
                          const SizedBox(width: 8),
                          _badge(
                            '$tempsMinutes min',
                            ThemeSafeRoute.texteSecondaire,
                            bgAlpha: 0.08,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Instructions (visible seulement si _expanded)
                if (_expanded) ...[
                  const Divider(color: Colors.white10),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.35,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (fournisseur.instructions.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(30),
                              child: Center(
                                child: Text(
                                  "Aucune étape disponible.",
                                  style: TextStyle(
                                      color: ThemeSafeRoute.texteSecondaire),
                                ),
                              ),
                            )
                          else
                            ...fournisseur.instructions
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final step = entry.value;
                              final isFirst = index == 0;
                              final isLast = index ==
                                  fournisseur.instructions.length - 1;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                      alpha: isFirst ? 0.04 : 0.01),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  dense: true,
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isFirst
                                          ? ThemeSafeRoute.bleuPrimaire
                                              .withValues(alpha: 0.2)
                                          : Colors.white
                                              .withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isLast
                                          ? Icons.flag_rounded
                                          : (isFirst
                                              ? Icons.directions_walk_rounded
                                              : Icons
                                                  .subdirectory_arrow_right_rounded),
                                      color: isFirst
                                          ? ThemeSafeRoute.bleuPrimaire
                                          : ThemeSafeRoute.texteSecondaire,
                                      size: 16,
                                    ),
                                  ),
                                  title: Text(
                                    step['rue'] ?? '',
                                    style: TextStyle(
                                      color: ThemeSafeRoute.textePrimaire,
                                      fontWeight: isFirst
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    isLast
                                        ? 'Arrivée à destination'
                                        : 'Continuer sur ${step['distance']} m',
                                    style: TextStyle(
                                      color: ThemeSafeRoute.texteSecondaire
                                          .withValues(
                                              alpha: isFirst ? 1.0 : 0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _badge(String text, Color color, {double bgAlpha = 0.1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: bgAlpha),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String label,
    bool active,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? ThemeSafeRoute.bleuPrimaire : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: ThemeSafeRoute.bleuPrimaire.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? Colors.black : ThemeSafeRoute.texteSecondaire,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active
                    ? Colors.black
                    : ThemeSafeRoute.textePrimaire.withValues(alpha: 0.8),
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
