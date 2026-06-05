import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:saferoute/services/service_api.dart';

class FournisseurItineraire with ChangeNotifier {
  final ServiceApi _serviceApi = ServiceApi();
  
  Map<String, dynamic>? _donneesItineraire;
  bool _modeSecurise = true;
  bool _enChargement = false;

  List<LatLng> get itineraireActuel {
    if (_donneesItineraire == null) return [];
    return _modeSecurise 
        ? _donneesItineraire!['securise']['points'] 
        : _donneesItineraire!['rapide']['points'];
  }

  List<dynamic> get instructions {
    if (_donneesItineraire == null) return [];
    return _modeSecurise 
        ? _donneesItineraire!['securise']['instructions'] 
        : _donneesItineraire!['rapide']['instructions'];
  }

  int get distanceTotale {
    if (_donneesItineraire == null) return 0;
    return _modeSecurise 
        ? _donneesItineraire!['securise']['distance'] 
        : _donneesItineraire!['rapide']['distance'];
  }

  bool get modeSecurise => _modeSecurise;
  bool get enChargement => _enChargement;

  void setModeSecurise(bool valeur) {
    _modeSecurise = valeur;
    notifyListeners();
  }

  Future<void> recupererItineraire(LatLng depart, LatLng arrivee) async {
    _enChargement = true;
    notifyListeners();

    final resultat = await _serviceApi.obtenirItineraireSur(depart, arrivee);
    
    if (resultat != null) {
      _donneesItineraire = resultat;
    } else {
      _donneesItineraire = null;
    }

    _enChargement = false;
    notifyListeners();
  }

  Future<void> verifierPosition(LatLng positionActuelle) async {
    final points = itineraireActuel;
    if (points.isEmpty || _enChargement) return;

    double distanceMin = double.infinity;
    for (var point in points) {
      final d = const Distance().as(LengthUnit.Meter, positionActuelle, point);
      if (d < distanceMin) distanceMin = d;
    }

    if (distanceMin > 60) { // On passe à 60m pour être plus tolérant
      final destination = points.last;
      await recupererItineraire(positionActuelle, destination);
    }
  }

  void effacerItineraire() {
    _donneesItineraire = null;
    notifyListeners();
  }
}
