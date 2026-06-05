import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceStorage {
  static const String _keyNom = "profile_nom";
  static const String _keyBloodGroup = "profile_blood_group";
  static const String _keyAlertes = "profile_alertes";
  static const String _keyGuidageVocal = "profile_guidage_vocal";
  static const String _keyContacts = "emergency_contacts";

  static Future<void> saveProfileNom(String nom) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNom, nom);
  }

  static Future<String> loadProfileNom() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNom) ?? "Utilisateur SafeRoute";
  }

  static Future<void> saveBloodGroup(String bg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBloodGroup, bg);
  }

  static Future<String> loadBloodGroup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBloodGroup) ?? "O+";
  }

  static Future<void> saveAlertes(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAlertes, val);
  }

  static Future<bool> loadAlertes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAlertes) ?? true;
  }

  static Future<void> saveGuidageVocal(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGuidageVocal, val);
  }

  static Future<bool> loadGuidageVocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGuidageVocal) ?? false;
  }

  static Future<void> saveContacts(List<Map<String, String>> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(contacts);
    await prefs.setString(_keyContacts, encoded);
  }

  static Future<List<Map<String, String>>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_keyContacts);
    if (encoded == null) {
      return [
        {"nom": "Contact d'urgence 1 (Maman)", "numero": "+261340000000"},
        {"nom": "Contact d'urgence 2 (Papa)", "numero": "+261320000000"},
      ];
    }
    try {
      final List<dynamic> decoded = jsonDecode(encoded);
      return decoded.map((item) => Map<String, String>.from(item)).toList();
    } catch (e) {
      return [];
    }
  }
}
