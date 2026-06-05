import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saferoute/providers/fournisseur_itineraire.dart';
import 'package:saferoute/theme.dart';

class LegendeCarte extends StatefulWidget {
  const LegendeCarte({super.key});

  @override
  State<LegendeCarte> createState() => _LegendeCarteState();
}

class _LegendeCarteState extends State<LegendeCarte> {
  bool _estEtendu = false;

  @override
  Widget build(BuildContext context) {
    final fournisseur = Provider.of<FournisseurItineraire>(context);
    final aItineraire = fournisseur.itineraireActuel.isNotEmpty;

    return Positioned(
      left: 16,
      bottom: aItineraire ? 180 : 110,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: _estEtendu ? _buildLegendeEtendue() : _buildBoutonDeclencheur(),
      ),
    );
  }

  Widget _buildBoutonDeclencheur() {
    return GestureDetector(
      onTap: () => setState(() => _estEtendu = true),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ThemeSafeRoute.couleurSurfaceClaire,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.info_outline_rounded,
          color: ThemeSafeRoute.bleuPrimaire,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLegendeEtendue() {
    return Container(
      width: 190,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeSafeRoute.couleurSurfaceClaire,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "LÉGENDE DE CARTE",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: ThemeSafeRoute.bleuPrimaire,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _estEtendu = false),
                child: const Icon(
                  Icons.close_rounded,
                  color: ThemeSafeRoute.texteSecondaire,
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLegendItem(Icons.circle, ThemeSafeRoute.bleuPrimaire, "Votre trajet", isDot: true),
          _buildLegendItem(Icons.circle, ThemeSafeRoute.rougeDanger, "Zone de danger", isDot: true),
          _buildLegendItem(Icons.security, ThemeSafeRoute.bleuAccent, "Refuge (Sûr)"),
          _buildLegendItem(Icons.lightbulb_outline, ThemeSafeRoute.orangeDanger, "Zone sombre"),
          _buildLegendItem(Icons.people_outline, ThemeSafeRoute.orangeDanger, "Zone déserte"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String label, {bool isDot = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            child: Icon(icon, color: color, size: isDot ? 10 : 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ThemeSafeRoute.textePrimaire,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
