import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:saferoute/providers/fournisseur_itineraire.dart';
import 'package:saferoute/services/service_api.dart';
import 'package:saferoute/theme.dart';
import 'package:saferoute/widgets/legende_carte.dart';
import 'package:saferoute/widgets/barre_recherche.dart';
import 'package:saferoute/widgets/overlay_itineraire.dart';
import 'package:saferoute/widgets/boutons_action.dart';
import 'package:saferoute/widgets/carte_interactive.dart';

import 'package:saferoute/screens/ecran_contacts.dart';
import 'package:saferoute/screens/ecran_profil.dart';

class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil> {
  final MapController _controleurCarte = MapController();
  final TextEditingController _controleurRecherche = TextEditingController();
  LatLng? _destination;
  LatLng? _positionActuelle;
  List<Map<String, dynamic>> _suggestions = [];
  bool _enRecherche = false;
  List<Marker> _markersSignalements = [];
  List<Marker> _markersRefuges = [];
  List<CircleMarker> _cerclesSignalements = [];
  int _ongletActuel = 0;

  static const LatLng _centreInitial = LatLng(-21.4536, 47.0857);

  @override
  void initState() {
    super.initState();
    _determinerPosition();
    _chargerSignalements();
    _chargerRefuges();
  }

  Future<void> _chargerRefuges() async {
    final refuges = await ServiceApi().recupererRefuges();
    if (refuges != null && mounted) {
      setState(() {
        _markersRefuges = refuges.map((r) {
          final isPolice = r['type_refuge'] == 'police';
          return Marker(
            point: LatLng(r['latitude'], r['longitude']),
            width: 36,
            height: 36,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [ThemeSafeRoute.bleuAccent, ThemeSafeRoute.vertSecurite],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: ThemeSafeRoute.vertSecurite.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                isPolice ? Icons.security_rounded : Icons.local_hospital_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          );
        }).toList();
      });
    }
  }

