import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:saferoute/providers/fournisseur_itineraire.dart';
import 'package:saferoute/theme.dart';

class CarteInteractive extends StatelessWidget {
  final MapController mapController;
  final LatLng? positionActuelle;
  final LatLng? destination;
  final List<Marker> markersSignalements;
  final List<Marker> markersRefuges;
  final List<CircleMarker> cerclesSignalements;
  final void Function(dynamic, LatLng)? onLongPress;

  // Centre par défaut sur Fianarantsoa, Madagascar
  static const LatLng _centreInitial = LatLng(-21.4536, 47.0857);

  const CarteInteractive({
    super.key,
    required this.mapController,
    required this.positionActuelle,
    required this.destination,
    required this.markersSignalements,
    required this.markersRefuges,
    required this.cerclesSignalements,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: positionActuelle ?? _centreInitial,
        initialZoom: 15.0,
        maxZoom: 19.0,
        minZoom: 0.0,
        onTap: (_, __) => FocusScope.of(context).unfocus(),
        onLongPress: onLongPress,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        // Couche de tuiles OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'mg.saferoute.app',
          maxNativeZoom: 19,
          retinaMode: false,
          keepBuffer: 2,
          tileUpdateTransformer: TileUpdateTransformers.debounce(
            const Duration(milliseconds: 100),
          ),
        ),

        // Cercles de danger translucides stylisés
        CircleLayer(
          circles: cerclesSignalements,
        ),

        // Tracé de l'itinéraire néon glowing
        Consumer<FournisseurItineraire>(
          builder: (context, fournisseur, child) {
            if (fournisseur.itineraireActuel.isEmpty) return const SizedBox.shrink();
            return PolylineLayer(
              polylines: [
                // Ombre sous la ligne d'itinéraire
                Polyline(
                  points: fournisseur.itineraireActuel,
                  strokeWidth: 8,
                  color: ThemeSafeRoute.bleuPrimaire.withOpacity(0.2),
                ),
                // Ligne d'itinéraire principale brillante
                Polyline(
                  points: fournisseur.itineraireActuel,
                  strokeWidth: 5,
                  color: ThemeSafeRoute.bleuPrimaire,
                ),
              ],
            );
          },
        ),

        // Couche de marqueurs
        MarkerLayer(
          markers: [
            // Position Actuelle GPS animée
            if (positionActuelle != null)
              Marker(
                point: positionActuelle!,
                width: 50,
                height: 50,
                child: const MarqueurPositionPulsant(),
              ),

            // Destination finale
            if (destination != null)
              Marker(
                point: destination!,
                width: 45,
                height: 45,
                child: const MarqueurDestination(),
              ),

            ...markersSignalements,
            ...markersRefuges,
          ],
        ),
      ],
    );
  }
}

// Widget de pulsation radar pour la position GPS de l'utilisateur
class MarqueurPositionPulsant extends StatefulWidget {
  const MarqueurPositionPulsant({super.key});

  @override
  State<MarqueurPositionPulsant> createState() => _MarqueurPositionPulsantState();
}

class _MarqueurPositionPulsantState extends State<MarqueurPositionPulsant>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationRadar;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _animationRadar = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationRadar,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Halo extérieur en expansion
            Container(
              width: 44 * _animationRadar.value,
              height: 44 * _animationRadar.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeSafeRoute.bleuPrimaire.withOpacity(0.35 * (1.0 - _animationRadar.value)),
                border: Border.all(
                  color: ThemeSafeRoute.bleuPrimaire.withOpacity(0.5 * (1.0 - _animationRadar.value)),
                  width: 1.5,
                ),
              ),
            ),
            
            // Halo fixe doux
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeSafeRoute.bleuPrimaire.withOpacity(0.15),
              ),
            ),

            // Point central blanc et bleu électrique
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeSafeRoute.bleuPrimaire,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Widget pour le marqueur de destination final
class MarqueurDestination extends StatefulWidget {
  const MarqueurDestination({super.key});

  @override
  State<MarqueurDestination> createState() => _MarqueurDestinationState();
}

class _MarqueurDestinationState extends State<MarqueurDestination>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationFlottement;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animationFlottement = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationFlottement,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animationFlottement.value),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // L'ombre au sol du marqueur
              Opacity(
                opacity: (1.0 + (_animationFlottement.value / 12.0)).clamp(0.2, 0.7),
                child: Container(
                  width: 10,
                  height: 3,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black45,
                  ),
                ),
              ),
              // Épingler
              Container(
                margin: const EdgeInsets.only(bottom: 3),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: ThemeSafeRoute.rougeDanger,
                  size: 38,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
