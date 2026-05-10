import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mantar/providers/mushroom_provider.dart';
import 'package:mantar/screens/home_page.dart';
import 'package:mantar/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MushroomProvider())],
      child: const MantarUygulamasi(),
    ),
  );
}

class MantarUygulamasi extends StatelessWidget {
  const MantarUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Asıl Ayarlar (MaterialApp) BURADA olur.
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // <-- BANNER'I KALDIRAN KOD BURADA OLMALI
      title: 'Mantar Rehberi',

      theme: AppTheme.lightTheme,

      // Açılış Sayfası
      home: const HomePage(),
    );
  }
}