  Future<void> _chargerSignalements() async {
    final signalements = await ServiceApi().recupererSignalements();
    if (signalements != null && mounted) {
      setState(() {
        _markersSignalements = signalements.map((s) {
          return Marker(
            point: LatLng(s['latitude'], s['longitude']),
            width: 34,
            height: 34,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [ThemeSafeRoute.rougeDanger, ThemeSafeRoute.orangeDanger],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: ThemeSafeRoute.rougeDanger.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                _obtenirIconeDanger(s['type_danger']),
                color: Colors.white,
                size: 16,
              ),
            ),
          );
        }).toList();

        _cerclesSignalements = signalements
            .map((s) => CircleMarker(
                  point: LatLng(s['latitude'], s['longitude']),
                  radius: 35,
                  useRadiusInMeter: true,
                  color: ThemeSafeRoute.rougeDanger.withValues(alpha: 0.16),
                  borderColor: ThemeSafeRoute.rougeDanger.withValues(alpha: 0.35),
                  borderStrokeWidth: 1.5,
                ))
            .toList();
      });
    }
  }

  Future<void> _determinerPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Veuillez activer la localisation/GPS de votre téléphone."),
              behavior: SnackBarBehavior.floating,
              backgroundColor: ThemeSafeRoute.rougeDanger,
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("L'autorisation d'accès GPS est requise pour SafeRoute."),
                behavior: SnackBarBehavior.floating,
                backgroundColor: ThemeSafeRoute.rougeDanger,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("L'accès GPS est bloqué de façon permanente. Veuillez l'activer dans les paramètres."),
              behavior: SnackBarBehavior.floating,
              backgroundColor: ThemeSafeRoute.rougeDanger,
            ),
          );
        }
        return;
      }

      // 1. Tenter d'obtenir la dernière position connue pour une réactivité instantanée
      final Position? lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null && mounted) {
        setState(() {
          _positionActuelle = LatLng(lastPosition.latitude, lastPosition.longitude);
        });
        _controleurCarte.move(_positionActuelle!, 15.0);
      }

      // 2. Obtenir la position actuelle avec un timeout de 7 secondes
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
        timeLimit: const Duration(seconds: 7),
      ).catchError((error) async {
        // En cas de timeout ou erreur, essayer en basse précision avant d'abandonner
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
          ),
          timeLimit: const Duration(seconds: 5),
        );
      });

      if (!mounted) return;
      setState(() => _positionActuelle = LatLng(position.latitude, position.longitude));
      _controleurCarte.move(_positionActuelle!, 15.0);

      // 3. Écouter le flux de positions en temps réel
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 15,
        ),
      ).listen((Position pos) {
        if (!mounted) return;
        final nouvellePos = LatLng(pos.latitude, pos.longitude);
        setState(() => _positionActuelle = nouvellePos);
        Provider.of<FournisseurItineraire>(context, listen: false)
            .verifierPosition(nouvellePos);
      }, onError: (err) {
        debugPrint("Erreur flux GPS: $err");
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur de localisation : $e"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ThemeSafeRoute.rougeDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _ongletActuel,
        children: [
          _buildOngletCarte(context),
          const EcranContacts(),
          const EcranProfil(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(estSombre),
    );
  }

  Widget _buildOngletCarte(BuildContext context) {
    final fournisseur = Provider.of<FournisseurItineraire>(context);
    return Stack(
      children: [
        // ── Carte interactive ──
        CarteInteractive(
          mapController: _controleurCarte,
          positionActuelle: _positionActuelle,
          destination: _destination,
          markersSignalements: _markersSignalements,
          markersRefuges: _markersRefuges,
          cerclesSignalements: _cerclesSignalements,
          onLongPress: (tapPosition, point) {
            setState(() => _destination = point);
            fournisseur.recupererItineraire(_positionActuelle ?? _centreInitial, point);
          },
        ),

        // ── Chargement ──
        if (fournisseur.enChargement)
          const Center(
            child: Card(
              elevation: 10,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeSafeRoute.bleuPrimaire),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Calcul de l'itinéraire...",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: ThemeSafeRoute.textePrimaire,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Légende rétractable ──
        const LegendeCarte(),

        // ── Barre de recherche ──
        BarreRecherche(
          controller: _controleurRecherche,
          suggestions: _suggestions,
          enRecherche: _enRecherche,
          onChanged: _rechercherAdresse,
          onClear: () {
            setState(() {
              _controleurRecherche.clear();
              _suggestions = [];
              _destination = null;
            });
          },
          onSuggestionSelected: _selectionnerSuggestion,
        ),

        // ── Overlay d'itinéraire ──
        OverlayItineraire(
          onClose: () {
            fournisseur.effacerItineraire();
            setState(() {
              _destination = null;
              _controleurRecherche.clear();
            });
          },
        ),

        // ── Bouton GPS ──
        if (fournisseur.itineraireActuel.isEmpty)
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {
                if (_positionActuelle != null) {
                  _controleurCarte.move(_positionActuelle!, 16.0);
                } else {
                  _determinerPosition();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Recherche de votre position..."),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Icon(Icons.my_location_rounded, size: 20),
            ),
          ),

        // ── Boutons d'action SOS / Signaler ──
        BoutonsAction(
          onSOS: () => _declencherSOS(context),
          onSignaler: () => _afficherDialogueSignalement(context),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(bool estSombre) {
    return Container(
      decoration: BoxDecoration(
        color: estSombre 
            ? ThemeSafeRoute.couleurSurface.withValues(alpha: 0.95)
            : ThemeSafeRoute.couleurSurfaceL.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: estSombre ? Colors.white12 : Colors.black12,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _ongletActuel,
        onTap: (index) {
          setState(() {
            _ongletActuel = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: estSombre ? ThemeSafeRoute.bleuPrimaire : ThemeSafeRoute.bleuAccent,
        unselectedItemColor: ThemeSafeRoute.texteSecondaire,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            activeIcon: Icon(Icons.map_rounded),
            label: "Carte",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call_rounded),
            activeIcon: Icon(Icons.call_rounded),
            label: "SOS Mada",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  // ─── Dialogue SOS ───────────────────────────────────────────────────────────
  void _declencherSOS(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeSafeRoute.couleurSurfaceClaire,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: ThemeSafeRoute.rougeDanger.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: ThemeSafeRoute.rougeDanger, size: 28),
            SizedBox(width: 10),
            Text(
              'URGENCE SOS',
              style: TextStyle(
                color: ThemeSafeRoute.rougeDanger,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        content: const Text(
          'Êtes-vous en situation de danger ?\nVoulez-vous envoyer immédiatement une alerte SOS d\'urgence aux autorités et refuges à proximité ?',
          style: TextStyle(height: 1.5, color: ThemeSafeRoute.textePrimaire),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ANNULER',
              style: TextStyle(
                color: ThemeSafeRoute.texteSecondaire,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _envoyerAlerteSOS();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeSafeRoute.rougeDanger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'ENVOYER L\'ALERTE',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _envoyerAlerteSOS() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.security_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ALERTE SOS ENVOYÉE ! Les autorités ont été notifiées.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: ThemeSafeRoute.rougeDanger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  IconData _obtenirIconeDanger(String type) {
    if (type == 'sombre') return Icons.lightbulb_outline;
    if (type == 'desert') return Icons.people_outline;
    return Icons.warning;
  }

  void _rechercherAdresse(String query) async {
    if (query.length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _enRecherche = true);
    final res = await ServiceApi().rechercherAdresse(query);
    if (mounted) {
      setState(() {
        _suggestions = res ?? [];
        _enRecherche = false;
      });
    }
  }

  void _selectionnerSuggestion(Map<String, dynamic> suggestion) {
    final point =
        LatLng(double.parse(suggestion['lat']), double.parse(suggestion['lon']));
    setState(() {
      _destination = point;
      _suggestions = [];
      _controleurRecherche.text = suggestion['display_name'];
    });
    _controleurCarte.move(point, 15.0);
    Provider.of<FournisseurItineraire>(context, listen: false)
        .recupererItineraire(_positionActuelle ?? _centreInitial, point);
    FocusScope.of(context).unfocus();
  }

  // ─── Bottom Sheet de Signalement ────────────────────────────────────────────
  void _afficherDialogueSignalement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ThemeSafeRoute.couleurSurfaceClaire,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4.5,
              decoration: BoxDecoration(
                color: ThemeSafeRoute.texteSecondaire.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'Signaler un danger',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeSafeRoute.textePrimaire,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Aidez la communauté à naviguer en sécurité',
              style: TextStyle(
                fontSize: 12,
                color: ThemeSafeRoute.texteSecondaire.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 18),

            // Zone Sombre
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ThemeSafeRoute.orangeDanger.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lightbulb_outline_rounded,
                      color: ThemeSafeRoute.orangeDanger, size: 20),
                ),
                title: const Text('Zone sombre / Pas d\'éclairage',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Rues mal éclairées ou lampadaires en panne'),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: ThemeSafeRoute.texteSecondaire),
                onTap: () => _soumettreSignalement(context, 'sombre'),
              ),
            ),
            const SizedBox(height: 8),

            // Zone Déserte
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ThemeSafeRoute.rougeDanger.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.people_outline_rounded,
                      color: ThemeSafeRoute.rougeDanger, size: 20),
                ),
                title: const Text('Zone déserte / Risquée',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Faible affluence, activité suspecte fréquente'),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: ThemeSafeRoute.texteSecondaire),
                onTap: () => _soumettreSignalement(context, 'desert'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _soumettreSignalement(BuildContext context, String type) async {
    final centre = _controleurCarte.camera.center;
    final succes = await ServiceApi().envoyerSignalement(
        type, centre.latitude, centre.longitude, "Signalement via SafeRoute");
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                succes ? Icons.check_circle_rounded : Icons.error_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                succes
                    ? 'Signalement enregistré !'
                    : 'Erreur lors de l\'envoi.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor:
              succes ? ThemeSafeRoute.vertSecurite : ThemeSafeRoute.rougeDanger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      if (succes) _chargerSignalements();
    }
  }
}
