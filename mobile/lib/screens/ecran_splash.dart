import 'package:flutter/material.dart';
import 'package:saferoute/screens/ecran_accueil.dart';
import 'package:saferoute/theme.dart';

class EcranSplash extends StatefulWidget {
  const EcranSplash({super.key});

  @override
  State<EcranSplash> createState() => _EcranSplashState();
}

class _EcranSplashState extends State<EcranSplash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Rediriger vers l'écran d'accueil après 2.8 secondes
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const EcranAccueil(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeSafeRoute.fondSombre,
      body: Stack(
        children: [
          // Effet de halo néon en arrière-plan
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeSafeRoute.bleuPrimaire.withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: ThemeSafeRoute.bleuPrimaire.withOpacity(0.05),
                    blurRadius: 100,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),

          // Contenu principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo avec animation d'apparition et de zoom
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: ThemeSafeRoute.bleuPrimaire.withOpacity(0.15),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(70),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 35),

                // Textes avec animation retardée
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textOpacityAnimation.value,
                      child: Column(
                        children: [
                          // Nom de l'app
                          Text(
                            'SafeRoute',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 34,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: ThemeSafeRoute.bleuPrimaire.withOpacity(0.5),
                                      blurRadius: 15,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                          ),
                          const SizedBox(height: 10),

                          // Slogan lumineux
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: ThemeSafeRoute.bleuPrimaire.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: ThemeSafeRoute.bleuPrimaire.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'NAVIGUEZ EN TOUTE SÉCURITÉ',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: ThemeSafeRoute.bleuPrimaire,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Signature en bas de l'écran
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(ThemeSafeRoute.bleuPrimaire),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'APPLICATION DE SÉCURITÉ',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontSize: 9,
                                color: ThemeSafeRoute.texteSecondaire.withOpacity(0.6),
                                letterSpacing: 1.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
