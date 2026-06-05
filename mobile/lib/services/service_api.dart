import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class ServiceApi {
  // ─── API publiques ──────────────────────────────────────────────────────────
  static const String _osrmBase = 'https://router.project-osrm.org';
  static const String _nominatimBase = 'https://nominatim.openstreetmap.org';

  // Backend local (signalements / refuges uniquement)
  static const String _backendUrl = 'http://10.0.2.2:8000';

  static const Map<String, String> _nominatimHeaders = {
    'User-Agent': 'SafeRoute/1.0 (mg.saferoute.app)',
    'Accept-Language': 'fr',
  };

  // ─── Calcul d'itinéraire via OSRM public ────────────────────────────────────
  Future<Map<String, dynamic>?> obtenirItineraireSur(
      LatLng depart, LatLng arrivee) async {
    try {
      // OSRM attend les coordonnées au format longitude,latitude
      final coords =
          '${depart.longitude},${depart.latitude};${arrivee.longitude},${arrivee.latitude}';
      final url =
          '$_osrmBase/route/v1/driving/$coords?overview=full&geometries=geojson&steps=true';

      final response = await http
          .get(Uri.parse(url), headers: {'User-Agent': 'SafeRoute/1.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] != 'Ok' || (data['routes'] as List).isEmpty) {
          return null;
        }

        final route = data['routes'][0];

        // Extraction des points depuis la géométrie GeoJSON (format [lon, lat])
        final List<dynamic> rawCoords =
            route['geometry']['coordinates'] as List;
        final List<LatLng> points =
            rawCoords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();

        // Extraction des instructions de navigation depuis les étapes
        final List<dynamic> steps =
            (route['legs'][0]['steps'] as List);
        final List<String> instructions = steps.map<String>((step) {
          final maneuver = step['maneuver'];
          final type = maneuver['type'] ?? '';
          final modifier = maneuver['modifier'] ?? '';
          final name = step['name'] ?? '';
          return _traduireInstruction(type, modifier, name);
        }).toList();

        final int distanceM = (route['distance'] as num).round();

        // On retourne le même itinéraire pour "rapide" et "securise"
        // (OSRM propose un seul trajet ; on garde la structure attendue)
        final trajet = {
          'points': points,
          'instructions': instructions,
          'distance': distanceM,
        };

        return {
          'rapide': trajet,
          'securise': trajet,
        };
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur OSRM : $e');
      return null;
    }
  }

  String _traduireInstruction(String type, String modifier, String name) {
    final rue = name.isNotEmpty ? ' sur $name' : '';
    switch (type) {
      case 'depart':
        return 'Démarrer$rue';
      case 'arrive':
        return 'Vous êtes arrivé à destination';
      case 'turn':
        if (modifier.contains('left')) return 'Tourner à gauche$rue';
        if (modifier.contains('right')) return 'Tourner à droite$rue';
        return 'Continuer tout droit$rue';
      case 'new name':
        return 'Continuer$rue';
      case 'continue':
        return 'Continuer tout droit$rue';
      case 'merge':
        return 'Rejoindre$rue';
      case 'roundabout':
        return 'Prendre le rond-point$rue';
      case 'exit roundabout':
        return 'Quitter le rond-point$rue';
      default:
        return 'Continuer$rue';
    }
  }

  // ─── Recherche d'adresse via Nominatim ──────────────────────────────────────
  Future<List<Map<String, dynamic>>?> rechercherAdresse(String requete) async {
    try {
      // Recherche centrée sur Madagascar pour des résultats pertinents
      final url =
          '$_nominatimBase/search?q=${Uri.encodeComponent(requete)}&format=json&limit=5&countrycodes=mg&accept-language=fr';

      final response = await http
          .get(Uri.parse(url), headers: _nominatimHeaders)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          return decoded.cast<Map<String, dynamic>>();
        }
        // Si aucun résultat au Madagascar, élargir la recherche
        final urlGlobal =
            '$_nominatimBase/search?q=${Uri.encodeComponent(requete)}&format=json&limit=5&accept-language=fr';
        final responseGlobal = await http
            .get(Uri.parse(urlGlobal), headers: _nominatimHeaders)
            .timeout(const Duration(seconds: 8));
        if (responseGlobal.statusCode == 200) {
          final decodedGlobal = jsonDecode(responseGlobal.body);
          if (decodedGlobal is List) {
            return decodedGlobal.cast<Map<String, dynamic>>();
          }
        }
        return [];
      }
      return null;
    } catch (e) {
      print('Erreur Nominatim : $e');
      return null;
    }
  }

  // ─── Signalement (backend local, échoue gracieusement sur téléphone) ─────
  Future<bool> envoyerSignalement(
      String type, double lat, double lon, String? desc) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/signalement'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'type_danger': type,
              'latitude': lat,
              'longitude': lon,
              'description': desc,
            }),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('Serveur local inaccessible (signalement) : $e');
      return false;
    }
  }

  // ─── Signalements (backend local) ─────────────────────────────────────────
  Future<List<Map<String, dynamic>>?> recupererSignalements() async {
    try {
      final response = await http
          .get(Uri.parse('$_backendUrl/signalements'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Serveur local inaccessible (signalements) : $e');
      return []; // Retourne une liste vide au lieu de null = pas d'erreur visible
    }
  }

  // ─── Refuges (backend local) ────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>?> recupererRefuges() async {
    try {
      final response = await http
          .get(Uri.parse('$_backendUrl/refuges'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Serveur local inaccessible (refuges) : $e');
      return []; // Retourne une liste vide au lieu de null = pas d'erreur visible
    }
  }
}
