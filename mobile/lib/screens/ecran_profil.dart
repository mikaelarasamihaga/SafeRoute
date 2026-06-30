import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saferoute/providers/fournisseur_theme.dart';
import 'package:saferoute/theme.dart';
import 'package:saferoute/services/service_storage.dart';

class EcranProfil extends StatefulWidget {
  const EcranProfil({super.key});

  @override
  State<EcranProfil> createState() => _EcranProfilState();
}

class _EcranProfilState extends State<EcranProfil> {
  String _nom = "Utilisateur SafeRoute";
  String _groupeSanguin = "O+";

  @override
  void initState() {
    super.initState();
    _chargerPreferences();
  }

  Future<void> _chargerPreferences() async {
    final nom = await ServiceStorage.loadProfileNom();
    final gs = await ServiceStorage.loadBloodGroup();
    if (mounted) {
      setState(() {
        _nom = nom;
        _groupeSanguin = gs;
      });
    }
  }

  void _modifierNom() {
    final controller = TextEditingController(text: _nom);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier le nom"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Votre Nom",
            hintText: "Saisissez votre nom",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _nom = controller.text;
                });
                ServiceStorage.saveProfileNom(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  void _modifierGroupeSanguin() {
    final groupes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "Non spécifié"];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Groupe Sanguin"),
        content: DropdownButtonFormField<String>(
          value: _groupeSanguin,
          items: groupes
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _groupeSanguin = val;
              });
              ServiceStorage.saveBloodGroup(val);
              Navigator.pop(context);
            }
          },
          decoration: const InputDecoration(
            labelText: "Sélectionnez votre groupe",
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<FournisseurTheme>(context);
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MON PROFIL"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Avatar Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ThemeSafeRoute.bleuPrimaire, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeSafeRoute.bleuPrimaire.withValues(alpha: 0.25),
                              blurRadius: 16,
                            )
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.transparent,
                          child: Icon(Icons.person_rounded, size: 50, color: ThemeSafeRoute.bleuPrimaire),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _modifierNom,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: ThemeSafeRoute.bleuAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nom,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Utilisateur Premium (Madagascar)",
                    style: TextStyle(color: ThemeSafeRoute.texteSecondaire, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Profile info cards
            _sectionHeader("INFORMATIONS MÉDICALES / SÉCURITÉ"),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.bloodtype_rounded, color: ThemeSafeRoute.rougeDanger),
                    title: const Text("Groupe Sanguin (Secours)"),
                    subtitle: const Text("Utile aux secouristes en cas d'accident"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _groupeSanguin,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                    onTap: _modifierGroupeSanguin,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings options
            _sectionHeader("CONFIGURATION ET PRÉFÉRENCES"),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  // Theme switch
                  SwitchListTile(
                    secondary: Icon(
                      estSombre ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: ThemeSafeRoute.bleuPrimaire,
                    ),
                    title: const Text("Thème Sombre"),
                    subtitle: const Text("Activer/Désactiver le mode nuit"),
                    value: estSombre,
                    onChanged: (val) {
                      themeProvider.basculerTheme();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Legal info
            _sectionHeader("À PROPOS DE SAFEROUTE"),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text("Version de l'application"),
                    trailing: Text("1.0", style: TextStyle(color: ThemeSafeRoute.texteSecondaire)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded),
                    title: const Text("Support / Aide"),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Aide en ligne non disponible")),
                      );
                    },
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

  Widget _sectionHeader(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: ThemeSafeRoute.texteSecondaire,
        ),
      ),
    );
  }
}
