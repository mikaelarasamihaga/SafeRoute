import 'package:flutter/material.dart';
import 'package:saferoute/theme.dart';

class BarreRecherche extends StatelessWidget {
  final TextEditingController controller;
  final List<Map<String, dynamic>> suggestions;
  final bool enRecherche;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<Map<String, dynamic>> onSuggestionSelected;

  const BarreRecherche({
    super.key,
    required this.controller,
    required this.suggestions,
    required this.enRecherche,
    required this.onChanged,
    required this.onClear,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Column(
        children: [
          // Barre de recherche principale
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: ThemeSafeRoute.couleurSurface.withValues(alpha: 0.97),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: ThemeSafeRoute.textePrimaire,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Où voulez-vous aller ?',
                hintStyle: TextStyle(
                  color: ThemeSafeRoute.texteSecondaire.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                // Mini logo SafeRoute comme prefix
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ThemeSafeRoute.bleuPrimaire.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeSafeRoute.bleuPrimaire.withValues(alpha: 0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: ThemeSafeRoute.texteSecondaire,
                          size: 20,
                        ),
                        onPressed: onClear,
                      ),
                    if (enRecherche)
                      const Padding(
                        padding: EdgeInsets.only(right: 12.0),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ThemeSafeRoute.bleuPrimaire,
                            ),
                          ),
                        ),
                      )
                    else if (controller.text.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          Icons.search_rounded,
                          color: ThemeSafeRoute.bleuPrimaire,
                          size: 22,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Liste des suggestions
          if (suggestions.isNotEmpty)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: ThemeSafeRoute.couleurSurface.withValues(alpha: 0.97),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: suggestions.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.white.withValues(alpha: 0.06),
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  final s = suggestions[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ThemeSafeRoute.bleuPrimaire.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: ThemeSafeRoute.bleuPrimaire,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      s['display_name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ThemeSafeRoute.textePrimaire,
                      ),
                    ),
                    onTap: () => onSuggestionSelected(s),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
