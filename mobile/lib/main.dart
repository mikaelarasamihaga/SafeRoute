import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saferoute/screens/ecran_splash.dart';
import 'package:saferoute/theme.dart';
import 'package:saferoute/providers/fournisseur_itineraire.dart';
import 'package:saferoute/providers/fournisseur_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FournisseurItineraire()),
        ChangeNotifierProvider(create: (_) => FournisseurTheme()),
      ],
      child: const SafeRouteApp(),
    ),
  );
}

class SafeRouteApp extends StatelessWidget {
  const SafeRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<FournisseurTheme>(context);
    
    return MaterialApp(
      title: 'SafeRoute',
      debugShowCheckedModeBanner: false,
      theme: ThemeSafeRoute.themeClair,
      darkTheme: ThemeSafeRoute.themeSombre,
      themeMode: themeProvider.themeMode,
      home: const EcranSplash(),
    );
  }
}
