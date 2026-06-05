import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saferoute/providers/fournisseur_itineraire.dart';
import 'package:saferoute/theme.dart';

class BoutonsAction extends StatelessWidget {
  final VoidCallback onSOS;
  final VoidCallback onSignaler;

  const BoutonsAction({
    super.key,
    required this.onSOS,
    required this.onSignaler,
  });

  @override
  Widget build(BuildContext context) {
    final fournisseur = Provider.of<FournisseurItineraire>(context);
    if (fournisseur.itineraireActuel.isNotEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 30,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // ── Bouton SOS (même taille que Signaler grâce à Expanded) ──
          Expanded(
            child: BoutonSOSPulsant(onTap: onSOS),
          ),

          const SizedBox(width: 12),

          // ── Bouton Signaler (même taille que SOS grâce à Expanded) ──
          Expanded(
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00B0FF),
                    ThemeSafeRoute.vertSecurite,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeSafeRoute.vertSecurite.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: const Color(0xFF00B0FF).withValues(alpha: 0.15),
                    blurRadius: 24,
                    spreadRadius: -4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSignaler,
                  borderRadius: BorderRadius.circular(18),
                  splashColor: Colors.white24,
                  highlightColor: Colors.white10,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_location_alt_rounded,
                        color: Colors.white,
                        size: 22,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Signaler',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget local pour le Bouton SOS avec pulsation
class BoutonSOSPulsant extends StatefulWidget {
  final VoidCallback onTap;

  const BoutonSOSPulsant({super.key, required this.onTap});

  @override
  State<BoutonSOSPulsant> createState() => _BoutonSOSPulsantState();
}

class _BoutonSOSPulsantState extends State<BoutonSOSPulsant> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulsation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulsation = Tween<double>(begin: 1.0, end: 1.06).animate(
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
      animation: _pulsation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulsation.value,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [
                  ThemeSafeRoute.rougeDanger,
                  Color(0xFFFF5252),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeSafeRoute.rougeDanger.withValues(alpha: 0.45 * (2.0 - _pulsation.value)),
                  blurRadius: 16,
                  spreadRadius: 2.0 * (_pulsation.value - 1.0),
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(18),
                splashColor: Colors.white24,
                highlightColor: Colors.white10,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emergency_rounded,
                      color: Colors.white,
                      size: 22,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    SizedBox(width: 8),
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
