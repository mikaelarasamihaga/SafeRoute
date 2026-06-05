import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saferoute/theme.dart';
import 'package:saferoute/services/service_storage.dart';

class ContactUrgence {
  final String nom;
  final String numero;
  final IconData icone;
  final Color couleur;
  final String description;

  ContactUrgence({
    required this.nom,
    required this.numero,
    required this.icone,
    required this.couleur,
    required this.description,
  });
}

class EcranContacts extends StatefulWidget {
  const EcranContacts({super.key});

  @override
  State<EcranContacts> createState() => _EcranContactsState();
}

class _EcranContactsState extends State<EcranContacts> {
  final List<ContactUrgence> _contactsMada = [
    ContactUrgence(
      nom: "Police Nationale",
      numero: "17",
      icone: Icons.security_rounded,
      couleur: ThemeSafeRoute.bleuAccent,
      description: "Secours et intervention de police immédiate",
    ),
    ContactUrgence(
      nom: "Gendarmerie Nationale",
      numero: "119",
      icone: Icons.local_police_rounded,
      couleur: ThemeSafeRoute.bleuPrimaire,
      description: "Sécurité publique en zone périurbaine et rurale",
    ),
    ContactUrgence(
      nom: "Sapeurs-Pompiers",
      numero: "18",
      icone: Icons.local_fire_department_rounded,
      couleur: ThemeSafeRoute.rougeDanger,
      description: "Incendies, accidents et urgences médicales de secours",
    ),
    ContactUrgence(
      nom: "SAMU / Urgences Médicales",
      numero: "124",
      icone: Icons.medical_services_rounded,
      couleur: ThemeSafeRoute.vertSecurite,
      description: "Service d'aide médicale urgente et ambulances",
    ),
  ];

  List<Map<String, String>> _contactsPersonnels = [];

  @override
  void initState() {
    super.initState();
    _chargerContacts();
  }

  Future<void> _chargerContacts() async {
    final contacts = await ServiceStorage.loadContacts();
    if (mounted) {
      setState(() {
        _contactsPersonnels = contacts;
      });
    }
  }

  Future<void> _sauvegarderContacts() async {
    await ServiceStorage.saveContacts(_contactsPersonnels);
  }

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();

  Future<void> _passerAppel(String numero) async {
    final Uri uri = Uri(scheme: 'tel', path: numero);
    if (await launchUrl(uri)) {
      // Succès
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Impossible de lancer l'appel vers $numero"),
            backgroundColor: ThemeSafeRoute.rougeDanger,
          ),
        );
      }
    }
  }

  void _ajouterContactPersonnel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter un contact d'urgence"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: "Nom du contact",
                hintText: "Ex: Mère, Frère, Conjoint",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _numeroController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Numéro de téléphone",
                hintText: "Ex: +261 34 XX XXX XX",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nomController.clear();
              _numeroController.clear();
              Navigator.pop(context);
            },
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nomController.text.isNotEmpty && _numeroController.text.isNotEmpty) {
                setState(() {
                  _contactsPersonnels.add({
                    "nom": _nomController.text,
                    "numero": _numeroController.text,
                  });
                });
                _sauvegarderContacts();
                _nomController.clear();
                _numeroController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Contact d'urgence ajouté avec succès"),
                    backgroundColor: ThemeSafeRoute.vertSecurite,
                  ),
                );
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("URGENCES & SOS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _ajouterContactPersonnel,
            tooltip: "Ajouter un contact personnel",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: estSombre
                      ? [ThemeSafeRoute.rougeDanger.withValues(alpha: 0.15), Colors.transparent]
                      : [ThemeSafeRoute.rougeDanger.withValues(alpha: 0.08), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ThemeSafeRoute.rougeDanger.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: ThemeSafeRoute.rougeDanger, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lignes d'assistance directe",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeSafeRoute.rougeDanger,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "En cas de danger immédiat, contactez directement les autorités locales de Madagascar.",
                          style: TextStyle(fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Madagascar numbers title
            const Text(
              "AUTORITÉS DE MADAGASCAR",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: ThemeSafeRoute.texteSecondaire,
              ),
            ),
            const SizedBox(height: 12),

            // Madagascar list
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _contactsMada.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _contactsMada[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.couleur.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icone, color: item.couleur, size: 24),
                    ),
                    title: Text(
                      item.nom,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        item.description,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _passerAppel(item.numero),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.couleur,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.call, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            item.numero,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Personal numbers title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "CONTACTS DE CONFIANCE PERSONNELS",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: ThemeSafeRoute.texteSecondaire,
                  ),
                ),
                TextButton.icon(
                  onPressed: _ajouterContactPersonnel,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Ajouter", style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Personal contacts list
            if (_contactsPersonnels.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text(
                  "Aucun contact personnel configuré.",
                  style: TextStyle(color: ThemeSafeRoute.texteSecondaire),
                ),
              )
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _contactsPersonnels.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final contact = _contactsPersonnels[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: estSombre ? Colors.white10 : Colors.black.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: estSombre ? Colors.white : Colors.black87,
                        ),
                      ),
                      title: Text(
                        contact["nom"] ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(contact["numero"] ?? ""),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.call, color: ThemeSafeRoute.bleuPrimaire),
                            onPressed: () => _passerAppel(contact["numero"] ?? ""),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: ThemeSafeRoute.rougeDanger),
                            onPressed: () {
                              setState(() {
                                _contactsPersonnels.removeAt(index);
                              });
                              _sauvegarderContacts();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
